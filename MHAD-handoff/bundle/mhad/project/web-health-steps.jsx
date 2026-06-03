// web-health-steps.jsx — Desktop wizard layouts for the three new steps:
// Diagnoses (ICD-10), Allergies (RxTerms), Medications (current + preferences).
// Reuses AutoComplete / HealthChip / SearchField from health-steps.jsx.

// ─── Shared desktop wizard chrome ─────────────────────────────────────
function WebHealthShell({ stepN, current, title, subtitle, children, aiPanel, footer }) {
  const { palette: p } = React.useContext(MHADContext);

  const STEPS = [
    ['01', 'About you', 'done'],
    ['02', 'When this kicks in', 'done'],
    ['03', 'People I trust', 'done'],
    ['04', 'Guardian', 'done'],
    ['05', 'Where I want care', 'done'],
    ['06', 'Diagnoses', stepN === 6 ? 'current' : (stepN > 6 ? 'done' : '')],
    ['07', 'Medications', stepN === 7 ? 'current' : (stepN > 7 ? 'done' : '')],
    ['08', 'Allergies', stepN === 8 ? 'current' : (stepN > 8 ? 'done' : '')],
    ['09', 'Procedures', stepN === 9 ? 'current' : (stepN > 9 ? 'done' : '')],
    ['10', 'Anything else', stepN === 10 ? 'current' : (stepN > 10 ? 'done' : '')],
    ['11', 'Review', stepN === 11 ? 'current' : ''],
  ];

  return (
    <>
      <WebSidebar active="home" />
      <div style={{ flex: 1, overflow: 'auto' }}>
        {/* Top progress bar */}
        <div style={{
          display: 'flex', alignItems: 'center', gap: 16,
          padding: '14px 32px', borderBottom: `1px solid ${p.border}`,
          background: p.card,
        }}>
          <span style={{ fontSize: 13, color: p.textMuted, display: 'flex', alignItems: 'center', gap: 6 }}>
            <Icon d="M15 18l-6-6 6-6" size={14} /> My MHAD
          </span>
          <div style={{ flex: 1, height: 6, background: p.border, borderRadius: 100, overflow: 'hidden', maxWidth: 380 }}>
            <div style={{ height: '100%', width: `${(stepN / 11) * 100}%`, background: p.primary, borderRadius: 100 }} />
          </div>
          <span style={{ fontSize: 12, color: p.textMuted, fontFamily: MONO }}>{stepN} / 11</span>
          <div style={{ flex: 1 }} />
          <TabOnlyPill />
          <Btn kind="ghost" size="sm" leading={<Download size={13} />}>Download draft</Btn>
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: '180px 1fr 320px', gap: 0, minHeight: 'calc(100% - 56px)' }}>
          {/* Step rail */}
          <div style={{ padding: '32px 0 32px 24px', borderRight: `1px solid ${p.border}` }}>
            {STEPS.map(([n, label, state]) => (
              <div key={n} style={{
                display: 'flex', alignItems: 'center', gap: 8, padding: '7px 12px 7px 0',
                fontSize: 12.5, fontWeight: state === 'current' ? 700 : 500,
                color: state === 'current' ? p.text : (state === 'done' ? p.text : p.textMuted),
                borderLeft: `3px solid ${state === 'current' ? p.primary : 'transparent'}`,
                paddingLeft: state === 'current' ? 9 : 12,
                marginLeft: state === 'current' ? -3 : 0,
              }}>
                <span style={{ fontFamily: MONO, fontSize: 10.5, opacity: state ? 0.7 : 0.4, width: 18 }}>{n}</span>
                <span style={{ flex: 1 }}>{label}</span>
                {state === 'done' && <Check size={12} stroke={p.primary} sw={3} />}
              </div>
            ))}
          </div>

          {/* Main form */}
          <div style={{ padding: '36px 40px 80px', overflow: 'auto', position: 'relative' }}>
            <div style={{ display: 'flex', alignItems: 'baseline', gap: 16 }}>
              <span style={{
                fontFamily: SERIF, fontStyle: 'italic', fontSize: 86, lineHeight: 1,
                color: p.primary, letterSpacing: -2,
              }}>{String(stepN).padStart(2, '0')}</span>
              <div>
                <h1 style={{ fontFamily: SANS, fontSize: 30, fontWeight: 700, margin: 0, letterSpacing: -0.5 }}>
                  {title}
                </h1>
                <p style={{ margin: '4px 0 0', fontSize: 14, color: p.textMuted, maxWidth: 560, lineHeight: 1.5 }}>
                  {subtitle}
                </p>
              </div>
            </div>
            <div style={{ height: 24 }} />
            {children}

            <div style={{ height: 28 }} />
            {footer || (
            <div style={{ display: 'flex', gap: 10 }}>
              <Btn kind="outline">← Back to step {String(stepN - 1).padStart(2, '0')}</Btn>
              <div style={{ flex: 1 }} />
              <Btn kind="ghost">Skip optional</Btn>
              <Btn kind="primary" trailing={<Arrow size={16} />}>Continue to step {String(stepN + 1).padStart(2, '0')}</Btn>
            </div>
            )}
          </div>

          {/* AI / context panel */}
          <div style={{ background: p.card, borderLeft: `1px solid ${p.border}`, padding: '28px 22px', overflow: 'auto' }}>
            {aiPanel}
          </div>
        </div>
      </div>
    </>
  );
}

// Smaller desktop autocomplete & chip helpers — built atop the shared ones.
function DesktopSearch({ icon, placeholder, value, source, items, query, badge }) {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <div style={{ position: 'relative', zIndex: 4 }}>
      <div style={{
        display: 'flex', alignItems: 'center', gap: 12,
        padding: '14px 16px',
        background: p.card, border: `1.5px solid ${p.primary}`,
        borderRadius: 12, boxShadow: `0 0 0 4px ${p.primary}18`,
      }}>
        {icon}
        <input
          defaultValue={value}
          placeholder={placeholder}
          style={{
            flex: 1, border: 'none', outline: 'none', background: 'transparent',
            fontFamily: SANS, fontSize: 15, color: p.text, fontWeight: 600,
          }}
        />
        <span style={{
          display: 'inline-flex', alignItems: 'center', gap: 4,
          fontFamily: MONO, fontSize: 10, fontWeight: 700, letterSpacing: 0.5,
          color: p.primary, background: p.primaryTint,
          padding: '4px 8px', borderRadius: 5,
        }}>
          <Sparkles size={10} stroke={p.primary} /> {badge}
        </span>
        <span style={{ fontFamily: MONO, fontSize: 10, color: p.textMuted, letterSpacing: 0.4 }}>
          {items.length} matches
        </span>
      </div>
      {/* Dropdown */}
      <div style={{
        position: 'absolute', left: 0, right: 0, top: 'calc(100% + 6px)',
        background: p.card, border: `1px solid ${p.border}`, borderRadius: 12,
        padding: 6, boxShadow: '0 12px 36px rgba(0,0,0,0.14), 0 2px 4px rgba(0,0,0,0.04)',
        zIndex: 5,
      }}>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 8,
          padding: '6px 10px 8px', borderBottom: `1px solid ${p.border}`, marginBottom: 4,
        }}>
          <Sparkles size={12} stroke={p.primary} />
          <span style={{ fontFamily: MONO, fontSize: 10, fontWeight: 700, color: p.primary, letterSpacing: 0.6, textTransform: 'uppercase' }}>
            {source}
          </span>
          <div style={{ flex: 1 }} />
          <span style={{ fontFamily: MONO, fontSize: 10, color: p.textMuted, letterSpacing: 0.4 }}>
            ↑↓ to navigate · ↵ to add · esc to dismiss
          </span>
        </div>
        {items.map((it, i) => (
          <div key={i} style={{
            display: 'flex', alignItems: 'flex-start', gap: 12,
            padding: '10px 10px', borderRadius: 8,
            background: i === 0 ? p.primaryTint : 'transparent', cursor: 'pointer',
          }}>
            <div style={{
              fontFamily: MONO, fontSize: 11, color: p.primary, fontWeight: 700,
              background: p.card, border: `1px solid ${p.primaryLight}`,
              padding: '3px 7px', borderRadius: 4, letterSpacing: 0.4,
              flexShrink: 0, marginTop: 1, minWidth: 70, textAlign: 'center',
            }}>{it.code}</div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 14, fontWeight: 600, color: p.text, lineHeight: 1.3 }}>
                {it.label.split(new RegExp(`(${query})`, 'i')).map((part, j) =>
                  part.toLowerCase() === query.toLowerCase()
                    ? <mark key={j} style={{ background: 'transparent', color: p.primary, fontWeight: 800 }}>{part}</mark>
                    : <span key={j}>{part}</span>
                )}
              </div>
              {it.sub && <div style={{ fontSize: 12, color: p.textMuted, marginTop: 2, lineHeight: 1.35 }}>{it.sub}</div>}
            </div>
            {i === 0 && (
              <span style={{
                fontFamily: MONO, fontSize: 10, fontWeight: 700, letterSpacing: 0.4,
                color: p.primary, padding: '3px 7px', borderRadius: 4,
                border: `1px solid ${p.primary}`, flexShrink: 0, alignSelf: 'center',
              }}>↵ Add</span>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}

// Compact chip used in desktop card lists
function DesktopChip({ code, label, sub, tone = 'primary', dose, source }) {
  const { palette: p } = React.useContext(MHADContext);
  const styles = {
    primary: { bg: p.card, border: p.border, codeBg: p.primary, codeFg: p.onPrimary, text: p.text },
    warn:    { bg: p.warnBg, border: p.warnBorder, codeBg: p.warnText, codeFg: '#fff', text: p.warnText },
    crisis:  { bg: p.crisisBg, border: p.crisisBorder, codeBg: p.crisisAccent, codeFg: '#fff', text: p.crisisText },
  }[tone];
  return (
    <div style={{
      background: styles.bg, border: `1px solid ${styles.border}`,
      borderRadius: 10, padding: '11px 14px',
      display: 'flex', alignItems: 'center', gap: 12,
    }}>
      <div style={{
        fontFamily: MONO, fontSize: 11, color: styles.codeFg, fontWeight: 700,
        background: styles.codeBg, padding: '4px 7px', borderRadius: 4, letterSpacing: 0.4,
        flexShrink: 0, minWidth: 60, textAlign: 'center',
      }}>{code}</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 10, flexWrap: 'wrap' }}>
          <span style={{ fontSize: 14, fontWeight: 700, color: styles.text }}>{label}</span>
          {dose && (
            <span style={{ fontFamily: MONO, fontSize: 11.5, color: styles.text, opacity: 0.75, letterSpacing: 0.3, fontWeight: 600 }}>{dose}</span>
          )}
        </div>
        {sub && <div style={{ fontSize: 12, color: styles.text, opacity: 0.75, marginTop: 2 }}>{sub}</div>}
      </div>
      {source && (
        <span style={{
          fontFamily: MONO, fontSize: 9.5, fontWeight: 700, letterSpacing: 0.5,
          color: styles.codeBg, background: '#fff',
          padding: '2px 6px', borderRadius: 3,
          border: `1px solid ${styles.border}`, flexShrink: 0,
        }}>{source}</span>
      )}
      <Edit size={14} stroke={p.textMuted} />
      <X size={14} sw={2.5} stroke={p.textMuted} />
    </div>
  );
}

// ─── Step 06 · Diagnoses (desktop) ────────────────────────────────────
function WebDiagnoses() {
  const { palette: p } = React.useContext(MHADContext);

  const matches = [
    { code: 'F31.9',  label: 'Bipolar disorder, unspecified',                              sub: 'Mood disorders' },
    { code: 'F31.0',  label: 'Bipolar disorder, current episode hypomanic',                sub: 'Mood disorders' },
    { code: 'F31.10', label: 'Bipolar disorder, current episode manic without psychotic features', sub: 'Mood disorders' },
    { code: 'F31.2',  label: 'Bipolar disorder, current episode manic, severe with psychotic features', sub: 'Mood disorders · severe' },
    { code: 'F31.81', label: 'Bipolar II disorder',                                        sub: 'Mood disorders' },
  ];

  return (
    <WebHealthShell
      stepN={6}
      title="Diagnoses"
      subtitle="Help your care team see the whole picture in a crisis. Search by name — we attach the ICD-10 code your doctors use."
      aiPanel={
        <>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 14 }}>
            <div style={{ width: 28, height: 28, borderRadius: 8, background: p.primaryTint, color: p.primary, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Sparkles size={16} />
            </div>
            <div>
              <div style={{ fontSize: 13, fontWeight: 700 }}>AI assistant</div>
              <div style={{ fontSize: 10.5, color: p.textMuted, fontFamily: MONO, letterSpacing: 0.4 }}>ICD-10 · NLM API</div>
            </div>
          </div>

          <div style={{ background: p.primaryTint, border: `1px solid ${p.primary}25`, borderRadius: 12, padding: 12 }}>
            <div style={{ fontSize: 12, fontWeight: 700, color: p.primaryDark, marginBottom: 6 }}>Where this data lives</div>
            <p style={{ fontSize: 12, color: p.text, margin: 0, lineHeight: 1.5 }}>
              Codes come straight from the NLM clinical-tables ICD-10-CM service. Lookups happen in your browser — we never know what you searched.
            </p>
          </div>

          <div style={{ height: 14 }} />
          <SectionLabel>Don't know the official name?</SectionLabel>
          <div style={{
            background: p.surface, border: `1px solid ${p.border}`, borderRadius: 10,
            padding: '10px 12px', marginTop: 8,
            fontSize: 12.5, color: p.text, lineHeight: 1.45,
          }}>
            Describe how it shows up for you and I'll suggest the closest ICD-10 code for you to confirm.
            <div style={{ marginTop: 8, display: 'flex', gap: 6 }}>
              <span style={{ fontSize: 11, fontWeight: 700, color: p.primary, cursor: 'pointer' }}>Try "racing thoughts" →</span>
            </div>
          </div>

          <div style={{ height: 18 }} />
          <SectionLabel>Privacy</SectionLabel>
          <div style={{
            background: p.primaryTint, border: `1px solid ${p.primary}25`,
            borderRadius: 10, padding: 12, marginTop: 8,
            display: 'flex', alignItems: 'flex-start', gap: 8,
          }}>
            <Lock size={14} stroke={p.primary} />
            <p style={{ margin: 0, fontSize: 12, color: p.text, lineHeight: 1.45 }}>
              You're not required to list anything. Anything you do list is shared only with the people your directive names.
            </p>
          </div>
        </>
      }
    >
      <SectionLabel>Add a diagnosis</SectionLabel>
      <div style={{ height: 8 }} />

      <DesktopSearch
        icon={<Icon size={18} stroke={p.textMuted} sw={2}><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></Icon>}
        placeholder="Search a condition (e.g. depression, ADHD)…"
        value="bipo"
        source="ICD-10-CM · NLM clinical tables"
        items={matches}
        query="bipo"
        badge="ICD-10"
      />

      <div style={{ height: 280 }} />

      {/* Primary care doctor sub-section (moved here from Step 2) */}
      <SectionLabel>Primary care doctor · optional</SectionLabel>
      <p style={{ fontSize: 12.5, color: p.textMuted, margin: '6px 0 10px', lineHeight: 1.45 }}>
        Who knows your history best? Care teams call them first.
      </p>
      <div style={{ background: p.card, border: `1px solid ${p.border}`, borderRadius: 12, padding: 14, display: 'flex', gap: 14, alignItems: 'center', maxWidth: 520 }}>
        <div style={{
          width: 44, height: 44, borderRadius: 100, flexShrink: 0,
          background: p.primary, color: p.onPrimary,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontFamily: SANS, fontWeight: 700, fontSize: 14,
        }}>RP</div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: 15, fontWeight: 700, color: p.text }}>Dr. R. Patel</div>
          <div style={{ fontSize: 12.5, color: p.textMuted }}>Psychiatrist · UPMC Western</div>
        </div>
        <div style={{ fontFamily: MONO, fontSize: 13, color: p.primary, fontWeight: 600 }}>(412) 555-0102</div>
        <Edit size={15} stroke={p.textMuted} />
      </div>

      <div style={{ height: 22 }} />

      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10 }}>
        <SectionLabel>Added · 3 conditions</SectionLabel>
        <span style={{ fontFamily: MONO, fontSize: 10, color: p.textMuted, letterSpacing: 0.5 }}>SORTED BY PRIMARY</span>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
        <DesktopChip code="F31.81" label="Bipolar II disorder" sub="Diagnosed 2018 · Dr. Patel (UPMC)" source="ICD-10" />
        <DesktopChip code="F41.1"  label="Generalized anxiety disorder" sub="Diagnosed 2020" source="ICD-10" />
        <DesktopChip code="G47.00" label="Insomnia, unspecified" sub="From snap-to-fill (med list photo)" source="ICD-10" />
      </div>
    </WebHealthShell>
  );
}

// ─── Step 07 · Allergies (desktop) ────────────────────────────────────
function WebAllergies() {
  const { palette: p } = React.useContext(MHADContext);

  const matches = [
    { code: 'RX-202525',  label: 'Penicillin V Potassium 250 MG Oral Tablet',     sub: 'PEN-V · class: Penicillins' },
    { code: 'RX-313782',  label: 'Penicillin G Benzathine 600000 UNT/ML Injection', sub: 'BICILLIN · class: Penicillins' },
    { code: 'RX-1668187', label: 'Amoxicillin 500 MG Oral Capsule',                sub: 'AMOXIL · class: Penicillins · cross-reactive' },
  ];

  return (
    <WebHealthShell
      stepN={8}
      title="Allergies & reactions"
      subtitle="Drug allergies, sensitivities, past adverse reactions. This is the most-checked section by ER staff."
      aiPanel={
        <>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 14 }}>
            <div style={{ width: 28, height: 28, borderRadius: 8, background: p.primaryTint, color: p.primary, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Sparkles size={16} />
            </div>
            <div>
              <div style={{ fontSize: 13, fontWeight: 700 }}>AI assistant</div>
              <div style={{ fontSize: 10.5, color: p.textMuted, fontFamily: MONO, letterSpacing: 0.4 }}>RXTERMS · NLM API</div>
            </div>
          </div>

          <div style={{ background: p.primaryTint, border: `1px solid ${p.primary}25`, borderRadius: 12, padding: 12 }}>
            <div style={{ fontSize: 12, fontWeight: 700, color: p.primaryDark, marginBottom: 6 }}>Backward nudge into Medications</div>
            <p style={{ fontSize: 12, color: p.text, margin: 0, lineHeight: 1.5 }}>
              Because Allergies comes after Medications, anything you mark <strong>Severe</strong> here prompts you to jump back to Step 07 and add it to your <em>Avoid</em> list — binding under Act 194.
            </p>
          </div>

          <div style={{ height: 14 }} />
          <SectionLabel>Cross-links</SectionLabel>
          <div style={{
            background: p.primaryTint, border: `1px solid ${p.primary}25`, borderRadius: 10, padding: 12, marginTop: 8,
            fontSize: 12, color: p.text, lineHeight: 1.5,
          }}>
            If you're allergic to penicillins, you may also react to <strong>amoxicillin, cephalexin, and other beta-lactams</strong> — the dropdown flags cross-reactive classes inline.
          </div>

          <div style={{ height: 14 }} />
          <SectionLabel>Beyond drugs</SectionLabel>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 6, marginTop: 8 }}>
            {['Food allergens · ICD-10 Z91.01', 'Materials e.g. latex · ICD-10 Z91.040', 'Other / unspecified · ICD-10 T78.4'].map((q, i) => (
              <div key={i} style={{
                background: p.surface, border: `1px solid ${p.border}`, borderRadius: 8,
                padding: '8px 10px', fontSize: 12, color: p.text,
              }}>{q}</div>
            ))}
          </div>
        </>
      }
    >
      <SectionLabel>Add an allergy</SectionLabel>
      <div style={{ height: 8 }} />

      {/* Kind toggle — switches data source */}
      <div style={{ display: 'flex', gap: 6, marginBottom: 12 }}>
        {[
          { id: 'drug', label: 'Drug', src: 'RxTerms' },
          { id: 'food', label: 'Food', src: 'ICD-10' },
          { id: 'material', label: 'Material', src: 'ICD-10' },
          { id: 'other', label: 'Other', src: 'ICD-10' },
        ].map((k) => {
          const active = k.id === 'drug';
          return (
            <div key={k.id} style={{
              padding: '7px 14px', borderRadius: 100, cursor: 'pointer',
              background: active ? p.primary : p.card,
              color: active ? p.onPrimary : p.textMuted,
              border: `1.5px solid ${active ? p.primary : p.border}`,
              fontSize: 12.5, fontWeight: 700,
              display: 'flex', alignItems: 'center', gap: 7,
            }}>
              {k.label}
              <span style={{ fontFamily: MONO, fontSize: 9, letterSpacing: 0.4, opacity: active ? 0.85 : 0.7 }}>{k.src}</span>
            </div>
          );
        })}
      </div>

      <DesktopSearch
        icon={<Icon size={18} stroke={p.textMuted} sw={2}><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></Icon>}
        placeholder="Search a drug or class…"
        value="penic"
        source="RxTerms · NLM clinical tables"
        items={matches}
        query="penic"
        badge="RxTerms"
      />
      <p style={{ fontSize: 11, color: p.textMuted, fontStyle: 'italic', margin: '8px 2px 0' }}>
        Drug allergies search RxTerms. Food, material &amp; other search ICD-10 (Z91.01, Z91.040, T78.4…).
      </p>

      <div style={{ height: 220 }} />

      {/* Backward nudge into Medications */}
      <div style={{
        background: p.crisisBg, border: `1px solid ${p.crisisBorder}`,
        borderRadius: 12, padding: 14, display: 'flex', gap: 12, color: p.crisisText, marginBottom: 18,
      }}>
        <Info size={18} stroke={p.crisisText} />
        <div style={{ flex: 1, fontSize: 13, lineHeight: 1.5 }}>
          <strong>You marked Haldol as Severe.</strong> Add it to your <em>Avoid</em> list back in Step 07 (Medications) so your care team is bound to refuse it?
          <div style={{ display: 'flex', gap: 10, marginTop: 10 }}>
            <span style={{
              fontSize: 12.5, fontWeight: 700, color: '#fff', background: p.crisisAccent,
              padding: '7px 13px', borderRadius: 8, display: 'inline-flex', alignItems: 'center', gap: 6,
            }}>
              <Icon d="M15 18l-6-6 6-6" size={14} stroke="#fff" /> Add to Step 07 · Avoid
            </span>
            <span style={{ fontSize: 12.5, fontWeight: 700, color: p.crisisText, padding: '7px 8px', alignSelf: 'center' }}>Not now</span>
          </div>
        </div>
      </div>

      {/* Severity & reaction (preview of what shows after picking) */}
      <SectionLabel>Severity & reaction (preview)</SectionLabel>
      <div style={{
        marginTop: 10, background: p.card, border: `1px solid ${p.border}`,
        borderRadius: 12, padding: 16, display: 'grid', gridTemplateColumns: '1fr 1.4fr', gap: 18,
      }}>
        <div>
          <div style={{ fontSize: 11, fontFamily: MONO, color: p.textMuted, letterSpacing: 0.5, fontWeight: 700, textTransform: 'uppercase', marginBottom: 8 }}>
            How serious?
          </div>
          <div style={{ display: 'flex', gap: 6 }}>
            {['Mild', 'Moderate', 'Severe'].map((s, i) => {
              const active = s === 'Severe';
              return (
                <div key={i} style={{
                  flex: 1,
                  background: active ? p.crisisAccent : (s === 'Moderate' ? p.warnBg : p.primaryTint),
                  color: active ? '#fff' : (s === 'Moderate' ? p.warnText : p.text),
                  border: `1.5px solid ${active ? p.crisisAccent : (s === 'Moderate' ? p.warnBorder : p.primaryLight)}`,
                  borderRadius: 10, padding: '8px 6px',
                  textAlign: 'center', fontWeight: 700, fontSize: 12.5,
                }}>{s}</div>
              );
            })}
          </div>
        </div>
        <div>
          <div style={{ fontSize: 11, fontFamily: MONO, color: p.textMuted, letterSpacing: 0.5, fontWeight: 700, textTransform: 'uppercase', marginBottom: 8 }}>
            What happens
          </div>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
            {['Anaphylaxis', 'Hives', 'Swelling', 'Throat closing', '+ Add'].map((t, i) => {
              const isAdd = t.startsWith('+');
              return (
                <span key={i} style={{
                  fontSize: 12, fontWeight: 600,
                  background: isAdd ? 'transparent' : p.crisisBg,
                  color: isAdd ? p.primary : p.crisisText,
                  border: isAdd ? `1px dashed ${p.primary}` : `1px solid ${p.crisisBorder}`,
                  padding: '5px 10px', borderRadius: 100,
                }}>{t}</span>
              );
            })}
          </div>
        </div>
      </div>

      <div style={{ height: 18 }} />
      <SectionLabel>Added · 3 allergies</SectionLabel>
      <div style={{ marginTop: 10, display: 'flex', flexDirection: 'column', gap: 8 }}>
        <DesktopChip code="SEVERE" tone="crisis" label="Haloperidol (Haldol)" dose="any dose" sub="Severe dystonia · ER admission 2019" source="RxTerms" />
        <DesktopChip code="MOD"    tone="warn"   label="Latex"                                    sub="Hives, swelling"            source="UMLS" />
        <DesktopChip code="MILD"   tone="primary" label="Shellfish"                                sub="Mild GI · self-managed"     source="Free text" />
      </div>
    </WebHealthShell>
  );
}

// ─── Step 07 · Medications (desktop) ──────────────────────────────────
function WebMedications() {
  const { palette: p } = React.useContext(MHADContext);

  const matches = [
    { code: 'RX-312940', label: 'Sertraline 100 MG Oral Tablet',     sub: 'ZOLOFT · SSRI · once-daily' },
    { code: 'RX-312938', label: 'Sertraline 50 MG Oral Tablet',      sub: 'ZOLOFT · SSRI' },
    { code: 'RX-312941', label: 'Sertraline 25 MG Oral Tablet',      sub: 'ZOLOFT · SSRI' },
    { code: 'RX-636042', label: 'Sertraline 20 MG/ML Oral Solution', sub: 'ZOLOFT · liquid form' },
  ];

  return (
    <WebHealthShell
      stepN={7}
      title="Medications"
      subtitle="What you take, and what to avoid. Two sections: meds you take now (informational) and meds to refuse during a crisis (binding under Act 194)."
      aiPanel={
        <>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 14 }}>
            <div style={{ width: 28, height: 28, borderRadius: 8, background: p.primaryTint, color: p.primary, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Sparkles size={16} />
            </div>
            <div>
              <div style={{ fontSize: 13, fontWeight: 700 }}>AI assistant</div>
              <div style={{ fontSize: 10.5, color: p.textMuted, fontFamily: MONO, letterSpacing: 0.4 }}>RXTERMS · NLM API</div>
            </div>
          </div>

          <div style={{ background: p.primaryTint, border: `1px solid ${p.primary}25`, borderRadius: 12, padding: 12 }}>
            <div style={{ fontSize: 12, fontWeight: 700, color: p.primaryDark, marginBottom: 6 }}>Backward nudge from Allergies</div>
            <p style={{ fontSize: 12, color: p.text, margin: 0, lineHeight: 1.5 }}>
              Allergies (Step 08) comes next. When you mark a substance <strong>Severe</strong> there, you'll be prompted to come back here and add it to <em>Avoid</em>. Haldol below arrived that way.
            </p>
            <div style={{ display: 'flex', gap: 6, marginTop: 10 }}>
              <span style={{ fontSize: 11, fontWeight: 700, color: p.primary, cursor: 'pointer' }}>Keep it</span>
              <span style={{ fontSize: 11, color: p.textMuted }}>·</span>
              <span style={{ fontSize: 11, fontWeight: 700, color: p.primary, cursor: 'pointer' }}>Go to Step 08</span>
            </div>
          </div>

          <div style={{ height: 14 }} />
          <SectionLabel>Quick prompts</SectionLabel>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 6, marginTop: 8 }}>
            {[
              'Help me word a dose ceiling',
              'What\'s an "as-needed" preference?',
              'Can my agent override a "no" on a specific drug?',
              'Show example language for benzodiazepine refusal',
            ].map((q, i) => (
              <div key={i} style={{
                background: p.surface, border: `1px solid ${p.border}`, borderRadius: 8,
                padding: '8px 10px', fontSize: 12, color: p.text, cursor: 'pointer',
              }}>{q}</div>
            ))}
          </div>
        </>
      }
    >
      {/* ── Section A · Current medications ── */}
      <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 6 }}>
        <SectionLabel>A · Current medications</SectionLabel>
        <span style={{ fontFamily: MONO, fontSize: 10, color: p.primary, fontWeight: 700, letterSpacing: 0.5 }}>
          3 · INFORMATIONAL
        </span>
      </div>
      <p style={{ fontSize: 12.5, color: p.textMuted, margin: '0 0 12px', lineHeight: 1.45 }}>
        What you're taking now. Shared with care teams so they don't double-prescribe or miss an interaction.
      </p>

      <DesktopSearch
        icon={<Icon size={18} stroke={p.textMuted} sw={2}><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></Icon>}
        placeholder="Search a medication you take (drug name or brand)…"
        value="sertra"
        source="RxTerms · NLM clinical tables"
        items={matches}
        query="sertra"
        badge="RxTerms"
      />

      <div style={{ height: 240 }} />

      <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
        <DesktopChip code="SSRI" label="Sertraline" dose="100 mg · 1× daily, AM" sub="Dr. R. Patel · since Feb 2024 · from snap-to-fill" source="RxTerms" />
        <DesktopChip code="MOOD" label="Lamotrigine" dose="200 mg · 2× daily"     sub="Dr. R. Patel · since Mar 2024"                       source="RxTerms" />
        <DesktopChip code="PRN"  label="Hydroxyzine" dose="25 mg · as needed"     sub="Self-reported"                                       source="RxTerms" />
      </div>

      <div style={{ marginTop: 10, padding: '10px 14px', background: p.surface, border: `1px dashed ${p.border}`, borderRadius: 10, display: 'flex', alignItems: 'center', gap: 8 }}>
        <Plus size={15} stroke={p.primary} />
        <span style={{ flex: 1, fontSize: 13, color: p.text, fontWeight: 600 }}>Add another current medication</span>
        <span style={{ fontFamily: MONO, fontSize: 10, color: p.textMuted, letterSpacing: 0.4 }}>OR DROP AN Rx PHOTO</span>
      </div>

      <div style={{ height: 24 }} />
      <div style={{ borderTop: `1px dashed ${p.border}` }} />
      <div style={{ height: 22 }} />

      {/* ── Section B · Avoid (binding) ── */}
      <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 6 }}>
        <SectionLabel>B · Medications to avoid</SectionLabel>
        <span style={{ fontFamily: MONO, fontSize: 10, color: p.crisisAccent, fontWeight: 700, letterSpacing: 0.5 }}>
          BINDING
        </span>
      </div>
      <p style={{ fontSize: 12.5, color: p.textMuted, margin: '0 0 12px', lineHeight: 1.45 }}>
        Specific medications you refuse during a crisis. Bind your agent and care team under Act 194.
      </p>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
        <div style={{
          background: p.crisisBg, border: `1px solid ${p.crisisBorder}`, borderRadius: 12, padding: '13px 14px',
          display: 'flex', alignItems: 'flex-start', gap: 12,
        }}>
          <X size={18} sw={2.5} stroke={p.crisisText} style={{ marginTop: 1, flexShrink: 0 }} />
          <div style={{ flex: 1 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, flexWrap: 'wrap' }}>
              <span style={{ fontSize: 14, fontWeight: 700, color: p.crisisText }}>Haloperidol (Haldol)</span>
              <span style={{
                fontFamily: MONO, fontSize: 9, fontWeight: 700, letterSpacing: 0.4,
                color: p.crisisAccent, background: '#fff', padding: '1px 5px', borderRadius: 3,
                border: `1px solid ${p.crisisBorder}`,
              }}>FROM STEP 08 ALLERGY</span>
            </div>
            <div style={{ fontSize: 12, color: p.crisisText, opacity: 0.85, marginTop: 2 }}>You flagged this as a Severe allergy and added it here.</div>
          </div>
          <Edit size={14} stroke={p.crisisText} />
          <X size={14} sw={2.5} stroke={p.crisisText} />
        </div>

        <div style={{ padding: '10px 14px', background: p.surface, border: `1px dashed ${p.border}`, borderRadius: 10, display: 'flex', alignItems: 'center', gap: 8 }}>
          <Plus size={15} stroke={p.primary} />
          <span style={{ flex: 1, fontSize: 13, color: p.text, fontWeight: 600 }}>Add a medication to avoid</span>
          <span style={{ fontFamily: MONO, fontSize: 10, color: p.textMuted, letterSpacing: 0.4 }}>RxTerms</span>
        </div>
      </div>
    </WebHealthShell>
  );
}

Object.assign(window, { WebDiagnoses, WebAllergies, WebMedications });
