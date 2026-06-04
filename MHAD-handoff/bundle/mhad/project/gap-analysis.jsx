// gap-analysis.jsx — Research-backed gap & improvement analysis.
// Adds: (1) an analysis dashboard with sources, (2) a coverage matrix,
// (3) a priority roadmap, and (4) new mobile screens for the biggest gaps.

// Local copies so this file is independent of mobile.jsx scope.
const GA_STATUSBAR_H = 60;
const GA_HOME_H = 34;

// ─── 1. RESEARCH FOUNDATION CARD ──────────────────────────────────────
function ResearchCard() {
  const { palette: p } = React.useContext(MHADContext);

  const findings = [
    { stat: '3% → 62%', label: 'Completion rate without vs. with a facilitator', src: 'Swanson et al., RCT, 469 patients' },
    { stat: '43% → 24%', label: 'Coercive interventions during incapacity, after PAD completion', src: 'PMC 2835342' },
    { stat: '66–77%', label: 'Of people with SMI would complete a PAD if helped', src: 'Five-city US survey, n>1,000' },
    { stat: '10.1%', label: 'Veterans with SMI actually have a PAD on file today', src: 'VHA records review, 2025' },
  ];

  return (
    <div style={{ background: p.scaffold, padding: '32px 36px', height: '100%', boxSizing: 'border-box', color: p.text, fontFamily: SANS, overflow: 'hidden' }}>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 14, marginBottom: 4 }}>
        <SectionLabel>Gap analysis · research foundation</SectionLabel>
        <span style={{ fontSize: 10.5, fontFamily: MONO, color: p.textMuted }}>Reviewed: 12 peer-reviewed sources + SAMHSA + MyDirectives + My Mental Health Crisis Plan (SMI Adviser)</span>
      </div>
      <h2 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 38, margin: '4px 0 6px', fontWeight: 400, letterSpacing: -0.5, lineHeight: 1.05 }}>
        The directive isn't the bottleneck. <span style={{ color: p.primary }}>The path to one is.</span>
      </h2>
      <p style={{ fontSize: 13.5, color: p.textMuted, margin: 0, maxWidth: 820, lineHeight: 1.5 }}>
        Service-user surveys consistently show 66–77% interest in PADs but completion below 10%. The single biggest lever is structured human help during creation. Once signed, accessibility in a crisis is what determines whether the document is actually honored.
      </p>

      {/* Stats row */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 14, marginTop: 22 }}>
        {findings.map((f, i) => (
          <div key={i} style={{
            background: p.card, border: `1px solid ${p.border}`, borderRadius: 12,
            padding: '14px 14px 12px', display: 'flex', flexDirection: 'column', gap: 4,
          }}>
            <div style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 30, lineHeight: 1, color: p.primary, letterSpacing: -0.5 }}>{f.stat}</div>
            <div style={{ fontSize: 12.5, color: p.text, fontWeight: 500, lineHeight: 1.35, marginTop: 4 }}>{f.label}</div>
            <div style={{ fontSize: 10, color: p.textMuted, fontFamily: MONO, marginTop: 6, letterSpacing: 0.3 }}>{f.src}</div>
          </div>
        ))}
      </div>

      {/* Three principles */}
      <div style={{ marginTop: 18, display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 14 }}>
        {[
          {
            n: '01',
            t: 'Facilitation, not paperwork',
            b: 'The single biggest predictor of completion is a person walking through it with you. Most apps replicate the form. None replicate the facilitator.',
            tag: 'Swanson 2006 · SAMHSA 2019',
          },
          {
            n: '02',
            t: 'Be useful in the worst minute',
            b: 'PADs fail when EMS, ER, or police can\'t find them. Wallet QR is the start — lock-screen presence, EHR push, and a clinician-readable view close the loop.',
            tag: 'JMIR 2025 · RAND 2024',
          },
          {
            n: '03',
            t: 'Capture the whole person',
            b: 'WRAP and Joint Crisis Plans add early warning signs, triggers, sensory preferences, and "things to say to me." Current wizard captures treatment only.',
            tag: 'Copeland · MHAMD',
          },
        ].map((b, i) => (
          <div key={i} style={{
            background: p.primaryTint, border: `1px solid ${p.primaryLight}`,
            borderRadius: 12, padding: '14px 14px 12px',
          }}>
            <div style={{ display: 'flex', alignItems: 'baseline', gap: 8 }}>
              <span style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 26, color: p.primary, lineHeight: 1 }}>{b.n}</span>
              <span style={{ fontSize: 14, fontWeight: 700, color: p.text, letterSpacing: -0.2 }}>{b.t}</span>
            </div>
            <p style={{ fontSize: 12, color: p.textMuted, margin: '8px 0 6px', lineHeight: 1.45 }}>{b.b}</p>
            <span style={{ fontFamily: MONO, fontSize: 9.5, color: p.primary, letterSpacing: 0.6, fontWeight: 600, textTransform: 'uppercase' }}>{b.tag}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── 2. COVERAGE GAP MATRIX ───────────────────────────────────────────
function GapMatrix() {
  const { palette: p } = React.useContext(MHADContext);

  // status: ok | partial | missing | shipped
  const rows = [
    { area: 'Onboarding & education', items: [
      { name: 'Welcome / disclaimer / consent', s: 'ok' },
      { name: 'Plain-language glossary', s: 'ok' },
      { name: 'Why a PAD helps (evidence)', s: 'partial', note: 'Learn hub exists but no outcome data shown' },
      { name: 'State-specific rules (PA Act 194)', s: 'ok' },
    ]},
    { area: 'Creation support', items: [
      { name: 'Wizard with progress', s: 'ok' },
      { name: 'Smart-fill from ID / contacts', s: 'ok' },
      { name: 'Snap-to-fill: ID + Rx + conditions + other', s: 'shipped', note: 'AI-assisted extraction, multi-target' },
      { name: 'Web image upload (desktop + mobile)', s: 'shipped' },
      { name: 'AI assistant', s: 'ok' },
      { name: 'Live facilitator / peer co-pilot', s: 'shipped', note: '+62% completion in RCT — biggest single lever' },
      { name: 'Schedule a 1:1 with a peer specialist', s: 'shipped' },
    ]},
    { area: 'Content depth (the directive itself)', items: [
      { name: 'Treatment preferences', s: 'ok' },
      { name: 'Agent & alternate', s: 'ok' },
      { name: 'ECT / trials / research', s: 'ok' },
      { name: 'Diagnoses (ICD-10 autocomplete)', s: 'shipped', note: 'NLM clinical-tables API' },
      { name: 'Allergies (RxTerms + severity)', s: 'shipped', note: 'Cross-links into Avoid meds' },
      { name: 'Current medications list (RxTerms)', s: 'shipped' },
      { name: 'Early warning signs & triggers (WRAP)', s: 'shipped' },
      { name: 'Wellness toolbox: what helps me', s: 'shipped' },
      { name: 'Sensory & environment preferences', s: 'partial', note: 'Covered in Crisis plan; not its own section' },
      { name: 'Self-binding / Ulysses clause', s: 'shipped', note: 'PA Act 194 explicit consent' },
      { name: 'Things to say / not say to me', s: 'shipped' },
    ]},
    { area: 'Legal execution', items: [
      { name: 'Two-witness signing', s: 'ok' },
      { name: 'Witness eligibility check', s: 'ok' },
      { name: 'Agent formal acceptance', s: 'shipped', note: 'Timestamped, cryptographically signed receipt' },
      { name: 'Remote notary handoff', s: 'missing' },
    ]},
    { area: 'Accessibility in a crisis', items: [
      { name: 'Wallet QR card', s: 'ok' },
      { name: 'Verifier landing page', s: 'ok' },
      { name: 'Lock screen / Live Activity widget', s: 'missing', note: 'Dropped — platform constraints' },
      { name: 'Push to EHR (Epic / Cerner)', s: 'missing', note: 'Roadmap P3 — FHIR' },
      { name: '1-tap "I am in crisis right now"', s: 'partial', note: 'Crisis sheet exists; not surfaced from lockscreen' },
      { name: 'Offline / airplane-mode access', s: 'missing' },
    ]},
    { area: 'Reading the directive', items: [
      { name: 'PDF preview', s: 'ok' },
      { name: 'Plain-English ⇄ Legal language toggle', s: 'shipped' },
      { name: 'Clinician-friendly summary view', s: 'shipped', note: '"What I need to know in 30s"' },
      { name: 'Read-aloud / voice playback', s: 'partial', note: 'Voice input exists, no read-back' },
    ]},
    { area: 'Maintenance', items: [
      { name: '2-year renewal nudge', s: 'ok' },
      { name: 'Revocation', s: 'ok' },
      { name: 'Temporary pause (no full revoke)', s: 'missing' },
      { name: 'Version history & changelog', s: 'missing' },
    ]},
    { area: 'Accessibility & inclusion', items: [
      { name: 'Text-size & dyslexia font', s: 'shipped' },
      { name: 'Spanish (PA 2nd-most spoken)', s: 'shipped' },
      { name: 'Screen-reader labels', s: 'partial', note: 'Hinted in copy, not exposed' },
    ]},
  ];

  const tone = (s) => ({
    ok:      { bg: p.okBg, fg: p.okText, dot: p.okText },
    shipped: { bg: p.primaryTint, fg: p.primaryDark, dot: p.primary },
    partial: { bg: p.warnBg, fg: p.warnText, dot: p.warnText },
    missing: { bg: p.crisisBg, fg: p.crisisText, dot: p.crisisAccent },
  }[s]);

  // Tally
  const all = rows.flatMap(r => r.items);
  const counts = { ok: 0, shipped: 0, partial: 0, missing: 0 };
  all.forEach(it => counts[it.s]++);

  return (
    <div style={{ background: p.scaffold, padding: '28px 32px', height: '100%', boxSizing: 'border-box', color: p.text, fontFamily: SANS, overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
      <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', marginBottom: 6 }}>
        <div>
          <SectionLabel>Coverage matrix · existing artboards vs. best-practice scope</SectionLabel>
          <h2 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 32, margin: '2px 0 0', fontWeight: 400, letterSpacing: -0.4 }}>
            What we ship today, and <span style={{ color: p.primary }}>what's still missing.</span>
          </h2>
        </div>
        {/* Legend / tally */}
        <div style={{ display: 'flex', gap: 8 }}>
          {[
            { k: 'ok', label: 'Already covered', n: counts.ok },
            { k: 'shipped', label: 'Shipped this round', n: counts.shipped },
            { k: 'partial', label: 'Partial', n: counts.partial },
            { k: 'missing', label: 'Still missing', n: counts.missing },
          ].map((c, i) => {
            const t = tone(c.k);
            return (
              <div key={i} style={{ background: t.bg, color: t.fg, padding: '6px 10px', borderRadius: 8, display: 'flex', alignItems: 'center', gap: 8 }}>
                <span style={{ width: 8, height: 8, borderRadius: 100, background: t.dot, display: 'inline-block' }} />
                <span style={{ fontSize: 11, fontWeight: 700, letterSpacing: 0.4, textTransform: 'uppercase' }}>{c.label}</span>
                <span style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 18, fontWeight: 400 }}>{c.n}</span>
              </div>
            );
          })}
        </div>
      </div>

      {/* Grid of areas */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 10, marginTop: 14, flex: 1, overflow: 'hidden' }}>
        {rows.map((row, i) => (
          <div key={i} style={{
            background: p.card, border: `1px solid ${p.border}`, borderRadius: 10,
            padding: '10px 12px 8px', display: 'flex', flexDirection: 'column', gap: 5,
            overflow: 'hidden',
          }}>
            <div style={{ fontSize: 11, fontWeight: 700, color: p.text, letterSpacing: 0.2, marginBottom: 4 }}>{row.area}</div>
            {row.items.map((it, j) => {
              const t = tone(it.s);
              return (
                <div key={j} style={{ display: 'flex', alignItems: 'flex-start', gap: 7, fontSize: 11, lineHeight: 1.3 }}>
                  <span style={{ width: 7, height: 7, borderRadius: 100, background: t.dot, display: 'inline-block', marginTop: 5, flexShrink: 0 }} />
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{
                      color: it.s === 'missing' ? p.text : p.text,
                      fontWeight: it.s === 'missing' ? 600 : 400,
                      textDecoration: it.s === 'ok' ? 'none' : 'none',
                    }}>{it.name}</div>
                    {it.note && (
                      <div style={{ fontSize: 9.5, color: t.fg, fontStyle: 'italic', marginTop: 1, fontFamily: SANS, lineHeight: 1.25 }}>{it.note}</div>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── 3. PRIORITY ROADMAP ──────────────────────────────────────────────
function PriorityRoadmap() {
  const { palette: p } = React.useContext(MHADContext);

  const items = [
    {
      tier: 'P0',
      title: 'Crisis plan & wellness toolbox',
      kind: 'New wizard add-on',
      effort: 'M',
      impact: 'High',
      why: 'WRAP/Joint Crisis Plan staples — early warning signs, triggers, what helps, things to say. Without them, the directive misses the lived-experience half of crisis care.',
      ref: 'mob · m-crisisplan',
      shipped: true,
    },
    {
      tier: 'P0',
      title: 'Diagnoses + Allergies + Current meds intake',
      kind: 'Three new wizard steps',
      effort: 'M',
      impact: 'High',
      why: 'ICD-10 + RxTerms autocomplete makes intake fast and pre-resolves the auto-link from Severe allergies into the Avoid-meds list.',
      ref: 'mob · m-diagnoses / m-allergies / m-medications',
      shipped: true,
    },
    {
      tier: 'P0',
      title: 'Live Activity & lock-screen card',
      kind: 'iOS surface',
      effort: 'M',
      impact: 'High',
      why: 'Dropped this round — reliable lock-screen presence for a third-party directive runs into platform constraints. Wallet QR + clinician view cover the crisis-access need for now.',
      ref: '— dropped',
    },
    {
      tier: 'P0',
      title: 'Get help (facilitation)',
      kind: 'New entry point',
      effort: 'L',
      impact: 'Very high',
      why: 'Structured help drives a 20× completion lift in RCTs. Referral to PA peer specialists, plus print-to-review-in-person and email-draft-to-clinician paths (no server needed).',
      ref: 'mob · m-facilitator',
      shipped: true,
    },
    {
      tier: 'P0',
      title: 'Snap-to-fill (multi-target image capture)',
      kind: 'AI image processing',
      effort: 'M',
      impact: 'High',
      why: 'One camera surface for ID, Rx label, conditions list, and anything else. Closes the data-entry friction gap.',
      ref: 'mob · m-scan + m-snap-review',
      shipped: true,
    },
    {
      tier: 'P1',
      title: 'Clinician / verifier summary view',
      kind: 'Read mode',
      effort: 'S',
      impact: 'High',
      why: 'Doctors say PADs are "too long to read in an emergency". A 30-second summary, shown from the wallet QR or handed over in person. Read-only, no server, no audit trail.',
      ref: 'mob · m-clinician',
      shipped: true,
    },
    {
      tier: 'P1',
      title: 'Plain English ⇄ Legal toggle',
      kind: 'View mode',
      effort: 'S',
      impact: 'Med',
      why: 'Same content, two registers. Lets the user verify their words against the legal language their court / facility will see.',
      ref: 'mob · m-legaltoggle',
      shipped: true,
    },
    {
      tier: 'P1',
      title: 'Self-binding (Ulysses) clause',
      kind: 'Optional section',
      effort: 'S',
      impact: 'Med',
      why: 'Lets the user pre-consent to treatment even if they refuse it during a future episode — explicitly recognized in PA Act 194.',
      ref: 'mob · m-ulysses',
      shipped: true,
    },
    {
      tier: 'P2',
      title: 'Agent acceptance receipt',
      kind: 'Flow extension',
      effort: 'S',
      impact: 'Med',
      why: 'Closes the loop on the invite: agent formally accepts in-app, with timestamped signature.',
      ref: 'mob · m-agentaccept',
      shipped: true,
    },
    {
      tier: 'P2',
      title: 'Accessibility settings',
      kind: 'Settings panel',
      effort: 'S',
      impact: 'Med',
      why: 'Text scale, dyslexia font, Spanish, screen-reader hints. Required to serve PA\'s actual mental-health population.',
      ref: 'mob · m-a11y',
      shipped: true,
    },
    {
      tier: 'P3',
      title: 'Temporary pause',
      kind: 'Status flag',
      effort: 'S',
      impact: 'Low',
      why: 'For users in transitions (new meds, pregnancy, treatment change) who want to suspend without losing the draft.',
      ref: '—',
    },
    {
      tier: 'P3',
      title: 'EHR push (Epic / Cerner via FHIR)',
      kind: 'Integration',
      effort: 'XL',
      impact: 'High (long-term)',
      why: 'The MyDirectives / St. Charles model. Out of scope for v1 but should be a north star.',
      ref: '—',
    },
    {
      tier: 'P3',
      title: 'Read-aloud / voice playback',
      kind: 'Accessibility',
      effort: 'M',
      impact: 'Med',
      why: 'Speech-synthesize the directive for low-vision users and verification by phone with a non-reading agent.',
      ref: '—',
    },
  ];

  const tierColor = (t) => ({
    P0: { bg: p.crisisAccent, fg: '#fff' },
    P1: { bg: p.primary, fg: p.onPrimary },
    P2: { bg: p.primaryMid, fg: p.onPrimary },
    P3: { bg: p.textMuted, fg: p.card },
  }[t]);

  return (
    <div style={{ background: p.scaffold, padding: '28px 32px', height: '100%', boxSizing: 'border-box', color: p.text, fontFamily: SANS, overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
      <SectionLabel>Improvement roadmap · prioritized</SectionLabel>
      <h2 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 32, margin: '2px 0 4px', fontWeight: 400, letterSpacing: -0.4 }}>
        The improvement backlog — <span style={{ color: p.primary }}>9 shipped, 1 dropped, 3 ahead.</span>
      </h2>
      <p style={{ fontSize: 13, color: p.textMuted, margin: '0 0 14px', maxWidth: 760, lineHeight: 1.5 }}>
        Items with a ✓ are in the canvas. The lock-screen card was dropped on platform constraints. P3 items remain on the long-term roadmap.
      </p>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, flex: 1, overflow: 'hidden' }}>
        {items.map((it, i) => {
          const tc = tierColor(it.tier);
          return (
            <div key={i} style={{
              background: it.shipped ? p.primaryTint : p.card,
              border: `1px solid ${it.shipped ? p.primaryLight : p.border}`,
              borderRadius: 10,
              padding: '11px 13px 10px', display: 'flex', gap: 12, alignItems: 'flex-start',
            }}>
              <div style={{
                width: 36, height: 36, borderRadius: 8, flexShrink: 0,
                background: tc.bg, color: tc.fg,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontFamily: MONO, fontSize: 13, fontWeight: 700, letterSpacing: 0.3,
                position: 'relative',
              }}>
                {it.tier}
                {it.shipped && (
                  <div style={{
                    position: 'absolute', bottom: -6, right: -6,
                    width: 18, height: 18, borderRadius: 100,
                    background: p.okText, color: '#fff',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    border: `2px solid ${it.shipped ? p.primaryTint : p.card}`,
                  }}>
                    <Check size={10} sw={3} stroke="#fff" />
                  </div>
                )}
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ display: 'flex', alignItems: 'baseline', gap: 8, flexWrap: 'wrap' }}>
                  <span style={{ fontSize: 13, fontWeight: 700, color: p.text }}>{it.title}</span>
                  <span style={{ fontFamily: MONO, fontSize: 9.5, color: p.textMuted, letterSpacing: 0.5, textTransform: 'uppercase' }}>{it.kind}</span>
                  {it.shipped && (
                    <span style={{
                      fontFamily: MONO, fontSize: 9, color: p.okText, background: '#fff',
                      padding: '1px 5px', borderRadius: 3, letterSpacing: 0.5, fontWeight: 700,
                      border: `1px solid ${p.okBorder}`,
                    }}>SHIPPED</span>
                  )}
                </div>
                <div style={{ fontSize: 11.5, color: p.textMuted, marginTop: 2, lineHeight: 1.4 }}>{it.why}</div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 6, fontFamily: MONO, fontSize: 9.5, color: p.textMuted, letterSpacing: 0.4 }}>
                  <span>EFFORT · <strong style={{ color: p.text }}>{it.effort}</strong></span>
                  <span>IMPACT · <strong style={{ color: p.text }}>{it.impact}</strong></span>
                  {it.ref !== '—' && <span style={{ color: p.primary }}>{it.ref} →</span>}
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

// ─── 4. NEW MOBILE SCREENS ────────────────────────────────────────────

// 4a. Crisis plan / wellness toolbox — new wizard step
function ScrCrisisPlan() {
  const { palette: p } = React.useContext(MHADContext);

  const Section = ({ icon, title, sub, items, accent, chipKind = 'tag' }) => (
    <div style={{ background: p.card, border: `1px solid ${p.border}`, borderRadius: TOK.rCard, padding: 14, marginBottom: 12 }}>
      <div style={{ display: 'flex', gap: 10 }}>
        <div style={{
          width: 32, height: 32, borderRadius: 8, flexShrink: 0,
          background: accent || p.primaryTint, color: accent ? '#fff' : p.primary,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>{icon}</div>
        <div style={{ flex: 1 }}>
          <h3 style={{ margin: 0, fontSize: 14.5, fontWeight: 700, color: p.text, letterSpacing: -0.2 }}>{title}</h3>
          <p style={{ margin: '2px 0 0', fontSize: 11.5, color: p.textMuted, lineHeight: 1.4 }}>{sub}</p>
        </div>
      </div>
      <div style={{ marginTop: 10, display: 'flex', flexWrap: 'wrap', gap: 6 }}>
        {items.map((t, i) => (
          <span key={i} style={{
            fontSize: 11.5, fontWeight: 500,
            color: chipKind === 'avoid' ? p.crisisText : p.onPrimaryLight,
            background: chipKind === 'avoid' ? p.crisisBg : p.primaryLight,
            border: `1px solid ${chipKind === 'avoid' ? p.crisisBorder : 'transparent'}`,
            padding: '4px 9px', borderRadius: 100, lineHeight: 1.2,
          }}>{t}</span>
        ))}
        <span style={{
          fontSize: 11.5, fontWeight: 600, color: p.primary,
          padding: '4px 9px', borderRadius: 100, lineHeight: 1.2,
          border: `1px dashed ${p.primary}`,
        }}>+ Add</span>
      </div>
    </div>
  );

  return (
    <Screen scroll={false}>
      <CrisisBar compact />
      <WizardHeader />
      <div style={{ padding: '4px 22px 0', display: 'flex', justifyContent: 'center' }}>
        <span style={{
          fontFamily: MONO, fontSize: 10, fontWeight: 700, letterSpacing: 0.8,
          color: p.primary, background: p.primaryTint, border: `1px solid ${p.primaryLight}`,
          padding: '4px 10px', borderRadius: 100, textTransform: 'uppercase',
        }}>Optional add-on · reachable from Step 10, Home & Settings</span>
      </div>

      <div style={{ overflow: 'auto', flex: 1, minHeight: 0 }}>
        <div style={{ padding: '14px 22px 6px' }}>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: 14, marginBottom: 4 }}>
            <span style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 54, lineHeight: 1, color: p.primary, letterSpacing: -1 }}>+</span>
            <span style={{ fontFamily: MONO, fontSize: 11, color: p.textMuted, letterSpacing: 1, textTransform: 'uppercase' }}>Optional add-on · NEW</span>
          </div>
          <h2 style={{ fontFamily: SANS, fontWeight: 700, fontSize: 24, margin: '4px 0 4px', letterSpacing: -0.3, lineHeight: 1.15 }}>
            How I know I'm not okay
          </h2>
          <p style={{ fontSize: 13.5, color: p.textMuted, margin: 0, lineHeight: 1.45 }}>
            Adapted from WRAP. Help the people around you spot trouble early — and know what actually helps you when they do.
          </p>
        </div>

        <div style={{ padding: '14px 22px 18px' }}>
          <Section
            icon={<Icon size={16} sw={2}><path d="M2 12h3M19 12h3M12 2v3M12 19v3M4.9 4.9l2.1 2.1M17 17l2.1 2.1M4.9 19.1l2.1-2.1M17 7l2.1-2.1"/><circle cx="12" cy="12" r="3"/></Icon>}
            title="Early warning signs"
            sub="The first things I notice when my mood starts shifting. Often subtle."
            items={['Sleeping past noon', 'Skipping meals', 'Cancelling plans', 'Re-reading old messages']}
          />
          <Section
            icon={<Icon size={16} sw={2}><path d="M12 2L4 6v6c0 5 3.5 8.5 8 10 4.5-1.5 8-5 8-10V6l-8-4z"/></Icon>}
            title="Triggers to watch for"
            sub="External things that have set off episodes before."
            accent={p.crisisAccent}
            chipKind="avoid"
            items={['Job loss', 'Anniversary of dad\'s death (Aug 14)', 'Long flights', 'Going off Lamictal']}
          />
          <Section
            icon={<Icon size={16} sw={2}><path d="M12 22s7-7 7-12a7 7 0 0 0-14 0c0 5 7 12 7 12z"/><circle cx="12" cy="10" r="2.5"/></Icon>}
            title="Things that genuinely help"
            sub="Specific, concrete. Not 'self-care' — what actually works for me."
            items={['Therapy dog visits', 'Cold showers', 'Calling my sister Jordan', 'Lo-fi playlist (saved)']}
          />
          <Section
            icon={<Icon size={16} sw={2}><circle cx="12" cy="12" r="9"/><path d="M8 14s1.5 2 4 2 4-2 4-2M9 9.5v.5M15 9.5v.5"/></Icon>}
            title="Things to say to me"
            sub="Words that ground me. Useful for staff, EMS, family."
            items={['"You\'re safe. This is temporary."', 'Use my name, not "ma\'am"', 'Mention my dog Bea']}
          />
          <Section
            icon={<Icon size={16} sw={2}><path d="M3 3l18 18"/><circle cx="12" cy="12" r="9"/></Icon>}
            title="Don't do these"
            sub="Approaches that escalate me. Be specific."
            accent={p.crisisAccent}
            chipKind="avoid"
            items={['Don\'t raise your voice', 'No physical restraints', 'No men-only staff if avoidable']}
          />

          <div style={{
            background: p.primaryTint, border: `1px solid ${p.primaryLight}`,
            borderRadius: 12, padding: 12, display: 'flex', gap: 10, marginTop: 4,
          }}>
            <Sparkles size={16} stroke={p.primary} />
            <div style={{ fontSize: 12, color: p.text, lineHeight: 1.4 }}>
              <strong>Heads up:</strong> this section is yours alone — it isn't required by PA Act 194, but in practice it's the part agents and ER staff read first.
            </div>
          </div>
        </div>
      </div>

      <BottomBar />
    </Screen>
  );
}

// 4b. Lock screen / Live Activity card
function ScrLockCard() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <Screen scroll={false} style={{ background: '#000', color: '#fff', fontFamily: SANS }}>
      {/* iOS-like lock screen */}
      <div style={{ height: GA_STATUSBAR_H }} />

      {/* Time */}
      <div style={{ textAlign: 'center', padding: '20px 0 6px', position: 'relative' }}>
        <div style={{ fontSize: 14, color: 'rgba(255,255,255,0.85)', fontWeight: 500 }}>Saturday, May 14</div>
        <div style={{ fontFamily: SERIF, fontSize: 88, lineHeight: 1, fontWeight: 200, letterSpacing: -2, marginTop: 4 }}>9:41</div>
      </div>

      {/* Live Activity for active crisis directive */}
      <div style={{ padding: '14px 14px 0' }}>
        <div style={{
          background: 'rgba(40,40,42,0.85)', backdropFilter: 'blur(20px)',
          borderRadius: 22, padding: 14, color: '#fff',
        }}>
          <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12 }}>
            <div style={{
              width: 38, height: 38, borderRadius: 10,
              background: p.primary, color: p.onPrimary,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}><Shield size={20} /></div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 10.5, fontWeight: 700, letterSpacing: 1, textTransform: 'uppercase', opacity: 0.7 }}>MHAD · Active directive</div>
              <div style={{ fontSize: 15, fontWeight: 600, marginTop: 2 }}>Alex M. Kowalski has a PA MHAD on file</div>
              <div style={{ fontSize: 12, opacity: 0.7, marginTop: 1 }}>Expires May 2028 · last updated 4 days ago</div>
            </div>
          </div>
          <div style={{ display: 'flex', gap: 6, marginTop: 12 }}>
            <button style={{
              flex: 1, background: 'rgba(255,255,255,0.12)', color: '#fff', border: 'none',
              padding: '9px 8px', borderRadius: 10, fontFamily: SANS, fontSize: 12, fontWeight: 600,
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6,
            }}><QR size={13} /> Show QR</button>
            <button style={{
              flex: 1, background: 'rgba(255,255,255,0.12)', color: '#fff', border: 'none',
              padding: '9px 8px', borderRadius: 10, fontFamily: SANS, fontSize: 12, fontWeight: 600,
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6,
            }}><Phone size={13} /> Call Jordan</button>
            <button style={{
              background: p.crisisAccent, color: '#fff', border: 'none',
              padding: '9px 12px', borderRadius: 10, fontFamily: SANS, fontSize: 12, fontWeight: 700,
            }}>988</button>
          </div>
        </div>

        {/* Notification: agent confirmed */}
        <div style={{
          marginTop: 8,
          background: 'rgba(40,40,42,0.85)', backdropFilter: 'blur(20px)',
          borderRadius: 18, padding: '12px 14px', color: '#fff',
          display: 'flex', gap: 12, alignItems: 'flex-start',
        }}>
          <div style={{
            width: 30, height: 30, borderRadius: 7, flexShrink: 0,
            background: '#fff', color: p.primaryDark,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}><Shield size={16} /></div>
          <div style={{ flex: 1 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
              <span style={{ fontSize: 13, fontWeight: 600 }}>MHAD</span>
              <span style={{ fontSize: 11, opacity: 0.6 }}>now</span>
            </div>
            <div style={{ fontSize: 13, opacity: 0.9, marginTop: 1, lineHeight: 1.35 }}>
              Jordan accepted as your primary agent. Tap to view the receipt.
            </div>
          </div>
        </div>

        {/* Notification: renewal */}
        <div style={{
          marginTop: 8,
          background: 'rgba(40,40,42,0.85)', backdropFilter: 'blur(20px)',
          borderRadius: 18, padding: '12px 14px', color: '#fff',
          display: 'flex', gap: 12, alignItems: 'flex-start',
        }}>
          <div style={{
            width: 30, height: 30, borderRadius: 7, flexShrink: 0,
            background: p.warnBg, color: p.warnText,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}><Calendar size={16} /></div>
          <div style={{ flex: 1 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
              <span style={{ fontSize: 13, fontWeight: 600 }}>MHAD</span>
              <span style={{ fontSize: 11, opacity: 0.6 }}>2h ago</span>
            </div>
            <div style={{ fontSize: 13, opacity: 0.9, marginTop: 1, lineHeight: 1.35 }}>
              Your directive renews in 30 days. Tap to review.
            </div>
          </div>
        </div>
      </div>

      {/* Lockscreen footer */}
      <div style={{ position: 'absolute', bottom: GA_HOME_H + 30, left: 0, right: 0, display: 'flex', justifyContent: 'space-between', padding: '0 30px' }}>
        <div style={{
          width: 44, height: 44, borderRadius: 22, background: 'rgba(255,255,255,0.15)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <Phone size={20} stroke="#fff" />
        </div>
        <div style={{
          width: 44, height: 44, borderRadius: 22, background: 'rgba(255,255,255,0.15)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <Icon size={20} stroke="#fff"><circle cx="12" cy="12" r="4"/><path d="M3 9l9-7 9 7v11a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1z"/></Icon>
        </div>
      </div>

      {/* Annotation overlay */}
      <div style={{
        position: 'absolute', top: 96, right: 14,
        background: p.primary, color: p.onPrimary,
        padding: '6px 9px', borderRadius: 6,
        fontFamily: MONO, fontSize: 9.5, fontWeight: 700, letterSpacing: 0.5,
        boxShadow: '0 4px 18px rgba(0,0,0,0.4)',
      }}>NEW · Live Activity</div>
    </Screen>
  );
}

// 4c. Facilitator mode — invite a peer to help
function ScrFacilitator() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <Screen>
      <CrisisBar compact />
      <div style={{ padding: '12px 22px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <span style={{ fontSize: 13, color: p.primary, fontWeight: 600, display: 'flex', alignItems: 'center', gap: 4 }}>
          <Icon d="M15 18l-6-6 6-6" size={16} /> Back
        </span>
      </div>

      <div style={{ padding: '12px 22px 100px' }}>
        <SectionLabel>Get help · evidence-based</SectionLabel>
        <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 38, margin: '4px 0 4px', fontWeight: 400, letterSpacing: -0.5, lineHeight: 1, marginTop: 4 }}>
          You don't have to do this alone.
        </h1>
        <p style={{ fontSize: 13.5, color: p.textMuted, margin: 0, lineHeight: 1.5 }}>
          People who fill this out with help finish it <strong style={{ color: p.text }}>far more often</strong>. Pick the kind of support that fits today.
        </p>

        <div style={{ height: 18 }} />

        {/* Three pathways */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          {[
            {
              icon: <Heart size={20} />,
              tag: 'Peer support specialist',
              title: 'Talk to someone who\'s been here',
              sub: 'Free PA peer-support and PAD-facilitation lines staffed by people with lived experience. We give you the numbers — you call when you\'re ready.',
              meta: ['Free', 'PA P&A · MHA-PA · NRC-PAD'],
              cta: 'See PA help lines',
              primary: true,
            },
            {
              icon: <Users size={20} />,
              tag: 'Someone I already trust',
              title: 'Review it with someone, in person',
              sub: 'Print your draft or hand them your phone and walk through it together. Nothing is sent anywhere — you stay in control of every field.',
              meta: ['In-person', 'Nothing leaves your device'],
              cta: 'Print draft to review',
            },
            {
              icon: <Brain size={20} />,
              tag: 'My care team',
              title: 'Email a draft to my clinician',
              sub: 'Send the PDF to your therapist or psychiatrist from your own mail app. They reply with comments; you type the changes in yourself.',
              meta: ['Opens your mail app', 'You make the edits'],
              cta: 'Send draft',
            },
          ].map((it, i) => (
            <div key={i} style={{
              background: it.primary ? p.primary : p.card,
              color: it.primary ? p.onPrimary : p.text,
              border: it.primary ? 'none' : `1px solid ${p.border}`,
              borderRadius: TOK.rCard, padding: 16, position: 'relative', overflow: 'hidden',
            }}>
              {it.primary && (
                <div style={{ position: 'absolute', right: -8, top: -20, fontFamily: SERIF, fontStyle: 'italic', fontSize: 64, color: 'rgba(255,255,255,0.10)', lineHeight: 1, pointerEvents: 'none' }}>PA</div>
              )}
              <div style={{ position: 'relative' }}>
                <div style={{
                  display: 'inline-flex', alignItems: 'center', gap: 6, marginBottom: 6,
                  fontFamily: MONO, fontSize: 10, fontWeight: 700, letterSpacing: 1, textTransform: 'uppercase',
                  color: it.primary ? 'rgba(255,255,255,0.85)' : p.primary,
                }}>{it.icon} {it.tag}</div>
                <div style={{ fontSize: 17, fontWeight: 700, lineHeight: 1.2, letterSpacing: -0.2 }}>{it.title}</div>
                <p style={{ margin: '4px 0 10px', fontSize: 13, opacity: it.primary ? 0.9 : 1, color: it.primary ? 'rgba(255,255,255,0.9)' : p.textMuted, lineHeight: 1.45 }}>
                  {it.sub}
                </p>
                <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, marginBottom: 12 }}>
                  {it.meta.map((m, j) => (
                    <span key={j} style={{
                      fontSize: 10.5, fontWeight: 600,
                      color: it.primary ? p.onPrimary : p.textMuted,
                      background: it.primary ? 'rgba(255,255,255,0.18)' : p.surface,
                      padding: '3px 8px', borderRadius: 100, fontFamily: MONO, letterSpacing: 0.4, textTransform: 'uppercase',
                    }}>{m}</span>
                  ))}
                </div>
                <button style={{
                  background: it.primary ? '#fff' : 'transparent',
                  color: it.primary ? p.primaryDark : p.primary,
                  border: it.primary ? 'none' : `1.5px solid ${p.primary}`,
                  borderRadius: 10, padding: '9px 14px', fontSize: 13.5, fontWeight: 700,
                  display: 'inline-flex', alignItems: 'center', gap: 6, fontFamily: SANS,
                }}>
                  {it.cta} <Arrow size={14} />
                </button>
              </div>
            </div>
          ))}
        </div>

        <div style={{ height: 14 }} />
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '12px', background: p.surface, borderRadius: 12, border: `1px solid ${p.border}` }}>
          <Info size={16} stroke={p.textMuted} />
          <span style={{ flex: 1, fontSize: 12, color: p.textMuted, lineHeight: 1.4 }}>
            Prefer to do it yourself? <strong style={{ color: p.text }}>That's fine</strong> — keep going from where you left off.
          </span>
          <span style={{ fontSize: 12, color: p.primary, fontWeight: 700 }}>Skip →</span>
        </div>
      </div>
    </Screen>
  );
}

// 4d. Clinician view — what a doctor sees
function ScrClinicianView() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <Screen>
      {/* Clinician banner */}
      <div style={{
        padding: `${GA_STATUSBAR_H + 8}px 22px 12px`,
        background: p.primaryDark, color: '#fff',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <div style={{ width: 6, height: 6, borderRadius: 100, background: p.crisisAccent }} />
          <span style={{ fontFamily: MONO, fontSize: 10.5, fontWeight: 700, letterSpacing: 1, textTransform: 'uppercase' }}>Read-only · 30-sec summary</span>
        </div>
        {/* Same surface, two audiences — clinician here, paramedic when scanned from the wallet QR */}
        <div style={{ display: 'flex', gap: 6, marginTop: 8 }}>
          {[
            { id: 'clinician', label: 'Clinician', active: true },
            { id: 'paramedic', label: 'Paramedic (from QR)', active: false },
          ].map((a) => (
            <span key={a.id} style={{
              fontSize: 11, fontWeight: 700, fontFamily: SANS,
              padding: '4px 10px', borderRadius: 100,
              background: a.active ? '#fff' : 'rgba(255,255,255,0.14)',
              color: a.active ? p.primaryDark : 'rgba(255,255,255,0.85)',
            }}>{a.label}</span>
          ))}
        </div>
        <div style={{ marginTop: 8, fontFamily: SERIF, fontStyle: 'italic', fontSize: 26, letterSpacing: -0.3, fontWeight: 400 }}>
          Alex M. Kowalski · DOB 06/14/89
        </div>
        <div style={{ fontSize: 12, opacity: 0.8, marginTop: 2 }}>
          PA MHAD · signed 05/14/26 · valid through 05/14/28
        </div>
      </div>

      <div style={{ padding: '14px 22px 30px' }}>
        {/* Hard limits — what you cannot do */}
        <div style={{
          background: p.crisisBg, border: `1px solid ${p.crisisBorder}`,
          borderRadius: 12, padding: 12, marginBottom: 10,
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 6 }}>
            <X size={14} stroke={p.crisisText} sw={3} />
            <span style={{ fontFamily: MONO, fontSize: 10, fontWeight: 700, letterSpacing: 0.8, color: p.crisisText, textTransform: 'uppercase' }}>Do not</span>
          </div>
          <ul style={{ margin: 0, padding: '0 0 0 16px', fontSize: 13, color: p.crisisText, lineHeight: 1.5 }}>
            <li><strong>Haloperidol (Haldol)</strong> — severe dystonia history</li>
            <li><strong>Physical restraints</strong> — unless imminent danger</li>
            <li><strong>ECT</strong> — only with Jordan Lee's verbal consent</li>
            <li><strong>Male-only staffing</strong> if avoidable</li>
          </ul>
        </div>

        {/* Preferred treatment */}
        <div style={{
          background: p.okBg, border: `1px solid ${p.okBorder}`,
          borderRadius: 12, padding: 12, marginBottom: 10,
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 6 }}>
            <Check size={14} stroke={p.okText} sw={3} />
            <span style={{ fontFamily: MONO, fontSize: 10, fontWeight: 700, letterSpacing: 0.8, color: p.okText, textTransform: 'uppercase' }}>Prefers</span>
          </div>
          <ul style={{ margin: 0, padding: '0 0 0 16px', fontSize: 13, color: p.okText, lineHeight: 1.5 }}>
            <li><strong>Sertraline 100mg AM</strong>, Lamotrigine 200mg BID — current</li>
            <li><strong>UPMC Western Psych</strong> if admission needed</li>
            <li>Quiet single room · therapy-dog visits permitted</li>
          </ul>
        </div>

        {/* Decision authority */}
        <div style={{
          background: p.card, border: `1.5px solid ${p.primary}`,
          borderRadius: 12, padding: 12, marginBottom: 14,
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 8 }}>
            <Users size={14} stroke={p.primary} />
            <span style={{ fontFamily: MONO, fontSize: 10, fontWeight: 700, letterSpacing: 0.8, color: p.primary, textTransform: 'uppercase' }}>Who to call · in order</span>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            {[
              { n: '1', name: 'Jordan Lee', rel: 'Sister · primary agent', phone: '(412) 555-0188' },
              { n: '2', name: 'Sam Reyes', rel: 'Spouse · alternate', phone: '(412) 555-0177' },
              { n: '3', name: 'Dr. R. Patel', rel: 'Psychiatrist · UPMC', phone: '(412) 555-0102' },
            ].map((c, i) => (
              <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                <div style={{
                  width: 22, height: 22, borderRadius: 100, flexShrink: 0,
                  background: p.primary, color: p.onPrimary,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontFamily: MONO, fontSize: 11, fontWeight: 700,
                }}>{c.n}</div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 13, fontWeight: 600 }}>{c.name}</div>
                  <div style={{ fontSize: 11.5, color: p.textMuted }}>{c.rel}</div>
                </div>
                <div style={{ fontFamily: MONO, fontSize: 11.5, color: p.primary, fontWeight: 600 }}>{c.phone}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Warning signs */}
        <div style={{ marginBottom: 14 }}>
          <SectionLabel>Patient-described warning signs</SectionLabel>
          <p style={{ fontSize: 12.5, color: p.textMuted, margin: '6px 0 0', lineHeight: 1.5 }}>
            "Sleeping past noon · skipping meals · cancelling plans · re-reading old messages."
          </p>
        </div>

        <div style={{ marginBottom: 4 }}>
          <SectionLabel>Patient asks to be told</SectionLabel>
          <p style={{ fontSize: 12.5, color: p.text, margin: '6px 0 0', lineHeight: 1.5, fontStyle: 'italic' }}>
            "You're safe. This is temporary." Use my first name. Mention my dog Bea.
          </p>
        </div>

        <div style={{ height: 12 }} />
        <div style={{ display: 'flex', gap: 8 }}>
          <Btn kind="outline" leading={<Download size={14} />} style={{ flex: 1 }}>Full PDF</Btn>
          <Btn kind="outline" leading={<FileText size={14} />} style={{ flex: 1 }}>Legal text</Btn>
          <Btn kind="dark" leading={<Phone size={14} />} style={{ flex: 1 }}>Call agent</Btn>
        </div>
        <p style={{ fontSize: 10.5, color: p.textMuted, fontFamily: MONO, marginTop: 10, textAlign: 'center', letterSpacing: 0.4 }}>
          SCANNED FROM WALLET CARD · READ-ONLY · NO COPY IS STORED
        </p>
      </div>
    </Screen>
  );
}

// 4e. Plain English ⇄ Legal toggle
function ScrLegalToggle() {
  const { palette: p } = React.useContext(MHADContext);
  const [mode, setMode] = React.useState('plain');

  const plain = (
    <div style={{ fontSize: 14.5, color: p.text, lineHeight: 1.55 }}>
      <p style={{ margin: '0 0 12px' }}>I'm Alex M. Kowalski, and this is my mental health advance directive.</p>
      <p style={{ margin: '0 0 12px' }}>If two doctors decide I can't make my own treatment decisions, here's what I want.</p>
      <p style={{ margin: '0 0 12px' }}><strong>Jordan Lee, my sister</strong>, should make decisions for me. If she can't, my spouse <strong>Sam Reyes</strong>.</p>
      <p style={{ margin: '0 0 12px' }}>I do not want Haldol. I have had a bad reaction. Other antipsychotics are okay if Jordan agrees.</p>
      <p style={{ margin: '0 0 0' }}>If admitted, I prefer UPMC Western Psych. ECT only if Jordan says yes.</p>
    </div>
  );

  const legal = (
    <div style={{ fontSize: 13, color: p.text, lineHeight: 1.7, fontFamily: SERIF, letterSpacing: 0.1 }}>
      <p style={{ margin: '0 0 10px' }}>
        I, <strong>ALEX M. KOWALSKI</strong>, being of sound mind and at least eighteen (18) years of age, do hereby execute this Mental Health Advance Directive pursuant to the Mental Health Care Act, 20 Pa.C.S. Ch. 58 (Act 194 of 2004).
      </p>
      <p style={{ margin: '0 0 10px' }}>
        This Directive shall become effective upon a determination, by examination by a psychiatrist and one of the following — another psychiatrist, psychologist, family physician, attending physician or mental health treatment professional — that I am incapable of making mental health care decisions. Whenever possible, one of the decision makers will be one of my treating professionals.
      </p>
      <p style={{ margin: '0 0 10px' }}>
        I hereby appoint <strong>JORDAN LEE</strong>, my sister, as my mental health care agent, with the authority set forth in 20 Pa.C.S. § 5836. In the event my primary agent is unavailable, I appoint <strong>SAM REYES</strong>, my spouse, as alternate agent.
      </p>
      <p style={{ margin: '0 0 0' }}>
        This declaration may be revoked in whole or in part at any time, either orally or in writing, as long as I have not been found to be incapable of making mental health decisions…
      </p>
    </div>
  );

  return (
    <Screen>
      <CrisisBar compact />
      <div style={{ padding: '12px 22px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <span style={{ fontSize: 13, color: p.primary, fontWeight: 600, display: 'flex', alignItems: 'center', gap: 4 }}>
          <Icon d="M15 18l-6-6 6-6" size={16} /> Done
        </span>
        <span style={{ fontSize: 13, color: p.primary, fontWeight: 600, display: 'flex', alignItems: 'center', gap: 4 }}>
          <Share size={15} stroke={p.primary} /> Share
        </span>
      </div>

      <div style={{ padding: '8px 22px 22px' }}>
        <SectionLabel>Your directive · two registers</SectionLabel>
        <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 32, margin: '4px 0 4px', fontWeight: 400, letterSpacing: -0.4, lineHeight: 1 }}>
          Same meaning, two voices.
        </h1>
        <p style={{ fontSize: 13, color: p.textMuted, margin: 0, lineHeight: 1.45 }}>
          What you wrote, and what a court or hospital will read.
        </p>

        {/* Toggle */}
        <div style={{
          display: 'flex', background: p.surface, borderRadius: 100, padding: 4,
          marginTop: 16, border: `1px solid ${p.border}`,
        }}>
          {[
            { id: 'plain', label: 'Plain English', icon: <Heart size={13} /> },
            { id: 'legal', label: 'Legal language', icon: <FileText size={13} /> },
          ].map((opt) => (
            <button key={opt.id} onClick={() => setMode(opt.id)} style={{
              flex: 1, background: mode === opt.id ? p.card : 'transparent',
              border: 'none', borderRadius: 100, padding: '9px 12px',
              fontSize: 13, fontWeight: 600, color: mode === opt.id ? p.text : p.textMuted,
              boxShadow: mode === opt.id ? '0 1px 3px rgba(0,0,0,0.06)' : 'none',
              fontFamily: SANS, cursor: 'pointer',
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6,
            }}>{opt.icon} {opt.label}</button>
          ))}
        </div>

        {/* Content */}
        <div style={{
          marginTop: 16, background: p.card, border: `1px solid ${p.border}`,
          borderRadius: TOK.rCard, padding: 18, minHeight: 340, position: 'relative',
        }}>
          {mode === 'legal' && (
            <div style={{
              display: 'flex', alignItems: 'center', gap: 8, marginBottom: 14,
              padding: '8px 10px', background: p.warnBg, border: `1px solid ${p.warnBorder}`,
              borderRadius: 8,
            }}>
              <AlertTri size={14} stroke={p.warnText} />
              <span style={{ fontSize: 11, color: p.warnText, lineHeight: 1.35, fontWeight: 600 }}>
                DRAFT · not yet attorney-reviewed. This rendering is a preview, not the certified legal text.
              </span>
            </div>
          )}
          {mode === 'plain' ? plain : legal}
        </div>

        <div style={{
          marginTop: 10, display: 'flex', alignItems: 'center', gap: 8,
          padding: '10px 12px', background: p.primaryTint, border: `1px solid ${p.primaryLight}`, borderRadius: 10,
        }}>
          <Info size={15} stroke={p.primary} />
          <span style={{ fontSize: 12, color: p.text, flex: 1, lineHeight: 1.4 }}>
            Plain English is exactly what you wrote and will sign. The Legal rendering is generated to help you check wording — the version your court or facility reads is the signed PDF.
          </span>
        </div>
      </div>
    </Screen>
  );
}

// 4f. Self-binding (Ulysses) clause
function ScrUlysses() {
  const { palette: p } = React.useContext(MHADContext);
  const [enabled, setEnabled] = React.useState(true);
  const [confirmOpen, setConfirmOpen] = React.useState(false);

  // Turning it ON passes through a confirmation gate pointing to facilitator
  // support. Turning it OFF is immediate.
  const requestToggle = () => {
    if (enabled) setEnabled(false);
    else setConfirmOpen(true);
  };

  return (
    <Screen>
      <CrisisBar compact />
      <WizardHeader />
      <div style={{ padding: '4px 22px 0', display: 'flex', justifyContent: 'center' }}>
        <span style={{
          fontFamily: MONO, fontSize: 10, fontWeight: 700, letterSpacing: 0.8,
          color: p.primary, background: p.primaryTint, border: `1px solid ${p.primaryLight}`,
          padding: '4px 10px', borderRadius: 100, textTransform: 'uppercase',
        }}>Optional add-on · reachable from Step 10, Home & Settings</span>
      </div>

      <div style={{ padding: '14px 22px 30px' }}>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 14, marginBottom: 4 }}>
          <span style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 54, lineHeight: 1, color: p.primary, letterSpacing: -1 }}>+</span>
          <span style={{ fontFamily: MONO, fontSize: 11, color: p.textMuted, letterSpacing: 1, textTransform: 'uppercase' }}>Optional add-on · OPTIONAL</span>
        </div>
        <h2 style={{ fontFamily: SANS, fontWeight: 700, fontSize: 24, margin: '4px 0 4px', letterSpacing: -0.3, lineHeight: 1.15 }}>
          If future-me refuses…
        </h2>
        <p style={{ fontSize: 13.5, color: p.textMuted, margin: 0, lineHeight: 1.45 }}>
          Sometimes during a crisis, people refuse treatment that they\'d want when well. You can tell your future self: <em>honor what I wrote today, even if I argue.</em>
        </p>

        <div style={{ height: 20 }} />

        {/* Big toggle card */}
        <div style={{
          background: enabled ? p.primary : p.card,
          color: enabled ? p.onPrimary : p.text,
          border: enabled ? 'none' : `1px solid ${p.border}`,
          borderRadius: TOK.rCard, padding: 18, position: 'relative', overflow: 'hidden',
        }}>
          <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between' }}>
            <div style={{ flex: 1 }}>
              <div style={{ fontFamily: MONO, fontSize: 10, fontWeight: 700, letterSpacing: 1, textTransform: 'uppercase', opacity: 0.8 }}>
                Self-binding clause · "Ulysses"
              </div>
              <div style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 24, lineHeight: 1.15, fontWeight: 400, marginTop: 4, letterSpacing: -0.3 }}>
                Tie myself to the mast.
              </div>
            </div>
            <div onClick={requestToggle} style={{
              width: 50, height: 30, borderRadius: 100, flexShrink: 0,
              background: enabled ? 'rgba(255,255,255,0.25)' : p.border,
              padding: 3, cursor: 'pointer', transition: 'all 0.2s',
            }}>
              <div style={{
                width: 24, height: 24, borderRadius: 100, background: '#fff',
                transform: enabled ? 'translateX(20px)' : 'translateX(0)',
                transition: 'transform 0.2s',
              }} />
            </div>
          </div>
          <p style={{ fontSize: 13, opacity: 0.9, margin: '10px 0 0', lineHeight: 1.5 }}>
            Under PA Act 194, once two qualified professionals find me unable to make mental health decisions, I <strong>cannot revoke this directive</strong> until my capacity returns. The wishes I wrote here are followed even if I object in the moment. Acknowledging this is how the protection takes effect.
          </p>
        </div>

        {/* The fine print, beautifully */}
        <div style={{ marginTop: 16 }}>
          <SectionLabel>Boundaries on this clause</SectionLabel>
          <div style={{ marginTop: 10, display: 'flex', flexDirection: 'column', gap: 10 }}>
            {[
              { label: 'Applies only after two qualified professionals find me unable to make mental health decisions', val: true },
              { label: 'Covers the treatment instructions and agent authority set in this directive', val: true },
              { label: 'Ends 2 years after signing — unless I am incapable at that time, when it stays in effect', val: true },
              { label: 'A court-appointed guardian may revoke, suspend or terminate it', val: true },
              { label: 'My capacity is re-examined; the protection lifts when capacity returns', val: true },
            ].map((row, i) => (
              <div key={i} style={{ display: 'flex', alignItems: 'flex-start', gap: 10 }}>
                <div style={{
                  width: 18, height: 18, borderRadius: 5, flexShrink: 0, marginTop: 1,
                  background: p.primary, color: p.onPrimary,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}><Check size={11} sw={3} stroke={p.onPrimary} /></div>
                <span style={{ fontSize: 13, color: p.text, lineHeight: 1.45 }}>{row.label}</span>
              </div>
            ))}
          </div>
        </div>

        <div style={{
          marginTop: 16, display: 'flex', gap: 10,
          padding: '12px', background: p.warnBg, border: `1px solid ${p.warnBorder}`, borderRadius: 10,
        }}>
          <Info size={16} stroke={p.warnText} />
          <span style={{ fontSize: 12, color: p.warnText, flex: 1, lineHeight: 1.45 }}>
            This is a significant decision. We strongly recommend talking it through with a peer specialist or your clinician before enabling.
          </span>
        </div>
      </div>

      {/* Confirmation gate — fires when turning the clause ON */}
      {confirmOpen && (
        <div style={{
          position: 'absolute', inset: 0, zIndex: 20,
          background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'flex-end',
        }}>
          <div style={{
            background: p.card, borderRadius: `${TOK.rSheet}px ${TOK.rSheet}px 0 0`,
            padding: '14px 22px 40px', width: '100%', boxSizing: 'border-box',
            boxShadow: '0 -10px 40px rgba(0,0,0,0.35)',
          }}>
            <div style={{ width: 40, height: 4, background: p.border, borderRadius: 100, margin: '0 auto 16px' }} />
            <div style={{
              width: 44, height: 44, borderRadius: 12, marginBottom: 12,
              background: p.warnBg, color: p.warnText,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}><AlertTri size={22} stroke={p.warnText} /></div>
            <h3 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 26, margin: '0 0 6px', fontWeight: 400, letterSpacing: -0.4, lineHeight: 1.1 }}>
              Before you bind future-you
            </h3>
            <p style={{ fontSize: 13.5, color: p.textMuted, margin: 0, lineHeight: 1.5 }}>
              A self-binding clause lets your care team treat you <strong style={{ color: p.text }}>over your objection</strong> during a future crisis. It's powerful and hard to undo in the moment. Most people talk it through with someone first.
            </p>

            <div style={{
              marginTop: 14, display: 'flex', alignItems: 'center', gap: 10,
              padding: '12px', background: p.primaryTint, border: `1px solid ${p.primaryLight}`, borderRadius: 12,
            }}>
              <Heart size={16} stroke={p.primary} />
              <span style={{ flex: 1, fontSize: 12.5, color: p.text, lineHeight: 1.4 }}>
                Talk it through first — a peer specialist or your clinician can help.
              </span>
              <span style={{ fontSize: 12, fontWeight: 700, color: p.primary }}>Get help ›</span>
            </div>

            <div style={{ height: 16 }} />
            <Btn kind="primary" size="lg" full onClick={() => { setEnabled(true); setConfirmOpen(false); }}>
              I understand — turn it on
            </Btn>
            <div style={{ height: 8 }} />
            <Btn kind="ghost" full onClick={() => setConfirmOpen(false)}>Not now</Btn>
          </div>
        </div>
      )}
    </Screen>
  );
}

// 4g. Agent acceptance receipt
function ScrAgentAccept() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <Screen>
      <div style={{ height: GA_STATUSBAR_H }} />

      <div style={{ padding: '20px 22px 30px' }}>
        <div style={{
          width: 64, height: 64, borderRadius: 16,
          background: p.okBg, color: p.okText,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          marginBottom: 14,
        }}><Check size={32} sw={3} stroke={p.okText} /></div>

        <SectionLabel style={{ color: p.okText }}>● Acceptance confirmed</SectionLabel>
        <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 40, margin: '4px 0 6px', fontWeight: 400, letterSpacing: -0.6, lineHeight: 1 }}>
          Jordan is now your agent.
        </h1>
        <p style={{ fontSize: 14, color: p.textMuted, margin: 0, lineHeight: 1.5 }}>
          She read your directive in full and accepted on Saturday, May 14 at 2:08 PM. A signed receipt is in your records.
        </p>

        <div style={{ height: 22 }} />

        {/* Receipt card */}
        <div style={{
          background: p.card, border: `1px solid ${p.border}`,
          borderRadius: TOK.rCard, padding: 16, position: 'relative',
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 12 }}>
            <div style={{
              width: 44, height: 44, borderRadius: 100,
              background: p.primary, color: p.onPrimary,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontFamily: SANS, fontWeight: 700, fontSize: 15,
            }}>JL</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 15, fontWeight: 700 }}>Jordan Lee</div>
              <div style={{ fontSize: 12, color: p.textMuted }}>Primary agent · sister</div>
            </div>
            <Badge tone="ok">Verified</Badge>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: 10, fontSize: 12.5 }}>
            {[
              ['Reviewed the directive', 'All 11 sections opened'],
              ['Acknowledged duties', 'All 5 acknowledgments checked'],
              ['Signature captured', 'Drawn on this device'],
              ['Accepted at', 'Sat May 14, 2026 · 2:08 PM EDT'],
            ].map((r, i) => (
              <div key={i} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', borderBottom: i < 3 ? `1px dashed ${p.border}` : 'none', paddingBottom: 8 }}>
                <span style={{ color: p.textMuted }}>{r[0]}</span>
                <span style={{ fontWeight: 600, color: p.text, textAlign: 'right', maxWidth: '60%' }}>{r[1]}</span>
              </div>
            ))}
          </div>

          {/* Signature scrawl */}
          <div style={{ marginTop: 12, padding: '8px 12px', background: p.surface, borderRadius: 8 }}>
            <div style={{ fontSize: 10.5, fontFamily: MONO, color: p.textMuted, letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 4 }}>Agent signature</div>
            <svg width="100%" height="36" viewBox="0 0 280 36" preserveAspectRatio="xMidYMid meet">
              <path d="M10 24 C 25 8, 40 30, 55 18 S 90 24, 110 12 C 130 4, 145 28, 165 20 S 200 22, 220 14 C 235 8, 250 26, 268 18" stroke={p.text} strokeWidth="1.8" fill="none" strokeLinecap="round" />
            </svg>
          </div>
        </div>

        <div style={{ height: 14 }} />
        <div style={{
          background: p.primaryTint, border: `1px solid ${p.primaryLight}`,
          borderRadius: 12, padding: 12, display: 'flex', gap: 10,
        }}>
          <Sparkles size={16} stroke={p.primary} />
          <div style={{ flex: 1, fontSize: 12.5, color: p.text, lineHeight: 1.45 }}>
            We sent Jordan a one-page <strong>"How to use this directive"</strong> guide for agents. You can resend or message her about it.
          </div>
        </div>

        <div style={{ height: 16 }} />
        <div style={{ display: 'flex', gap: 8 }}>
          <Btn kind="outline" leading={<Download size={14} />} style={{ flex: 1 }}>Receipt PDF</Btn>
          <Btn kind="primary" trailing={<Arrow size={14} />} style={{ flex: 1 }}>Done</Btn>
        </div>
      </div>
    </Screen>
  );
}

// 4h. Accessibility settings
function ScrA11y() {
  const { palette: p } = React.useContext(MHADContext);
  const [size, setSize] = React.useState(1);
  const [dyslexia, setDyslexia] = React.useState(false);
  const [lang, setLang] = React.useState('en');

  const Toggle = ({ on, onClick }) => (
    <div onClick={onClick} style={{
      width: 44, height: 26, borderRadius: 100, flexShrink: 0,
      background: on ? p.primary : p.border,
      padding: 3, cursor: 'pointer', transition: 'all 0.2s',
    }}>
      <div style={{
        width: 20, height: 20, borderRadius: 100, background: '#fff',
        transform: on ? 'translateX(18px)' : 'translateX(0)',
        transition: 'transform 0.2s',
        boxShadow: '0 1px 3px rgba(0,0,0,0.15)',
      }} />
    </div>
  );

  const Row = ({ label, sub, trailing, phase, osLink }) => (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12,
      padding: '12px 14px', background: p.card, border: `1px solid ${p.border}`,
      borderRadius: 12, marginBottom: 8, opacity: phase === 2 ? 0.62 : 1,
    }}>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 14, fontWeight: 600, color: p.text, display: 'flex', alignItems: 'center', gap: 7 }}>
          {label}
          {phase === 2 && (
            <span style={{ fontFamily: MONO, fontSize: 8.5, fontWeight: 700, letterSpacing: 0.5, color: p.textMuted, background: p.surface, border: `1px solid ${p.border}`, padding: '1px 5px', borderRadius: 3 }}>PHASE 2</span>
          )}
        </div>
        {sub && <div style={{ fontSize: 11.5, color: p.textMuted, marginTop: 2, lineHeight: 1.35 }}>{sub}</div>}
      </div>
      {osLink
        ? <Icon size={16} stroke={p.textMuted}><path d="M7 17L17 7M9 7h8v8"/></Icon>
        : trailing}
    </div>
  );

  return (
    <Screen>
      <CrisisBar compact />
      <div style={{ padding: '14px 22px 30px' }}>
        <span style={{ fontSize: 13, color: p.primary, fontWeight: 600, display: 'inline-flex', alignItems: 'center', gap: 4 }}>
          <Icon d="M15 18l-6-6 6-6" size={16} /> Settings
        </span>
        <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 36, margin: '8px 0 4px', fontWeight: 400, letterSpacing: -0.5, lineHeight: 1.05 }}>
          Make it readable.
        </h1>
        <p style={{ fontSize: 13, color: p.textMuted, margin: 0, lineHeight: 1.45 }}>
          Adjust how the app feels for you. Changes apply everywhere instantly.
        </p>

        <div style={{ height: 20 }} />

        {/* Text size slider */}
        <SectionLabel>Text size</SectionLabel>
        <div style={{
          marginTop: 8, background: p.card, border: `1px solid ${p.border}`, borderRadius: 12,
          padding: 14,
        }}>
          <div style={{
            fontSize: 13 + size * 4, color: p.text, marginBottom: 14, lineHeight: 1.4,
            fontFamily: dyslexia ? "'Atkinson Hyperlegible', " + SANS : SANS,
          }}>
            People who I trust will make my decisions if I can't.
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <span style={{ fontSize: 11, color: p.textMuted, fontFamily: MONO }}>A</span>
            <div style={{ flex: 1, height: 4, background: p.border, borderRadius: 100, position: 'relative' }}>
              <div style={{ position: 'absolute', left: 0, top: 0, height: 4, width: `${(size / 3) * 100}%`, background: p.primary, borderRadius: 100 }} />
              <div style={{ position: 'absolute', left: `calc(${(size / 3) * 100}% - 11px)`, top: -8, width: 22, height: 22, borderRadius: 100, background: '#fff', border: `2px solid ${p.primary}` }} />
            </div>
            <span style={{ fontSize: 18, color: p.textMuted, fontFamily: MONO }}>A</span>
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 6, fontFamily: MONO, fontSize: 9.5, color: p.textMuted, letterSpacing: 0.5 }}>
            <span>SMALL</span><span>DEFAULT</span><span>LARGE</span><span>HUGE</span>
          </div>
        </div>

        <div style={{ height: 18 }} />
        <SectionLabel>Reading</SectionLabel>
        <div style={{ marginTop: 8 }}>
          <Row label="Dyslexia-friendly font" sub="Atkinson Hyperlegible · bundled, swaps at runtime" trailing={<Toggle on={dyslexia} onClick={() => setDyslexia(!dyslexia)} />} />
          <Row label="Read aloud" sub="Reads article body + section headers · uses your device's voice" trailing={<Toggle on={true} />} />
          <Row label="Reduce motion" sub="No transitions, no parallax" trailing={<Toggle on={false} />} />
          <Row label="High contrast" sub="Switches to a higher-separation palette variant" trailing={<Toggle on={false} />} />
        </div>

        <div style={{ height: 18 }} />
        <SectionLabel>Language</SectionLabel>
        <div style={{
          marginTop: 8, background: p.card, border: `1px solid ${p.border}`,
          borderRadius: 12, padding: 6, display: 'flex', gap: 4,
        }}>
          {[
            { id: 'en', label: 'English' },
            { id: 'es', label: 'Español' },
            { id: 'zh', label: '中文' },
            { id: 'ar', label: 'العربية' },
          ].map((l) => (
            <button key={l.id} onClick={() => setLang(l.id)} style={{
              flex: 1, background: lang === l.id ? p.primary : 'transparent',
              color: lang === l.id ? p.onPrimary : p.text,
              border: 'none', borderRadius: 8, padding: '8px 6px',
              fontSize: 12.5, fontWeight: 600, fontFamily: SANS, cursor: 'pointer',
              opacity: l.id === 'ar' ? 0.62 : 1,
            }}>{l.label}</button>
          ))}
        </div>
        <p style={{ fontSize: 11, color: p.textMuted, marginTop: 6, fontStyle: 'italic', lineHeight: 1.4 }}>
          Spanish &amp; Chinese ship first; <strong>Arabic is Phase 2</strong> — it flips the whole app to right-to-left, so it lands after the RTL layout pass. Legal text always renders in English to preserve PA Act 194 wording.
        </p>

        <div style={{ height: 18 }} />
        <SectionLabel>Hardware · uses your phone's settings</SectionLabel>
        <div style={{ marginTop: 8 }}>
          <Row label="VoiceOver hints" sub="Extra context we add for every control" trailing={<Toggle on={true} />} />
          <Row label="Switch Control" sub="Works automatically — our focus rings follow your phone's setting" osLink />
          <Row label="Hearing aid pairing" sub="Opens your phone's Bluetooth settings" osLink />
        </div>

        <div style={{
          marginTop: 12, background: p.surface, border: `1px dashed ${p.border}`,
          borderRadius: 10, padding: 12, display: 'flex', gap: 10,
        }}>
          <Info size={15} stroke={p.textMuted} />
          <span style={{ fontSize: 11.5, color: p.textMuted, lineHeight: 1.45 }}>
            Rows with <strong>↗</strong> hand off to your phone's own accessibility settings — we don't duplicate them. <strong>Phase 2</strong> items ship in a later release.
          </span>
        </div>
      </div>
    </Screen>
  );
}

// ─── ROUTER ───────────────────────────────────────────────────────────
function GapScreens({ name }) {
  return (
    <Surface kind="android">
    <AndroidShell width={422} height={860}>
      {(() => {
        switch (name) {
          case 'crisisplan': return <ScrCrisisPlan />;
          case 'lockcard':   return <ScrLockCard />;
          case 'facilitator':return <ScrFacilitator />;
          case 'clinician':  return <ScrClinicianView />;
          case 'legaltoggle':return <ScrLegalToggle />;
          case 'ulysses':    return <ScrUlysses />;
          case 'agentaccept':return <ScrAgentAccept />;
          case 'a11y':       return <ScrA11y />;
          default: return null;
        }
      })()}
    </AndroidShell>
    </Surface>
  );
}

Object.assign(window, {
  ResearchCard, GapMatrix, PriorityRoadmap, GapScreens,
});
