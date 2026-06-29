# PA MHAD Gap Analysis V4 — Regulatory Re-validation & Improvement Backlog

**Date:** 2026-05-19
**Author:** automated comprehensive review (code audit + May 2026 online research)
**Scope:** Re-validate V2/V3 "all gaps closed" claims against (a) the *current* codebase and
(b) the regulatory landscape as of May 2026, then surface new gaps and improvement
opportunities. V2/V3 are treated as historical — several of their items have drifted or
were superseded by regulations that changed *after* they were written.

> ⚠️ **Framing:** V3 concludes "all identified gaps are addressed." That is no longer
> true. The FTC HBNR amendments (eff. Jul 2024), three new state consumer-health-data
> laws (CT/NV/NY), the Google Play Jan 28 2026 health-app rules, and Apple's Nov 2025
> third-party-AI guideline all post-date or were under-scoped in V3. This is **not**
> rework of closed items for its own sake — it is closing genuinely new exposure.

> 🔄 **Re-scoped for the 2026-06-16 web-first pivot (updated 2026-06-20).** The app now
> ships as the Chrome/Edge **web** app only; native Android/iOS are postponed indefinitely
> (see CLAUDE.md). That demotes the app-store **submission** items here — **V4-C1**
> (public privacy-policy URL — Play blocker), **V4-C2** (Play verified-Organization
> account), and **V4-H5** (Apple third-party-AI / `PrivacyInfo.xcprivacy` / nutrition
> label) — to **deferred, native-only**; they are no longer release blockers for the
> shipping surface and are tagged `[deferred — native]` below. Items since closed:
> **V4-H7** (orphan `AppStrings` deleted) and **V4-M9** (the draw-to-sign pad was dropped
> for wet-ink-only, mooting the dragging-movement gap). The live engineering priorities
> are now **V4-H6 (test coverage)** and the regulatory/privacy items that apply to the web
> app (HBNR, multi-state health-data laws — both substantially addressed in the privacy
> copy). A public privacy URL (C1) is also now *trivially* hostable via the GitHub Pages
> web deploy even though it's no longer a Play gate.

## Status key: [ ] Todo · [~] Partial · [!] Regressed/drifted from prior claim

---

## CRITICAL

### V4-C1: No public, non-PDF privacy-policy URL — Google Play health-app blocker
- **Files:** `lib/ui/settings/privacy_policy_screen.dart` (in-app text only; no URL launch)
- **Evidence:** Google Play (Jan 28 2026 health rules) requires the privacy policy to be a
  *publicly accessible web page* (no PDF) at a URL **identical** across Play Console, the
  app, and the developer website. The app currently has only an in-app screen — there is
  no hosted URL referenced anywhere in code.
- **Impact:** Hard submission/blocker for the Health category on Play; also relevant to
  Apple privacy labels and FTC/state-law transparency obligations.
- **Fix:** Publish the privacy policy at a stable HTTPS page; reference that exact URL in
  the app (e.g., a "View online" link on the privacy screen), Play Console, and website.
  Keep the in-app copy in sync.
- **Status:** `[deferred — native]` — no longer a Play blocker (web-first pivot). Note: the
  in-app "View this policy online" link was deliberately **removed** (2026-06; product
  decision). Hosting `PRIVACY_POLICY.md` via the web deploy would still be a clean win.

### V4-C2: Google Play health/medical category now requires a verified Organization account
- **Evidence:** As of **Jan 28 2026**, individual developer accounts are no longer
  permitted for apps in the health/medical category; migration to a verified Organization
  account is mandatory (enables breach accountability). `Git user: Onica5000` suggests an
  individual account.
- **Impact:** App cannot be published/updated in the health category without this.
- **Fix:** Confirm/convert to a verified Organization account before the next Play
  submission. (Process/admin task — flagged here so it isn't missed.)
- **Status:** `[deferred — native]` — Play-only; not applicable to the web app.

---

## HIGH

### V4-H3: FTC HBNR amended breach-notice content not verified against `BREACH_PLAN.md`
- **Files:** `docs/BREACH_PLAN.md` (created in V3-H6, *before* the amendments took effect)
- **Evidence:** The HBNR final rule (eff. **Jul 29 2024**) expands required notice content:
  full identity of any third party that acquired PHR-identifiable info, a description of
  what the entity is doing to protect affected users, and **at least two** contact methods
  (toll-free phone, email, website, **in-app**, postal). ≥500-individual breaches require
  notifying the FTC *at the same time* as individuals, within 60 days. V3-H6 predates this.
- **Fix:** Revise `BREACH_PLAN.md` to the amended content/timing; add an in-app breach
  notice surface as one of the two contact channels (the app is local-first, so an
  in-app banner is the realistic primary channel).
- **Status:** [~]

### V4-H4: Consumer-health-data laws beyond Washington (CT, NV, NY) not addressed
- **Files:** `lib/ui/settings/privacy_policy_screen.dart` (V3-M11 added WA MHMDA only)
- **Evidence:** Since WA MHMDA, Connecticut, Nevada, and **New York** (NY Health
  Information Privacy Act) enacted consumer-health-data laws. WA's private right of action
  is live — first class action filed Feb 2025. Mental-health-directive content is
  squarely "consumer health data." The app's local-first, no-SDK, no-ads, no-sale posture
  is a strong defense, but the privacy policy/consent language should generalize beyond WA.
- **Fix:** Broaden the privacy-policy section from "WA MHMDA" to a "Consumer Health Data
  (WA/CT/NV/NY)" section; explicitly state no sale, no targeted ads, no third-party SDKs,
  and that the only third-party transfer is the *opt-in* AI feature (already consented).
- **Status:** [~]

### V4-H5: Apple Nov 2025 guideline — explicit disclosure + permission before third-party AI
- **Files:** `lib/ui/widgets/ai_consent_dialog.dart`, `ios/Runner/PrivacyInfo.xcprivacy`,
  App Store privacy nutrition label (external)
- **Evidence:** Apple's revised guidelines (Nov 2025) require apps to *clearly disclose*
  where personal data is shared with third parties **including third-party AI** and obtain
  *explicit permission* first. The in-app consent dialog is actually strong (names Google,
  free-tier data use, "I Authorize" affirmative gate, PII warning, irrevocability) — but
  the **App Store privacy nutrition label** and `PrivacyInfo.xcprivacy` must also reflect
  the Gemini data flow, and the consent must demonstrably gate every send.
- **Fix:** (1) Verify the consent dialog gates the *first* AI send per session and is not
  bypassable; (2) ensure the privacy label/manifest declare health data sent to a third
  party for the AI feature; (3) Spring 2026 — set the Medical/Health regulatory-status
  declaration ("not a regulated medical device").
- **Status:** `[deferred — native]` — Apple App Store / iOS-manifest scoped; the in-app
  Gemini consent gate (the part that also matters on web) is in place.

### V4-H6: Test coverage is far below what health/legal software warrants
- **Files:** `test/` — the suite has grown substantially since this was written (the
  full run is now **223 tests, green**, incl. PII-context lock, encrypted-export,
  side-effects JSON, extraction/personal-info contracts). It still **under-covers** the
  wizard *step widgets* (validate/save/restore per step), routing/redirect gating, and the
  `MhadBottomNav`/`ResponsiveShell` layout — the highest-risk, mostly-untested areas.
  ACTION_PLAN Phase 7 promised wizard-step, provider, and AI tests; partially delivered.
- **Impact:** This is a 2-year legal document generator handling mental-health PII; a
  silent regression in step persistence, form-type step omission, or PDF field mapping is
  high-consequence and currently uncaught. The nav rewrite this session was only saved by
  the 2 home tests that happened to exist.
- **Fix:** Add: golden/structure tests for each of the 3 form-type PDFs; widget tests for
  each consolidated wizard step (validate/save/restore); a router redirect test
  (disclaimer→mode→home gating); a `FormType.steps` ↔ `_buildStep` exhaustiveness test;
  a bottom-nav/route-highlight test. Target the wizard + router first (highest risk).
- **Status:** [~] — Progress 2026-06-28: router-redirect gating (`router_test.dart`) and
  `FormType.steps` composition (`form_type_test.dart`) are covered; added the first
  wizard-step validate/save/restore widget test
  (`test/wizard/people_i_trust_step_test.dart`, locking the agents-step collapse
  regression) + multi-provider storage tests (`test/ai/ai_prefs_test.dart`). Remaining:
  per-step persistence for the other consolidated steps + golden PDF tests
  (`pdf_generator_test.dart` has smoke tests, not goldens).

### V4-H7: Localization is half-wired — two competing string layers, neither complete
- **Files:** `lib/l10n/app_*.arb` + generated `AppLocalizations` (used ~31×) **and**
  `lib/ui/strings.dart` `AppStrings` (V3-M15, used **1×**). Most of the 87 UI files still
  hardcode English. `CLAUDE.md` itself lists "never hardcode UI strings (TODO)."
- **Evidence:** V3 marked both M15 (AppStrings) and L20 (es stub) "done," but AppStrings
  is effectively dead code and the ARB/es path covers a tiny fraction of UI. PA has a
  large Spanish-speaking population; PAD research shows comprehension is a top completion
  barrier — partial/garbled localization is worse than none.
- **Fix:** Pick **one** mechanism (the generated `AppLocalizations`/ARB — it's already the
  Flutter-standard and partially wired), delete the orphaned `AppStrings`, and migrate
  strings screen-by-screen. Don't ship `es` until a screen is fully covered.
- **Status:** `[x]` **DONE** — `lib/ui/strings.dart` / `AppStrings` deleted; the generated
  `AppLocalizations`/ARB is the single mechanism (see CLAUDE.md "Localization"). Per-screen
  ARB migration + `es` coverage continue as ordinary work, but the dead-code drift is gone.

---

## MEDIUM

### V4-M8: Exported PDF has no protection, and the docs claim otherwise
- **Files:** `lib/ui/export/export_screen.dart:41` — `// (Password protection removed —
  pdf package does not support encryption)`
- **Evidence:** A prior gap analysis (V3, since removed) claimed the toggle was
  "UI-ready with a TODO." Reality: the feature was **removed**. Exported directives
  contain full mental-health PII and are shared via `share_plus` with zero protection.
- **Fix:** Either (a) integrate a PDF encryption path (native plugin or a maintained Dart
  lib), or (b) explicitly warn the user at export time that the file is unprotected and
  recommend secure handling.
- **Status:** [~] — An **encrypted export** path now exists (`ExportEncryptionService`,
  encrypt-then-MAC / HMAC-authenticated; `export_encryption_test.dart`) producing a
  protected *data file* for re-upload. The **printable PDF** is still plaintext by
  necessity (it has to be printed and wet-signed); keep the at-export "handle securely"
  guidance. See the `custom-encryption-todo` note for the two-output spec.

### V4-M9: WCAG 2.2 deltas not evaluated (signature dragging, focus-not-obscured)
- **Evidence:** WCAG 2.2 added **2.5.7 Dragging Movements** (AA) and **2.4.11 Focus Not
  Obscured** (AA). The execution step uses a draw-to-sign `signature` pad (a dragging
  movement); the app now has a sticky bottom nav + sticky accept footers that can obscure
  a focused field. The existing a11y test only checks tap-target/contrast/labels.
- **Fix:** (1) Provide a non-drag path for signing or document the "essential" exception
  with a typed-name + later wet-ink fallback (the disclaimer already says wet ink is
  legally required anyway — lean into that); (2) ensure focused inputs scroll clear of the
  sticky bottom nav/footer (insets/`Scrollable.ensureVisible`); (3) extend
  `accessibility_test.dart` beyond the home screen to the wizard and disclaimer.
- **Status:** `[x]` **MOOTED + 2.4.11 VERIFIED 2026-06-29** — the draw-to-sign `signature`
  pad was dropped; signing is wet-ink-only (typed name in-app, then print + sign on paper),
  so there's no dragging movement to remediate. **Focus Not Obscured (2.4.11):** verified
  compliant — the global mobile nav lays out in a `Column` (`Expanded(child)` above
  `MhadBottomNav`, see `responsive_shell.dart`) and the wizard bar is a
  `Scaffold.bottomNavigationBar`, so content/focused fields are always laid out *above*
  them (never overlaid). No `Positioned` sticky footer overlays any input form (the 5
  `Positioned` bottom uses are badges/heroes/autocomplete dropdowns/wallet-card art).
  Nothing to remediate.

### V4-M10: Crisis-time availability — the "transmitter/receiver problem"
- **Evidence:** PAD implementation research repeatedly identifies the core failure mode:
  a directive that exists but is **not accessible to clinicians during a crisis** is
  inert ("transmitter/receiver problem"). The app has QR + wallet card (V3-M14/L16) which
  is good, but there is no guidance/feature for *registering* or *pre-sharing* the
  directive with the user's providers/agent ahead of a crisis.
- **Fix (improvement):** Add a "Make it findable in a crisis" checklist/flow:
  share-to-agent, give-to-provider, carry wallet card, and (PA-specific) note any state
  registry or facility-record options. This directly targets the #1 evidence-based
  failure mode and is a strong product differentiator.
- **Status:** [x] **DONE 2026-06-29** — `MakeItFindableScreen` (`/findable/:id`,
  `lib/ui/crisis_findability/`): a crisis-readiness checklist (share with agent +
  trusted person, give a copy to the care team, print/carry the wallet card) that
  routes to the existing export hub, plus PA-specific guidance (no statewide registry;
  Act-194 "meant to be followed"). Reached from Home's tools grid. Widget test added.

### V4-M10c: Prototype visual fidelity sweep beyond the disclaimer (resolved 2026-05-20)
- **Evidence:** The disclaimer screen and navigation chrome (bottom-nav /
  WebSidebar) were already prototype-faithful. The remaining top-level screens —
  Mode selection, Form-type selection, Home — used legacy designs that
  diverged from the Claude-Design handoff:
  - Mode selection used a primary-teal full-screen background with onPrimary
    text (forcing the V4-M9 contrast workaround); the prototype `ScrMode` uses
    a cream scaffold with white "Card2" cards.
  - Form-type selection used a `DesignCard` with icon-block-and-chevron;
    the prototype `ScrFormType` uses a radio-dot `Opt` card with monospace tag
    pills and a "Help me choose →" primaryLight pill banner.
  - Home was missing the prototype's active-directive hero (with progress
    bar + "Continue where you left off" CTA) and the 2×2 tools grid.
- **Fix:** Three commits on `chore/prototype-fidelity-mode-formtype-home`:
  - Mode selection rebuilt around the prototype's Card2 pattern, scaffold
    background, sans H1, CrisisTopBar, and the floating RECOMMENDED badge.
    All auth wiring (biometric / passcode / loading) preserved verbatim.
  - Form-type screen rewritten with the prototype's Opt radio cards + tag
    pills + primaryLight quiz banner. POA confirmation dialog, AI setup
    prompt, snapshot/restore copy logic, loading overlay all preserved.
  - Home gets two additive widgets — `_ActiveDirectiveHero` (most-recent
    draft with progress + Continue CTA, only renders when a draft exists)
    and `_ToolsGrid` (2x2 of AI / Learn / Wallet card / Crisis help) —
    without removing the existing AppBar menu, directive list, public-mode
    notice, _LearnMoreCard, ProviderResourcesCard, or "New Directive"
    button. Zero removals; legacy entry points all still work.
- **Note on wizard steps:** the wizard step chrome (`StepHead`,
  `StepDots`, `WizardBottomBar`) and the global `inputDecorationTheme`
  in `app_theme.dart` already match the prototype's editorial pattern
  (serif italic numeral, mono "Step N of Y", filled white card inputs).
  The wizard AppBar carries four functional action icons (Smart Fill,
  Document Import, AI chat, Close) that are *features*, not chrome —
  stripping them to match the prototype's minimal "Back / Save & exit"
  header would remove user-facing functionality and was intentionally
  not done. Wizard-step visual fidelity is therefore considered
  complete via the existing widgets.
- **Status:** [x]

### V4-M10b: Provider-duty content understated the statutory "shall comply" rule (resolved 2026-05-20)
- **Evidence:** Independent research compared 20 Pa.C.S. §5462(c)(1) (Chapter 54,
  general health care) and the analogous §5842 (Chapter 58, Mental Health Care) against
  patient-facing handouts (UPMC FAQ, hospital brochures, planning workbooks) and found
  the patient materials understate physician duties — describing directives as
  "guidelines only" or saying "no law guarantees" compliance. The existing in-app FAQ
  `faq_providers_follow` opened with "Yes, unless…" which mirrored the same soft framing
  the research flagged as misleading. The existing `supp_provider_obligations` cited the
  right sections but did not quote the statutory text, did not bridge to Chapter 54, and
  did not address the patient-materials discrepancy.
- **Fix:** Rewrote `faq_providers_follow` to lead with the mandatory "shall comply"
  language and cite both §5842 (MHAD) and §5462(c)(1) (general health care). Added new
  FAQ entries `faq_guidelines_only_misconception` and `faq_mhad_vs_health_care_directive`;
  expanded `supp_provider_obligations` with the actual quoted statutory text and the
  good-faith immunity provision under §5805; added new supplementary sections
  `supp_chapter_54_vs_58` and `supp_patient_materials_discrepancy`; added glossary
  entries `glossary_shall_comply` and `glossary_chapter_54_vs_58`; and added the
  `checklist_provider_refuses_to_follow` advocate checklist. All additions feed the AI
  assistant via the system-prompt reference loop.
- **Status:** [x]

### V4-M11: `docs/ACTION_PLAN.md` is materially stale (doc/code drift)
- **Evidence:** ACTION_PLAN says AI = **Claude** API (`ClaudeApiAssistant`,
  `claude-opus-4-6`) and dependency = `drift_flutter`; the actual code uses **Gemini**
  (`gemini_api_assistant.dart`, `google_generative_ai`) and pubspec explicitly removed
  `drift_flutter`. Phase 3/7 checkboxes are unticked despite the features existing; the
  Sept-2025 nav rewrite and the bottom-nav/sidebar model aren't reflected anywhere.
- **Impact:** Future contributors (human or agent) will act on false architecture facts —
  this is exactly how "a mess" gets reintroduced.
- **Fix:** Update ACTION_PLAN + CLAUDE.md to reflect Gemini, the removed deps, the 9-step
  consolidated wizard, and the bottom-nav/sidebar navigation; add a one-line "superseded
  by V4" banner to V2/V3 so their "all closed" summaries aren't taken at face value.
- **Status:** [~] — CLAUDE.md is current (Gemini, web pivot, navigation). `ACTION_PLAN.md`
  has been retitled **historical** with a corrective banner (2026-06-20) rather than kept
  as a live plan; its body is superseded by CLAUDE.md + README.

---

## LOW / IMPROVEMENTS (opportunities, not defects)

### V4-L12: Lean into the evidence base — facilitation is the proven intervention
- **Evidence:** RCT evidence: *facilitated* PADs raise completion ~30× and roughly halve
  coercive interventions over 24 months vs. non-facilitated. The app's wizard + contextual
  education + AI assistant is effectively a *digital facilitation* tool — but it doesn't
  say so or structure itself around the facilitation interview model (symptoms → crisis
  history → proxy → preferences).
- **Opportunity:** Reframe onboarding/AI prompts around the validated facilitation
  interview arc; cite the evidence in education content; consider an optional "guided
  session" mode. Differentiator + better outcomes + marketing-safe (process, not medical
  claims — keep within `MARKETING_GUIDELINES.md`).
- **Status:** [ ]

### V4-L13: Resilience hardening (OWASP MASVS-R) is partial
- **Evidence:** App has SQLCipher, secure storage, cert pinning, root/jailbreak detection,
  screenshot protection — solid L1/L2. Not present: anti-hooking/Frida, debugger/tamper
  detection (MASVS-R). For a mental-health-PII app this is defensible to defer, but should
  be a conscious, documented decision rather than an unstated gap.
- **Fix:** Document the threat model + the deliberate MASVS-R scope decision; revisit a
  RASP solution only if distribution risk warrants it. Don't gold-plate.
- **Status:** [ ]

### V4-L14: `safe_device` MissingPluginException noise in tests
- **Evidence:** Every test run logs `MissingPluginException ... isJailBroken`. Harmless
  but obscures real failures (it nearly masked the nav-rewrite failure this session).
- **Fix:** Guard `DeviceSecurityService` behind a platform/`kIsWeb`/test check or inject a
  no-op in the test harness.
- **Status:** [ ]

### V4-L15: AI consent re-affirmation & data-minimization cadence
- **Evidence:** Consent dialog is strong but verify: shown before the *first* send each
  session, re-shown on policy change, and that PII stripping (`pii_stripper`) runs on
  every outbound payload (it is unit-tested in isolation — confirm it's actually invoked
  in `gemini_api_assistant.dart` before transmission).
- **Fix:** Add an integration test asserting no raw PII leaves `GeminiApiAssistant`.
- **Status:** [ ]

---

## Summary

Re-scoped for the web-first pivot (2026-06-20):

| Priority (web app) | Count | Theme |
|---|---|---|
| Critical | 0 | (Both prior Criticals were Play-submission blockers → `deferred — native`.) |
| High | 2 live | **V4-H6 test coverage** + HBNR/multi-state health-data alignment (H3/H4, largely addressed in privacy copy). H5 → deferred-native. |
| Medium | 3 | PDF-protection (encrypted-export now exists, [~]), crisis availability (M10), stale docs (M11, in progress). M9 mooted. |
| Low | 4 | Facilitation framing, MASVS-R, test noise, AI consent cadence |
| Deferred — native | 3 | V4-C1 (privacy URL), V4-C2 (Play org account), V4-H5 (Apple AI rule) |
| Closed since V4 | 2 | V4-H7 (orphan `AppStrings` deleted), V4-M9 (draw-to-sign pad dropped) |

**Highest-leverage now:** **V4-H6** (wizard/router widget tests — protects the core asset
and remains the biggest real gap), then **V4-M10** (crisis-time findability — the
evidence-based #1 failure mode). With native submission deferred, the prior "unblock
release" Criticals no longer drive priority; doc accuracy (this pass) and test coverage do.

## Sources (May 2026)

- FTC — Health Breach Notification Rule final amendments: <https://www.ftc.gov/news-events/news/press-releases/2024/04/ftc-finalizes-changes-health-breach-notification-rule> · <https://www.federalregister.gov/documents/2024/05/30/2024-10855/health-breach-notification-rule>
- WA My Health My Data Act — first class action / enforcement: <https://www.wilmerhale.com/en/insights/blogs/wilmerhale-privacy-and-cybersecurity-law/20250220-first-lawsuit-filed-under-washingtons-my-health-my-data-act> · <https://app.leg.wa.gov/RCW/default.aspx?cite=19.373&full=true>
- Google Play health apps — 2025 / Jan 2026 requirements: <https://support.google.com/googleplay/android-developer/answer/16679511> · <https://myappmonitor.com/blog/google-play-health-apps-update-2026-requirements>
- Apple — App Review Guidelines & third-party-AI disclosure (Nov 2025): <https://developer.apple.com/app-store/review/guidelines/> · <https://techcrunch.com/2025/11/13/apples-new-app-review-guidelines-clamp-down-on-apps-sharing-personal-data-with-third-party-ai/> · <https://developer.apple.com/documentation/bundleresources/privacy-manifest-files>
- WCAG 2.2 (Target Size, Dragging Movements, Focus Not Obscured): <https://www.w3.org/TR/WCAG22/> · <https://w3c.github.io/matf/>
- Flutter security / OWASP MASVS: <https://docs.talsec.app/appsec-articles/articles/owasp-top-10-for-flutter-m1-mastering-credential-security-in-flutter> · <https://fluttersecurity.com/>
- PA Act 194 / 20 Pa.C.S. Ch. 58: <https://www.palegis.us/statutes/consolidated/view-statute?iFrame=true&txtType=HTM&ttl=20&div=0&chpt=58> · <https://nrc-pad.org/states/pennsylvania-faq/>
- Psychiatric advance directive facilitation evidence: <https://pmc.ncbi.nlm.nih.gov/articles/PMC3747558/> · <https://pmc.ncbi.nlm.nih.gov/articles/PMC3642865/> · <https://psychiatryonline.org/doi/10.1176/appi.ps.202000659>
