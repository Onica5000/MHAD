# MHAD — UI/UX Audit (2026-06-15)

> ⚠️ **Untracked worklist — verify each item against current code before acting
> (note 2026-06-20).** This is a point-in-time finding list with no done/not-done
> tracking, so some items are already resolved. Notably **#1 (snap-to-fill PII
> contradiction) is addressed**: autofill now *intentionally* reads PII to fill the form
> (reviewed before saving) and the "PII detected and removed" copy is gone, with the
> privacy policy/disclaimer rewritten to match (commits `7862ab9`, `6514d84`). **#5**
> (assistant "PII stripped" overclaims) was also partly addressed. Treat the rest as
> candidate refinements to re-confirm, not a verified backlog.

Read-only audit of the web-focused user surfaces, for making the app more
**professional, user-friendly, and intuitive**. The design foundation is strong
(cohesive tokens, editorial voice, bundled fonts, good privacy framing) — these
are refinements. Findings are file:line-anchored; a11y/contrast items should be
visually confirmed at 200% scale + narrow phone-web.

## Top 8 highest-impact
1. **Resolve the snap-to-fill PII contradiction.** The pipeline promotes "Photo of ID → Name·DOB·address" with a FASTEST badge *and* warns not to upload PII *and* then shows "PII was detected and removed before analysis" — but for images/PDFs **nothing is stripped before going to Google** (matches the `ai-usage-facts` memory). Trust/safety defect, highest priority. (`document_pipeline_flow.dart:333,1580,1603,2225`)
2. **Validation copy lies about enforcement.** Wizard tells web users to "complete before exporting," but every `validateAndSave` returns true and never blocks; Review later flags "$n sections still need attention." Pick one model and align all copy. (`wizard_screen.dart:407-417`, step files, `review_step.dart:360`)
3. **Unify the two wizard design languages.** Some steps use the editorial system, others raw Material 3 (`personal_info_step`, `agent_designation_step:136-229`, `medications_step:181-233`). Step 1→3 looks like two apps. Biggest polish/credibility win.
4. **Make the pipeline review checkbox accessible + ≥44px.** The core control on the most important screen is a bare `GestureDetector` (~22px, no Semantics). (`document_pipeline_flow.dart:2623-2641,2703`)
5. **Fix assistant "● ACTIVE / PII STRIPPED" overclaims** shown even with no key / for image paths. Drive the pill from `hasKey`; soften to "PII redaction on (text only)." (`assistant_screen.dart:196-210`, `ai_consent_dialog.dart:42`)
6. **Relabel misleading actions** — "Preview" → "Review & sign" (it stamps execution date), the facility "search" that just forwards to AI chat, the duplicate "Skip"/"Continue to step 2" that do the same thing. (`wizard_screen.dart:259/278,973`, `document_pipeline_flow.dart:1207-1224`)
7. **De-fang destructive web flows + consent fatigue.** Up to 3-4 chained modals before the pipeline does anything; the "Exit Without Saving?" dialog leads with fear. Reassure first, consolidate. (`wizard_screen.dart:491-527`, pipeline `_startPipeline`)
8. **Sweep sub-44px tap targets + route hardcoded `Colors.orange/green` through `SemanticColors`** (export/wizard/settings; dark-mode + contrast). (`export_screen.dart:1583,1588`, `ai_setup_screen.dart:347,354`, many tap targets)

## By lens (selected)
**First-run clarity:** "Snap to fill" jargon as a title → "Autofill from a photo or PDF"; "Contact picker ✓" chip driven by `address.isNotEmpty` → "Address on file"; "Principal" leaks as wallet name fallback.

**Professionalism:** pipeline results step downgrades to plain Material `Card`+`Checkbox` mid-flow (reuse `_SnapReviewRow`); inconsistent primary-button heights; raw `'Smart Fill failed: $e'` instead of `FriendlyError.from`; "Export all data" gives no success feedback; bare default-color spinners.

**Intuitiveness:** "Generate more" leaves extracted data un-applied and lands on a different review list; auto-firing "Copy Personal Info?" modal on step-1 paint; AI consent "Not Now" silently restores text with no explanation; education has 3 inconsistent detail screens (one dead-ends).

**Accessibility:** small tap targets (Back button, rail "Full view", review Edit icon, export zoom 30×30 — bottom-nav's 48px box is the pattern to copy); settings/pipeline rows lack grouped `Semantics(button:)`; async progress not a `liveRegion`; severity conveyed by color alone; mono captions 8-10.5px should floor at ~11px and scale.

**Trust:** two adjacent "encrypt" features with opposite guarantees (rename the obfuscation one); privacy policy is a 13-section wall (add an "In short:" card).

**Mobile-web:** pipeline confirm-bar ellipsizes "Add 7 fiel…" at ~360px; encrypt-export dialog not scrollable with keyboard; touch-without-camera 461-719px shows a desktop drop-zone; heavy fixed chrome squeezes the phone-web wizard; verify the 1000-1300px band on Home/Export.

**Strengths to preserve:** onboarding capacity-presumption reassurance; export unencrypted-file ack + persistent banner; web_landing privacy-promise grid; per-message "not advice" disclaimer.
