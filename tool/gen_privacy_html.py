#!/usr/bin/env python3
"""Generate web/privacy.html (the hosted privacy policy) from the in-app screen.

The in-app PrivacyPolicyScreen is the single source of truth. This script reads
which `context.l10n` keys its `_PolicySection(title: ..., body: ...)` entries use,
resolves them from lib/l10n/app_en.arb, fills the version / date / URL facts from
assets/data/app_data.json, and writes a static page that
the GitHub Pages deploy serves at https://onica5000.github.io/MHAD/privacy.html
(`flutter build web` copies everything in web/ into build/web/).

  python tool/gen_privacy_html.py          # regenerate
  python tool/gen_privacy_html.py --check  # exit 1 if web/privacy.html is stale

CI runs `--check` ("Hosted privacy policy is in sync") and fails when the page
drifts from the screen, so rerun this after editing the policy copy.

A section may show the API-path or the copy-and-paste text
(`appData.ai.apiModeVisible ? context.l10n.a : context.l10n.aHandoff`); the
page publishes the variant the shipped app shows (app_data.json
`ai.apiModeVisible`). Every `_PolicySection` must parse — none is dropped.
"""

import html
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCREEN = ROOT / "lib" / "ui" / "settings" / "privacy_policy_screen.dart"
APP_DATA = ROOT / "assets" / "data" / "app_data.json"
OUT = ROOT / "web" / "privacy.html"

ARB = ROOT / "lib" / "l10n" / "app_en.arb"

def _expr(name: str) -> str:
    """`context.l10n.key[(args)]`, or the API/handoff choice
    `[(]appData.ai.apiModeVisible ? context.l10n.a : context.l10n.b[)]`."""
    return (
        rf"(?:\(?\s*appData\.ai\.apiModeVisible\s*\?\s*context\.l10n\.(?P<{name}_api>\w+)"
        rf"\s*:\s*context\.l10n\.(?P<{name}_off>\w+)\s*\)?"
        rf"|context\.l10n\.(?P<{name}>\w+)(?:\((?P<{name}_args>[^)]*)\))?)"
    )


_SECTION = re.compile(
    r"_PolicySection\(\s*title:\s*" + _expr("title")
    + r"\s*,\s*body:\s*" + _expr("body") + r"\s*,",
    re.S,
)


def _key(m: re.Match, name: str, api_visible: bool) -> str:
    if m.group(name + "_api"):
        return m.group(name + "_api") if api_visible else m.group(name + "_off")
    return m.group(name)


def sections(dart: str, arb: dict, facts: dict, api_visible: bool):
    """Resolve each section's title/body from app_en.arb (the screen reads them
    via AppLocalizations). Positional args fill the key's placeholders."""
    found = list(_SECTION.finditer(dart))
    if len(found) != len(re.findall(r"_PolicySection\(\s*title:", dart)):
        sys.exit("A _PolicySection didn't parse — update the pattern, or a "
                 "section would be silently missing from the hosted page.")
    for m in found:
        title = arb[_key(m, "title", api_visible)]
        body = arb[_key(m, "body", api_visible)]
        if m.group("body_args"):
            names = list(arb.get("@" + m.group("body"), {}).get("placeholders", {}))
            args = [a.strip() for a in m.group("body_args").split(",") if a.strip()]
            for name, expr in zip(names, args):
                if expr not in facts:
                    sys.exit(f"Unknown argument {expr!r} for {m.group('body')}")
                body = body.replace("{" + name + "}", facts[expr])
        yield title, body


_MONTHS = ["January", "February", "March", "April", "May", "June", "July",
           "August", "September", "October", "November", "December"]


def _date(value: str) -> str:
    """yyyy-MM → "November 2026", yyyy-MM-dd → "November 18, 2026"; other
    text as written (the app formats the same fact per language)."""
    m = re.fullmatch(r"(\d{4})-(\d{2})(?:-(\d{2}))?", value)
    if not m:
        return value
    month = _MONTHS[int(m.group(2)) - 1]
    if m.group(3):
        return f"{month} {int(m.group(3))}, {m.group(1)}"
    return f"{month} {m.group(1)}"


def _inline(text: str) -> str:
    esc = html.escape(text)
    esc = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", esc)
    return re.sub(r"(https://[^\s()<]+)", r'<a href="\1">\1</a>', esc)


def body_html(body: str) -> str:
    parts = []
    for para in body.split("\n\n"):
        lines = para.split("\n")
        items = [l for l in lines if l.startswith("  - ")]
        head = [l for l in lines if not l.startswith("  - ")]
        if head:
            parts.append("<p>" + "<br>".join(_inline(l) for l in head) + "</p>")
        if items:
            parts.append("<ul>" + "".join(
                f"<li>{_inline(l[4:])}</li>" for l in items) + "</ul>")
    return "\n".join(parts)


def render() -> str:
    data = json.loads(APP_DATA.read_text(encoding="utf-8"))
    arb = json.loads(ARB.read_text(encoding="utf-8"))
    facts = {"appData.privacyPolicyUrl": data["urls"]["privacyPolicy"]}
    dart = SCREEN.read_text(encoding="utf-8")
    api_visible = bool(data.get("ai", {}).get("apiModeVisible", False))
    secs = list(sections(dart, arb, facts, api_visible))
    if not secs:
        sys.exit("No _PolicySection found — did the screen's structure change?")
    blocks = []
    for title, body in secs:
        if "{" in body:
            sys.exit(f"Unresolved placeholder in section {title!r}")
        blocks.append(f"<section>\n<h2>{html.escape(title)}</h2>\n"
                      f"{body_html(body)}\n</section>")
    updated = _date(data["dated"]["privacyPolicyUpdated"])
    version = data["dated"]["privacyPolicyVersion"]
    return f"""<!DOCTYPE html>
<!-- GENERATED by tool/gen_privacy_html.py from
     lib/ui/settings/privacy_policy_screen.dart. Do not edit by hand. -->
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{html.escape(arb["tabPagePrivacyPolicy"])} – PA Mental Health Advance Directive</title>
<meta name="description" content="Privacy policy for the PA Mental Health Advance Directive web app.">
<style>
  :root {{ color-scheme: light dark; --fg:#1f2937; --muted:#4b5563; --bg:#ffffff; --accent:#1E3A8A; }}
  @media (prefers-color-scheme: dark) {{ :root {{ --fg:#e5e7eb; --muted:#9ca3af; --bg:#0f172a; --accent:#93c5fd; }} }}
  body {{ margin:0; background:var(--bg); color:var(--fg); font:16px/1.6 system-ui,-apple-system,"Segoe UI",Roboto,sans-serif; }}
  main {{ max-width:720px; margin:0 auto; padding:32px 16px 64px; }}
  h1 {{ font-size:1.6rem; margin:0 0 4px; }}
  h2 {{ font-size:1.15rem; margin:32px 0 8px; }}
  .meta {{ color:var(--muted); margin:0 0 24px; }}
  a {{ color:var(--accent); overflow-wrap:anywhere; }}
  ul {{ padding-left:1.25rem; }}
</style>
</head>
<body>
<main>
<h1>{html.escape(arb["privacyPolicyPaMhadAppPrivacyPolicy"])}</h1>
<p class="meta">Last updated: {html.escape(updated)} ({html.escape(version)}).
The same policy is shown in the app under {html.escape(arb["navSettings"])} → {html.escape(arb["tabPagePrivacyPolicy"])}.</p>
{chr(10).join(blocks)}
<p class="meta"><a href="./">Open the app</a></p>
</main>
</body>
</html>
"""


def main():
    page = render()
    if "--check" in sys.argv:
        current = OUT.read_text(encoding="utf-8") if OUT.exists() else ""
        if current != page:
            sys.exit("web/privacy.html is stale — run: python tool/gen_privacy_html.py")
        print("web/privacy.html is up to date")
        return
    OUT.write_text(page, encoding="utf-8")
    print(f"wrote {OUT.relative_to(ROOT)} ({len(page)} bytes)")


if __name__ == "__main__":
    main()
