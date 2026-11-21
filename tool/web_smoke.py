#!/usr/bin/env python3
"""Browser smoke test for the built web app.

`flutter analyze`, `flutter test` and even a successful `flutter build web`
can all pass while the deployed app still dies in the browser (a dart2js-only
crash, a bootstrap that never calls main, a missing asset). This loads the
real release build in headless Chromium and checks that the app reaches its
first frame without an uncaught error.

It then walks the passphrase-locked progress copy end to end (the browser's
own Web Crypto path, which `flutter test` can't reach — its Chrome runner
hung on CI): lock with a passphrase, type, check the saved copy decrypts
with an independent Web Crypto implementation of the documented format and
holds nothing readable, reload, refuse a wrong passphrase, unlock with the
right one and get the typed text back.

Usage (from the repo root, after `flutter build web --base-href "/MHAD/"`):

    python3 tool/web_smoke.py build/web

It serves build/web under /MHAD/ on a local port, so the --base-href used in
CI resolves exactly as it does on GitHub Pages. Needs `pip install playwright`
and `python3 -m playwright install --with-deps chromium`.
"""

from __future__ import annotations

import functools
import http.server
import json
import pathlib
import re
import sys
import threading
from urllib.parse import urlparse

from playwright.sync_api import TimeoutError as PlaywrightTimeout
from playwright.sync_api import sync_playwright

# Same folder: Flutter semantics helpers shared with the nothing-removed tool.
from ui_inventory import click_named, enable_semantics, pass_gates

BASE = "/MHAD/"

# The locked-progress walk (see the module docstring).
PASSPHRASE = "Blue horse tea!"
WRONG_PASSPHRASE = "blue horse tea!"
PROBE_TEXT = "Ana Prueba"
LOCK_ITERATIONS = 600_000  # kLockIterations (lib/services/locked_progress)

# Opens the saved copy WITHOUT the app's code, from the format alone
# (lib/services/locked_progress/locked_format.dart): PBKDF2-SHA-256 over the
# passphrase's UTF-8 with the header's salt and rounds -> AES-256-GCM with the
# header's nonce and the header JSON (everything but "data", same key order)
# as additional data -> gunzip -> JSON text. Returns the text, or "ERR …".
DECRYPT_COPY_JS = """async (pass) => {
  try {
    const raw = localStorage.getItem('mhad_locked_copy');
    if (!raw) return 'ERR no copy';
    const {data, ...header} = JSON.parse(raw);
    const bytes = (s) => Uint8Array.from(atob(s), (c) => c.charCodeAt(0));
    const enc = new TextEncoder();
    const base = await crypto.subtle.importKey(
        'raw', enc.encode(pass), 'PBKDF2', false, ['deriveKey']);
    const key = await crypto.subtle.deriveKey(
        {name: 'PBKDF2', hash: 'SHA-256', salt: bytes(header.kdf.salt),
         iterations: header.kdf.iterations},
        base, {name: 'AES-GCM', length: 256}, false, ['decrypt']);
    const plain = await crypto.subtle.decrypt(
        {name: 'AES-GCM', iv: bytes(header.cipher.nonce),
         additionalData: enc.encode(JSON.stringify(header)), tagLength: 128},
        key, bytes(data));
    const unzipped = new Blob([plain]).stream()
        .pipeThrough(new DecompressionStream('gzip'));
    return await new Response(unzipped).text();
  } catch (e) {
    return 'ERR ' + e;
  }
}"""

# Outside hosts the app may contact just by loading (no user action). The
# privacy policy names each one ("No third-party tracking" section); a new
# host here means the policy must name it too, so the check fails until both
# change together. Lookups the person starts (NIH/NLM, FDA, ZIP) don't run on
# load and aren't listed.
LOAD_HOSTS = {
    "www.gstatic.com",  # Flutter's display engine (CanvasKit)
    "fonts.gstatic.com",  # fallback fonts
}
FIRST_FRAME_TIMEOUT_MS = 90_000


class _Handler(http.server.SimpleHTTPRequestHandler):
    """Serves `root` at /MHAD/ (like GitHub Pages) and nothing else."""

    def translate_path(self, path: str) -> str:
        path = path.split("?", 1)[0].split("#", 1)[0]
        if not path.startswith(BASE):
            return str(pathlib.Path(self.directory) / "__not_found__")
        return super().translate_path("/" + path[len(BASE):])

    def log_message(self, *args) -> None:  # keep CI logs readable
        pass


def _screen_text(page) -> str:
    return " | ".join(page.evaluate(
        "() => [...document.querySelectorAll('flt-semantics')].map(e => "
        "(e.getAttribute('aria-label') || e.textContent || '').trim())"
        ".filter(t => t)"))


def _boot(page, url: str) -> None:
    page.goto(url, wait_until="load")
    page.wait_for_function("() => !document.getElementById('boot-splash')",
                           timeout=FIRST_FRAME_TIMEOUT_MS)
    page.wait_for_timeout(2500)
    enable_semantics(page)
    pass_gates(page)
    page.wait_for_timeout(1500)
    enable_semantics(page)


def _type_into(page, label: str, value: str) -> bool:
    box = page.get_by_role("textbox", name=re.compile(label))
    if not box.count():
        return False
    box.first.click()
    page.wait_for_timeout(300)
    page.keyboard.press("Control+A")
    page.keyboard.type(value, delay=20)
    page.wait_for_timeout(400)
    return True


def _hide_and_show(page) -> None:
    """The tab going to the background: the app saves the open step quietly."""
    for state in ("hidden", "visible"):
        page.evaluate(
            "(s) => { Object.defineProperty(document, 'visibilityState', "
            "{configurable: true, get: () => s}); "
            "document.dispatchEvent(new Event('visibilitychange')); }", state)
        page.wait_for_timeout(3000 if state == "hidden" else 500)


def locked_progress_walk(browser, url: str) -> list[str]:
    """Returns what went wrong (empty = pass); prints each step."""
    problems: list[str] = []

    def step(ok: bool, what: str) -> bool:
        print(("ok:   " if ok else "FAIL: ") + what)
        if not ok:
            problems.append(what)
        return ok

    context = browser.new_context(viewport={"width": 1280, "height": 900})
    page = context.new_page()
    errors: list[str] = []
    page.on("pageerror", lambda e: errors.append(str(e)))
    try:
        _boot(page, url)
        if not step(click_named(page, "button", "Start now"),
                    "Home offers Start now"):
            return problems
        page.wait_for_timeout(1500)
        enable_semantics(page)
        if not step(click_named(page, "button",
                                "Yes, lock it with a passphrase"),
                    "start choice offers a locked copy"):
            return problems
        page.wait_for_timeout(1500)
        enable_semantics(page)
        if not step(_type_into(page, "^Passphrase", PASSPHRASE)
                    and _type_into(page, "Type it again", PASSPHRASE),
                    "passphrase form takes the passphrase twice"):
            return problems
        click_named(page, "button", "Lock my progress")
        page.wait_for_timeout(3500)
        enable_semantics(page)
        if not step("#/wizard/" in page.url, "locking opens the wizard"):
            return problems

        boxes = page.get_by_role("textbox")
        if not step(boxes.count() > 0, "the first step has a text field"):
            return problems
        boxes.first.click()
        page.keyboard.type(PROBE_TEXT, delay=20)
        page.wait_for_timeout(2500)  # past the 2 s save debounce
        _hide_and_show(page)

        raw = page.evaluate("() => localStorage.getItem('mhad_locked_copy')")
        if not step(raw is not None, "a locked copy is saved in the browser"):
            return problems
        header = json.loads(raw)
        step(header.get("format") == "pa-mhad-locked"
             and header.get("kind") == "copy", "the copy is a locked-format copy")
        step(header.get("kdf", {}).get("iterations") == LOCK_ITERATIONS,
             f"the key takes {LOCK_ITERATIONS:,} PBKDF2 rounds")
        step(PROBE_TEXT not in raw and "Prueba" not in raw,
             "nothing typed is readable in the saved copy")
        plain = page.evaluate(DECRYPT_COPY_JS, PASSPHRASE)
        step(PROBE_TEXT in plain,
             "an independent Web Crypto decrypt of the copy finds the typed "
             f"text ({plain[:80] if plain.startswith('ERR') else 'ok'})")
        step(page.evaluate(DECRYPT_COPY_JS, WRONG_PASSPHRASE).startswith("ERR"),
             "the copy does not open with a wrong passphrase")

        page.reload(wait_until="load")
        page.wait_for_function("() => !document.getElementById('boot-splash')",
                               timeout=FIRST_FRAME_TIMEOUT_MS)
        page.wait_for_timeout(3500)
        enable_semantics(page)
        pass_gates(page)
        page.wait_for_timeout(2500)
        enable_semantics(page)
        if not step("Welcome back" in _screen_text(page),
                    "after a reload the app asks for the passphrase"):
            return problems
        _type_into(page, "^Passphrase", WRONG_PASSPHRASE)
        click_named(page, "button", "Unlock")
        page.wait_for_timeout(2500)
        enable_semantics(page)
        step("9 more wrong tries" in _screen_text(page),
             "the app refuses a wrong passphrase and counts the try")
        _type_into(page, "^Passphrase", PASSPHRASE)
        click_named(page, "button", "Unlock")
        page.wait_for_timeout(4000)
        enable_semantics(page)
        step("#/wizard/" in page.url, "the right passphrase reopens the wizard")
        values = page.evaluate(
            "() => [...document.querySelectorAll('input,textarea')]"
            ".map(e => e.value)")
        step(any(PROBE_TEXT in v for v in values),
             "the typed text came back after unlocking")
        step(not errors, "no page errors during the walk"
             + (f" ({errors[0][:120]})" if errors else ""))
    except PlaywrightTimeout as e:
        step(False, f"timed out: {str(e)[:160]}")
    finally:
        context.close()
    return problems


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__)
        return 2
    root = pathlib.Path(sys.argv[1]).resolve()
    if not (root / "index.html").is_file():
        print(f"FAIL: {root}/index.html not found; build the web app first")
        return 2

    handler = functools.partial(_Handler, directory=str(root))
    server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    url = f"http://127.0.0.1:{server.server_address[1]}{BASE}"

    page_errors: list[str] = []
    failed_requests: list[str] = []
    outside_hosts: set[str] = set()
    console_errors: list[str] = []
    first_frame = False
    has_view = False
    walk_problems: list[str] = []
    try:
        with sync_playwright() as p:
            browser = p.chromium.launch()
            page = browser.new_page(viewport={"width": 1280, "height": 900})
            page.on("pageerror", lambda e: page_errors.append(str(e)))
            page.on(
                "console",
                lambda m: console_errors.append(m.text)
                if m.type == "error"
                else None,
            )
            page.on(
                "requestfailed",
                lambda r: failed_requests.append(r.url)
                if r.url.startswith(url)
                else None,
            )
            # Same-origin 404s (a missing asset) are failures too.
            page.on(
                "response",
                lambda r: failed_requests.append(f"{r.status} {r.url}")
                if r.url.startswith(url) and r.status >= 400
                else None,
            )

            page.on(
                "request",
                lambda r: outside_hosts.add(urlparse(r.url).hostname or "")
                if not r.url.startswith(url)
                and urlparse(r.url).scheme in ("http", "https")
                else None,
            )

            page.goto(url, wait_until="load")
            try:
                # index.html removes #boot-splash on Flutter's first frame.
                page.wait_for_function(
                    "() => !document.getElementById('boot-splash')",
                    timeout=FIRST_FRAME_TIMEOUT_MS,
                )
                first_frame = True
            except PlaywrightTimeout:
                pass
            has_view = page.evaluate(
                "() => !!document.querySelector('flutter-view')"
            )
            page.close()
            if first_frame and has_view:
                print("locked progress walk:")
                walk_problems = locked_progress_walk(browser, url)
            browser.close()
    finally:
        server.shutdown()

    unlisted = sorted(outside_hosts - LOAD_HOSTS)
    ok = (first_frame and has_view and not page_errors and not failed_requests
          and not unlisted and not walk_problems)
    print(f"first frame reached: {first_frame}; flutter-view present: {has_view}")
    for e in page_errors:
        print(f"page error: {e}")
    for r in failed_requests:
        print(f"failed request: {r}")
    for h in unlisted:
        print(f"outside host not named in the privacy policy: {h} "
              "(add it there and to LOAD_HOSTS, or stop contacting it)")
    for c in console_errors:  # informational; not a failure on its own
        print(f"console error (not fatal): {c}")
    print("PASS" if ok else "FAIL")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
