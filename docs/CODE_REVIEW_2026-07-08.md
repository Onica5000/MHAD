# Code Review 2026-07-08 — Findings & Fix Tracker

Whole-codebase quality review (post-Opus). Branch: `chore/code-review-2026-07-08`.
Ground rule: zero functional/visual behavior change, except the two ✱-marked
user-approved QoL items. One commit per item; commit hash recorded on completion.

## Baseline (verified healthy — no action)
- `flutter analyze` clean; no TODO/FIXME/`print()`; no dead files anywhere in `lib/`.
- All 9 `_stub/_native/_web` conditional-import trios correctly wired via facades.
- Export/import paths use typed user-facing exceptions (strongest area of the codebase).
- All UI Timers cancelled in `dispose()`; no leaked StreamControllers; Drift streams consumed via auto-cancelling builders.
- No Cupertino widgets. Async `mounted` discipline is good (one suspected gap in `export_screen.dart` was re-checked and is properly guarded — false positive).

## Package 1 — Bug fixes + user QoL

| # | Finding | Fix | Status | Commit |
|---|---|---|---|---|
| 1 | **[BUG — data loss]** `DatabaseEncryptionService.getOrCreateKey` generates + persists a NEW key when the secure-storage read *throws* (transient keystore failure), silently bricking an existing encrypted private-mode DB. Runs every boot. | Read retries once then throws `DatabaseKeyUnavailableException`; key generated only when the read succeeded and found nothing. Web skips the round-trip entirely (key provably unused there). 6 unit tests. | ✅ | (this commit) |
| 2 | **[LEAK]** `DocumentExtractor`/`SmartFillService`/`LlmAssistant`/`LlmClient` own pinned `http.Client`s with no close path; call sites instantiate-and-discard. | Add `dispose()`; call at pipeline call sites + `ref.onDispose` in `aiAssistantProvider`. | ☐ | |
| 3 | **[HARDENING]** `main()` serial await chain — any load throwing → blank screen; independent loads not parallelized. | `Future.wait` independent loads; minimal error/retry screen fallback. | ☐ | |
| 4 | ✱ **[QoL]** Blank page while `main.dart.js` downloads (no pre-Flutter loading indicator). | Inline CSS splash in `web/index.html`, hidden on `flutter-first-frame`. | ☐ | |

## Package 2 — New tests

| # | Finding | Fix | Status | Commit |
|---|---|---|---|---|
| 5 | Zero migration coverage for 20 hand-written schema versions (`app_database.dart` onUpgrade; incl. benign-but-odd `from<11` before `from<9` ordering). | Migration test: historical schema → v20, schema + data assertions. | ☐ | |
| 6 | `directive_file_codec` encrypted container: only `isEncrypted()` asserted. | Round-trip + tamper→`DirectiveFileException` + version-gate test. | ☐ | |
| 7 | `SmartFillService` consent/prompt building untested (V4-L15 adjacent). | Test consent values gate prompt content. | ☐ | |

## Package 3 — Refactors / de-duplication (behavior-preserving)

| # | Finding | Fix | Status | Commit |
|---|---|---|---|---|
| 9 | JSON fence-strip+trailing-comma+decode copy-pasted 3× across AI files. | One shared helper. | ☐ | |
| 10 | 429 string-sniffed in 3 places; 3 different retry strategies. | Typed rate-limit error at `LlmClient._httpError`; single retry policy in `LlmClient`. | ☐ | |
| 11 | AI service constructor block (model resolution + pinned client + LlmClient) duplicated 3×. | Shared factory/base. | ☐ | |
| 12 | `FormType`/`MedicationEntryType` enums bypassed by bare string literals in ~20 files; ad-hoc valid-set in `smart_fill_service.dart`. | Route through enums (string values unchanged). | ☐ | |
| 13 | Secure-storage options duplicated; storage-key strings scattered (no registry). | Central config module (mirrors `constants.dart` consent pattern). | ☐ | |
| 14 | Autosave controller listener add/remove/dispose boilerplate duplicated across ~18 wizard steps. | `registerController()` on `AutoSaveMixin`; mechanical retrofit. | ☐ | |
| 15 | `document_pipeline_flow.dart` 1,945 lines; State class ~1,770. | Extract `PipelinePickStep` + processing-step widgets. No UI change. | ☐ | |
| 16 | `combined_pdf.dart` re-inlines Part I–IV content also built by declaration/poa renderers. | Shared Part-builder functions; verified with PDF fidelity harness. **Done last.** | ☐ | |
| 17 | 10/18 wizard steps inline header styling despite shared `SectionLabel`/`EditorialHeading`. | Retrofit only where rendered output is pixel-identical. | ☐ | |
| 18 | `analysis_options.yaml` is the stock template. | Curated stricter lint set + mechanical fallout fixes. | ☐ | |

## Package 4 — Localization kickoff

**Finding:** l10n fully wired (delegates, en+es, ~70 ARB keys) but consumed **nowhere** —
0 `AppLocalizations.of` calls outside generated code. ~575 hardcoded UI strings; es ARB is dead weight.

| # | Item | Status | Commit |
|---|---|---|---|
| 19 | `context.l10n` extension | ☐ | |
| 20 | Screen-by-screen migration to ARB (en) — per-screen table below | ☐ | |
| 21 | Spanish policy: es only for fully-covered non-legal screens; legal copy flagged for human review, never machine-translated | ☐ (policy) | |

### Per-screen migration progress (worst offenders first)
| Screen | ~strings | Status |
|---|---|---|
| export_screen.dart | 47 | ☐ |
| admin_update_screen.dart | 29 | ☐ |
| form_type_quiz.dart | 22 | ☐ |
| document_pipeline_flow.dart | 20 | ☐ |
| home_screen.dart | 19 | ☐ |
| (remaining ~110 UI files) | ~440 | ☐ |

## Noted, deliberately not done
- **Major dependency upgrades** (Riverpod 3, go_router 17, drift 2.34, flutter_local_notifications 22, …): deferred — churn risk out of scope for this pass.
- **`sqlcipher_flutter_libs` is upstream EOL** (`0.7.0+eol`): affects only the deferred native/desktop private-mode DB (web is in-memory). Revisit if native is revived — likely migration: `sqlite3_flutter_libs` + an alternative encryption story.
- Item 8 in the plan was a process note (test-gotcha guardrails), not a finding.
- One reviewed finding was a **false positive** (unguarded context after await in `export_screen.dart:287-293` — it is guarded) and is excluded.
