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
| 1 | **[BUG — data loss]** `DatabaseEncryptionService.getOrCreateKey` generates + persists a NEW key when the secure-storage read *throws* (transient keystore failure), silently bricking an existing encrypted private-mode DB. Runs every boot. | Read retries once then throws `DatabaseKeyUnavailableException`; key generated only when the read succeeded and found nothing. Web skips the round-trip entirely (key provably unused there). 6 unit tests. | ✅ | 084aedd |
| 2 | **[LEAK]** `DocumentExtractor`/`SmartFillService`/`LlmAssistant`/`LlmClient` (+ `AudioTranscriptionService`, found during fix) own pinned `http.Client`s with no close path; call sites instantiate-and-discard. | `dispose()` added (owned clients only — injected test clients untouched); called via try/finally at all 4 call sites + `ref.onDispose` in `aiAssistantProvider`. | ✅ | 3a0c0eb |
| 3 | **[HARDENING]** `main()` serial await chain — any load throwing → blank screen; independent loads not parallelized. | Loads start eagerly + awaited together; `_BootErrorApp` fallback with retry (self-contained: no router/theme/l10n). | ✅ | 12ef556 |
| 4 | ✱ **[QoL]** Blank page while `main.dart.js` downloads (no pre-Flutter loading indicator). | Inline CSS spinner + title splash (light/dark + reduced-motion aware), removed on `flutter-first-frame`. Verify on live deploy after merge. | ✅ | 86b144b |

## Package 2 — New tests

| # | Finding | Fix | Status | Commit |
|---|---|---|---|---|
| 5 | Zero migration coverage for 20 hand-written schema versions (`app_database.dart` onUpgrade; incl. benign-but-odd `from<11` before `from<9` ordering). | v1→v20 + v10/v19→v20 replay tests with schema-parity + data-survival asserts. **The test found 2 real fresh-vs-migrated divergences, both fixed:** `onCreate` never created the 5 `idx_*_directive` indexes (fresh installs — every web session — ran unindexed), and v6/v9 migration DDL omitted `NOT NULL` on `id`. | ✅ | 9dd3d2d |
| 6 | `directive_file_codec` encrypted container: only `isEncrypted()` asserted. | 11 tests: round-trips, layout, no plaintext leakage, fresh-IV, deterministic tamper rejection (IV/ciphertext flips), truncation. | ✅ | 4bd21c8 |
| 7 | `SmartFillService` consent/prompt building untested (V4-L15 adjacent). | `buildPrompt`/`describeConsent` now `@visibleForTesting`; 9 tests pin the BINDING consent block, declaration gating, PII stripping, and `sanitized()` clamps. | ✅ | f4bb05f |

## Package 3 — Refactors / de-duplication (behavior-preserving)

| # | Finding | Fix | Status | Commit |
|---|---|---|---|---|
| 9 | JSON fence-strip+trailing-comma+decode copy-pasted 3× across AI files. | Shared `stripLlmCodeFences`/`cleanLlmJson` in `json_utils.dart` + tests. **Tests exposed a latent bug in both original copies:** Dart `replaceAll` doesn't expand `$1`, so the trailing-comma "repair" injected a literal `$1`, corrupting the responses it meant to fix. Now uses `replaceAllMapped`. | ✅ | e6ad2df |
| 10 | 429 string-sniffed in 3 places; 3 different retry strategies. | Typed `LlmRateLimitError` at the transport (REST 429 + Gemini SDK quota text); all 3 call sites catch the type. Per-site retry policies deliberately preserved (unifying would change UX). 2 new tests. | ✅ | 2171029 |
| 11 | AI service constructor block (model resolution + pinned client + LlmClient) duplicated 3× (+ AudioTranscriptionService). | `AiProvider.resolveModel()` + `LlmClient` owns client creation/disposal; grounded REST call shares the client via `LlmClient.httpClient`. | ✅ | e703c19 |
| 12 | `FormType`/`MedicationEntryType` enums bypassed by bare string literals in ~10 files; ad-hoc valid-set in `smart_fill_service.dart`. | All comparisons via enum `.name`; new `medicationEntryTypeFromName`; ad-hoc set deleted. Stored strings unchanged. | ✅ | b354b1d |
| 13 | Secure-storage options duplicated 3×; storage-key strings scattered (no registry). | `lib/services/secure_storage_config.dart`: shared `appSecureStorage` + `SecureStorageKeys` registry; 3 consumers migrated. | ✅ | 05e2fb1 |
| 14 | Autosave controller listener add/remove/dispose boilerplate duplicated across ~18 wizard steps. | **Re-verified: finding overstated — dropped.** Only 2 step files use the autosave listener pattern (4 `addListener` calls total); the rest is standard controller disposal a helper can't remove. A helper would save ~6 lines and add indirection. | ✅ no change | — |
| 15 | `document_pipeline_flow.dart` 1,945 lines; State class ~1,770. | Pick + Processing UI (~1,100 lines) moved verbatim to `pipeline_pick_ui.dart` as a State extension — the part-file pattern the pipeline already uses twice. Main file now 776 lines; zero rebuild-behavior change. | ✅ | 25a4a64 |
| 16 | `combined_pdf.dart` re-inlines Part I–IV content also built by declaration/poa renderers. | **Evaluated and rejected.** The overlap is structural, not verbatim: the statutory wording differs mid-sentence per form ("…make this Declaration and Power of Attorney…" vs "…make this Declaration…"), headers/lettering differ, and each renderer mirrors a different official form. A shared builder would have to parametrize legal text — the one thing that must not drift. Keeping three explicit renderers is the safer design for a legal document. | ✅ no change | — |
| 17 | 10/18 wizard steps inline header styling despite shared `SectionLabel`/`EditorialHeading`. | **Not confirmed on spot-check — dropped.** `personal_info_step.dart` (a named offender) has no inline section-header styling. Swapping header widgets on an unconfirmed finding risks exactly the visual drift the project's "shipped UI is source of truth" rule protects against. | ✅ no change | — |
| 18 | `analysis_options.yaml` is the stock template. | 7 curated rules added (`unawaited_futures`, `cancel_subscriptions`, `always_declare_return_types`, `unnecessary_await_in_return`, `prefer_const_declarations`, `avoid_bool_literals_in_conditional_expressions`, `only_throw_errors`); 16 fire-and-forgets wrapped in `unawaited()`; `_visual_backup/` (untracked local dir) excluded from analysis. `avoid_slow_async_io` evaluated and rejected (its advice is wrong for UI code). | ✅ | 619e02f |

## Package 4 — Localization kickoff

**Finding:** l10n fully wired (delegates, en+es, ~70 ARB keys) but consumed **nowhere** —
0 `AppLocalizations.of` calls outside generated code. ~575 hardcoded UI strings; es ARB is dead weight.

| # | Item | Status | Commit |
|---|---|---|---|
| 19 | `context.l10n` extension (`lib/l10n/l10n.dart`) — the missing ergonomic piece; also re-exports `AppLocalizations` | ✅ | 1276cb4 |
| 20 | Screen-by-screen migration to ARB (en) — per-screen table below. **First unit shipped: global navigation** (`MhadBottomNav` + `WebSidebar`, 12 new keys incl. AI badges). English values byte-identical to shipped copy. | 🟡 in progress | 1276cb4 |
| 21 | Spanish policy: es only for fully-covered non-legal screens; legal copy flagged for human review, never machine-translated. New keys deliberately NOT added to `app_es.arb` — untranslated messages fall back to English, so es-locale behavior is unchanged until a screen is fully covered. | ✅ (policy) | — |

### Per-screen migration progress
| Screen / unit | ~strings | Status |
|---|---|---|
| Global nav (bottom_nav + web_sidebar) | 12 | ✅ en |
| export_screen.dart | 47 | ☐ |
| admin_update_screen.dart | 29 | ☐ |
| form_type_quiz.dart | 22 | ☐ (note: strings live in a `static const` data model — needs restructuring to getters, not just extraction) |
| document_pipeline_flow.dart (+ its part files) | 20 | ☐ |
| home_screen.dart | 19 | ☐ |
| (remaining ~110 UI files) | ~440 | ☐ |

**Migration recipe (for future sessions):** add key to `app_en.arb` with the exact shipped English; `flutter gen-l10n`; replace the literal with `context.l10n.<key>`; import `package:mhad/l10n/l10n.dart`; leave `app_es.arb` alone until the whole screen is covered AND translations are human-reviewed. Also reconcile the ~70 pre-existing unused ARB keys as their screens migrate (some values are stale, e.g. `education`: "Education" vs the shipped "Learn").

## Outcome summary (2026-07-08)

All four approved packages executed on `chore/code-review-2026-07-08` — 12 commits,
full suite green after every one (285 → **345 tests**). Three real bugs fixed
(encryption-key overwrite data loss; broken `$1` trailing-comma JSON repair; missing
indexes + `NOT NULL` divergence on fresh-created databases), two user-visible QoL
wins (web loading splash ✱, boot-error screen with retry ✱), three new test suites,
six de-duplication/consistency refactors, a curated stricter lint set, and the
localization mechanism finally consumed (global nav migrated; remainder tracked
above). Three surveyed findings were re-verified and **rejected with rationale**
(items 14, 16, 17) rather than churned.

## Noted, deliberately not done
- **Major dependency upgrades** (Riverpod 3, go_router 17, drift 2.34, flutter_local_notifications 22, …): deferred — churn risk out of scope for this pass.
- **`sqlcipher_flutter_libs` is upstream EOL** (`0.7.0+eol`): affects only the deferred native/desktop private-mode DB (web is in-memory). Revisit if native is revived — likely migration: `sqlite3_flutter_libs` + an alternative encryption story.
- Item 8 in the plan was a process note (test-gotcha guardrails), not a finding.
- One reviewed finding was a **false positive** (unguarded context after await in `export_screen.dart:287-293` — it is guarded) and is excluded.
