#!/usr/bin/env python3
"""Browser smoke test for the built web app.

`flutter analyze`, `flutter test` and even a successful `flutter build web`
can all pass while the deployed app still dies in the browser (a dart2js-only
crash, a bootstrap that never calls main, a missing asset). This loads the
real release build in headless Chromium and checks that the app reaches its
first frame without an uncaught error.

Usage (from the repo root, after `flutter build web --base-href "/MHAD/"`):

    python3 tool/web_smoke.py build/web

It serves build/web under /MHAD/ on a local port, so the --base-href used in
CI resolves exactly as it does on GitHub Pages. Needs `pip install playwright`
and `python3 -m playwright install --with-deps chromium`.
"""

from __future__ import annotations

import functools
import http.server
import pathlib
import sys
import threading
from urllib.parse import urlparse

from playwright.sync_api import TimeoutError as PlaywrightTimeout
from playwright.sync_api import sync_playwright

BASE = "/MHAD/"

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
            browser.close()
    finally:
        server.shutdown()

    unlisted = sorted(outside_hosts - LOAD_HOSTS)
    ok = (first_frame and has_view and not page_errors and not failed_requests
          and not unlisted)
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
