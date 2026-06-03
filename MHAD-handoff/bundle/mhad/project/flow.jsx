// flow.jsx — Before/After wizard flow consolidation diagram.

function FlowDiagram() {
  const { palette: p } = React.useContext(MHADContext);

  // Old flow — 15 steps in original order
  const oldSteps = [
    { n: 1, label: 'Personal Information' },
    { n: 2, label: 'Medical Diagnoses' },
    { n: 3, label: 'Effective Condition' },
    { n: 4, label: 'Treatment Facility' },
    { n: 5, label: 'Medications' },
    { n: 6, label: 'ECT Preferences' },
    { n: 7, label: 'Experimental Studies' },
    { n: 8, label: 'Drug Trials' },
    { n: 9, label: 'Additional Instructions' },
    { n: 10, label: 'Agent Designation' },
    { n: 11, label: 'Alternate Agent' },
    { n: 12, label: 'Agent Authority' },
    { n: 13, label: 'Guardian Nomination' },
    { n: 14, label: 'Review' },
    { n: 15, label: 'Execution' },
  ];

  // New flow — 9 consolidated steps. `from` maps to old step numbers it absorbs.
  const newSteps = [
    { n: 1, title: 'About you', sub: 'Just the basics so the document is uniquely yours.', from: [1], tone: 'core' },
    { n: 2, title: 'When this kicks in', sub: 'When you\'re considered unable to decide — including the conditions and any relevant diagnoses.', from: [2, 3], tone: 'merged' },
    { n: 3, title: 'People I trust', sub: 'Primary agent, alternate, and what they can decide — one screen with progressive sections.', from: [10, 11, 12], tone: 'merged', poaOnly: true },
    { n: 4, title: 'If a court appoints a guardian', sub: 'Your preferred guardian, in case it ever comes to that.', from: [13], tone: 'core' },
    { n: 5, title: 'Where I want care', sub: 'Facilities I prefer, and ones I want to avoid.', from: [4], tone: 'core' },
    { n: 6, title: 'Diagnoses', sub: 'ICD-10 autocomplete from the NLM clinical-tables API.', from: [], tone: 'new' },
    { n: 7, title: 'Allergies & reactions', sub: 'RxTerms autocomplete + severity + reaction chips. Cross-links into meds.', from: [], tone: 'new' },
    { n: 8, title: 'Medications', sub: 'Current meds (informational, RxTerms) and crisis preferences (binding).', from: [5, 6, 7], tone: 'merged' },
    { n: 9, title: 'Procedures & research', sub: 'ECT, experimental studies, drug trials — one screen, three consent tiles.', from: [6, 7, 8], tone: 'merged' },
    { n: 10, title: 'Anything else', sub: 'Free-form preferences not covered above.', from: [9], tone: 'core' },
    { n: 11, title: 'Review', sub: 'Final pass through every field before Sign & witness.', from: [14], tone: 'core' },
  ];

  // Color for merge highlight on the left column
  const mergedColor = (n) => {
    // group merges
    if ([2, 3].includes(n)) return { tone: 'merge1', label: '02' };       // diagnoses + effective condition
    if ([10, 11, 12].includes(n)) return { tone: 'merge2', label: '03' };
    if ([6, 7, 8].includes(n)) return { tone: 'merge3', label: '07' };
    if ([14, 15].includes(n)) return { tone: 'merge4', label: '09' };
    return null;
  };

  const mergeColors = {
    merge1: p.primary,
    merge2: p.primaryMid,
    merge3: p.primaryDark,
    merge4: p.primary,
  };

  return (
    <div style={{ background: p.scaffold, padding: '32px 40px', height: '100%', boxSizing: 'border-box', color: p.text, fontFamily: SANS, overflow: 'hidden' }}>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 14, marginBottom: 4 }}>
        <SectionLabel>Wizard flow · consolidation</SectionLabel>
      </div>
      <h2 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 38, margin: '4px 0 4px', fontWeight: 400, letterSpacing: -0.5 }}>
        Fewer screens, <span style={{ color: p.primary }}>same legal coverage.</span>
      </h2>
      <p style={{ fontSize: 13.5, color: p.textMuted, margin: 0, maxWidth: 720 }}>
        Three things in the original flow were doing the same job: deciding <em>who</em> speaks for you (3 screens), consenting to <em>special treatments</em> (3 screens), and <em>finishing</em> (2 screens). I merged them, reordered around the user's mental model — basics → when it activates → who decides → what I want — and dropped the count from 15 to 9.
      </p>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 80px 1.3fr', gap: 0, marginTop: 22, height: 460 }}>

        {/* LEFT — old */}
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 10 }}>
            <Badge tone="neutral">Before</Badge>
            <span style={{ fontSize: 12, color: p.textMuted }}>15 steps · current main branch</span>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
            {oldSteps.map((s) => {
              const m = mergedColor(s.n);
              return (
                <div key={s.n} style={{
                  display: 'flex', alignItems: 'center', gap: 10,
                  padding: '7px 12px',
                  background: m ? `${mergeColors[m.tone]}14` : p.card,
                  border: `1px solid ${m ? `${mergeColors[m.tone]}40` : p.border}`,
                  borderRadius: 8,
                  position: 'relative',
                }}>
                  <span style={{
                    fontFamily: MONO, fontSize: 10.5, fontWeight: 600,
                    color: m ? mergeColors[m.tone] : p.textMuted, width: 22,
                  }}>{String(s.n).padStart(2, '0')}</span>
                  <span style={{ fontSize: 13, color: p.text, flex: 1, textDecoration: m ? 'line-through' : 'none', textDecorationColor: `${mergeColors[m?.tone] || p.text}80`, textDecorationThickness: 1 }}>
                    {s.label}
                  </span>
                  {m && <span style={{
                    fontFamily: MONO, fontSize: 10, fontWeight: 700,
                    color: mergeColors[m.tone], padding: '2px 6px',
                    borderRadius: 4, background: `${mergeColors[m.tone]}18`,
                  }}>→ {m.label}</span>}
                </div>
              );
            })}
          </div>
        </div>

        {/* MIDDLE — arrow river */}
        <div style={{ position: 'relative', overflow: 'hidden' }}>
          <svg width="100%" height="100%" viewBox="0 0 80 460" preserveAspectRatio="none" style={{ display: 'block' }}>
            <defs>
              <marker id="arr" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
                <path d="M0 0 L10 5 L0 10 z" fill={p.textMuted}/>
              </marker>
            </defs>
            {/* Approximate line positions: 15 old rows over 460px = ~30.6px each; 9 new rows over 460px = ~51px each. Each old row centers at (i+0.5)*30.6, new at (j+0.5)*51 */}
            {(() => {
              const oldY = (n) => (n - 1) * 30.6 + 18;
              const newY = (n) => (n - 1) * 51 + 26;
              const lines = [
                [1, 1], [2, 2], [3, 2], [4, 5], [5, 6], [6, 7], [7, 7], [8, 7], [9, 8],
                [10, 3], [11, 3], [12, 3], [13, 4], [14, 9], [15, 9],
              ];
              return lines.map(([o, nw], i) => (
                <path key={i}
                  d={`M0 ${oldY(o)} C 40 ${oldY(o)}, 40 ${newY(nw)}, 78 ${newY(nw)}`}
                  fill="none" stroke={p.textMuted} strokeOpacity={0.45} strokeWidth={1}
                  markerEnd="url(#arr)"
                />
              ));
            })()}
          </svg>
        </div>

        {/* RIGHT — new */}
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 10 }}>
            <Badge tone="primary">After</Badge>
            <span style={{ fontSize: 12, color: p.textMuted }}>11 steps · proposed</span>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
            {newSteps.map((s) => (
              <div key={s.n} style={{
                display: 'flex', alignItems: 'flex-start', gap: 10,
                padding: '8px 12px',
                background: s.tone === 'new' ? p.primaryTint : p.card,
                border: `1px solid ${s.tone === 'merged' || s.tone === 'new' ? p.primary : p.border}`,
                borderLeft: `3px solid ${s.tone === 'merged' || s.tone === 'new' ? p.primary : p.primaryLight}`,
                borderRadius: 8, minHeight: 42, boxSizing: 'border-box',
              }}>
                <span style={{
                  fontFamily: SERIF, fontStyle: 'italic', fontSize: 22, lineHeight: 1,
                  color: p.primary, width: 28, marginTop: 1,
                }}>{String(s.n).padStart(2, '0')}</span>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 13.5, fontWeight: 600, color: p.text, display: 'flex', alignItems: 'center', gap: 6 }}>
                    {s.title}
                    {s.tone === 'merged' && (
                      <span style={{ fontFamily: MONO, fontSize: 9.5, fontWeight: 700, color: p.primary, background: p.primaryLight, padding: '2px 6px', borderRadius: 4 }}>
                        MERGES {s.from.length}
                      </span>
                    )}
                    {s.tone === 'new' && (
                      <span style={{ fontFamily: MONO, fontSize: 9.5, fontWeight: 700, color: p.onPrimary, background: p.primary, padding: '2px 6px', borderRadius: 4 }}>
                        NEW
                      </span>
                    )}
                    {s.poaOnly && (
                      <span style={{ fontFamily: MONO, fontSize: 9.5, fontWeight: 700, color: p.textMuted, background: p.surface, padding: '2px 6px', borderRadius: 4, border: `1px solid ${p.border}` }}>
                        COMBINED / POA ONLY
                      </span>
                    )}
                  </div>
                  <div style={{ fontSize: 11.5, color: p.textMuted, marginTop: 2, lineHeight: 1.35 }}>
                    {s.sub}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { FlowDiagram });
