// web.jsx — Desktop / web screens, framed in a browser window.

function Web({ name }) {
  return (
    <ChromeWindow tabs={[{ title: 'PA MHAD · onica5000.github.io' }, { title: '988 Lifeline' }]} url="onica5000.github.io/MHAD/">
      {(() => {
        switch (name) {
          case 'dashboard': return <WebDashboard />;
          case 'wizard': return <WebWizard />;
          case 'export': return <WebExport />;
          case 'learn': return <WebLearn />;
          case 'ai': return <WebAI />;
          default: return null;
        }
      })()}
    </ChromeWindow>
  );
}

// ChromeWindow wrapper that we use here — give the children a real bg
function ChromeWindow({ children, tabs, url }) {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <div style={{ width: '100%', height: '100%', display: 'flex', flexDirection: 'column', background: p.scaffold, fontFamily: SANS, overflow: 'hidden' }}>
      <ChromeTabBar tabs={tabs} activeIndex={0} />
      <ChromeToolbar url={url} />
      <div style={{ flex: 1, overflow: 'hidden', display: 'flex' }}>{children}</div>
    </div>
  );
}

// ─── Web sidebar nav (shared) ────────────────────────────────────────────
function WebSidebar({ active = 'home' }) {
  const { palette: p } = React.useContext(MHADContext);
  const items = [
    { id: 'home', icon: <Home size={18} />, label: 'My directives' },
    { id: 'learn', icon: <Book size={18} />, label: 'Learn' },
    { id: 'ai', icon: <Sparkles size={18} />, label: 'AI assistant' },
    { id: 'export', icon: <FileText size={18} />, label: 'Export & share' },
    { id: 'settings', icon: <Gear size={18} />, label: 'Settings' },
  ];
  return (
    <div style={{
      width: 232, background: p.card, borderRight: `1px solid ${p.border}`,
      display: 'flex', flexDirection: 'column', padding: '20px 14px',
    }}>
      {/* Brand */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '0 8px 16px', borderBottom: `1px solid ${p.border}`, marginBottom: 12 }}>
        <div style={{
          width: 32, height: 32, borderRadius: 8,
          background: p.primary, color: p.onPrimary,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontFamily: SERIF, fontStyle: 'italic', fontSize: 18, fontWeight: 400,
        }}>m</div>
        <div>
          <div style={{ fontSize: 13, fontWeight: 700, letterSpacing: -0.2 }}>PA MHAD</div>
          <div style={{ fontSize: 10, color: p.textMuted, fontFamily: MONO, letterSpacing: 0.6 }}>ACT 194 · 2004</div>
        </div>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
        {items.map(it => (
          <div key={it.id} style={{
            display: 'flex', alignItems: 'center', gap: 10,
            padding: '9px 10px', borderRadius: 8,
            fontSize: 13.5, fontWeight: 500,
            background: active === it.id ? p.primaryLight : 'transparent',
            color: active === it.id ? p.onPrimaryLight : p.textMuted,
          }}>{it.icon}<span>{it.label}</span></div>
        ))}
      </div>

      <div style={{ flex: 1 }} />

      {/* Crisis card pinned to bottom of sidebar */}
      <div style={{
        background: p.crisisBg, border: `1px solid ${p.crisisBorder}`,
        borderRadius: 12, padding: 12, color: p.crisisText,
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 4 }}>
          <Phone size={14} stroke={p.crisisAccent} />
          <span style={{ fontFamily: MONO, fontSize: 10.5, fontWeight: 700, letterSpacing: 0.7 }}>24/7 LIFELINE</span>
        </div>
        <div style={{ fontSize: 13, fontWeight: 700, color: p.crisisText }}>988 · Call or text</div>
        <div style={{ fontSize: 11.5, color: p.crisisText, opacity: 0.85, marginTop: 2 }}>Free, confidential, anytime.</div>
      </div>

      {/* User chip */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '12px 8px 0' }}>
        <div style={{
          width: 30, height: 30, borderRadius: 100, background: p.primary, color: p.onPrimary,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: 11.5, fontWeight: 700,
        }}>AK</div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: 12.5, fontWeight: 600, color: p.text }}>Alex Kowalski</div>
          <div style={{ fontSize: 10.5, color: p.textMuted, fontFamily: MONO, letterSpacing: 0.4 }}>● PRIVATE · FACE ID</div>
        </div>
      </div>
    </div>
  );
}

// ─── Dashboard ──────────────────────────────────────────────────────────
function WebDashboard() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <>
      <WebSidebar active="home" />
      <div style={{ flex: 1, overflow: 'auto', padding: '32px 40px 40px' }}>
        {/* Hero */}
        <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', marginBottom: 26 }}>
          <div>
            <SectionLabel>Saturday · May 14, 2026</SectionLabel>
            <h1 style={{
              fontFamily: SERIF, fontStyle: 'italic', fontSize: 56, margin: '4px 0 0',
              fontWeight: 400, letterSpacing: -1, lineHeight: 1,
            }}>
              Hi, Alex. <span style={{ color: p.textMuted }}>Pick up where you left off.</span>
            </h1>
          </div>
          <Btn kind="primary" leading={<Plus size={16} />}>New directive</Btn>
        </div>

        {/* In-progress directive — full-width feature card */}
        <div style={{
          background: p.primary, color: p.onPrimary, borderRadius: 20,
          padding: '28px 32px', position: 'relative', overflow: 'hidden',
          display: 'grid', gridTemplateColumns: '1.4fr 1fr', gap: 32,
        }}>
          <div style={{
            position: 'absolute', right: -20, top: -60,
            fontFamily: SERIF, fontStyle: 'italic', fontSize: 320, lineHeight: 1,
            color: 'rgba(255,255,255,0.08)', fontWeight: 400,
          }}>03</div>
          <div style={{ position: 'relative' }}>
            <Badge tone="primary" style={{ background: 'rgba(255,255,255,0.18)', color: p.onPrimary }}>● Draft · auto-saved</Badge>
            <h2 style={{ fontSize: 28, fontWeight: 700, margin: '8px 0 4px', letterSpacing: -0.5 }}>My MHAD · Combined form</h2>
            <p style={{ margin: 0, fontSize: 14, opacity: 0.85 }}>Step 3 of 9 · People I trust · last edited 2 hours ago</p>
            <div style={{ display: 'flex', gap: 8, marginTop: 18 }}>
              <Btn kind="dark" style={{ background: '#fff', color: p.primaryDark }} trailing={<Arrow size={16} />}>Continue draft</Btn>
              <Btn kind="ghost" style={{ color: '#fff' }}>Preview PDF</Btn>
            </div>
          </div>
          <div style={{ position: 'relative' }}>
            {/* Step progress list */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: 5 }}>
              {[
                ['01', 'About you', 'done'],
                ['02', 'When this kicks in', 'done'],
                ['03', 'People I trust', 'current'],
                ['04', 'Guardian', ''],
                ['05', 'Where I want care', ''],
                ['06', 'Medications', ''],
                ['07', 'Procedures & research', ''],
                ['08', 'Anything else', ''],
                ['09', 'Sign & witness', ''],
              ].map(([n, label, state]) => (
                <div key={n} style={{
                  display: 'flex', alignItems: 'center', gap: 10,
                  padding: '5px 10px', borderRadius: 6,
                  background: state === 'current' ? 'rgba(255,255,255,0.18)' : 'transparent',
                  fontSize: 12.5,
                }}>
                  <span style={{ fontFamily: MONO, fontSize: 10.5, opacity: 0.7, width: 18 }}>{n}</span>
                  <span style={{ flex: 1, fontWeight: state === 'current' ? 700 : 400, opacity: state ? 1 : 0.6 }}>{label}</span>
                  {state === 'done' && <Check size={12} stroke={p.onPrimary} sw={3} />}
                  {state === 'current' && <span style={{ fontSize: 10, fontWeight: 700, opacity: 0.85 }}>NOW</span>}
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Tools row */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 14, marginTop: 24 }}>
          {[
            { icon: <Sparkles size={18} />, title: 'AI assistant', sub: 'Field suggestions, plain-language explanations.', cta: 'Ask anything' },
            { icon: <Wallet size={18} />, title: 'Wallet card', sub: 'Carry an emergency-readable summary.', cta: 'Preview' },
            { icon: <Share size={18} />, title: 'Share with provider', sub: 'Email, print, or generate a QR.', cta: 'Send' },
            { icon: <Calendar size={18} />, title: 'Renew on schedule', sub: 'Active through May 14, 2028.', cta: '30-day reminder' },
          ].map((t, i) => (
            <div key={i} style={{
              background: p.card, border: `1px solid ${p.border}`, borderRadius: 14,
              padding: 16, display: 'flex', flexDirection: 'column',
            }}>
              <div style={{ width: 34, height: 34, borderRadius: 8, background: p.primaryTint, color: p.primary, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 10 }}>{t.icon}</div>
              <div style={{ fontSize: 14, fontWeight: 700, color: p.text }}>{t.title}</div>
              <div style={{ fontSize: 12, color: p.textMuted, marginTop: 3, lineHeight: 1.4, flex: 1 }}>{t.sub}</div>
              <div style={{ fontSize: 12, fontWeight: 700, color: p.primary, marginTop: 10 }}>{t.cta} →</div>
            </div>
          ))}
        </div>

        {/* Past + Learn */}
        <div style={{ display: 'grid', gridTemplateColumns: '1.4fr 1fr', gap: 18, marginTop: 24 }}>
          <div>
            <SectionLabel>Past directives</SectionLabel>
            <div style={{ marginTop: 8, background: p.card, border: `1px solid ${p.border}`, borderRadius: 12, padding: '6px 14px' }}>
              {[
                { title: 'Directive · 2023', sub: 'Combined · expired May 2025', badge: 'Expired', tone: 'warn' },
                { title: 'Directive · 2021', sub: 'Declaration only · expired May 2023', badge: 'Expired', tone: 'warn' },
              ].map((d, i) => (
                <div key={i} style={{
                  display: 'flex', alignItems: 'center', gap: 12, padding: '12px 0',
                  borderBottom: i === 0 ? `1px solid ${p.border}` : 'none',
                }}>
                  <FileText size={18} stroke={p.textMuted} />
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: 13.5, fontWeight: 600 }}>{d.title}</div>
                    <div style={{ fontSize: 12, color: p.textMuted }}>{d.sub}</div>
                  </div>
                  <Badge tone={d.tone}>{d.badge}</Badge>
                  <DotsH size={16} stroke={p.textMuted} />
                </div>
              ))}
            </div>
          </div>
          <div>
            <SectionLabel>From the booklet</SectionLabel>
            <div style={{
              marginTop: 8, background: p.primaryTint, border: `1px solid ${p.primary}30`,
              borderRadius: 12, padding: 16,
            }}>
              <div style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 22, color: p.primaryDark, lineHeight: 1.2 }}>
                "An MHAD is your voice when you can't speak for yourself."
              </div>
              <div style={{ fontSize: 11.5, color: p.textMuted, marginTop: 8, fontFamily: MONO, letterSpacing: 0.6 }}>
                — PA MHAD booklet · Office of Mental Health
              </div>
              <Btn kind="ghost" style={{ marginTop: 10, height: 36, padding: '0 0' }}>Read 4-min summary →</Btn>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}

// ─── Wizard desktop ─────────────────────────────────────────────────────
function WebWizard() {
  const { palette: p } = React.useContext(MHADContext);

  return (
    <>
      <WebSidebar active="home" />
      <div style={{ flex: 1, overflow: 'auto' }}>
        {/* Top bar with progress */}
        <div style={{
          display: 'flex', alignItems: 'center', gap: 16,
          padding: '14px 32px', borderBottom: `1px solid ${p.border}`,
          background: p.card,
        }}>
          <span style={{ fontSize: 13, color: p.textMuted, display: 'flex', alignItems: 'center', gap: 6 }}>
            <Icon d="M15 18l-6-6 6-6" size={14} /> My MHAD
          </span>
          <div style={{ flex: 1, height: 6, background: p.border, borderRadius: 100, overflow: 'hidden', maxWidth: 380 }}>
            <div style={{ height: '100%', width: '33%', background: p.primary, borderRadius: 100 }} />
          </div>
          <span style={{ fontSize: 12, color: p.textMuted, fontFamily: MONO }}>3 / 9</span>
          <div style={{ flex: 1 }} />
          <Btn kind="ghost" size="sm">Save & exit</Btn>
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: '180px 1fr 320px', gap: 0, minHeight: 'calc(100% - 56px)' }}>
          {/* Step rail */}
          <div style={{ padding: '32px 0 32px 24px', borderRight: `1px solid ${p.border}` }}>
            {[
              ['01', 'About you', 'done'],
              ['02', 'When this kicks in', 'done'],
              ['03', 'People I trust', 'current'],
              ['04', 'Guardian', ''],
              ['05', 'Where I want care', ''],
              ['06', 'Medications', ''],
              ['07', 'Procedures', ''],
              ['08', 'Anything else', ''],
              ['09', 'Sign & witness', ''],
            ].map(([n, label, state]) => (
              <div key={n} style={{
                display: 'flex', alignItems: 'center', gap: 8, padding: '7px 12px 7px 0',
                fontSize: 12.5, fontWeight: state === 'current' ? 700 : 500,
                color: state === 'current' ? p.text : (state === 'done' ? p.text : p.textMuted),
                borderLeft: `3px solid ${state === 'current' ? p.primary : 'transparent'}`,
                paddingLeft: state === 'current' ? 9 : 12,
                marginLeft: state === 'current' ? -3 : 0,
              }}>
                <span style={{ fontFamily: MONO, fontSize: 10.5, opacity: state ? 0.7 : 0.4, width: 18 }}>{n}</span>
                <span style={{ flex: 1, textDecoration: state === 'done' ? '' : 'none' }}>{label}</span>
                {state === 'done' && <Check size={12} stroke={p.primary} sw={3} />}
              </div>
            ))}
          </div>

          {/* Main form */}
          <div style={{ padding: '36px 40px 80px', overflow: 'auto' }}>
            <div style={{ display: 'flex', alignItems: 'baseline', gap: 16 }}>
              <span style={{
                fontFamily: SERIF, fontStyle: 'italic', fontSize: 86, lineHeight: 1,
                color: p.primary, letterSpacing: -2,
              }}>03</span>
              <div>
                <h1 style={{ fontFamily: SANS, fontSize: 30, fontWeight: 700, margin: 0, letterSpacing: -0.5 }}>
                  People I trust
                </h1>
                <p style={{ margin: '4px 0 0', fontSize: 14, color: p.textMuted, maxWidth: 520, lineHeight: 1.5 }}>
                  They speak for you if you can't. You can name a primary, an alternate, and set limits on what they decide.
                </p>
              </div>
            </div>

            <div style={{ height: 24 }} />

            {/* Two-column agent layout */}
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14 }}>
              {/* Primary agent */}
              <div style={{ background: p.card, border: `1.5px solid ${p.primary}`, borderRadius: TOK.rCard, padding: 18 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 14 }}>
                  <Badge tone="primary">Primary agent</Badge>
                  <span style={{ fontSize: 11, color: p.textMuted, fontFamily: MONO, letterSpacing: 0.4 }}>REQUIRED</span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 14 }}>
                  <div style={{ width: 50, height: 50, borderRadius: 100, background: p.primary, color: p.onPrimary, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 16, fontWeight: 700 }}>JL</div>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: 16, fontWeight: 700 }}>Jordan Lee</div>
                    <div style={{ fontSize: 12.5, color: p.textMuted }}>Sister · (412) 555-0188</div>
                  </div>
                  <Btn kind="ghost" size="sm">Edit</Btn>
                </div>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
                  <Field label="Email" value="jordan.lee@example.com" />
                  <Field label="Relationship" value="Sister" />
                </div>
              </div>

              {/* Alternate */}
              <div style={{ background: p.card, border: `1.5px solid ${p.border}`, borderRadius: TOK.rCard, padding: 18 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 14 }}>
                  <Badge tone="neutral">Alternate</Badge>
                  <span style={{ fontSize: 11, color: p.textMuted, fontFamily: MONO, letterSpacing: 0.4 }}>RECOMMENDED</span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 14 }}>
                  <div style={{ width: 50, height: 50, borderRadius: 100, background: p.primaryLight, color: p.onPrimaryLight, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 16, fontWeight: 700 }}>SR</div>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: 16, fontWeight: 700 }}>Sam Reyes</div>
                    <div style={{ fontSize: 12.5, color: p.textMuted }}>Spouse · (412) 555-0177</div>
                  </div>
                  <Btn kind="ghost" size="sm">Edit</Btn>
                </div>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
                  <Field label="Email" value="sam.reyes@example.com" />
                  <Field label="Relationship" value="Spouse" />
                </div>
              </div>
            </div>

            <div style={{ height: 28 }} />

            {/* Authority */}
            <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 12 }}>
              <h3 style={{ fontFamily: SANS, fontSize: 18, fontWeight: 700, margin: 0, letterSpacing: -0.2 }}>What can they decide?</h3>
              <span style={{ fontSize: 12, color: p.textMuted }}>5 questions · 2 min</span>
            </div>

            <div style={{ background: p.card, border: `1px solid ${p.border}`, borderRadius: TOK.rCard, padding: '4px 18px' }}>
              {[
                ['Talk to my doctors and review my records', 'yes'],
                ['Admit me to a mental health facility', 'if'],
                ['Consent to medications on my behalf', 'agent'],
                ['Consent to ECT (electroconvulsive therapy)', 'no'],
                ['Decide where I live during treatment', 'agent'],
              ].map(([label, val], i, arr) => (
                <div key={i} style={{
                  display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 18,
                  padding: '14px 0',
                  borderBottom: i < arr.length - 1 ? `1px solid ${p.border}` : 'none',
                }}>
                  <div style={{ fontSize: 14, fontWeight: 500, color: p.text }}>{label}</div>
                  <div><ConsentRow value={val} /></div>
                </div>
              ))}
            </div>

            <div style={{ height: 28 }} />
            <div style={{ display: 'flex', gap: 10 }}>
              <Btn kind="outline">← Back to step 02</Btn>
              <div style={{ flex: 1 }} />
              <Btn kind="ghost">Skip optional</Btn>
              <Btn kind="primary" trailing={<Arrow size={16} />}>Continue to step 04</Btn>
            </div>
          </div>

          {/* AI / preview panel */}
          <div style={{ background: p.card, borderLeft: `1px solid ${p.border}`, padding: '28px 22px', overflow: 'auto' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 14 }}>
              <div style={{ width: 28, height: 28, borderRadius: 8, background: p.primaryTint, color: p.primary, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Sparkles size={16} />
              </div>
              <div>
                <div style={{ fontSize: 13, fontWeight: 700 }}>AI assistant</div>
                <div style={{ fontSize: 10.5, color: p.textMuted, fontFamily: MONO, letterSpacing: 0.4 }}>GEMINI · PII STRIPPED</div>
              </div>
            </div>

            <div style={{ background: p.primaryTint, border: `1px solid ${p.primary}25`, borderRadius: 12, padding: 12 }}>
              <div style={{ fontSize: 12, fontWeight: 700, color: p.primaryDark, marginBottom: 6 }}>Heads up on this step</div>
              <p style={{ fontSize: 12.5, color: p.text, margin: 0, lineHeight: 1.5 }}>
                You picked <strong>"No"</strong> for ECT consent. Under PA Act 194, this binds your agent — they cannot override it. Make sure this matches your intent.
              </p>
              <div style={{ display: 'flex', gap: 6, marginTop: 10 }}>
                <span style={{ fontSize: 11, fontWeight: 700, color: p.primary, cursor: 'pointer' }}>Keep "No"</span>
                <span style={{ fontSize: 11, color: p.textMuted }}>·</span>
                <span style={{ fontSize: 11, fontWeight: 700, color: p.primary, cursor: 'pointer' }}>Change to "If…"</span>
              </div>
            </div>

            <div style={{ height: 14 }} />
            <SectionLabel>Suggested questions</SectionLabel>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6, marginTop: 8 }}>
              {[
                'What\'s the difference between an agent and a guardian?',
                'Can my agent override my medication preferences?',
                'What if both my agent and alternate are unavailable?',
                'Show me example language for ECT limits',
              ].map((q, i) => (
                <div key={i} style={{
                  background: p.surface, border: `1px solid ${p.border}`, borderRadius: 10,
                  padding: '9px 11px', fontSize: 12.5, color: p.text, cursor: 'pointer',
                }}>{q}</div>
              ))}
            </div>

            <div style={{ height: 14 }} />
            <div style={{
              display: 'flex', alignItems: 'center', gap: 8,
              background: p.surface, border: `1.5px solid ${p.border}`, borderRadius: 100,
              padding: '6px 6px 6px 14px',
            }}>
              <input style={{
                flex: 1, border: 'none', outline: 'none', background: 'transparent',
                fontFamily: SANS, fontSize: 13, color: p.text,
              }} placeholder="Ask anything about your directive…" />
              <div style={{ width: 32, height: 32, borderRadius: 100, background: p.primary, color: p.onPrimary, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Arrow size={14} stroke={p.onPrimary} />
              </div>
            </div>
            <p style={{ fontSize: 10, color: p.textMuted, margin: '8px 4px 0', lineHeight: 1.4 }}>
              AI-generated · not legal advice. Review any suggestion before accepting.
            </p>
          </div>
        </div>
      </div>
    </>
  );
}

// ─── Export / PDF preview ─────────────────────────────────────────────
function WebExport() {
  const { palette: p } = React.useContext(MHADContext);

  return (
    <>
      <WebSidebar active="export" />
      <div style={{ flex: 1, overflow: 'auto', display: 'grid', gridTemplateColumns: '1fr 320px' }}>
        {/* PDF preview */}
        <div style={{ padding: '24px 32px 40px', background: p.surface }}>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: 12, marginBottom: 12 }}>
            <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 38, margin: 0, fontWeight: 400, letterSpacing: -0.5 }}>
              Your directive, <span style={{ color: p.primary }}>on paper.</span>
            </h1>
          </div>
          <p style={{ fontSize: 13, color: p.textMuted, margin: '0 0 14px', maxWidth: 540 }}>
            Pixel-perfect to the official PA MHAD form. Print on letter-size paper.
          </p>

          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 14 }}>
            <Btn kind="ghost" size="sm">← Page 1 of 6</Btn>
            <div style={{ flex: 1 }} />
            <span style={{ fontSize: 12, color: p.textMuted, fontFamily: MONO }}>ZOOM 90%</span>
            <Btn kind="ghost" size="sm" leading={<Icon d="M21 21l-4.3-4.3M11 11m-7 0a7 7 0 1 0 14 0a7 7 0 1 0-14 0" size={14}/>}>Find</Btn>
          </div>

          {/* Mock PDF page */}
          <div style={{
            background: '#fff', boxShadow: '0 4px 24px rgba(0,0,0,0.08)',
            border: `1px solid ${p.border}`, borderRadius: 4,
            padding: '40px 48px', maxWidth: 620, margin: '0 auto',
            fontFamily: 'Times, Georgia, serif', color: '#1a1a1a',
          }}>
            <div style={{ textAlign: 'center', fontSize: 11, letterSpacing: 1, color: '#555' }}>COMMONWEALTH OF PENNSYLVANIA · ACT 194 OF 2004</div>
            <h1 style={{ textAlign: 'center', fontSize: 22, fontWeight: 700, margin: '14px 0 4px' }}>
              MENTAL HEALTH ADVANCE DIRECTIVE
            </h1>
            <div style={{ textAlign: 'center', fontSize: 12, color: '#555', marginBottom: 22 }}>Combined Declaration &amp; Power of Attorney</div>

            <div style={{ fontSize: 11.5, lineHeight: 1.55 }}>
              <p style={{ margin: '8px 0' }}><strong>I, ALEX M. KOWALSKI</strong>, of Allegheny County, Pennsylvania, being of sound mind, voluntarily make this Mental Health Advance Directive under the provisions of Act 194 of 2004.</p>

              <p style={{ margin: '14px 0 6px', fontWeight: 700 }}>SECTION 1. EFFECTIVE CONDITION</p>
              <p style={{ margin: '4px 0' }}>This directive shall become effective when a physician and a mental health professional have determined that I am incapable of making mental health treatment decisions.</p>

              <p style={{ margin: '14px 0 6px', fontWeight: 700 }}>SECTION 2. DESIGNATION OF AGENT</p>
              <p style={{ margin: '4px 0' }}>I hereby appoint <strong>JORDAN LEE</strong>, my sister, residing at 87 Forbes Ave, Pittsburgh PA, telephone (412) 555-0188, as my mental health treatment agent…</p>

              <div style={{ borderTop: '1px dashed #999', margin: '14px 0' }} />
              <p style={{ fontSize: 10, color: '#777', textAlign: 'center' }}>— continued on page 2 —</p>
            </div>
          </div>

          {/* page rail */}
          <div style={{ display: 'flex', justifyContent: 'center', gap: 4, marginTop: 14 }}>
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={i} style={{
                width: 28, height: 36,
                background: i === 0 ? p.primary : p.card,
                border: `1px solid ${i === 0 ? p.primary : p.border}`,
                borderRadius: 3,
                color: i === 0 ? p.onPrimary : p.textMuted,
                fontSize: 11, fontFamily: MONO, fontWeight: 600,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>{i + 1}</div>
            ))}
          </div>
        </div>

        {/* Right column controls */}
        <div style={{ borderLeft: `1px solid ${p.border}`, background: p.card, padding: '24px 22px', overflow: 'auto' }}>
          <SectionLabel>Include sections</SectionLabel>
          <div style={{ marginTop: 10, display: 'flex', flexDirection: 'column', gap: 4 }}>
            {[
              ['Declaration (treatment preferences)', true],
              ['Power of Attorney (agent authority)', true],
              ['Guardian nomination', true],
              ['Wallet-card summary', true],
              ['Distribution checklist (for me)', false],
              ['FHIR JSON copy (for EHR)', false],
            ].map(([label, on], i) => (
              <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '7px 0' }}>
                <div style={{
                  width: 18, height: 18, borderRadius: 4,
                  background: on ? p.primary : 'transparent',
                  border: on ? 'none' : `1.5px solid ${p.border}`,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  {on && <Check size={12} stroke={p.onPrimary} sw={3} />}
                </div>
                <span style={{ fontSize: 13, color: on ? p.text : p.textMuted, fontWeight: on ? 600 : 500 }}>{label}</span>
              </div>
            ))}
          </div>

          <div style={{ height: 18, borderBottom: `1px solid ${p.border}`, marginBottom: 14 }} />

          <SectionLabel>Wallet card</SectionLabel>
          <div style={{
            marginTop: 8,
            background: `linear-gradient(135deg, ${p.primary}, ${p.primaryDark})`,
            color: p.onPrimary, borderRadius: 10, padding: 12,
            position: 'relative', overflow: 'hidden',
          }}>
            <div style={{ position: 'absolute', right: -10, top: -16, fontFamily: SERIF, fontStyle: 'italic', fontSize: 90, color: 'rgba(255,255,255,0.1)', lineHeight: 1 }}>MH</div>
            <div style={{ fontFamily: MONO, fontSize: 9, letterSpacing: 1, opacity: 0.8, position: 'relative' }}>PA MHAD · 2026</div>
            <div style={{ fontSize: 13, fontWeight: 700, marginTop: 4, position: 'relative' }}>Alex M. Kowalski</div>
            <div style={{ fontSize: 10, opacity: 0.85, marginTop: 2, position: 'relative' }}>Agent: Jordan Lee · 412 555-0188</div>
            <div style={{ marginTop: 8, height: 36, background: 'rgba(255,255,255,0.95)', borderRadius: 4, display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative' }}>
              <QR size={28} stroke={p.primaryDark} />
              <span style={{ fontFamily: MONO, fontSize: 10, color: p.primaryDark, marginLeft: 8 }}>scan to verify · valid 05/2028</span>
            </div>
          </div>

          <div style={{ height: 18 }} />
          <Btn kind="primary" full leading={<Download size={16} />}>Download PDF</Btn>
          <div style={{ height: 8 }} />
          <div style={{ display: 'flex', gap: 8 }}>
            <Btn kind="outline" leading={<Share size={14} />} style={{ flex: 1 }}>Share</Btn>
            <Btn kind="outline" leading={<Icon size={14}><path d="M6 9V2h12v7"/><rect x="6" y="14" width="12" height="8"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/></Icon>} style={{ flex: 1 }}>Print</Btn>
          </div>

          <div style={{
            background: p.warnBg, border: `1px solid ${p.warnBorder}`,
            borderRadius: 10, padding: 12, marginTop: 16,
            display: 'flex', gap: 10, color: p.warnText, fontSize: 12, lineHeight: 1.45,
          }}>
            <AlertTri size={16} stroke={p.warnText} />
            <div>
              <strong>Sign before sharing.</strong> The PDF is unsigned. Print, sign in front of 2 adult witnesses, then distribute.
            </div>
          </div>
        </div>
      </div>
    </>
  );
}

// ─── Learn hub ─────────────────────────────────────────────────────────
function WebLearn() {
  const { palette: p } = React.useContext(MHADContext);

  const Tile = ({ icon, title, sub, minutes, big }) => (
    <div style={{
      background: p.card, border: `1px solid ${p.border}`, borderRadius: TOK.rCard,
      padding: big ? 22 : 18, gridColumn: big ? 'span 2' : 'auto',
      display: 'flex', flexDirection: 'column', minHeight: big ? 'auto' : 160,
      position: 'relative', overflow: 'hidden',
    }}>
      <div style={{ width: 36, height: 36, borderRadius: 10, background: p.primaryTint, color: p.primary, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 10 }}>{icon}</div>
      <h3 style={{ margin: 0, fontSize: big ? 22 : 16, fontWeight: 700, letterSpacing: -0.3 }}>{title}</h3>
      <p style={{ margin: '4px 0 0', fontSize: 12.5, color: p.textMuted, lineHeight: 1.5, flex: 1 }}>{sub}</p>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 12 }}>
        <span style={{ fontFamily: MONO, fontSize: 10.5, color: p.textMuted, letterSpacing: 0.6 }}>{minutes}</span>
        <div style={{ flex: 1 }} />
        <Arrow size={14} stroke={p.primary} />
      </div>
    </div>
  );

  return (
    <>
      <WebSidebar active="learn" />
      <div style={{ flex: 1, overflow: 'auto', padding: '32px 40px 40px' }}>
        <SectionLabel>Education</SectionLabel>
        <h1 style={{
          fontFamily: SERIF, fontStyle: 'italic', fontSize: 56, margin: '4px 0 0',
          fontWeight: 400, letterSpacing: -1, lineHeight: 1,
        }}>
          Understand <span style={{ color: p.primary }}>before</span> you sign.
        </h1>
        <p style={{ fontSize: 14, color: p.textMuted, margin: '12px 0 0', maxWidth: 560, lineHeight: 1.5 }}>
          Everything below comes verbatim from the official PA MHAD booklet. No marketing, no opinions — just the rules and what they mean.
        </p>

        <div style={{ height: 24 }} />
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 14 }}>
          <Tile
            big
            icon={<Book size={20} />}
            title="What is an MHAD?"
            sub="The 4-minute version. A plain-language introduction to what a Mental Health Advance Directive is, who can make one, and what makes it legally binding under PA Act 194."
            minutes="4 MIN · MOST POPULAR"
          />
          <Tile icon={<Info size={20} />} title="FAQ" sub="The 18 most-asked questions, answered." minutes="6 MIN" />
          <Tile icon={<FileText size={20} />} title="Glossary" sub="Plain-language definitions of every legal term in the form." minutes="2 MIN · LOOKUP" />

          <Tile icon={<Check size={20} />} title="Step-by-step checklist" sub="Everything you need to do before, during, and after signing." minutes="3 MIN" />
          <Tile icon={<Users size={20} />} title="Choosing an agent" sub="How to pick the right person — and who can't be your agent." minutes="5 MIN" />
          <Tile icon={<Shield size={20} />} title="Your legal rights" sub="What providers must do — and what you can do if they don't." minutes="7 MIN" />
          <Tile icon={<Brain size={20} />} title="When does it activate?" sub="The specific conditions that trigger an MHAD." minutes="3 MIN" />
        </div>

        <div style={{ height: 22 }} />
        {/* Pull-quote from booklet */}
        <div style={{
          background: p.primaryTint, border: `1px solid ${p.primary}25`,
          borderRadius: 16, padding: '24px 28px', display: 'grid', gridTemplateColumns: '1fr 200px', alignItems: 'center', gap: 24,
        }}>
          <div>
            <div style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 26, color: p.primaryDark, lineHeight: 1.25 }}>
              "Your directive is your voice — written in advance, kept safe, honored when you can't speak for yourself."
            </div>
            <div style={{ fontSize: 11, color: p.textMuted, fontFamily: MONO, letterSpacing: 0.6, marginTop: 10 }}>
              — PA OFFICE OF MENTAL HEALTH &amp; SUBSTANCE ABUSE SERVICES · BOOKLET P.3
            </div>
          </div>
          <Btn kind="primary" trailing={<Arrow size={16} />}>Read the booklet</Btn>
        </div>
      </div>
    </>
  );
}

// ─── AI assistant ─────────────────────────────────────────────────────
function WebAI() {
  const { palette: p } = React.useContext(MHADContext);

  const Msg = ({ from, text, suggestion, applyTo }) => (
    <div style={{ display: 'flex', gap: 12, marginBottom: 18 }}>
      <div style={{
        width: 30, height: 30, borderRadius: 8, flexShrink: 0,
        background: from === 'ai' ? p.primaryTint : p.primary,
        color: from === 'ai' ? p.primary : p.onPrimary,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontWeight: 700, fontSize: 12,
      }}>{from === 'ai' ? <Sparkles size={16} /> : 'AK'}</div>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 11, fontWeight: 700, color: p.textMuted, fontFamily: MONO, letterSpacing: 0.6, marginBottom: 4 }}>
          {from === 'ai' ? 'GEMINI · NOT LEGAL ADVICE' : 'YOU'}
        </div>
        <div style={{ fontSize: 14, color: p.text, lineHeight: 1.55 }} dangerouslySetInnerHTML={{ __html: text }} />
        {suggestion && (
          <div style={{
            marginTop: 10, background: p.primaryTint, border: `1px solid ${p.primary}25`,
            borderRadius: 10, padding: 12,
          }}>
            <div style={{ fontFamily: MONO, fontSize: 10, fontWeight: 700, color: p.primary, letterSpacing: 0.6, marginBottom: 4 }}>SUGGESTED FOR: {applyTo}</div>
            <div style={{ fontSize: 13.5, color: p.text, lineHeight: 1.5, fontStyle: 'italic' }}>"{suggestion}"</div>
            <div style={{ display: 'flex', gap: 6, marginTop: 10 }}>
              <Btn kind="primary" size="sm">Use this</Btn>
              <Btn kind="ghost" size="sm">Edit first</Btn>
              <Btn kind="ghost" size="sm">Discard</Btn>
            </div>
          </div>
        )}
      </div>
    </div>
  );

  return (
    <>
      <WebSidebar active="ai" />
      <div style={{ flex: 1, display: 'grid', gridTemplateColumns: '1fr 280px', overflow: 'hidden' }}>
        {/* chat */}
        <div style={{ display: 'flex', flexDirection: 'column', borderRight: `1px solid ${p.border}` }}>
          {/* header */}
          <div style={{
            padding: '20px 32px', borderBottom: `1px solid ${p.border}`,
            display: 'flex', alignItems: 'center', gap: 12,
          }}>
            <div style={{ width: 38, height: 38, borderRadius: 10, background: p.primaryTint, color: p.primary, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Sparkles size={20} />
            </div>
            <div style={{ flex: 1 }}>
              <h2 style={{ margin: 0, fontSize: 18, fontWeight: 700, letterSpacing: -0.2 }}>AI assistant</h2>
              <div style={{ fontSize: 11, color: p.textMuted, fontFamily: MONO, letterSpacing: 0.4 }}>● ACTIVE · GEMINI 2.5 FLASH · PII STRIPPED BEFORE SEND</div>
            </div>
            <Btn kind="ghost" size="sm">Clear chat</Btn>
          </div>

          {/* messages */}
          <div style={{ flex: 1, overflow: 'auto', padding: '24px 32px' }}>
            <Msg from="ai" text="Hi Alex. I can help you choose plain-language wording for any section, explain a legal term, or check that your preferences are internally consistent. <strong>I'm not a lawyer or doctor</strong> — review anything I suggest before accepting." />

            <Msg from="user" text="Can you help me word the 'additional instructions' section? I want to say no restraints unless absolutely necessary, and please bring my therapy dog if I'm hospitalized." />

            <Msg
              from="ai"
              text="Here's a phrasing that's specific enough for providers to follow, in your voice:"
              applyTo="STEP 08 · ANYTHING ELSE"
              suggestion="If I am admitted, I prefer to avoid physical restraints. Use them only if I pose an immediate safety risk to myself or others and de-escalation has failed. I would like my therapy dog, Olive, brought to me when permitted by the facility — my agent Jordan can coordinate."
            />

            <Msg from="user" text="Looks good. One more — can I refuse a specific medication?" />

            <Msg
              from="ai"
              text="Yes. PA Act 194 specifically allows you to refuse listed medications, and that refusal binds your agent. You can also limit a medication (e.g. dose ceiling) or list reactions. I noticed you wrote 'avoid Haldol' in Medications — want me to also pull in your reaction history?"
            />
          </div>

          {/* input */}
          <div style={{ padding: '14px 32px 20px', borderTop: `1px solid ${p.border}` }}>
            <div style={{
              display: 'flex', alignItems: 'center', gap: 8,
              background: p.card, border: `1.5px solid ${p.border}`, borderRadius: 100,
              padding: '6px 6px 6px 16px',
            }}>
              <input style={{
                flex: 1, border: 'none', outline: 'none', background: 'transparent',
                fontFamily: SANS, fontSize: 14, color: p.text, padding: '8px 0',
              }} placeholder="Ask about your directive…" />
              <Mic size={18} stroke={p.textMuted} />
              <div style={{ width: 36, height: 36, borderRadius: 100, background: p.primary, color: p.onPrimary, display: 'flex', alignItems: 'center', justifyContent: 'center', marginLeft: 4 }}>
                <Arrow size={16} stroke={p.onPrimary} />
              </div>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 8, fontSize: 11, color: p.textMuted }}>
              <Lock size={12} stroke={p.textMuted} />
              <span>PII (name, address, phone) is auto-stripped before sending. Per-session consent applies.</span>
            </div>
          </div>
        </div>

        {/* right context panel */}
        <div style={{ background: p.card, padding: '24px 20px', overflow: 'auto' }}>
          <SectionLabel>Context the AI sees</SectionLabel>
          <div style={{ marginTop: 10, display: 'flex', flexDirection: 'column', gap: 6 }}>
            {[
              ['Form type', 'Combined'],
              ['Current step', '8 · Anything else'],
              ['Filled sections', '7 of 9'],
              ['PII stripped', '4 fields'],
            ].map(([k, v]) => (
              <div key={k} style={{ display: 'flex', justifyContent: 'space-between', fontSize: 12 }}>
                <span style={{ color: p.textMuted }}>{k}</span>
                <span style={{ color: p.text, fontWeight: 600 }}>{v}</span>
              </div>
            ))}
          </div>

          <div style={{ height: 18, borderBottom: `1px solid ${p.border}`, marginBottom: 14 }} />

          <SectionLabel>Suggested prompts</SectionLabel>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 6, marginTop: 8 }}>
            {[
              'Explain "least restrictive setting"',
              'Word my drug-trial preference',
              'Check my agent\'s authority for conflicts',
              'Help me write a backup plan',
            ].map((q, i) => (
              <div key={i} style={{
                background: p.surface, border: `1px solid ${p.border}`, borderRadius: 8,
                padding: '8px 10px', fontSize: 12, color: p.text, cursor: 'pointer',
              }}>{q}</div>
            ))}
          </div>

          <div style={{ height: 18 }} />
          <SectionLabel>Privacy</SectionLabel>
          <div style={{
            background: p.primaryTint, border: `1px solid ${p.primary}25`,
            borderRadius: 10, padding: 12, marginTop: 8,
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 6 }}>
              <Shield size={14} stroke={p.primary} />
              <span style={{ fontFamily: MONO, fontSize: 10.5, fontWeight: 700, color: p.primary, letterSpacing: 0.6 }}>PII REDACTION ON</span>
            </div>
            <p style={{ margin: 0, fontSize: 12, color: p.text, lineHeight: 1.45 }}>
              Names, addresses, phone numbers, and dates are replaced with placeholders before sending to Gemini. Suggestions come back with placeholders filled in locally.
            </p>
          </div>
        </div>
      </div>
    </>
  );
}

Object.assign(window, { Web });
