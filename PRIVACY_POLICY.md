# PA MHAD App — Privacy Policy

The privacy policy has **one** source of truth: the in-app screen
`lib/ui/settings/privacy_policy_screen.dart` (Settings → Privacy Policy).

It is published for the web at **<https://onica5000.github.io/MHAD/privacy.html>**
(`urls.privacyPolicy` in `assets/data/app_data.json`). That page, `web/privacy.html`, is
generated from the screen by `python tool/gen_privacy_html.py`; CI fails the deploy if the
two drift. Version and date live in `app_data.json` → `dated.privacyPolicyVersion` /
`dated.privacyPolicyUpdated`.

To change the policy: edit the screen, bump those two `dated` values, run the generator,
commit all three.

(This file used to hold a hand-maintained copy. It drifted — it still described Gemini
as the only AI provider and a native "mobile application" — so it was replaced by this
pointer on 2026-09-30.)
