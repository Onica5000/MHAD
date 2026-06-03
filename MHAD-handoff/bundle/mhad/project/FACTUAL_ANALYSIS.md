# MHAD — Factual & Best-Practices Gap Analysis (Round 2)

**Purpose:** A documentation reference for the next Claude Code revision pass.
This audit focuses on **factual correctness** of every legal claim the app
makes, **comprehensiveness** of the PA Act 194 coverage, and **best practices**
for psychiatric advance directives (PADs). Every legal fact below is sourced
from the Pennsylvania consolidated statute (20 Pa.C.S. Ch. 58) and the official
PA/advocacy forms. Citations are given so a reviewer can confirm independently.

> Scope note: This is a design/documentation prototype, not legal advice. Where
> wording must be exact for print, confirm against the current consolidated
> statute at the time of release. If questions remain about how a provision
> applies to a specific person, it is wise to consult an attorney.

---

## 1. Canonical facts — VERIFIED (use these as the source of truth)

| # | Fact | Verified wording / detail | Source |
|---|------|---------------------------|--------|
| F1 | **Statute** | Mental health care declarations & powers of attorney are codified at **20 Pa.C.S. Chapter 58** (Title 20 — Decedents, Estates and Fiduciaries). | 20 Pa.C.S. Ch. 58 |
| F2 | **Enactment vs. effective date** | Added **November 30, 2004, P.L. 1525, No. 194**; **effective January 29, 2005** (60 days after enactment). | Ch. 58 enactment note; MHAPA 2008 guide |
| F3 | **Three instrument types** | A person may make a **Mental Health Declaration**, a **Mental Health Power of Attorney**, or a **Combined** declaration + POA. | NRC-PAD PA FAQ; § 5803/§ 5821/§ 5831 forms |
| F4 | **Validity term** | Automatically **terminates two years from execution** — *unless* the person is deemed incapable of making mental health care decisions **at the time it would expire**, in which case it remains effective. | § 5823(D)/§ 5808 "Termination" |
| F5 | **Witnesses** | Signature must be **witnessed by two individuals at least 18 years of age**. Amendments must be re-signed and witnessed the same way. | DRP "Directions," Part V (Execution) |
| F6 | **Agent eligibility** | Any **adult with capacity** may be agent, **except** the person's **mental health care provider or an employee** of that provider, **or an owner/operator/employee of a residential facility** where the person is staying — **unless related by blood, marriage, or adoption**. | NRC-PAD PA FAQ Q4; MHAPA |
| F7 | **Incapacity determination** | Determined by **examination by a psychiatrist AND one of**: another psychiatrist, psychologist, family physician, attending physician, or mental health treatment professional. **Whenever possible, one is a treating professional.** A person may instead specify their own trigger event/behavior. | § 5823/§ 5808 preamble; NRC-PAD Q8 |
| F8 | **ECT** | Electroconvulsive therapy may be administered **only if the person specifically consented to it in the document**. An agent **cannot** consent to ECT **unless expressly granted** that power. | § 5808; § 5836(c) |
| F9 | **Experimental studies / drug trials / research** | Person is subject to lab trials/research **only if specifically provided for**. Agent **cannot** consent **unless expressly granted**. | § 5808; § 5836(c) |
| F10 | **Hard exclusions** | "Mental health care **does not include psychosurgery or termination of parental rights**." An agent may **never** consent to these. | § 5804/§ 5808; NRC-PAD Q5 |
| F11 | **Revocation** | May be revoked **in whole or in part at any time, orally or in writing, as long as the person has NOT been found incapable** of making mental health decisions. Effective **upon communication to the attending physician or other provider**, by the person or a witness. | § 5823(C)/§ 5808(E) |
| F12 | **Self-binding ("Ulysses") — structural, not opt-in** | Because revocation is only possible *while capable*, once a person is found incapable the directive **cannot be revoked until capacity returns** — the wishes stand even over contemporaneous protest. This is the statutory design, not a separate consent clause. | Derived from F11 |
| F13 | **Guardian interaction** | A person may **nominate** a guardian for the court's consideration; the court appoints per the most recent nomination **except for good cause or disqualification**. The person **explicitly chooses** (two checkbox options) whether an appointed guardian **may or may not revoke/suspend/terminate** the directive. | § 5823(E); combined form Part V |
| F14 | **Agent decision standard** | Substituted judgment: the agent makes "the decision I would make if I were competent," guided by the declaration and any clear prior instructions, after consultation with providers. | § 5836(d) |
| F15 | **Provider may decline** | A provider may decline to follow instructions that are **against accepted medical practice** or when the provider is **not physically available**. | NRC-PAD Q9 |
| F16 | **Dosage not binding** | A person may set medication exceptions/limitations (applying to generic, brand, and trade equivalents), **but dosage instructions are NOT binding on the physician**. | § 5823(B)(2)/§ 5808 |
| F17 | **Capacity presumption** | Adults are **presumed capable** of making mental health decisions (and of executing the directive) unless adjudicated incapacitated, involuntarily committed, or found incapable after the F7 examination. | § 5832; MHAPA |
| F18 | **Provider duty to comply** | An attending physician and mental health care provider **shall comply** with declarations and powers of attorney (subject to F15). Willful non-compliance / falsification carries liability; an agent who willfully fails to comply may be removed and sued. | Ch. 58 findings; § 5837 |
| F19 | **Forms not mandatory** | The PA DHS/OMHSAS forms are **recommended but not mandatory** — content controls, not a specific template. | NRC-PAD Q1 |
| F20 | **Declaration content menu** | Statutory declaration enumerates: medication preferences; ECT; experimental studies/drug trials; preferred/avoided facilities; plus optional matters — activities that help/worsen symptoms, crisis intervention type, mental & physical health history, dietary, religious, temporary custody of children, family notification, records-disclosure limits, other. | § 5823(B); combined form |

---

## 2. Factual issues in the CURRENT build (correct these)

These are places where the prototype is **inaccurate or imprecise** against §1.

| ID | Where | Current text | Problem | Correct it to |
|----|-------|--------------|---------|---------------|
| C1 | Welcome chip, Settings, PDF header | "Act 194 · 2004" / "valid 2 years" | Enactment year is fine, but **effective date is Jan 29, 2005**; "valid 2 years" omits the incapacity exception (F4). | Keep "Act 194 (2004)"; where space allows note "effective 2005." Add to the term: "…unless you're incapable when it would expire, when it stays in effect." |
| C2 | Agent / contact-picker eligibility | "Ineligible · your healthcare provider" | Rule is **narrower & has an exception** (F6): provider/employee or residential-facility owner/operator/employee, **unless related by blood/marriage/adoption**. | Soft-warn with the full rule + the family exception, rather than a hard "ineligible." |
| C3 | Guardian step (04) | Nominate-only options | Missing the **statutory binary choice** (F13): whether an appointed guardian **may / may not** revoke, suspend, or terminate the directive. | Add the explicit two-option control. |
| C4 | Procedures step (09) | ECT / trials tiles | Does not state the **agent cannot consent unless expressly granted** (F8/F9), nor the **psychosurgery / parental-rights hard exclusion** (F10). | Add a short statutory note on each; add a read-only "Never authorized" line for psychosurgery & parental-rights termination. |
| C5 | Medications step (07) | dose fields | Does not surface that **dosage is not binding** on the physician (F16). | Add a one-line note under dose entry. |
| C6 | Review / Done / disclaimer | implies the directive governs absolutely | Omits **provider-may-decline** (F15). | Add a plain-language note: providers may decline instructions against accepted medical practice or when unavailable. |
| C7 | "When this kicks in" copy (both platforms) | now "psychiatrist + one other" ✅ (already fixed this round) | — | Verify the same wording is mirrored in the PDF preview SECTION 1 (already updated) and the Legal toggle (already updated). |

---

## 3. Comprehensiveness gaps — facts the app should SURFACE but doesn't

Not errors, but the directive is less complete/useful than the statute allows:

1. **Substituted-judgment standard (F14).** The agent step should tell users their
   agent is legally bound to choose "what you would choose," guided by what you
   wrote — this is the single best argument for completing the declaration parts
   even when naming an agent.
2. **Records-disclosure limits (F20).** Act 194's § 5836(e) disclosure authority
   **supersedes** several confidentiality statutes (Drug & Alcohol Abuse Control
   Act, MH Procedures Act §111, HIV Confidentiality Act). The "Anything else"
   step should offer a structured "records I want released / withheld" control,
   since this is an enumerated declaration item.
3. **Temporary custody of children & family notification (F20).** Enumerated
   statutory declaration items currently only reachable via free-text; consider
   first-class prompts.
4. **Capacity-presumption reassurance (F17).** Onboarding should state plainly:
   "Making this changes nothing today — you keep all decision-making until two
   professionals find otherwise." Reduces the top adoption fear.
5. **Amendment path (F5).** Distinct from revocation: a user can amend in writing,
   re-signed/witnessed the same way. The app models renewal & revocation but not
   a lightweight **amendment** flow.
6. **"Forms not mandatory" (F19).** Reassure users the output is valid because of
   its content and execution, not because it matches one template — useful when a
   facility hands them a different form.

---

## 4. Best practices (PAD/MHAD domain + UX + accessibility)

### 4.1 PAD domain best practices (evidence-based)
- **Facilitation drives completion.** Structured human help is the single
  largest lever on PAD completion in the literature; keep the "Get help"
  pathways (peer/clinician referral) prominent and non-blocking.
- **Crisis usefulness > legal completeness.** The document only helps if it's
  found in a crisis. Keep wallet-QR + clinician/paramedic summary as
  first-class, and keep the 30-second summary ordered "Do not / Prefer / Who to
  call."
- **Lived-experience content (WRAP).** Early warning signs, triggers, "what
  helps," and "what to say/avoid" are the parts staff read first — retain the
  crisis-plan add-on.
- **Plain-language first, legal on demand.** Two-register view is correct; never
  present only legalese.

### 4.2 UX / interaction
- One idea per wizard step; progress always visible; save-and-resume (mobile
  private mode only — web is anonymous/no-save by design).
- Cross-step consistency checks at Review that **warn, never block** (already
  implemented).
- Provenance tags on AI-extracted fields; user confirms before anything is used.

### 4.3 Accessibility (target WCAG 2.2 AA)
- Text scaling, dyslexia-friendly font (Atkinson Hyperlegible), reduce-motion,
  high-contrast variant, screen-reader labels on every control.
- Spanish is the highest-value second language for PA; Arabic implies full RTL
  (phase later, flagged).
- Read-aloud for the directive body aids low-vision users and phone verification.

### 4.4 Privacy / architecture honesty (already corrected — keep enforced)
- Web app = anonymous, **nothing saved**, no server. No "verified links,"
  one-time codes, read-receipts, hosted QR URLs, or audit trails.
- Snap-to-fill is **Option B**: the image is sent to the AI to read, then
  discarded — never claim "stays on device."
- Signing is **wet-ink on paper** with two adult witnesses; no digital signature
  is collected. "Make it legal" is a print guide; the document is not valid until
  signed on paper.

---

## 5. Citation-precision caveat for the next pass

The consolidated Chapter 58 renumbered subparts over time. The **language** used
in the build is verbatim from the official PA declaration / combined forms and is
correct. The **section pin-cites** used in-app are:
- **Chapter-level**: "20 Pa.C.S. Ch. 58" — safe and correct everywhere.
- **Agent authority**: **§ 5836** (authority of mental health care agent) — correct.
- **Guardian nomination cross-reference**: the forms cite **20 Pa.C.S. § 5511**
  (incapacity proceedings) — use this rather than inventing a Ch. 58 subsection.
- Avoid pin-citing individual declaration/POA subsections (e.g. "§§ 5803–5805")
  unless confirmed against the current consolidated text; § 5803 is *legislative
  findings/intent*, not agent authority. Prefer Chapter-level or § 5836 / § 5511.

If a clause must carry a precise pin-cite for print, confirm against the live
consolidated statute at release time.

---

## 6. Quick checklist for the Claude Code revision

- [ ] C1 — term/expiry copy includes incapacity exception; effective-date note
- [ ] C2 — agent eligibility = full rule + blood/marriage/adoption exception (soft-warn)
- [ ] C3 — Guardian step adds the revoke/suspend/terminate binary (F13)
- [ ] C4 — Procedures: agent-needs-express-grant note + psychosurgery/parental-rights hard exclusion
- [ ] C5 — Medications: "dosage not binding on physician" note
- [ ] C6 — Review/Done/disclaimer: provider-may-decline note
- [ ] C7 — confirm effective-condition wording mirrored in PDF + Legal toggle
- [ ] Add substituted-judgment explainer to agent step (F14)
- [ ] Add structured records-disclosure control (F20 / § 5836(e))
- [ ] First-class prompts for child custody + family notification (F20)
- [ ] Capacity-presumption reassurance in onboarding (F17)
- [ ] Lightweight amendment flow distinct from renewal/revocation (F5)
- [ ] "Forms not mandatory" reassurance (F19)
- [ ] Keep architecture-honesty invariants (§4.4) enforced across any new screens
