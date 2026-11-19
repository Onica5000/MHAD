#!/usr/bin/env python3
"""Build assets/data/passphrase_lists.json from the zxcvbn-ts word-list packages.

Usage (stdlib only, reproducible - same inputs give byte-identical output):

    python tool/passphrase/build_lists.py <language-common dir> <language-en dir> \
        <language-es-es dir> [--out assets/data/passphrase_lists.json]

Each directory is an extracted npm tarball (the folder that holds package.json;
the lists are read from its src/*.json - plain JSON arrays, most common first).
Get them with `npm pack @zxcvbn-ts/language-common@<v>` etc. and `tar -xzf`.
The versions are read from each package.json and written to the "_source" block.

Lists written (all lowercase, newline-joined, most common first, de-duplicated
keeping the first occurrence, entries over 32 characters / containing a newline
or U+FFFD dropped):

  passwords  language-common passwords                           top 10,000
  en_words   language-en commonWords + wikipedia, merged 3:1     top 8,000
  es_words   language-es-es commonWords + wikipedia, merged 3:1  top 8,000
  names      es first names, en last names, es last names (interleaved,
             ranked, top 1,500) then every en first name (that source is
             alphabetical, not ranked, so those names sit after the ranked block)

Words and names shorter than 3 characters are dropped (the strength estimator
only matches tokens of 3+ characters outside `passwords`).
"""

import argparse
import json
import sys
from pathlib import Path

MAX_ENTRY_LEN = 32
TOP_PASSWORDS = 10_000
TOP_WORDS = 8_000
TOP_RANKED_NAMES = 1_500  # ranked block; unranked en first names follow
MIN_WORD_LEN = 3
SIZE_BUDGET = 300 * 1024

PACKAGES = (
    "@zxcvbn-ts/language-common",
    "@zxcvbn-ts/language-en",
    "@zxcvbn-ts/language-es-es",
)


def load_package(directory: Path, expected_name: str):
    pkg = json.loads((directory / "package.json").read_text(encoding="utf-8"))
    if pkg.get("name") != expected_name:
        sys.exit(f"{directory}: expected {expected_name}, found {pkg.get('name')}")
    if pkg.get("license") != "MIT":
        sys.exit(f"{expected_name}: license is {pkg.get('license')!r}, not MIT")
    return pkg["version"], directory / "src"


def read_list(src: Path, name: str):
    data = json.loads((src / f"{name}.json").read_text(encoding="utf-8"))
    if not isinstance(data, list) or not all(isinstance(x, str) for x in data):
        sys.exit(f"{src / (name + '.json')}: expected a JSON array of strings")
    return data


def clean(entries, min_len=1):
    """Lowercase, drop bad entries, dedupe keeping the first occurrence."""
    seen = set()
    out = []
    for raw in entries:
        w = raw.strip().lower()
        if (
            len(w) < min_len
            or len(w) > MAX_ENTRY_LEN
            or "\n" in w
            or "\r" in w
            or "ï¿½" in w
            or w in seen
        ):
            continue
        seen.add(w)
        out.append(w)
    return out


def interleave(*lists, weights=None):
    """Rank-proportional merge of ranked lists (weights default to all equal).

    An entry at 0-based position i in a list of weight w sorts by i / w, so
    equal weights give round-robin (rank 1 of each, then rank 2 of each...) and
    weights (3, 1) give three entries of the first list per entry of the second.
    Ties keep list order, so the result is deterministic.
    """
    weights = weights or (1,) * len(lists)
    keyed = [
        (i / w, n, i, word)
        for n, (lst, w) in enumerate(zip(lists, weights))
        for i, word in enumerate(lst)
    ]
    keyed.sort()
    return [word for _, _, _, word in keyed]


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("common_dir", type=Path)
    ap.add_argument("en_dir", type=Path)
    ap.add_argument("es_dir", type=Path)
    ap.add_argument("--out", type=Path, default=Path("assets/data/passphrase_lists.json"))
    args = ap.parse_args()

    versions = {}
    srcs = {}
    for name, d in zip(PACKAGES, (args.common_dir, args.en_dir, args.es_dir)):
        versions[name], srcs[name] = load_package(d, name)
    common, en, es = (srcs[n] for n in PACKAGES)

    passwords = clean(read_list(common, "passwords"))
    # commonWords (everyday speech) counts 3:1 over wikipedia, which carries
    # more proper nouns and markup debris.
    en_words = clean(
        interleave(read_list(en, "commonWords"), read_list(en, "wikipedia"), weights=(3, 1)),
        MIN_WORD_LEN,
    )
    es_words = clean(
        interleave(read_list(es, "commonWords"), read_list(es, "wikipedia"), weights=(3, 1)),
        MIN_WORD_LEN,
    )
    ranked_names = clean(
        interleave(
            read_list(es, "firstnames"),
            read_list(en, "lastnames"),
            read_list(es, "lastnames"),
        ),
        MIN_WORD_LEN,
    )[:TOP_RANKED_NAMES]
    en_first = clean(read_list(en, "firstnames"), MIN_WORD_LEN)
    names = clean(ranked_names + en_first, MIN_WORD_LEN)

    full = {
        "passwords": (passwords, TOP_PASSWORDS),
        "en_words": (en_words, TOP_WORDS),
        "es_words": (es_words, TOP_WORDS),
        "names": (names, len(names)),
    }
    out = {
        "_source": {
            "project": "zxcvbn-ts (https://github.com/zxcvbn-ts/zxcvbn)",
            "license": "MIT",
            "packages": versions,
            "notice": (
                "en_words and es_words draw on commonWords, derived from "
                "OpenSubtitles 2024 via OPUS (ODC-BY); see assets/licenses/zxcvbn-ts.txt"
            ),
            "generated_by": "tool/passphrase/build_lists.py",
        }
    }
    for key, (lst, top) in full.items():
        print(f"{key:10s} source {len(lst):>7,} entries -> kept {min(top, len(lst)):>6,}")
        out[key] = "\n".join(lst[:top])

    text = json.dumps(out, ensure_ascii=False, separators=(",", ":")) + "\n"
    data = text.encode("utf-8")
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_bytes(data)
    print(f"wrote {args.out}: {len(data):,} bytes ({len(data) / 1024:.1f} KB)")
    if len(data) > SIZE_BUDGET:
        sys.exit(f"over the {SIZE_BUDGET:,}-byte budget - lower the TOP_* constants")


if __name__ == "__main__":
    main()
