# PA MHAD App — Privacy Policy

**Last updated:** 2026-05-19 (v1.1)
**Canonical URL:** `https://onica5000.github.io/mhad/privacy` *(host this page; the URL
must be identical in the app, Google Play Console, and the developer website)*

This privacy policy applies to the Pennsylvania Mental Health Advance Directive (PA MHAD)
mobile application. The same content is shown in-app under **Settings → Privacy Policy**.

## Data we collect
Only the information **you** enter into your Mental Health Advance Directive forms:
- Personal information (name, address, phone, date of birth).
- Agent, alternate agent, and witness information.
- Treatment-facility preferences, medication lists, ECT/research/drug-trial preferences.
- Digital signatures, additional free-text instructions.

We do **not** collect analytics, crash reports, device identifiers, advertising IDs,
location data, contacts, or any other telemetry.

## How data is stored and protected
- All directive data is stored **locally on your device**. There is no server-side
  database, no cloud sync, no developer-side copy of your data.
- **Public Mode** uses an in-memory database that is erased when the app closes.
- **Private Mode** stores data in an on-device SQLite database encrypted with
  **SQLCipher (AES-256)**. The encryption key is stored in the device secure keystore
  (Android Keystore / iOS Keychain) and never leaves the device. Access requires
  biometric authentication or a passcode.
- Network traffic, where present, uses HTTPS with strict TLS and certificate pinning.

## AI features and third-party data sharing (opt-in)
The app's AI features (chat assistant, AI suggestions, document import) are optional.
If you opt in:
- Text you submit is sent to **Google's Gemini API** for processing.
- On the free tier, Google may use your inputs to improve their products, human
  reviewers may read inputs, and data may be retained indefinitely.
- The app **strips common personally identifying information** (names, addresses,
  phone, SSN, dates of birth, emails) before transmission. This is a best-effort filter,
  not a guarantee.
- Per-session, affirmative consent is required before any data is sent to Google.

You can avoid all third-party data sharing by not using the AI features.

## US state consumer-health-data laws (CA, WA, CT, NV, NY)
Mental-health-directive content is "consumer health data" under California CCPA/CPRA,
Washington MHMDA (which includes a **private right of action**), Connecticut, Nevada,
and New York consumer-health-data laws. Under all of them: we collect only what you
enter, solely to help you create your directive; we do not sell health data; the only
third-party transfer is the **opt-in** Gemini path described above; we use no
third-party SDKs, analytics, or advertising; and you can delete all local data at any
time via "Delete All Data" in the app menu.

## International users (GDPR)
If you are in the EEA, the UK, or Switzerland: legal basis for processing is your
explicit in-app consent. Your data stays on your device, giving you direct rights of
access, portability (PDF/FHIR export), and erasure ("Delete All Data" / uninstall).
Withdrawing consent for AI features is immediate (remove the API key in AI Setup).

## FTC Health Breach Notification Rule
We follow the amended FTC Health Breach Notification Rule (16 CFR Part 318, effective
2024-07-29). See `docs/BREACH_PLAN.md` in the repository for the full procedure. Notice
will be provided via at least two of: in-app banner, email (if available), this hosted
URL, and the app-store-listed support address.

## HIPAA
The app is **not** HIPAA-compliant. It is a consumer tool for documenting your own
preferences and is not a covered entity or business associate.

## Clinical reference data
The app uses the U.S. National Library of Medicine (NLM) Clinical Table Search Service
for medication and ICD-10 lookups. These queries do not contain user PII. NLM does not
endorse this product.

## Contact (at least two methods, per FTC HBNR)
- **In-app**: an in-app banner will be shown on next launch if a breach affects you.
- **Online**: this page (`https://onica5000.github.io/mhad/privacy`).
- **App-store listing**: developer support contact on the Google Play / App Store page.

## Children
The app is not directed to children. Users must affirm they are 18 or older (or an
emancipated minor) before use.

## Changes to this policy
Material changes will be reflected in the in-app policy screen and the
"Last updated" date above before they take effect. Continued use after a change
constitutes acceptance of the revised policy.
