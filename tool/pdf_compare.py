#!/usr/bin/env python3
"""Rasterize + diff the MHAD PDF artifacts (PyMuPDF).

Workflow (from the repo root):
  1. flutter test test/render_pdf_tool_test.dart       # writes build/_pdfcmp/*.pdf
  2. python tool/pdf_compare.py baseline               # snapshot -> build/_pdfcmp/baseline/
  3. ...refactor...
  4. flutter test test/render_pdf_tool_test.dart
  5. python tool/pdf_compare.py diff                   # compare vs baseline

`diff` reports a per-page mismatch percentage and writes side-by-side diff
images (baseline | current | changed-pixels) for any page over the threshold
to build/_pdfcmp/diffs/. Exit code 1 when any page exceeds the threshold, so
it can gate a refactor.

  python tool/pdf_compare.py rasterize <pdf> <outdir>  # one-off page PNGs
"""

import sys
import shutil
from pathlib import Path

import fitz  # PyMuPDF

ROOT = Path(__file__).resolve().parent.parent
CMP = ROOT / "build" / "_pdfcmp"
BASELINE = CMP / "baseline"
DIFFS = CMP / "diffs"
DPI = 120
THRESHOLD_PCT = 0.05  # % of pixels allowed to differ before a page "fails"

ARTIFACTS = [
    "filled_combined", "filled_declaration", "filled_poa",
    "blank_combined", "blank_declaration", "blank_poa",
]


def rasterize(pdf_path: Path, out_dir: Path) -> list[Path]:
    out_dir.mkdir(parents=True, exist_ok=True)
    pages = []
    with fitz.open(pdf_path) as doc:
        for i, page in enumerate(doc):
            pix = page.get_pixmap(dpi=DPI, colorspace=fitz.csGRAY)
            out = out_dir / f"{pdf_path.stem}_p{i + 1:02d}.png"
            pix.save(out)
            pages.append(out)
    return pages


def cmd_baseline() -> int:
    if BASELINE.exists():
        shutil.rmtree(BASELINE)
    total = 0
    for name in ARTIFACTS:
        pdf = CMP / f"{name}.pdf"
        if not pdf.exists():
            print(f"MISSING {pdf} - run the render test first")
            return 1
        total += len(rasterize(pdf, BASELINE))
    print(f"Baseline captured: {total} pages -> {BASELINE}")
    return 0


def _page_pixels(png: Path):
    pix = fitz.Pixmap(str(png))
    return pix.width, pix.height, bytes(pix.samples)


def cmd_diff() -> int:
    if not BASELINE.exists():
        print("No baseline - run `python tool/pdf_compare.py baseline` first")
        return 1
    if DIFFS.exists():
        shutil.rmtree(DIFFS)
    DIFFS.mkdir(parents=True)
    current = CMP / "current"
    if current.exists():
        shutil.rmtree(current)

    failures = 0
    for name in ARTIFACTS:
        pdf = CMP / f"{name}.pdf"
        if not pdf.exists():
            print(f"MISSING {pdf}")
            failures += 1
            continue
        cur_pages = rasterize(pdf, current)
        base_pages = sorted(BASELINE.glob(f"{name}_p*.png"))
        cur_pages = sorted(current.glob(f"{name}_p*.png"))
        if len(base_pages) != len(cur_pages):
            print(f"{name}: PAGE COUNT changed "
                  f"{len(base_pages)} -> {len(cur_pages)}")
            failures += 1
        for b, c in zip(base_pages, cur_pages):
            bw, bh, bs = _page_pixels(b)
            cw, ch, cs = _page_pixels(c)
            if (bw, bh) != (cw, ch):
                print(f"{b.name}: size changed {bw}x{bh} -> {cw}x{ch}")
                failures += 1
                continue
            diff_count = sum(1 for x, y in zip(bs, cs) if x != y)
            pct = 100.0 * diff_count / len(bs)
            status = "OK " if pct <= THRESHOLD_PCT else "DIFF"
            print(f"{status} {b.name}: {pct:.3f}% pixels differ")
            if pct > THRESHOLD_PCT:
                failures += 1
                _write_diff_image(b, c, bw, bh, bs, cs)
    if failures:
        print(f"\n{failures} page(s)/artifact(s) differ -> see {DIFFS}")
        return 1
    print("\nAll pages match the baseline.")
    return 0


def _write_diff_image(base_png: Path, cur_png: Path, w: int, h: int,
                      bs: bytes, cs: bytes) -> None:
    """Side-by-side: baseline | current | changed pixels highlighted."""
    gap = 8
    out = fitz.Pixmap(fitz.csGRAY, fitz.IRect(0, 0, w * 3 + gap * 2, h), 0)
    # fitz.Pixmap has no blit; build the composite via raw samples.
    row = bytearray()
    composite = bytearray()
    for y in range(h):
        brow = bs[y * w:(y + 1) * w]
        crow = cs[y * w:(y + 1) * w]
        drow = bytes(0 if x != y2 else 255 for x, y2 in zip(brow, crow))
        row = brow + b"\xff" * gap + crow + b"\xff" * gap + drow
        composite.extend(row)
    out = fitz.Pixmap(fitz.csGRAY, fitz.IRect(0, 0, w * 3 + gap * 2, h),
                      bytes(composite))
    out.save(DIFFS / f"diff_{base_png.name}")


def cmd_rasterize(pdf: str, outdir: str) -> int:
    pages = rasterize(Path(pdf), Path(outdir))
    print(f"Rasterized {len(pages)} pages -> {outdir}")
    return 0


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    cmd = sys.argv[1]
    if cmd == "baseline":
        return cmd_baseline()
    if cmd == "diff":
        return cmd_diff()
    if cmd == "rasterize" and len(sys.argv) == 4:
        return cmd_rasterize(sys.argv[2], sys.argv[3])
    print(__doc__)
    return 2


if __name__ == "__main__":
    sys.exit(main())
