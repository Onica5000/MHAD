#!/usr/bin/env python3
"""Inventory every interactive control on every route, to prove a redesign
removed nothing.

Loads the app (the live site or a local release build) in headless Chromium,
turns on Flutter's accessibility tree, walks the disclaimer + intro gates,
creates a directive ("Start now"), then visits each route by changing the URL
hash (so the in-memory data survives) at desktop and phone widths. On each
route it scrolls the page and records every button, link, checkbox, radio,
switch, tab, slider and text field as "role | accessible name".

Usage:
  python tool/ui_inventory.py --url https://onica5000.github.io/MHAD/ --out before.json
  python tool/ui_inventory.py --build build/web --out after.json
  python tool/ui_inventory.py --diff before.json after.json

The diff lists controls present before but missing after, per viewport and
route. Each one must be explained (moved, renamed, merged) before shipping.
Needs Python Playwright + Chromium (installed on this machine; see
notes/AI_Tools_Reference.md).
"""
from __future__ import annotations

import argparse
import functools
import http.server
import json
import pathlib
import sys
import threading

BASE = "/MHAD/"
VIEWPORTS = {"desktop": (1440, 900), "phone": (390, 844)}
ROUTES = (
    ["/", "/education", "/assistant", "/ai-setup", "/settings", "/accessibility",
     "/privacy-policy", "/permissions", "/facilitator", "/audio-guide"]
    + [f"/wizard/1?step={i}" for i in range(11)]
    + ["/upload/1", "/crisis-plan/1", "/ulysses/1", "/side-effects/1",
       "/findable/1", "/ai-check/1",
       # /sign stamps the directive as prepared, so it goes after the draft-only routes.
       "/sign/1", "/export/1", "/revoke/1", "/past/1"]
)
ROLES = ("button", "link", "checkbox", "radio", "switch", "tab", "slider",
         "textbox", "combobox", "menuitem")

COLLECT_JS = """(roles) => {
  const out = new Set();
  const sel = roles.map(r => `[role="${r}"]`).join(',') + ',input,textarea';
  for (const el of document.querySelectorAll(sel)) {
    const role = el.getAttribute('role') || el.tagName.toLowerCase();
    let name = (el.getAttribute('aria-label') || el.textContent || '').trim();
    name = name.replace(/\\s+/g, ' ').slice(0, 90);
    if (name) out.add(role + ' | ' + name);
  }
  return [...out];
}"""


class _Handler(http.server.SimpleHTTPRequestHandler):
    def translate_path(self, path: str) -> str:
        path = path.split("?", 1)[0].split("#", 1)[0]
        if not path.startswith(BASE):
            return str(pathlib.Path(self.directory) / "__not_found__")
        return super().translate_path("/" + path[len(BASE):])

    def log_message(self, *args) -> None:
        pass


def serve(root: str) -> str:
    handler = functools.partial(_Handler, directory=str(pathlib.Path(root).resolve()))
    server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    return f"http://127.0.0.1:{server.server_address[1]}{BASE}"


def enable_semantics(page) -> None:
    page.evaluate("() => { const p = document.querySelector('flt-semantics-placeholder');"
                  " if (p) p.click(); }")
    page.wait_for_timeout(600)


def click_named(page, role: str, name: str, timeout=8000) -> bool:
    try:
        page.get_by_role(role, name=name).first.click(timeout=timeout)
        return True
    except Exception:
        return False


def pass_gates(page) -> None:
    # Disclaimer: tick the consent box, then Get started. Onboarding: Get started.
    for _ in range(3):
        url = page.url
        if "#/disclaimer" in url:
            page.get_by_role("checkbox").first.click()
            click_named(page, "button", "Get started")
        elif "#/onboarding" in url:
            click_named(page, "button", "Get started")
        else:
            return
        page.wait_for_timeout(1500)
        enable_semantics(page)


def collect_route(page) -> list[str]:
    seen: set[str] = set()
    stale = 0
    for _ in range(14):
        found = set(page.evaluate(COLLECT_JS, list(ROLES)))
        new = found - seen
        seen |= found
        stale = 0 if new else stale + 1
        if stale >= 2:
            break
        page.mouse.move(page.viewport_size["width"] * 0.6, page.viewport_size["height"] * 0.5)
        page.mouse.wheel(0, 650)
        page.wait_for_timeout(450)
    return sorted(seen)


TAB_JS = """() => {
  const a = document.activeElement;
  if (!a || a === document.body) return '(body)';
  const name = (a.getAttribute('aria-label') || a.textContent || '').trim().replace(/\\s+/g, ' ');
  return (a.getAttribute('role') || a.tagName.toLowerCase()) + ' | ' + name.slice(0, 60);
}"""

UNNAMED_JS = """() => [...document.querySelectorAll('[role="button"]')]
  .filter(e => !(e.getAttribute('aria-label') || e.textContent || '').trim()).length"""


def tab_order(page, stops: int = 15) -> list[str]:
    page.evaluate("() => { if (document.activeElement) document.activeElement.blur(); }")
    order = []
    for _ in range(stops):
        page.keyboard.press("Tab")
        page.wait_for_timeout(120)
        order.append(page.evaluate(TAB_JS))
    return order


def route_record(page) -> dict:
    return {
        "title": page.title(),
        "controls": collect_route(page),
        "unnamed_buttons": page.evaluate(UNNAMED_JS),
        "tab": tab_order(page),
    }


def inventory(url: str) -> dict:
    from playwright.sync_api import sync_playwright
    result: dict = {}
    with sync_playwright() as pw:
        browser = pw.chromium.launch()
        for vp_name, (w, h) in VIEWPORTS.items():
            page = browser.new_page(viewport={"width": w, "height": h})
            page.goto(url, wait_until="load")
            page.wait_for_selector("flt-glass-pane, flutter-view", timeout=90_000)
            page.wait_for_timeout(2500)
            enable_semantics(page)
            pass_gates(page)
            page.evaluate("() => { location.hash = '#/'; }")
            page.wait_for_timeout(1800)
            enable_semantics(page)
            if not click_named(page, "button", "Start now"):
                print(f"[{vp_name}] could not find 'Start now'; per-directive routes may be empty",
                      file=sys.stderr)
            page.wait_for_timeout(2000)
            routes: dict = {}
            for route in ROUTES:
                page.evaluate(f"() => {{ location.hash = '#{route}'; }}")
                page.wait_for_timeout(1800)
                enable_semantics(page)
                routes[route] = route_record(page)
                print(f"[{vp_name}] {route}: {len(routes[route]['controls'])} controls, "
                      f"title {routes[route]['title']!r}", flush=True)
            if vp_name == "phone":
                # Items that only exist after interaction: the bottom nav's More sheet.
                page.evaluate("() => { location.hash = '#/'; }")
                page.wait_for_timeout(1500)
                enable_semantics(page)
                if click_named(page, "button", "More"):
                    page.wait_for_timeout(1200)
                    routes["/ (More sheet open)"] = route_record(page)
                    page.keyboard.press("Escape")
            result[vp_name] = routes
            page.close()
        browser.close()
    return result


def _controls(rec) -> list[str]:
    # Older inventories stored a bare list per route.
    return rec if isinstance(rec, list) else rec.get("controls", [])


def diff(before_path: str, after_path: str) -> int:
    """Missing controls fail; title and Tab-order changes are listed for review."""
    before = json.load(open(before_path, encoding="utf-8"))
    after = json.load(open(after_path, encoding="utf-8"))
    missing_total = 0
    for vp, routes in before.items():
        for route, rec in routes.items():
            new = after.get(vp, {}).get(route, {})
            gone = sorted(set(_controls(rec)) - set(_controls(new)))
            if gone:
                missing_total += len(gone)
                print(f"\n[{vp}] {route}  ({len(gone)} missing)")
                for g in gone:
                    print(f"   - {g}")
            if isinstance(rec, dict) and isinstance(new, dict):
                if rec.get("title") != new.get("title"):
                    print(f"[{vp}] {route}  title: {rec.get('title')!r} -> {new.get('title')!r}")
                if new.get("unnamed_buttons", 0) > rec.get("unnamed_buttons", 0):
                    print(f"[{vp}] {route}  unnamed buttons: "
                          f"{rec.get('unnamed_buttons')} -> {new.get('unnamed_buttons')}")
    print(f"\n{missing_total} controls present before are missing after.")
    return 0 if missing_total == 0 else 1


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    src = ap.add_mutually_exclusive_group()
    src.add_argument("--url", help="app URL ending in /MHAD/")
    src.add_argument("--build", help="local build/web folder to serve under /MHAD/")
    ap.add_argument("--out", help="write the inventory JSON here")
    ap.add_argument("--diff", nargs=2, metavar=("BEFORE", "AFTER"))
    a = ap.parse_args()
    if a.diff:
        return diff(*a.diff)
    if not (a.url or a.build) or not a.out:
        ap.error("give --url or --build, plus --out (or use --diff)")
    url = a.url or serve(a.build)
    data = inventory(url)
    pathlib.Path(a.out).write_text(json.dumps(data, indent=1, ensure_ascii=False), encoding="utf-8")
    print(f"wrote {a.out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
