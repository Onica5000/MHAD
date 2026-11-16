#!/usr/bin/env python3
"""Generate MHAD illustrations with Grok Imagine (image_gen), one at a time.

Reads tool/art/art_manifest.json (the single definition of every image).
Safe to run twice: an image whose output already exists is skipped unless --force.

For each image:
  1. make an EMPTY work dir (Grok's config is always-approve, so it never runs
     inside the repo) and run `grok -p ... --output-format json` there;
  2. verify it really came from the AI model: the Grok session's updates.jsonl
     must contain an image_gen call AND the saved file's sha256 must match an
     image in that session's images/ folder (code-drawn output fails this);
  3. keep the original JPEG in tool/art/originals/<group>/ (git-ignored) and
     write an optimized WebP to assets/images/<group>/ within the size budget;
  4. append one line to tool/art/generation_log.jsonl BEFORE starting the next
     image (save-as-you-go: a crash or quota stop loses nothing done so far).
Stops at the first `402 Payment Required` in ~/.grok/logs/unified.jsonl.

Usage:
  python tool/art/generate_art.py --set board            # 8-image style board + contact sheet
  python tool/art/generate_art.py --set main --style A   # the full app set in style A
  python tool/art/generate_art.py --only home_hero,form_poa --force
  python tool/art/generate_art.py --set main --dry-run   # print prompts only
"""
from __future__ import annotations

import argparse
import datetime as dt
import glob
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
import urllib.parse

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ART = os.path.join(ROOT, "tool", "art")
MANIFEST = os.path.join(ART, "art_manifest.json")
LOG = os.path.join(ART, "generation_log.jsonl")
ORIGINALS = os.path.join(ART, "originals")
ASSETS = os.path.join(ROOT, "assets", "images")
GROK = os.path.expanduser(os.path.join("~", ".grok", "bin", "grok.exe"))
GROK_SESSIONS = os.path.expanduser(os.path.join("~", ".grok", "sessions"))
GROK_LOG = os.path.expanduser(os.path.join("~", ".grok", "logs", "unified.jsonl"))
QUALITIES = (80, 72, 64, 56, 48)


def now() -> str:
    return dt.datetime.now().isoformat(timespec="seconds")


def log(entry: dict) -> None:
    entry = {"ts": now(), **entry}
    with open(LOG, "a", encoding="utf-8") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")
    print(json.dumps(entry, ensure_ascii=False), flush=True)


def sha256(path: str) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 16), b""):
            h.update(chunk)
    return h.hexdigest()


def build_prompt(m: dict, img: dict, style_key: str) -> str:
    style = m["styles"][style_key].format(palette=m["palette"])
    image_prompt = f"{style}. Subject: {img['subject']}. {m['rules']}"
    return (
        f'Call your image_gen tool exactly once, with aspect_ratio "{img["aspect"]}" '
        f"and exactly this prompt:\n\"{image_prompt}\"\n"
        "Do NOT draw, render or edit the image with code, ImageMagick, Python, SVG, "
        "HTML or ffmpeg; it must come from image_gen. Then copy the file image_gen "
        f"returned, unmodified, into the current working directory as {img['id']}.jpg "
        "and reply with only the saved path."
    )


def grok_log_size() -> int:
    return os.path.getsize(GROK_LOG) if os.path.exists(GROK_LOG) else 0


def quota_exhausted(since: int) -> bool:
    if not os.path.exists(GROK_LOG):
        return False
    with open(GROK_LOG, "rb") as f:
        f.seek(since)
        tail = f.read().decode("utf-8", "replace")
    return "402 Payment Required" in tail or "usage balance exhausted" in tail


def find_session(work: str, started: float) -> str | None:
    want = os.path.normcase(os.path.abspath(work))
    best, best_t = None, 0.0
    for d in glob.glob(os.path.join(GROK_SESSIONS, "*")):
        name = os.path.normcase(urllib.parse.unquote(os.path.basename(d)))
        if name != want:
            continue
        for s in glob.glob(os.path.join(d, "*")):
            t = os.path.getmtime(s)
            if os.path.isdir(s) and t >= started - 5 and t > best_t:
                best, best_t = s, t
    return best


def to_webp(src: str, dst: str, width: int, max_kb: int) -> tuple[int, int]:
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    size = 0
    for q in QUALITIES:
        subprocess.run(
            ["magick", src, "-resize", f"{width}x>", "-strip", "-quality", str(q), dst],
            check=True, capture_output=True,
        )
        size = os.path.getsize(dst)
        if size <= max_kb * 1024:
            return q, size
    return QUALITIES[-1], size


def generate(m: dict, img: dict, style_key: str, work_root: str, force: bool) -> str:
    group, iid, aspect = img["group"], img["id"], img["aspect"]
    orig = os.path.join(ORIGINALS, group, f"{iid}.jpg")
    is_board = img.get("set") == "board"
    out = orig if is_board else os.path.join(ASSETS, group, f"{iid}.webp")
    if os.path.exists(out) and not force:
        print(f"skip {iid} (exists)", flush=True)
        return "skipped"

    work = os.path.join(work_root, f"{iid}-{int(time.time())}")
    os.makedirs(work, exist_ok=False)
    prompt = build_prompt(m, img, style_key)
    log_mark = grok_log_size()
    started = time.time()
    try:
        proc = subprocess.run(
            [GROK, "--cwd", work, "--always-approve", "-p", prompt, "--output-format", "json"],
            capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=900,
        )
        stdout = proc.stdout or ""
    except subprocess.TimeoutExpired:
        log({"id": iid, "status": "timeout", "style": style_key})
        return "failed"

    if quota_exhausted(log_mark):
        log({"id": iid, "status": "quota_402", "style": style_key})
        return "quota"

    session = find_session(work, started)
    produced = sorted(glob.glob(os.path.join(work, "*.jpg")) + glob.glob(os.path.join(work, "*.jpeg"))
                      + glob.glob(os.path.join(work, "*.png")), key=os.path.getmtime)
    session_imgs = glob.glob(os.path.join(session, "images", "*")) if session else []
    updates = os.path.join(session, "updates.jsonl") if session else ""
    used_image_gen = bool(updates) and os.path.exists(updates) and '"image_gen"' in open(
        updates, encoding="utf-8", errors="replace").read()

    src = produced[-1] if produced else None
    session_hashes = {sha256(p): p for p in session_imgs}
    verified = bool(src) and used_image_gen and sha256(src) in session_hashes
    if not src and used_image_gen and session_imgs:
        # Grok generated but forgot to copy: take the session's own image (still image_gen-made).
        src = max(session_imgs, key=os.path.getmtime)
        verified = True
    if not verified:
        log({"id": iid, "status": "unverified", "style": style_key,
             "session": os.path.basename(session or ""), "image_gen_call": used_image_gen,
             "files": [os.path.basename(p) for p in produced], "stdout": stdout[-400:]})
        return "failed"

    os.makedirs(os.path.dirname(orig), exist_ok=True)
    shutil.copyfile(src, orig)
    entry = {"id": iid, "status": "ok", "style": style_key, "aspect": aspect,
             "session": os.path.basename(session), "sha256": sha256(orig),
             "original_bytes": os.path.getsize(orig)}
    if not is_board:
        q, size = to_webp(orig, out, m["widths"][aspect], m["max_kb"][aspect])
        entry.update({"webp": os.path.relpath(out, ROOT).replace(os.sep, "/"),
                      "webp_quality": q, "webp_kb": round(size / 1024, 1),
                      "over_budget": size > m["max_kb"][aspect] * 1024})
    log(entry)
    return "ok"


def contact_sheet() -> None:
    board = os.path.join(ORIGINALS, "board")
    tiles = []
    for k in "abcd":
        for kind in ("scene", "object"):
            p = os.path.join(board, f"board_{k}_{kind}.jpg")
            if os.path.exists(p):
                tiles.append(p)
    if not tiles:
        return
    out = os.path.join(board, "style_board.jpg")
    subprocess.run(["magick", "montage", *tiles, "-tile", "2x", "-geometry", "640x427+12+12",
                    "-background", "#FAF6EE", "-title", "MHAD style board: rows A-D (scene, object)",
                    "-pointsize", "28", out], check=True, capture_output=True)
    print(f"contact sheet: {out}", flush=True)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--set", choices=["board", "main"], help="which images to generate")
    ap.add_argument("--only", help="comma-separated ids")
    ap.add_argument("--style", help="style key override for --set main (default: manifest default_style)")
    ap.add_argument("--force", action="store_true", help="regenerate even if output exists")
    ap.add_argument("--dry-run", action="store_true", help="print prompts, generate nothing")
    ap.add_argument("--work", default=os.path.join(tempfile.gettempdir(), "mhad-grok-art"),
                    help="root for empty per-image work dirs (outside the repo)")
    a = ap.parse_args()

    m = json.load(open(MANIFEST, encoding="utf-8"))
    imgs = m["images"]
    if a.only:
        ids = {s.strip() for s in a.only.split(",") if s.strip()}
        imgs = [i for i in imgs if i["id"] in ids]
    elif a.set == "board":
        imgs = [i for i in imgs if i.get("set") == "board"]
    elif a.set == "main":
        imgs = [i for i in imgs if i.get("set") != "board"]
    else:
        ap.error("pass --set or --only")

    os.makedirs(a.work, exist_ok=True)
    counts: dict[str, int] = {}
    for img in imgs:
        style_key = img.get("style") or a.style or m["default_style"]
        if a.dry_run:
            print(f"--- {img['id']} [{img['aspect']}] style {style_key}\n{build_prompt(m, img, style_key)}\n")
            continue
        result = generate(m, img, style_key, a.work, a.force)
        counts[result] = counts.get(result, 0) + 1
        if result == "quota":
            print("Grok quota exhausted (402); stopping. Re-run later: finished images are kept.", flush=True)
            break
    if a.set == "board" and not a.dry_run:
        contact_sheet()
    print(f"done: {counts}", flush=True)
    return 0 if not counts.get("failed") and not counts.get("quota") else 1


if __name__ == "__main__":
    sys.exit(main())
