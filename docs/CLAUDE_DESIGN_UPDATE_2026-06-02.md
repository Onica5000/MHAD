# Update for Claude Design — MHAD Implementation

**Bundle implemented:** `7MymEiPDh58jY_cchvUF8A`
(opened from `Mental Health Advance Directive.html`).
**Implementation window:** 2026-06-02, single session.
**Resulting commit range on `main`:** `dd36673` → `a24168f`.

## Headline

Of the 47 mobile artboards declared in `Mental Health Advance
Directive.html`, **46 are now at functional parity in the Flutter
codebase**. The one remaining item (m-wallet) was deferred entirely by
the user pending an infrastructure decision. Visual fidelity matches
the prototype's editorial direction across the implemented set.

Full per-artboard delta with file pointers is in
[`PROTOTYPE_AUDIT_BUNDLE_7Mym.md`](./PROTOTYPE_AUDIT_BUNDLE_7Mym.md).

## What changed at the foundation level

| Layer | Before this session | After |
|---|---|---|
| Default palette | `teal` | `navy` (the bundle's EDITMODE-pinned default) |
| Other palettes | `teal` / `sage` reachable via Settings picker | **Navy-only.** Picker removed. Persisted teal/sage choices force-migrate on next launch. |
| Design tokens | All radii / button heights / spacing already matched `ds.jsx::TOK` | No change needed — token sync confirmed |
| Type stack | DM Sans + Instrument Serif Italic + JetBrains Mono | Same — confirmed bundled |
| Web shell | `ResponsiveShell` with `WebSidebar` at ≥1000px | Adds `kMaxContentWidth = 1100` so 1920+ px monitors get matched side gutters instead of stretched content |
| Service-worker caching | Flutter's self-unregistering stub | Plus belt-and-suspenders unregister + cache-clear in `web/index.html`. Future deploys land on next page load — no incognito needed for returning visitors. |

## How each editorial moment landed in code

| Prototype artboard | Implementation note |
|---|---|
| **m-welcome** | First page of the existing 4-page onboarding carousel restyled to the prototype's hero: "In your words." dual-color italic + 4 value pills. Pages 2-4 carry educational content the prototype's single screen omits — retained intentionally. |
| **m-home** | New `_HomeGreeting` widget renders **personalized "Hi, [Name]. / Let's keep your voice clear."** when any directive carries a stored fullName, paired with a 40×40 primaryLight initials avatar pill. Anonymous fallback ("Your voice, in your words.") preserved for first-launch. |
| **m-empty** | Rebuilt as the editorial hero card — 1.5px primary border, 200pt decorative italic "1" numeral, primary-tinted "Your first directive" label, italic "About 15 minutes. / That's all." h2, three monospace pill timeline rows ("~5 min" / "~8 min" / "~6 min"), embedded "Start my directive" primary CTA. |
| **m-public** | Dark "Public mode · nothing is saved" ephemeral strip above home content + italic editorial "Welcome, guest. / Quick draft, no trace." greeting that replaces the personalized one when in Public mode. The existing operational warning card (End Session button + 10-min cache recovery info) is retained. |
| **m-faceid** | `PinEntryDialog` rewritten as a full-screen editorial unlock with brand row, 124pt lock tile with pulse-ring, italic dual-color "Use your **passcode.**" headline, dynamic monospace status pill ("AUTHENTICATING…" / "ATTEMPT N / 5" / "LOCKED · WAIT 30S"), 18pt monospace passcode field, "Switch to public mode" ghost. API unchanged. |
| **m-wizard-people** | Right-aligned `20 Pa.C.S. § 5836` monospace statute badge added next to the "What can they decide?" section label, plus the prototype's dashed-border "Agent decides / No / If…" explainer card. Compact tap-to-expand agent-card layout intentionally not adopted — would replace working data-entry forms. |
| **m-sign** | **Behavioral change per user direction:** the wizard's witness-name/phone/address form is replaced by the prototype's print-and-sign editorial — italic "Make it legal — with a pen.", surface info pill on Act 194, 3-step numbered timeline with serif-italic numerals, warn-toned eligibility callout, "In your packet" file list, large "Download signing packet (PDF)" CTA. `executionDate` stamps on Continue. The `Witnesses` table stays in schema for PDF backward compatibility. |
| **m-renew** | New `showRenewalNudge()` modal sheet matching `ScrRenew` — warning-palette icon tile, italic "Time to renew, [Name].", days-until-expiry pill, primaryTint "Quick renew · ~5 min" card with 3-metric strip, primary "Start quick renew" CTA. |
| **m-checkin** | New `showQuarterlyCheckIn()` modal sheet matching `ScrCheckIn` — primary palette, italic "Anything changed?", form-type-aware "Common things that change" rows, "Still accurate — all good" + "Edit my directive" CTAs. |
| **m-agentaccept** | **Repurposed per user direction:** the prototype's online acceptance receipt is reframed as a principal-recorded manual log of an in-person verbal acceptance. Schema v11 adds `Agents.acceptedAt` + `Agents.acceptanceNotes`. Editorial italic "[FirstName] is now your agent." displays once logged. |
| **m-verify** | New `WalletVerifyScreen` — dark inverted scaffold, status banner with "ACT 194" pill, principal card with avatar + monospace DOB/city, "Call first" agent row launching `tel:`, treatment flags pulled from real data (severe allergies, ECT/drug-trial consent, room prefs). |
| **m-permission** | New `PermissionsOverviewScreen` reachable from Settings → AI & Privacy. Mirrors the prototype's 4-check transparency block per permission (Biometrics, Notifications, Camera, Microphone, Contacts). The OS-native permission dialog the prototype shows is shipped by iOS/Android, not customizable from Flutter; the buildable parity is the in-app explainer. |
| **w-wizard** | Desktop wizard wraps body in `LayoutBuilder`; at ≥1000px shows a 240px left step rail with "STEP N / TOTAL" editorial header + 11 step rows (done/current/pending dot states) alongside the existing form column capped at 760px width. Read-only in this pass. |

## Reminder auto-trigger policy (user-decided, implemented)

| Reminder | Window | Cooldown | Priority |
|---|---|---|---|
| Renewal nudge | Fires when `expirationDate − now ≤ 28d` | 7 days between re-shows | Wins over check-in |
| Quarterly check-in | Fires when `now − updatedAt ≥ 90d` | 90 days between re-shows | Lower priority |

In-app only on next launch — no `flutter_local_notifications`. State
tracked per directive + reminder type in SharedPreferences. At most one
modal per launch.

## Why some prototype elements were not adopted

| Prototype element | Why not | What ships instead |
|---|---|---|
| **m-contacts** editorial in-app bottom sheet with eligibility heuristics | The native OS contact picker provides the same functional flow with platform-consistent UX; replacing it would mean reimplementing search + filter + permission UX + the prototype's eligibility warnings in custom code | `ContactPickerButton` calling `FlutterContacts.native.showPicker()` |
| **m-voice** animated mic + waveform pulse + "SCANNING…" pill | The stock `speech_to_text` IconButton already works on iOS / Android. Animated waveform is visual polish over working functionality | `VoiceInputButton` with stock IconButton |
| **m-scan** custom camera-frame chrome with target selector (ID / meds / conditions / other) | The existing `image_picker` + multi-page capture flow handles the user-facing input; routing it to four different extraction prompts would duplicate plumbing in `document_extractor.dart` | Multi-page `image_picker` → AI extraction → review pipeline (1100+ lines of existing wiring) |
| **m-wizard-people** tap-to-expand agent cards | Adopting the card-collapse pattern would replace the existing data-entry forms with a different interaction model — outside visual-sweep scope | Statute badge + explainer card added; forms unchanged |
| **m-welcome** single editorial screen | Compressing the 4-page carousel into a single screen drops educational content (What you can include / What to have ready / Time expectations) the carousel pages carry. Per the "no functional removal" constraint, the carousel stays | Page 1 styled to prototype's hero; pages 2-4 retained |

## The one deferral

**m-wallet** — Apple/Google Wallet pass. Per user direction (2026-06-02):
**deferred entirely.** Building this requires:

1. Apple Developer enrollment ($99/year) for the Pass Type ID certificate
2. Google Pay API + Google Wallet API issuer enrollment
3. A `.pkpass` cryptographic signing pipeline (server-side or local-cert)
4. Pass artwork generation

This is a cert + infrastructure decision, not a Flutter-package gap.
Revisit when distribution / signing infrastructure is in place.

## What Claude Design might consider in future revisions

These are observations from the implementation pass, framed as
questions for the design team rather than blocking issues:

1. **m-sign change is a hard pivot.** The prototype's `ScrSign`
   editorial assumes the in-app sign step shows print-and-sign
   instructions instead of capturing witness data. The user explicitly
   chose this model over the previously-shipped witness form (which
   the v3 spec had endorsed). If future bundles include a witness-data-
   capture screen, it would conflict with the canonical Act 194 wet-ink
   model the user has now ratified. Consider treating the print-and-
   sign editorial as the final canonical layout.

2. **m-agentaccept was repurposed because the upstream flow doesn't
   exist.** The prototype's receipt implies an online agent-acceptance
   loop (agent receives a link, reviews the directive in a separate
   app session, signs digitally). Building that flow would require
   email/SMS plumbing, a separate web view for the agent, server-side
   identity verification, and would land outside the "no remote
   storage" architectural constraint set in `PROTOTYPE_DIFF_DECISIONS
   § 40`. The implemented Flutter screen reframes it as a manual log
   the principal keeps. If future bundles assume the online flow,
   that constraint should be revisited explicitly.

3. **Auto-trigger cadence for reminder sheets is a design call.** The
   implemented 28d / 90d / 7d cooldown / 90d cooldown numbers are
   reasonable defaults but were chosen by the implementer, not the
   designer. If the design system has opinions about how often a
   directive holder should be nudged, those would be useful to encode
   in a future bundle.

4. **m-wallet's `.pkpass` artwork.** When wallet card design becomes
   actionable, having pre-signed `.pkpass` example bundles in the
   handoff (or at least the artwork layers in a known format) would
   shorten the cert-acquisition → first-pass-generation loop
   substantially.

5. **`w-wiz-mobile` AI bottom sheet.** The 1000px-breakpoint collapse
   of the desktop AI right-rail into a tappable "Need help?" bar is
   the prototype's elegant answer to "where does AI help live on
   mobile-browser?" The Flutter wizard currently exposes AI help via
   the overflow ⋮ menu's "Ask the AI" entry. Surfacing it as a
   persistent bar/sheet would match the prototype more closely; it
   was deferred because it touches existing AI route plumbing. If a
   future bundle wants to push the bar/sheet pattern more firmly,
   noting it's a higher-priority change than the current bundle
   implied would help.

6. **No web-specific artboards were implemented per-screen.** The
   bundle's 30+ desktop artboards (w-dashboard / w-share / w-learn
   / w-snapfill / etc.) often add side panels or two-column layouts
   the mobile screens don't have. The Flutter web build now ships a
   sidebar + content max-width cap that approximates the desktop
   shell; per-screen desktop layouts were not built because (a) the
   responsive shell does enough for the editorial direction to read
   correctly, and (b) the bundle's web artboards are presented as
   1200px static layouts without explicit responsive breakpoints
   below the existing 1000px split. If future bundles want per-screen
   desktop layouts to be a priority, more explicit breakpoint
   guidance per screen would be useful.

## Files of interest in the Flutter repo

```
docs/
  PROTOTYPE_AUDIT_BUNDLE_7Mym.md       -- full per-artboard delta table + session log
  PROTOTYPE_DIFF_DECISIONS.md          -- historical binding decisions (§ refs cited in code)
  CLAUDE_DESIGN_UPDATE_2026-06-02.md   -- this document

lib/ui/
  agent_accept/                        -- m-agentaccept manual log
  permissions/                         -- m-permission overview
  reminders/                           -- m-renew + m-checkin sheets
  verify/                              -- m-verify wallet QR view
  mode_selection/pin_dialog.dart       -- m-faceid editorial unlock
  home/home_screen.dart                -- m-home greeting, m-public ephemeral, m-empty hero
  wizard/steps/execution_step.dart     -- m-sign editorial print-and-sign
  wizard/steps/people_i_trust_step.dart -- m-wizard-people § 5836 + explainer
  wizard/wizard_screen.dart            -- w-wizard desktop step rail
  widgets/design/responsive_shell.dart -- desktop content max-width cap

lib/services/
  reminder_scheduler.dart              -- in-app reminder auto-fire on launch
```

## Verification

Every commit in the implementation range was verified with:

```
flutter analyze   →  No issues found
flutter test      →  167/167 passing
flutter build web --release  →  succeeded (deployed via GitHub Actions)
```

The live deployment at https://onica5000.github.io/MHAD/ reflects
`a24168f`, the head of `main` at the close of this session.
