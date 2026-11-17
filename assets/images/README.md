# App photography

Every photo here was generated with **Grok Imagine** (xAI's `image_gen` tool) in the
"D — natural-light photography" style chosen 2026-11-16, by `tool/art/generate_art.py`.
Each generation is verified as a real `image_gen` call (Grok session log + image hash);
nothing is drawn with code.

| What | Where |
|---|---|
| Single source: id, group, aspect, subject (incl. cast), where it is used | `tool/art/art_manifest.json` |
| Ids in code | `lib/ui/theme/app_art.dart` (`AppArt`) — shown with `ArtImage` |
| Checks: ids ↔ manifest ↔ files, pixel sizes, aspect ratios, KB budgets | `test/unit/app_art_test.dart` |
| One log line per generation (session id, sha256, sizes) | `tool/art/generation_log.jsonl` |
| Full-size JPEG originals | `tool/art/originals/` (git-ignored) |

**Content rules** (also in the manifest's `rules`): no readable text; no distress, needles,
restraints or loose pills; calm everyday settings; people photos name a **diverse cast**
(race, gender, age — user requirement 2026-11-17).

**Redo one image:** edit its `subject` in the manifest, run
`python tool/art/generate_art.py --only <id> --style D --force`, then review it (hands,
faces, no text) on a contact sheet before committing.

This folder is not bundled itself — only its subfolders are listed in `pubspec.yaml`.
