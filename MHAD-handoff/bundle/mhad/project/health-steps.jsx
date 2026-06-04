// health-steps.jsx — New wizard steps for diagnoses, allergies, and current
// medications. All three use NLM clinical-tables autocomplete:
//   ICD-10:   clinicaltables.nlm.nih.gov/api/icd10cm/v3/search
//   RxTerms:  clinicaltables.nlm.nih.gov/api/rxterms/v3/search
//
// Mock data on these artboards reflects real shapes returned by those APIs.

// ─── Shared autocomplete dropdown ─────────────────────────────────────
function AutoComplete({ source, query, items, onPick, sticky = false }) {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <div style={{
      background: p.card, border: `1px solid ${p.border}`,
      borderRadius: 12, padding: 6,
      boxShadow: '0 8px 24px rgba(0,0,0,0.10), 0 1px 2px rgba(0,0,0,0.04)',
      position: sticky ? 'static' : 'absolute', left: 0, right: 0, top: '100%',
      marginTop: 4, zIndex: 5,
    }}>
      <div style={{
        display: 'flex', alignItems: 'center', gap: 6,
        padding: '4px 8px 6px', borderBottom: `1px solid ${p.border}`, marginBottom: 4,
      }}>
        <Sparkles size={11} stroke={p.primary} />
        <span style={{ fontFamily: MONO, fontSize: 9.5, fontWeight: 700, color: p.primary, letterSpacing: 0.6, textTransform: 'uppercase' }}>
          {source}
        </span>
        <div style={{ flex: 1 }} />
        <span style={{ fontFamily: MONO, fontSize: 9.5, color: p.textMuted, letterSpacing: 0.4 }}>
          {items.length} matches
        </span>
      </div>
      {items.map((it, i) => (
        <div key={i} style={{
          display: 'flex', alignItems: 'flex-start', gap: 10,
          padding: '8px 8px', borderRadius: 7,
          background: i === 0 ? p.primaryTint : 'transparent', cursor: 'pointer',
        }}>
          <div style={{
            fontFamily: MONO, fontSize: 10, color: p.primary, fontWeight: 700,
            background: p.card, border: `1px solid ${p.primaryLight}`,
            padding: '2px 5px', borderRadius: 4, letterSpacing: 0.4,
            flexShrink: 0, marginTop: 1,
          }}>{it.code}</div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontSize: 13, fontWeight: 600, color: p.text, lineHeight: 1.3 }}>
              {it.label.split(new RegExp(`(${query})`, 'i')).map((part, j) =>
                part.toLowerCase() === query.toLowerCase()
                  ? <mark key={j} style={{ background: 'transparent', color: p.primary, fontWeight: 800 }}>{part}</mark>
                  : <span key={j}>{part}</span>
              )}
            </div>
            {it.sub && <div style={{ fontSize: 11, color: p.textMuted, marginTop: 1, lineHeight: 1.3 }}>{it.sub}</div>}
          </div>
          {i === 0 && (
            <span style={{
              fontFamily: MONO, fontSize: 9, fontWeight: 700, letterSpacing: 0.4,
              color: p.primary, padding: '2px 5px', borderRadius: 3,
              border: `1px solid ${p.primary}`, flexShrink: 0, alignSelf: 'center',
            }}>↵</span>
          )}
        </div>
      ))}
    </div>
  );
}

// Pill / chip used in all three steps for selected items
function HealthChip({ code, label, sub, tone = 'primary', onRemove, dose, sourceTag }) {
  const { palette: p } = React.useContext(MHADContext);
  const styles = {
    primary: { bg: p.primaryTint, border: p.primaryLight, codeBg: p.primary, codeFg: p.onPrimary, text: p.text },
    warn:    { bg: p.warnBg,      border: p.warnBorder,   codeBg: p.warnText, codeFg: '#fff',     text: p.warnText },
    crisis:  { bg: p.crisisBg,    border: p.crisisBorder, codeBg: p.crisisAccent, codeFg: '#fff', text: p.crisisText },
  }[tone];
  return (
    <div style={{
      background: styles.bg, border: `1px solid ${styles.border}`,
      borderRadius: 12, padding: '10px 12px',
      display: 'flex', alignItems: 'flex-start', gap: 10,
    }}>
      <div style={{
        fontFamily: MONO, fontSize: 10, color: styles.codeFg, fontWeight: 700,
        background: styles.codeBg, padding: '3px 6px', borderRadius: 4, letterSpacing: 0.4,
        flexShrink: 0, marginTop: 1,
      }}>{code}</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 8, flexWrap: 'wrap' }}>
          <span style={{ fontSize: 13.5, fontWeight: 700, color: styles.text }}>{label}</span>
          {dose && (
            <span style={{
              fontFamily: MONO, fontSize: 10.5, color: styles.text, opacity: 0.75,
              letterSpacing: 0.4, fontWeight: 600,
            }}>{dose}</span>
          )}
          {sourceTag && (
            <span style={{
              fontFamily: MONO, fontSize: 9, fontWeight: 700, letterSpacing: 0.4,
              color: styles.codeBg, background: '#fff',
              padding: '1px 5px', borderRadius: 3,
              border: `1px solid ${styles.border}`,
            }}>{sourceTag}</span>
          )}
        </div>
        {sub && <div style={{ fontSize: 11.5, color: styles.text, opacity: 0.78, marginTop: 2, lineHeight: 1.35 }}>{sub}</div>}
      </div>
      <X size={14} sw={2.5} stroke={styles.text} />
    </div>
  );
}

// Step header reused across the three steps
function HealthStepHead({ n, total, kicker, title, sub }) {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <div style={{ padding: '14px 22px 6px' }}>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 14, marginBottom: 4 }}>
        <span style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 54, lineHeight: 1, color: p.primary, letterSpacing: -1 }}>{String(n).padStart(2, '0')}</span>
        <div>
          <div style={{ fontFamily: MONO, fontSize: 10.5, color: p.textMuted, letterSpacing: 1, textTransform: 'uppercase' }}>
            Step {n} of {total} · {kicker}
          </div>
          <h2 style={{ fontFamily: SANS, fontWeight: 700, fontSize: 24, margin: '2px 0 4px', letterSpacing: -0.3, lineHeight: 1.15 }}>
            {title}
          </h2>
        </div>
      </div>
      {sub && <p style={{ fontSize: 13, color: p.textMuted, margin: '4px 0 0', lineHeight: 1.45 }}>{sub}</p>}
    </div>
  );
}

// Search field with attached autocomplete (controlled visually only)
function SearchField({ icon, placeholder, value, showDropdown, children, badge }) {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <div style={{ position: 'relative', zIndex: showDropdown ? 4 : 1 }}>
      <div style={{
        display: 'flex', alignItems: 'center', gap: 10,
        padding: '11px 14px',
        background: p.card, border: `1.5px solid ${showDropdown ? p.primary : p.border}`,
        borderRadius: 12,
        boxShadow: showDropdown ? `0 0 0 4px ${p.primary}15` : 'none',
      }}>
        {icon}
        <input
          defaultValue={value}
          placeholder={placeholder}
          style={{
            flex: 1, border: 'none', outline: 'none', background: 'transparent',
            fontFamily: SANS, fontSize: 14, color: p.text, fontWeight: 600,
          }}
        />
        {badge && (
          <span style={{
            display: 'inline-flex', alignItems: 'center', gap: 4,
            fontFamily: MONO, fontSize: 9, fontWeight: 700, letterSpacing: 0.5,
            color: p.primary, background: p.primaryTint,
            padding: '3px 6px', borderRadius: 4,
          }}>
            <Sparkles size={9} stroke={p.primary} /> {badge}
          </span>
        )}
      </div>
      {children}
    </div>
  );
}

// ─── 06 · Diagnoses (ICD-10 autocomplete) ─────────────────────────────
function ScrDiagnoses() {
  const { palette: p } = React.useContext(MHADContext);

  // Realistic ICD-10-CM matches for "bipo"
  const matches = [
    { code: 'F31.9',  label: 'Bipolar disorder, unspecified',                              sub: 'Mood disorders' },
    { code: 'F31.0',  label: 'Bipolar disorder, current episode hypomanic',                sub: 'Mood disorders' },
    { code: 'F31.10', label: 'Bipolar disorder, current episode manic without psychotic features, unspecified', sub: 'Mood disorders' },
    { code: 'F31.2',  label: 'Bipolar disorder, current episode manic, severe with psychotic features', sub: 'Mood disorders' },
    { code: 'F31.81', label: 'Bipolar II disorder',                                        sub: 'Mood disorders' },
  ];

  return (
    <Screen scroll={false}>
      <CrisisBar compact />
      <WizardHeader pad="12px 22px 0" />
      <StepDots n={6} total={11} />

      <HealthStepHead
        n={6} total={11} kicker="Diagnoses · NEW"
        title="What you're being treated for"
        sub="Help your care team see the whole picture in a crisis. Search by name — we'll attach the ICD-10 code your doctors use."
      />

      <div style={{ padding: '8px 22px 28px', flex: 1, minHeight: 0, overflow: 'auto' }}>
        {/* Search field with autocomplete OPEN */}
        <SearchField
          icon={<Icon size={16} stroke={p.textMuted} sw={2}><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></Icon>}
          placeholder="Search a condition (e.g. depression, ADHD)…"
          value="bipo"
          showDropdown
          badge="ICD-10"
        >
          <AutoComplete source="ICD-10-CM · NLM clinical tables" query="bipo" items={matches} />
        </SearchField>

        <div style={{ height: 200 }} />

        {/* Primary care doctor sub-section (moved here from Step 2) */}
        <SectionLabel>Primary care doctor · optional</SectionLabel>
        <p style={{ fontSize: 12, color: p.textMuted, margin: '6px 0 10px', lineHeight: 1.45 }}>
          Who knows your history best? Care teams call them first.
        </p>
        <div style={{ background: p.card, border: `1px solid ${p.border}`, borderRadius: 12, padding: 12, display: 'flex', gap: 12, alignItems: 'center' }}>
          <div style={{
            width: 40, height: 40, borderRadius: 100, flexShrink: 0,
            background: p.primary, color: p.onPrimary,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontFamily: SANS, fontWeight: 700, fontSize: 13,
          }}>RP</div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontSize: 14, fontWeight: 700, color: p.text }}>Dr. R. Patel</div>
            <div style={{ fontSize: 12, color: p.textMuted }}>Psychiatrist · UPMC Western</div>
          </div>
          <div style={{ fontFamily: MONO, fontSize: 12, color: p.primary, fontWeight: 600 }}>(412) 555-0102</div>
          <Edit size={14} stroke={p.textMuted} />
        </div>
        <div style={{
          marginTop: 8, display: 'flex', gap: 8, padding: '10px 12px',
          background: p.surface, border: `1px dashed ${p.border}`, borderRadius: 10, alignItems: 'center',
        }}>
          <Plus size={14} stroke={p.primary} />
          <span style={{ flex: 1, fontSize: 12.5, color: p.text, fontWeight: 600 }}>Add another provider</span>
          <span style={{ fontFamily: MONO, fontSize: 10, color: p.textMuted, letterSpacing: 0.4 }}>OR FROM CONTACTS</span>
        </div>

        <div style={{ height: 18 }} />
        {/* Already-added diagnoses */}
        <SectionLabel>Added · 3 conditions</SectionLabel>
        <div style={{ marginTop: 10, display: 'flex', flexDirection: 'column', gap: 8 }}>
          <HealthChip
            code="F31.81"
            label="Bipolar II disorder"
            sub="Diagnosed 2018 · Dr. Patel (UPMC)"
            sourceTag="ICD-10"
          />
          <HealthChip
            code="F41.1"
            label="Generalized anxiety disorder"
            sub="Diagnosed 2020"
            sourceTag="ICD-10"
          />
          <HealthChip
            code="G47.00"
            label="Insomnia, unspecified"
            sub="From snap-to-fill (med list photo)"
            sourceTag="ICD-10"
          />
        </div>

        <div style={{ height: 12 }} />
        {/* AI assist */}
        <div style={{
          background: p.primaryTint, border: `1px solid ${p.primaryLight}`,
          borderRadius: 12, padding: 12, display: 'flex', gap: 10,
        }}>
          <Sparkles size={16} stroke={p.primary} />
          <div style={{ flex: 1, fontSize: 12.5, color: p.text, lineHeight: 1.45 }}>
            Don't know the official name? <strong>Describe how it shows up for you</strong> and I'll suggest the closest ICD-10 code for you to confirm.
          </div>
          <span style={{ fontSize: 12, color: p.primary, fontWeight: 700, alignSelf: 'center' }}>Try →</span>
        </div>

        <div style={{ height: 12 }} />
        <p style={{ fontSize: 11, color: p.textMuted, fontStyle: 'italic', lineHeight: 1.45 }}>
          You're not required to list anything. Anything you do list is shared only with the people your directive names.
        </p>
      </div>

      <BottomBar />
    </Screen>
  );
}

// ─── 08 · Allergies & reactions (RxTerms + ICD-10) ────────────────────
function ScrAllergies() {
  const { palette: p } = React.useContext(MHADContext);

  const matches = [
    { code: 'RX-202525',  label: 'Penicillin V Potassium 250 MG Oral Tablet',     sub: 'PEN-V · class: Penicillins' },
    { code: 'RX-313782',  label: 'Penicillin G Benzathine 600000 UNT/ML Injection', sub: 'BICILLIN · class: Penicillins' },
    { code: 'RX-1668187', label: 'Amoxicillin 500 MG Oral Capsule',                sub: 'AMOXIL · class: Penicillins · cross-reactive' },
  ];

  const severityTone = (sev) => sev === 'Severe' ? 'crisis' : sev === 'Moderate' ? 'warn' : 'primary';

  // Kind toggle drives which data source the search hits.
  const KINDS = [
    { id: 'drug',     label: 'Drug',     src: 'RxTerms' },
    { id: 'food',     label: 'Food',     src: 'ICD-10' },
    { id: 'material', label: 'Material', src: 'ICD-10' },
    { id: 'other',    label: 'Other',    src: 'ICD-10' },
  ];
  const activeKind = 'drug';

  return (
    <Screen scroll={false}>
      <CrisisBar compact />
      <WizardHeader pad="12px 22px 0" />
      <StepDots n={8} total={11} />

      <HealthStepHead
        n={8} total={11} kicker="Allergies & reactions"
        title="What your body refuses."
        sub="Drug allergies, sensitivities, past adverse reactions. This is the most-checked section by ER staff."
      />

      <div style={{ padding: '8px 22px 28px', flex: 1, minHeight: 0, overflow: 'auto' }}>
        {/* Kind toggle — switches the autocomplete data source */}
        <SectionLabel>Add an allergy</SectionLabel>
        <div style={{ height: 8 }} />
        <div style={{
          display: 'flex', gap: 4, padding: 4, marginBottom: 10,
          background: p.surface, border: `1px solid ${p.border}`, borderRadius: 100,
        }}>
          {KINDS.map((k) => {
            const active = k.id === activeKind;
            return (
              <div key={k.id} style={{
                flex: 1, textAlign: 'center', padding: '7px 4px', borderRadius: 100,
                background: active ? p.card : 'transparent',
                boxShadow: active ? '0 1px 3px rgba(0,0,0,0.08)' : 'none',
                fontSize: 12.5, fontWeight: 700, color: active ? p.text : p.textMuted,
                display: 'flex', flexDirection: 'column', gap: 1, cursor: 'pointer',
              }}>
                {k.label}
                <span style={{ fontFamily: MONO, fontSize: 8, letterSpacing: 0.4, color: active ? p.primary : p.textMuted, opacity: active ? 1 : 0.6 }}>{k.src}</span>
              </div>
            );
          })}
        </div>
        <SearchField
          icon={<Icon size={16} stroke={p.textMuted} sw={2}><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></Icon>}
          placeholder="Search a drug or class…"
          value="penic"
          showDropdown
          badge="RxTerms"
        >
          <AutoComplete source="RxTerms · NLM clinical tables" query="penic" items={matches} />
        </SearchField>
        <p style={{ fontSize: 10.5, color: p.textMuted, fontStyle: 'italic', margin: '6px 2px 0', lineHeight: 1.4 }}>
          Drug allergies search RxTerms. Food, material &amp; other allergies search ICD-10 (e.g. Z91.01 food allergy, T78.4 unspecified allergy).
        </p>

        <div style={{ height: 220 }} />

        {/* Severity row mock — what shows after picking */}
        <SectionLabel>Severity & reaction</SectionLabel>
        <div style={{
          marginTop: 8, background: p.card, border: `1px solid ${p.border}`,
          borderRadius: 12, padding: 14,
        }}>
          <div style={{ fontSize: 11, fontFamily: MONO, color: p.textMuted, letterSpacing: 0.6, fontWeight: 700, textTransform: 'uppercase' }}>
            How serious is it?
          </div>
          <div style={{ display: 'flex', gap: 6, marginTop: 8 }}>
            {[
              { id: 'Mild',     desc: 'rash, mild GI' },
              { id: 'Moderate', desc: 'hives, swelling' },
              { id: 'Severe',   desc: 'anaphylaxis · ER' },
            ].map((s, i) => {
              const active = s.id === 'Severe';
              const tone = severityTone(s.id);
              const styles = {
                primary: { bg: p.primaryTint, fg: p.text, border: p.primaryLight, active: p.primary, activeFg: p.onPrimary },
                warn:    { bg: p.warnBg,      fg: p.warnText, border: p.warnBorder, active: p.warnText, activeFg: '#fff' },
                crisis:  { bg: p.crisisBg,    fg: p.crisisText, border: p.crisisBorder, active: p.crisisAccent, activeFg: '#fff' },
              }[tone];
              return (
                <div key={i} style={{
                  flex: 1,
                  background: active ? styles.active : styles.bg,
                  color: active ? styles.activeFg : styles.fg,
                  border: `1.5px solid ${active ? styles.active : styles.border}`,
                  borderRadius: 10, padding: '8px 6px',
                  textAlign: 'center', fontWeight: 700, fontSize: 12.5, lineHeight: 1.25,
                }}>
                  {s.id}
                  <div style={{ fontSize: 10, fontWeight: 500, opacity: 0.85, marginTop: 2 }}>{s.desc}</div>
                </div>
              );
            })}
          </div>

          <div style={{ height: 12 }} />
          <div style={{ fontSize: 11, fontFamily: MONO, color: p.textMuted, letterSpacing: 0.6, fontWeight: 700, textTransform: 'uppercase' }}>
            What happens
          </div>
          <div style={{ marginTop: 6, display: 'flex', flexWrap: 'wrap', gap: 6 }}>
            {['Anaphylaxis', 'Hives', 'Swelling', 'Throat closing', '+ Add'].map((t, i) => {
              const isAdd = t.startsWith('+');
              return (
                <span key={i} style={{
                  fontSize: 11.5, fontWeight: 600,
                  background: isAdd ? 'transparent' : p.crisisBg,
                  color: isAdd ? p.primary : p.crisisText,
                  border: isAdd ? `1px dashed ${p.primary}` : `1px solid ${p.crisisBorder}`,
                  padding: '4px 9px', borderRadius: 100,
                }}>{t}</span>
              );
            })}
          </div>
        </div>

        <div style={{ height: 18 }} />
        <SectionLabel>Added · 3 allergies</SectionLabel>
        <div style={{ marginTop: 10, display: 'flex', flexDirection: 'column', gap: 8 }}>
          <HealthChip
            code="SEVERE"
            label="Haloperidol (Haldol)"
            dose="any dose"
            sub="Severe dystonia · ER admission 2019"
            sourceTag="RxTerms"
            tone="crisis"
          />
          <HealthChip
            code="MOD"
            label="Latex"
            sub="Hives, swelling"
            sourceTag="UMLS"
            tone="warn"
          />
          <HealthChip
            code="MILD"
            label="Shellfish"
            sub="Mild GI · self-managed"
            sourceTag="Free text"
          />
        </div>

        <div style={{ height: 12 }} />
        <div style={{
          background: p.crisisBg, border: `1px solid ${p.crisisBorder}`,
          borderRadius: 12, padding: 12, display: 'flex', gap: 10, color: p.crisisText,
        }}>
          <Info size={16} stroke={p.crisisText} />
          <div style={{ flex: 1, fontSize: 12.5, lineHeight: 1.45 }}>
            <strong>You marked Haldol as Severe.</strong> Want to add it to your <em>Avoid</em> list back in Step 7 (Medications) so your care team is bound to refuse it?
            <div style={{ display: 'flex', gap: 8, marginTop: 8 }}>
              <span style={{
                fontSize: 12, fontWeight: 700, color: '#fff', background: p.crisisAccent,
                padding: '6px 11px', borderRadius: 8, display: 'inline-flex', alignItems: 'center', gap: 5,
              }}>
                <Icon d="M15 18l-6-6 6-6" size={13} stroke="#fff" /> Add to Step 7 · Avoid
              </span>
              <span style={{ fontSize: 12, fontWeight: 700, color: p.crisisText, padding: '6px 8px', alignSelf: 'center' }}>Not now</span>
            </div>
          </div>
        </div>
      </div>

      <BottomBar />
    </Screen>
  );
}

// ─── 07 · Medications (Current + Avoid) ───────────────────────────────
function ScrMedicationsV2() {
  const { palette: p } = React.useContext(MHADContext);

  const matches = [
    { code: 'RX-312940', label: 'Sertraline 100 MG Oral Tablet',                   sub: 'ZOLOFT · SSRI · once-daily' },
    { code: 'RX-312938', label: 'Sertraline 50 MG Oral Tablet',                    sub: 'ZOLOFT · SSRI' },
    { code: 'RX-312941', label: 'Sertraline 25 MG Oral Tablet',                    sub: 'ZOLOFT · SSRI' },
    { code: 'RX-636042', label: 'Sertraline 20 MG/ML Oral Solution',               sub: 'ZOLOFT · liquid form' },
  ];

  return (
    <Screen scroll={false}>
      <CrisisBar compact />
      <WizardHeader pad="12px 22px 0" />
      <StepDots n={7} total={11} />

      <HealthStepHead
        n={7} total={11} kicker="Medications"
        title="What you take, and what to avoid."
        sub="Two sections: meds you take now (informational) and meds to refuse during a crisis (binding under Act 194)."
      />

      <div style={{ padding: '8px 22px 28px', flex: 1, minHeight: 0, overflow: 'auto' }}>
        {/* —————— Section A · Current meds —————— */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 6 }}>
          <SectionLabel>A · Current medications</SectionLabel>
          <span style={{ fontFamily: MONO, fontSize: 10, color: p.primary, fontWeight: 700, letterSpacing: 0.5 }}>
            3 · INFORMATIONAL
          </span>
        </div>
        <p style={{ fontSize: 12, color: p.textMuted, margin: '0 0 10px', lineHeight: 1.45 }}>
          What you're taking now. Shared with care teams so they don't double-prescribe or miss an interaction.
        </p>

        {/* Search with autocomplete OPEN */}
        <SearchField
          icon={<Icon size={16} stroke={p.textMuted} sw={2}><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></Icon>}
          placeholder="Search a medication you take…"
          value="sertra"
          showDropdown
          badge="RxTerms"
        >
          <AutoComplete source="RxTerms · NLM clinical tables" query="sertra" items={matches} />
        </SearchField>

        <div style={{ height: 200 }} />

        {/* Selected current meds */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          <HealthChip
            code="SSRI"
            label="Sertraline"
            dose="100 mg · 1× daily, AM"
            sub="Dr. R. Patel · since Feb 2024 · from snap-to-fill"
            sourceTag="RxTerms"
          />
          <HealthChip
            code="MOOD"
            label="Lamotrigine"
            dose="200 mg · 2× daily"
            sub="Dr. R. Patel · since Mar 2024"
            sourceTag="RxTerms"
          />
          <HealthChip
            code="PRN"
            label="Hydroxyzine"
            dose="25 mg · as needed for anxiety"
            sub="Self-reported"
            sourceTag="RxTerms"
          />
        </div>

        <div style={{ height: 6 }} />
        <div style={{
          display: 'flex', gap: 8, padding: '10px 12px',
          background: p.surface, border: `1px dashed ${p.border}`, borderRadius: 10,
          alignItems: 'center',
        }}>
          <Plus size={14} stroke={p.primary} />
          <span style={{ flex: 1, fontSize: 12.5, color: p.text, fontWeight: 600 }}>Add another current medication</span>
          <span style={{ fontFamily: MONO, fontSize: 10, color: p.textMuted, letterSpacing: 0.4 }}>OR SNAP A LABEL</span>
        </div>

        {/* Divider */}
        <div style={{ height: 22 }} />
        <div style={{ borderTop: `1px dashed ${p.border}` }} />
        <div style={{ height: 18 }} />

        {/* —————— Section B · Avoid (binding) —————— */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 6 }}>
          <SectionLabel>B · Medications to avoid</SectionLabel>
          <span style={{ fontFamily: MONO, fontSize: 10, color: p.crisisAccent, fontWeight: 700, letterSpacing: 0.5 }}>
            BINDING
          </span>
        </div>
        <p style={{ fontSize: 12, color: p.textMuted, margin: '0 0 12px', lineHeight: 1.45 }}>
          Specific medications you refuse during a mental health crisis. These bind your agent and care team under Act 194.
        </p>

        {/* Avoid list — full width */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          <div style={{
            background: p.crisisBg, border: `1px solid ${p.crisisBorder}`, borderRadius: 12, padding: '11px 13px',
            display: 'flex', alignItems: 'flex-start', gap: 10,
          }}>
            <X size={16} sw={2.5} stroke={p.crisisText} style={{ marginTop: 1, flexShrink: 0 }} />
            <div style={{ flex: 1 }}>
              <div style={{ display: 'flex', alignItems: 'baseline', gap: 8, flexWrap: 'wrap' }}>
                <span style={{ fontSize: 13.5, fontWeight: 700, color: p.crisisText }}>Haloperidol (Haldol)</span>
                <span style={{
                  fontFamily: MONO, fontSize: 9, fontWeight: 700, letterSpacing: 0.4,
                  color: p.crisisAccent, background: '#fff', padding: '1px 5px', borderRadius: 3,
                  border: `1px solid ${p.crisisBorder}`,
                }}>FROM STEP 8 ALLERGY</span>
              </div>
              <span style={{ fontSize: 11.5, color: p.crisisText, opacity: 0.85, display: 'block', marginTop: 2 }}>
                You flagged this as a Severe allergy and added it here.
              </span>
            </div>
            <X size={14} sw={2.5} stroke={p.crisisText} />
          </div>
        </div>

        <div style={{ height: 8 }} />
        <div style={{
          display: 'flex', gap: 8, padding: '10px 12px',
          background: p.surface, border: `1px dashed ${p.border}`, borderRadius: 10,
          alignItems: 'center',
        }}>
          <Plus size={14} stroke={p.primary} />
          <span style={{ flex: 1, fontSize: 12.5, color: p.text, fontWeight: 600 }}>Add a medication to avoid</span>
          <span style={{ fontFamily: MONO, fontSize: 10, color: p.textMuted, letterSpacing: 0.4 }}>RxTerms</span>
        </div>

        <div style={{ height: 12 }} />
        <div style={{
          background: p.primaryTint, border: `1px solid ${p.primaryLight}`,
          borderRadius: 12, padding: 12, display: 'flex', gap: 10,
        }}>
          <Info size={16} stroke={p.primary} />
          <div style={{ flex: 1, fontSize: 12.5, color: p.text, lineHeight: 1.45 }}>
            Coming up in <strong>Step 8 (Allergies)</strong>: anything you mark <em>Severe</em> there will nudge you back here to add it to this list.
          </div>
        </div>
      </div>

      <BottomBar />
    </Screen>
  );
}

// ─── Router for these new screens ─────────────────────────────────────
function HealthSteps({ name }) {
  return (
    <Surface kind="android">
    <AndroidShell width={422} height={860}>
      {(() => {
        switch (name) {
          case 'diagnoses':   return <ScrDiagnoses />;
          case 'allergies':   return <ScrAllergies />;
          case 'medications': return <ScrMedicationsV2 />;
          default: return null;
        }
      })()}
    </AndroidShell>
    </Surface>
  );
}

Object.assign(window, { HealthSteps, AutoComplete, HealthChip, SearchField, HealthStepHead });
