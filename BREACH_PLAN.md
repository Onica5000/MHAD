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

Per 16 CFR Part 318:

- **Discovery**: The date the breach is known or reasonably should have been known
- **FTC notification**: Within 60 calendar days of discovery
- **Individual notification**: Within 60 calendar days of discovery
- **If 500+ individuals affected**: Also notify prominent media outlets serving the
  affected area without unreasonable delay

## Notification Content (per 16 CFR 318.5)

All breach notifications must include:

1. A brief description of the breach, including the date(s) of the breach and the
   date of discovery
2. A description of the types of unsecured identifiable health information involved
   in the breach (e.g., treatment preferences, medication names, personal identifiers)
3. Steps individuals should take to protect themselves from potential harm resulting
   from the breach
4. A brief description of what the company is doing to investigate the breach,
   mitigate harm, and prevent future breaches
5. Contact information for individuals to ask questions, including a toll-free phone
   number, email address, website, or postal address

## Notification Methods

**Individuals (fewer than 500 affected):**
- Email to the individual's last known email address (if available), OR
- First-class mail to the individual's last known postal address
- If contact info is insufficient for 10 or more individuals: conspicuous posting
  on the app's website/landing page for 90 days

**Individuals (500 or more affected):**
- Same as above, PLUS
- Notify prominent media outlets serving the state of Pennsylvania

**FTC:**
- Submit breach report via https://www.ftc.gov/healthbreachnotification
- Include all required content listed above
- Submit within 60 days of discovery (or 10 business days if 500+ affected,
  per the updated 2024 rule)

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
