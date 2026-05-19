# Breach Notification Plan — PA MHAD App

## Applicability

This plan addresses obligations under the FTC Health Breach Notification Rule
(16 CFR Part 318, updated July 2024). While the MHAD app may be exempt (single-source
user input, not a multi-source PHR), this plan adopts a conservative approach.

The FTC Health Breach Notification Rule applies to vendors of personal health records
(PHRs) and their service providers. Because the MHAD app collects health-related
information (mental health treatment preferences) and optionally transmits user content
to a third-party AI service, this plan treats the app as potentially in scope.

## What Constitutes a Breach

A breach of security means the unauthorized acquisition of identifiable health
information in a personal health record.

**Includes:**
- Unauthorized access to or disclosure of personal health information (PHI)
- Database compromise (e.g., malicious access to on-device storage)
- Unauthorized API data exposure (e.g., interception of AI assistant traffic)
- Accidental sharing or disclosure of user data
- Compromise of a third-party service provider handling user data

**Does NOT include:**
- Authorized AI data sharing (user consented per session)
- User voluntarily sharing their own generated PDF
- Data access by the user on their own device

## Data at Risk

The following categories of data may be present on a user's device or transmitted
to third-party services:

**On-device (local database):**
- Directive content: treatment preferences, medication lists, facility preferences
- Personal info: names, addresses, phone numbers, dates of birth
- Agent/witness info: names, addresses, signatures
- Guardian nomination details

**Third-party (Google Gemini API):**
- AI conversation logs (text sent to and received from Google's servers)
- Note: PII stripping is applied before transmission, but residual PHI may be present
  in free-text user messages

## Notification Timeline

Per 16 CFR Part 318 (final rule effective **2024-07-29**):

- **Discovery**: The date the breach is known or reasonably should have been known.
- **Individual notification**: Without unreasonable delay, and in no case later than
  **60 calendar days** after discovery.
- **FTC notification**:
  - **< 500 individuals affected**: submit through the FTC online form by the end of
    the calendar year following discovery.
  - **≥ 500 individuals affected**: notify the FTC **at the same time** as affected
    individuals, and in no case later than 60 days after discovery (the amended rule
    requires *concurrent* FTC notice, not the pre-amendment 10-business-day window).
- **Media notice (≥ 500 individuals)**: notify prominent media outlets serving the
  affected area without unreasonable delay, and in no case later than 60 days.

## Notification Content (per amended 16 CFR 318.5)

All breach notifications must include:

1. A brief description of the breach, including the date(s) of the breach and the
   date of discovery.
2. A description of the types of unsecured PHR-identifiable health information involved
   (e.g., treatment preferences, medication names, personal identifiers).
3. **The full name or identity** (or, where impossible, a description) of any **third
   party** that acquired the PHR-identifiable health information as a result of the
   breach. *(Added by the 2024 amendments — required, not optional.)*
4. Steps individuals should take to protect themselves from potential harm.
5. A brief description of what the **notifying entity is doing to protect the affected
   individuals** (e.g., revoking API keys, issuing an app update, recommended user
   actions). *(Strengthened by the 2024 amendments.)*
6. A brief description of what the company is doing to investigate the breach and
   prevent future breaches.
7. **Contact procedures**: must include **at least two** of the following — toll-free
   phone number, email address, website, **in-app notice**, or postal address. *(The
   2024 amendments expressly added "in-app" as a permissible contact method, which is
   the realistic primary channel for this local-first app.)*

## Notification Methods

Because the app is local-first and stores no contact information server-side, the
**primary channel is in-app notice** (a full-screen blocker banner shown on next
launch). The other channels are used to the extent we have addresses for affected
users (e.g., people who voluntarily contacted us, or via Google for the Gemini path).

**Individuals (fewer than 500 affected):**
- **In-app notice** (primary), AND
- Email to the individual's last known email address (if available), OR
- First-class mail to the individual's last known postal address.
- If contact info is insufficient for 10 or more individuals: conspicuous posting
  on the privacy-policy URL (`PRIVACY_POLICY.md` hosted page) for 90 days.

**Individuals (500 or more affected):**
- All of the above, PLUS
- Notify prominent media outlets serving the state of Pennsylvania.

**FTC:**
- Submit breach report via <https://www.ftc.gov/healthbreachnotification>.
- Include all required content listed above (including the *third-party identity*
  field and at least two contact methods).
- **< 500 affected**: by the end of the calendar year following discovery.
- **≥ 500 affected**: **concurrent** with individual notice, no later than 60 days
  after discovery.

## Response Procedure

### Phase 1: Identification and Containment (Days 0-3)
1. Confirm the breach has occurred (distinguish from false alarm)
2. Identify the attack vector or cause of disclosure
3. Contain the breach (e.g., revoke compromised API keys, issue emergency app update)
4. Preserve evidence for investigation

### Phase 2: Assessment (Days 3-14)
1. Determine the scope: number of individuals affected
2. Identify the specific data types compromised
3. Assess whether the data was actually accessed/viewed or merely exposed
4. Evaluate risk of harm to affected individuals
5. Document all findings

### Phase 3: Notification (Days 14-60)
1. Prepare notification letters/emails per the content requirements above
2. Prepare FTC submission
3. If 500+ affected: prepare media notification and press release
4. Send all notifications within the 60-day window
5. Set up a point of contact for individual inquiries

### Phase 4: Remediation (Ongoing)
1. Implement corrective measures to prevent recurrence
2. Issue app update if a code change is required
3. Review and update this plan based on lessons learned
4. Consider offering identity monitoring if personal identifiers were compromised

## Risk Reduction (Already Implemented)

The MHAD app includes the following security measures that reduce breach risk:

- **Local-only data storage**: No cloud sync, no server-side database
- **Per-session AI consent**: User must explicitly authorize each AI session
- **PII stripping**: Personal identifiers are stripped before AI API calls
- **Biometric authentication option**: Fingerprint/face lock for app access
- **Portrait-only mode**: Reduces shoulder surfing risk
- **"Delete All Data" feature**: Users can wipe all local data at any time
- **HTTPS encryption**: All AI API traffic encrypted in transit
- **No analytics or crash reporting**: No telemetry data leaves the device

## Third-Party Service Provider Obligations

**Google Gemini API (AI assistant):**
- Google's data handling is governed by the Google API Terms of Service
- Free-tier usage: Google may use conversations for model improvement
- The app discloses this to users before they use the AI feature
- If Google notifies us of a breach on their end, we will follow this plan
  for any MHAD user data affected

## Contact

[App developer contact info to be filled in before release]

- Name: _______________
- Email: _______________
- Phone: _______________
- Website: _______________

## Review Schedule

This plan should be reviewed:
- Annually (at minimum)
- After any security incident or near-miss
- When the FTC updates 16 CFR Part 318
- When significant changes are made to the app's data handling (e.g., new cloud features)

## Version History

| Version | Date       | Changes                          |
|---------|------------|----------------------------------|
| 1.0     | 2026-03-16 | Initial breach notification plan |
| 1.1     | 2026-05-19 | Updated to amended 16 CFR Part 318 (eff. 2024-07-29): concurrent FTC notice for ≥500, third-party-identity content field, ≥2 contact methods incl. in-app, "protecting affected individuals" content strengthened. (V4-H3.) |
