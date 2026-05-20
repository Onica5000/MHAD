// mobile.jsx — All mobile (iOS) screens.

function Mobile({ name }) {
  return (
    <IOSDevice width={422} height={894}>
      {(() => {
        switch (name) {
          case 'welcome': return <ScrWelcome />;
          case 'mode': return <ScrMode />;
          case 'disclaimer': return <ScrDisclaimer />;
          case 'home': return <ScrHome />;
          case 'formtype': return <ScrFormType />;
          case 'wizard-about': return <ScrWizardAbout />;
          case 'wizard-people': return <ScrWizardPeople />;
          case 'wizard-procedures': return <ScrWizardProcedures />;
          case 'review': return <ScrReview />;
          case 'sign': return <ScrSign />;
          case 'done': return <ScrDone />;
          case 'crisis': return <ScrCrisis />;
          default: return null;
        }
      })()}
    </IOSDevice>
  );
}

// Top spacer for iOS status bar (~64px including dynamic island)
const STATUSBAR_H = 60;
// Bottom safe inset for home indicator
const HOME_H = 34;

// ─── 01 Welcome ──────────────────────────────────────────────────────────
function ScrWelcome() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <Screen scroll={false}>
      <div style={{ height: STATUSBAR_H }} />
      {/* Subtle 988 link in upper right */}
      <div style={{ position: 'absolute', top: STATUSBAR_H + 8, right: 16, zIndex: 5 }}>
        <span style={{
          fontSize: 11.5, fontWeight: 600, color: p.crisisAccent,
          background: p.crisisBg, padding: '6px 10px', borderRadius: 100,
          border: `1px solid ${p.crisisBorder}`,
          display: 'inline-flex', alignItems: 'center', gap: 5,
        }}>
          <Phone size={12} /> 988
        </span>
      </div>

      <div style={{ padding: '64px 28px 0', display: 'flex', flexDirection: 'column', height: `calc(100% - ${STATUSBAR_H}px)`, boxSizing: 'border-box' }}>
        <SectionLabel>PA MHAD · Act 194</SectionLabel>
        <div style={{ height: 18 }} />

        <h1 style={{
          fontFamily: SERIF, fontStyle: 'italic', fontSize: 68, lineHeight: 0.95,
          color: p.text, margin: 0, letterSpacing: -1.5, fontWeight: 400,
        }}>
          In your<br/>
          <span style={{ color: p.primary }}>words.</span>
        </h1>

        <div style={{ height: 22 }} />
        <p style={{ fontSize: 17, lineHeight: 1.45, color: p.textMuted, margin: 0, maxWidth: 320 }}>
          Document how you want to be treated during a mental health crisis — so your wishes are honored even when you can't speak for yourself.
        </p>

        <div style={{ height: 28 }} />
        {/* Value pills */}
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
          <Chip icon={<Calendar size={12} />}>Valid 2 years</Chip>
          <Chip icon={<Users size={12} />}>2 witnesses</Chip>
          <Chip icon={<Shield size={12} />}>PA Act 194</Chip>
          <Chip icon={<Lock size={12} />}>Stays on your device</Chip>
        </div>

        <div style={{ flex: 1 }} />

        <Btn kind="primary" size="lg" full trailing={<Arrow size={18} />}>
          Get started
        </Btn>
        <div style={{ height: 10 }} />
        <Btn kind="ghost" full>I already have a directive</Btn>

        <div style={{ height: 18 }} />
        <p style={{ fontSize: 11, color: p.textMuted, textAlign: 'center', margin: 0, lineHeight: 1.45 }}>
          Free · no account · no tracking · open source
        </p>
        <div style={{ height: HOME_H + 8 }} />
      </div>
    </Screen>
  );
}

// ─── 02 Mode select ──────────────────────────────────────────────────────
function ScrMode() {
  const { palette: p } = React.useContext(MHADContext);

  const Card2 = ({ icon, title, sub, badges, recommended }) => (
    <div style={{
      background: p.card, border: `1.5px solid ${recommended ? p.primary : p.border}`,
      borderRadius: TOK.rCard, padding: 18, position: 'relative',
    }}>
      {recommended && (
        <div style={{ position: 'absolute', top: -10, left: 16 }}>
          <Badge tone="primary" style={{ background: p.primary, color: p.onPrimary }}>Recommended</Badge>
        </div>
      )}
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 8 }}>
        <div style={{
          width: 38, height: 38, borderRadius: 10,
          background: p.primaryLight, color: p.onPrimaryLight,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>{icon}</div>
        <h3 style={{ margin: 0, fontSize: 18, fontWeight: 700, letterSpacing: -0.2, color: p.text }}>{title}</h3>
      </div>
      <p style={{ margin: 0, fontSize: 13.5, color: p.textMuted, lineHeight: 1.45 }}>{sub}</p>
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, marginTop: 12 }}>
        {badges.map((b, i) => (
          <span key={i} style={{
            fontSize: 11, fontWeight: 600, color: p.textMuted,
            background: p.surface, border: `1px solid ${p.border}`,
            padding: '3px 8px', borderRadius: 100,
          }}>{b}</span>
        ))}
      </div>
    </div>
  );

  return (
    <Screen>
      <CrisisBar />
      <div style={{ padding: '20px 22px 40px' }}>
        <SectionLabel>Step 1 of 3 · setup</SectionLabel>
        <h1 style={{ fontFamily: SANS, fontSize: 28, fontWeight: 700, margin: '6px 0 6px', letterSpacing: -0.5, lineHeight: 1.15 }}>
          How should we handle your data?
        </h1>
        <p style={{ fontSize: 14, color: p.textMuted, margin: 0, lineHeight: 1.5 }}>
          You can change this anytime in Settings.
        </p>

        <div style={{ height: 22 }} />
        <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
          <Card2
            icon={<Lock size={20} />}
            title="Private mode"
            sub="Your data stays on this device, encrypted. Unlock with Face ID or a passcode. You can come back to your draft anytime."
            badges={['Face ID', 'AES-256', 'Save drafts', 'Across sessions']}
            recommended
          />
          <Card2
            icon={<EyeOff size={20} />}
            title="Public mode"
            sub="No data is saved after you close the app. Best for shared devices, or one-time use without leaving a trace."
            badges={['Nothing saved', 'In-memory only', 'Single session']}
          />
        </div>

        <div style={{ height: 18 }} />
        <p style={{ fontSize: 11.5, color: p.textMuted, textAlign: 'center', margin: 0, lineHeight: 1.45 }}>
          This app is not HIPAA-compliant. Nothing is sent to a server for storage.
        </p>
      </div>
    </Screen>
  );
}

// ─── 03 Disclaimer ───────────────────────────────────────────────────────
function ScrDisclaimer() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <Screen scroll={false}>
      <CrisisBar />
      <div style={{ padding: '18px 22px', height: `calc(100% - ${HOME_H + 40}px)`, display: 'flex', flexDirection: 'column' }}>
        <SectionLabel>Before we begin</SectionLabel>
        <h1 style={{ fontFamily: SANS, fontSize: 26, fontWeight: 700, margin: '6px 0 4px', letterSpacing: -0.3 }}>
          A few important things.
        </h1>
        <p style={{ fontSize: 13.5, color: p.textMuted, margin: '0 0 16px', lineHeight: 1.5 }}>
          Read carefully — these confirm what this app does and doesn't do.
        </p>

        <div style={{
          background: p.warnBg, border: `1px solid ${p.warnBorder}`,
          borderRadius: TOK.rCard, padding: 14, display: 'flex', gap: 10, marginBottom: 14,
        }}>
          <AlertTri size={20} stroke={p.warnText} />
          <div style={{ fontSize: 13, color: p.warnText, fontWeight: 600, lineHeight: 1.45 }}>
            This app helps you <em>document</em> your preferences. It is <strong>not</strong> legal or medical advice.
          </div>
        </div>

        {/* Plain-language bullets */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12, flex: 1, overflow: 'auto' }}>
          {[
            { title: 'You must be 18 or older', body: 'Or an emancipated minor. PA Act 194 requires legal capacity at the time of signing.' },
            { title: 'Your directive is valid for 2 years', body: "After that you'll need to renew it. We'll remind you 30 days before it expires." },
            { title: 'Two adult witnesses are required', body: 'They must be 18+ and present when you sign. They can\'t be your designated agent.' },
            { title: 'Consult a lawyer for legal questions', body: 'PA Protection & Advocacy: 1-800-692-7443 (toll-free).' },
          ].map((b, i) => (
            <div key={i} style={{ display: 'flex', gap: 12 }}>
              <div style={{
                width: 26, height: 26, borderRadius: 8, flexShrink: 0,
                background: p.primaryLight, color: p.onPrimaryLight,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontFamily: SERIF, fontStyle: 'italic', fontSize: 16, fontWeight: 400,
              }}>{i + 1}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 14, fontWeight: 600, color: p.text }}>{b.title}</div>
                <div style={{ fontSize: 12.5, color: p.textMuted, marginTop: 2, lineHeight: 1.45 }}>{b.body}</div>
              </div>
            </div>
          ))}
        </div>

        <div style={{ marginTop: 14, display: 'flex', alignItems: 'center', gap: 10, padding: '10px 12px', background: p.card, border: `1px solid ${p.border}`, borderRadius: 12 }}>
          <div style={{ width: 22, height: 22, borderRadius: 6, background: p.primary, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Check size={14} stroke={p.onPrimary} sw={3} />
          </div>
          <span style={{ fontSize: 13, fontWeight: 500, color: p.text }}>I'm 18 or older, and I understand the above.</span>
        </div>

        <div style={{ height: 12 }} />
        <Btn kind="primary" size="lg" full>I understand · Continue</Btn>
        <div style={{ height: HOME_H }} />
      </div>
    </Screen>
  );
}

// ─── 04 Home ─────────────────────────────────────────────────────────────
function ScrHome() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <Screen>
      <CrisisBar />
      <div style={{ padding: '20px 22px 100px' }}>
        {/* Greeting */}
        <SectionLabel>Saturday · May 14</SectionLabel>
        <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', marginTop: 4 }}>
          <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 38, fontWeight: 400, margin: 0, lineHeight: 1.05, letterSpacing: -0.5 }}>
            Hi, Alex.<br/>
            <span style={{ color: p.textMuted, fontSize: 22 }}>Let's keep your voice clear.</span>
          </h1>
          <div style={{
            width: 40, height: 40, borderRadius: 100, background: p.primaryLight,
            color: p.onPrimaryLight, display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontFamily: SANS, fontWeight: 700, fontSize: 14,
          }}>AK</div>
        </div>

        <div style={{ height: 22 }} />

        {/* Active directive card */}
        <div style={{
          background: p.primary, color: p.onPrimary, borderRadius: TOK.rCard,
          padding: 18, position: 'relative', overflow: 'hidden',
        }}>
          {/* decorative numeral */}
          <div style={{
            position: 'absolute', right: -10, top: -22,
            fontFamily: SERIF, fontStyle: 'italic', fontSize: 180, lineHeight: 1,
            color: 'rgba(255,255,255,0.1)', fontWeight: 400,
          }}>3</div>
          <div style={{ position: 'relative' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 4 }}>
              <Badge tone="primary" style={{ background: 'rgba(255,255,255,0.18)', color: p.onPrimary }}>● Draft</Badge>
              <span style={{ fontSize: 11.5, color: 'rgba(255,255,255,0.75)', fontFamily: MONO }}>Step 3 of 9</span>
            </div>
            <h2 style={{ margin: 0, fontSize: 22, fontWeight: 700, letterSpacing: -0.3 }}>My MHAD</h2>
            <p style={{ margin: '4px 0 14px', fontSize: 13, opacity: 0.85, lineHeight: 1.4 }}>
              Combined form · last edited 2 hours ago
            </p>
            {/* progress bar */}
            <div style={{ height: 4, background: 'rgba(255,255,255,0.2)', borderRadius: 100, overflow: 'hidden' }}>
              <div style={{ height: '100%', width: '33%', background: '#fff', borderRadius: 100 }} />
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 10, fontSize: 12 }}>
              <span style={{ opacity: 0.85 }}>33% complete</span>
              <span style={{ fontWeight: 600 }}>~ 6 more steps</span>
            </div>
            <div style={{ height: 14 }} />
            <button style={{
              background: '#fff', color: p.primaryDark, border: 'none',
              borderRadius: 10, padding: '10px 14px', fontSize: 14, fontWeight: 600,
              display: 'flex', alignItems: 'center', gap: 6, fontFamily: SANS,
            }}>
              Continue where you left off <Arrow size={14} />
            </button>
          </div>
        </div>

        <div style={{ height: 18 }} />
        <Btn kind="outline" size="md" full leading={<Plus size={16} />}>Start a new directive</Btn>

        <div style={{ height: 22 }} />
        <SectionLabel>Tools</SectionLabel>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, marginTop: 8 }}>
          {[
            { icon: <Sparkles size={18} />, label: 'AI assistant', sub: 'Suggests + checks' },
            { icon: <Book size={18} />, label: 'Learn', sub: 'FAQ, glossary' },
            { icon: <Wallet size={18} />, label: 'Wallet card', sub: 'Carry a copy' },
            { icon: <Heart size={18} />, label: 'Crisis help', sub: '988 + more' },
          ].map((it, i) => (
            <div key={i} style={{
              background: p.card, border: `1px solid ${p.border}`, borderRadius: 12,
              padding: 12, display: 'flex', flexDirection: 'column', gap: 8,
            }}>
              <div style={{
                width: 32, height: 32, borderRadius: 8,
                background: p.primaryTint, color: p.primary,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>{it.icon}</div>
              <div>
                <div style={{ fontSize: 13.5, fontWeight: 600 }}>{it.label}</div>
                <div style={{ fontSize: 11.5, color: p.textMuted }}>{it.sub}</div>
              </div>
            </div>
          ))}
        </div>

        <div style={{ height: 18 }} />
        <SectionLabel>Past directives</SectionLabel>
        <div style={{ marginTop: 8, background: p.card, border: `1px solid ${p.border}`, borderRadius: 12, padding: 14, display: 'flex', alignItems: 'center', gap: 12 }}>
          <FileText size={20} stroke={p.textMuted} />
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 13.5, fontWeight: 600 }}>Directive · 2023</div>
            <div style={{ fontSize: 11.5, color: p.textMuted }}>Expired · revoke or copy to new</div>
          </div>
          <DotsH size={18} stroke={p.textMuted} />
        </div>
      </div>

      {/* Bottom nav (over content) */}
      <div style={{
        position: 'absolute', bottom: HOME_H, left: 12, right: 12,
        background: p.card, border: `1px solid ${p.border}`, borderRadius: 100,
        padding: '6px', display: 'flex', justifyContent: 'space-around',
        boxShadow: '0 4px 24px rgba(0,0,0,0.06)',
      }}>
        {[
          { icon: <Home size={20} />, label: 'Home', active: true },
          { icon: <Book size={20} />, label: 'Learn' },
          { icon: <Sparkles size={20} />, label: 'Ask' },
          { icon: <Gear size={20} />, label: 'Settings' },
        ].map((n, i) => (
          <div key={i} style={{
            padding: '8px 14px', borderRadius: 100,
            background: n.active ? p.primaryLight : 'transparent',
            color: n.active ? p.onPrimaryLight : p.textMuted,
            display: 'flex', alignItems: 'center', gap: 6, fontSize: 12.5, fontWeight: 600,
          }}>
            {n.icon}{n.active && n.label}
          </div>
        ))}
      </div>
    </Screen>
  );
}

// ─── 05 Form type ────────────────────────────────────────────────────────
function ScrFormType() {
  const { palette: p } = React.useContext(MHADContext);

  const Opt = ({ active, title, sub, tags, recommended }) => (
    <div style={{
      background: active ? p.primaryTint : p.card,
      border: `2px solid ${active ? p.primary : p.border}`,
      borderRadius: TOK.rCard, padding: 16, position: 'relative',
      display: 'flex', gap: 12,
    }}>
      <div style={{
        width: 22, height: 22, borderRadius: 100, flexShrink: 0,
        border: `2px solid ${active ? p.primary : p.border}`,
        background: active ? p.primary : 'transparent',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        {active && <div style={{ width: 8, height: 8, borderRadius: 100, background: p.onPrimary }} />}
      </div>
      <div style={{ flex: 1 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <h3 style={{ margin: 0, fontSize: 16, fontWeight: 700, letterSpacing: -0.2 }}>{title}</h3>
          {recommended && <Badge tone="primary">Recommended</Badge>}
        </div>
        <p style={{ margin: '4px 0 0', fontSize: 13, color: p.textMuted, lineHeight: 1.45 }}>{sub}</p>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 4, marginTop: 10 }}>
          {tags.map((t, i) => (
            <span key={i} style={{ fontSize: 10.5, fontWeight: 600, fontFamily: MONO, color: p.textMuted, background: p.surface, padding: '2px 7px', borderRadius: 4, letterSpacing: 0.4, textTransform: 'uppercase' }}>{t}</span>
          ))}
        </div>
      </div>
    </div>
  );

  return (
    <Screen>
      <CrisisBar />
      <div style={{ padding: '18px 22px 32px' }}>
        <SectionLabel>New directive · 1 of 2</SectionLabel>
        <h1 style={{ fontFamily: SANS, fontSize: 28, fontWeight: 700, margin: '6px 0 6px', letterSpacing: -0.4, lineHeight: 1.15 }}>
          Which form fits you?
        </h1>
        <p style={{ fontSize: 14, color: p.textMuted, margin: 0, lineHeight: 1.5 }}>
          You can switch later if you change your mind. Combined is the broadest.
        </p>

        <div style={{ height: 18 }} />
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          <Opt
            active
            recommended
            title="Combined"
            sub="Both name people I trust to speak for me, and document my treatment preferences. Most flexibility."
            tags={['9 steps', 'Agents + preferences', 'Most common']}
          />
          <Opt
            title="Declaration only"
            sub="Just document my treatment preferences — no agent. Decisions still go through doctors."
            tags={['6 steps', 'No agents']}
          />
          <Opt
            title="Power of Attorney only"
            sub="Just name people to make decisions for me. They'll decide treatment in the moment."
            tags={['7 steps', 'Agents only']}
          />
        </div>

        <div style={{ height: 18 }} />
        <div style={{
          background: p.primaryLight, border: `1px solid ${p.primary}30`,
          borderRadius: 12, padding: 12, display: 'flex', gap: 10, alignItems: 'center',
        }}>
          <Sparkles size={18} stroke={p.primary} />
          <span style={{ flex: 1, fontSize: 13, color: p.onPrimaryLight, fontWeight: 500 }}>
            Not sure? Take the 4-question quiz.
          </span>
          <span style={{ fontSize: 12.5, color: p.primary, fontWeight: 700 }}>Help me choose →</span>
        </div>

        <div style={{ height: 22 }} />
        <Btn kind="primary" size="lg" full trailing={<Arrow size={18} />}>Continue</Btn>
      </div>
    </Screen>
  );
}

// ─── 06 Wizard: About you ───────────────────────────────────────────────
function ScrWizardAbout() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <Screen scroll={false}>
      <CrisisBar compact />
      {/* Wizard header */}
      <div style={{ padding: '8px 22px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <span style={{ fontSize: 13, color: p.primary, fontWeight: 600, display: 'flex', alignItems: 'center', gap: 4 }}>
          <Icon d="M15 18l-6-6 6-6" size={16} /> Back
        </span>
        <span style={{ fontSize: 13, color: p.textMuted, fontWeight: 500 }}>Save & exit</span>
      </div>
      <StepDots n={1} total={9} />

      <div style={{ overflow: 'auto', height: `calc(100% - ${HOME_H + 110}px)` }}>
        <StepHead n={1} total={9} title="About you" sub="Just the basics so this document is uniquely yours." />

        <div style={{ padding: '0 22px 24px' }}>
          <Field label="Full legal name" value="Alex M. Kowalski" suffix={<Mic size={16} stroke={p.primary} />} />
          <div style={{ display: 'grid', gridTemplateColumns: '1.2fr 1fr', gap: 12 }}>
            <Field label="Date of birth" value="June 14, 1989" />
            <Field label="Sex on ID" value="F" />
          </div>
          <Field label="Address" value="412 Maple St, Pittsburgh PA 15217" suffix={<MapPin size={16} stroke={p.textMuted} />} />
          <Field label="Phone" value="(412) 555-0143" />

          <div style={{
            background: p.primaryLight, border: `1px solid ${p.primary}30`,
            borderRadius: 12, padding: 12, display: 'flex', gap: 10, marginTop: 4,
          }}>
            <Sparkles size={18} stroke={p.primary} />
            <div style={{ flex: 1, fontSize: 12.5, color: p.onPrimaryLight, lineHeight: 1.4 }}>
              <strong>Smart fill available.</strong> Import these from a photo of your ID, or paste from a previous directive.
            </div>
            <span style={{ fontSize: 12, fontWeight: 700, color: p.primary, alignSelf: 'center' }}>Import →</span>
          </div>
        </div>
      </div>

      <BottomBar />
    </Screen>
  );
}

// ─── 07 Wizard: People I trust (consolidated) ──────────────────────────
function ScrWizardPeople() {
  const { palette: p } = React.useContext(MHADContext);

  const AgentCard = ({ kind, name, rel, phone, expanded, primary }) => (
    <div style={{
      background: p.card, border: `1.5px solid ${expanded ? p.primary : p.border}`,
      borderRadius: TOK.rCard, padding: 14, marginBottom: 10,
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
        <div style={{
          width: 38, height: 38, borderRadius: 100,
          background: primary ? p.primary : p.primaryLight,
          color: primary ? p.onPrimary : p.onPrimaryLight,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontFamily: SANS, fontWeight: 700, fontSize: 13,
        }}>{name ? name.split(' ').map(s => s[0]).slice(0,2).join('') : <Plus size={18} />}</div>
        <div style={{ flex: 1 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <span style={{ fontSize: 11, fontFamily: MONO, fontWeight: 600, color: p.textMuted, textTransform: 'uppercase', letterSpacing: 1 }}>{kind}</span>
            {primary && <Badge tone="primary">Primary</Badge>}
          </div>
          <div style={{ fontSize: 15, fontWeight: 700, color: p.text, marginTop: 1 }}>{name || 'Add someone'}</div>
          {name && <div style={{ fontSize: 12, color: p.textMuted }}>{rel} · {phone}</div>}
        </div>
        {expanded ? <ChevD size={18} stroke={p.textMuted} /> : <ChevR size={18} stroke={p.textMuted} />}
      </div>
      {expanded && name && (
        <div style={{ marginTop: 12, paddingTop: 12, borderTop: `1px dashed ${p.border}` }}>
          <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
            <Chip>✓ Contact picker</Chip>
            <Chip>✓ Phone verified</Chip>
            <Chip>Edit details</Chip>
          </div>
        </div>
      )}
    </div>
  );

  return (
    <Screen scroll={false}>
      <CrisisBar compact />
      <div style={{ padding: '8px 22px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <span style={{ fontSize: 13, color: p.primary, fontWeight: 600, display: 'flex', alignItems: 'center', gap: 4 }}>
          <Icon d="M15 18l-6-6 6-6" size={16} /> Back
        </span>
        <span style={{ fontSize: 13, color: p.textMuted, fontWeight: 500 }}>Save & exit</span>
      </div>
      <StepDots n={3} total={9} />

      <div style={{ overflow: 'auto', height: `calc(100% - ${HOME_H + 110}px)` }}>
        <StepHead n={3} total={9} title="People I trust" sub="They speak for you if you can't speak for yourself." />

        <div style={{ padding: '0 22px 24px' }}>
          <AgentCard kind="Primary agent" name="Jordan Lee" rel="Sister" phone="(412) 555-0188" expanded primary />
          <AgentCard kind="Alternate agent" name="Sam Reyes" rel="Spouse" phone="(412) 555-0177" expanded={false} />

          <div style={{ height: 18 }} />
          <SectionLabel>What can they decide?</SectionLabel>
          <div style={{ marginTop: 10, display: 'flex', flexDirection: 'column', gap: 12 }}>
            {[
              { label: 'Talk to my doctors and review records', val: 'yes' },
              { label: 'Admit me to a mental health facility', val: 'if' },
              { label: 'Consent to medications on my behalf', val: 'agent' },
              { label: 'Consent to ECT (electroconvulsive therapy)', val: 'no' },
              { label: 'Decide where I live during treatment', val: 'agent' },
            ].map((row, i) => (
              <div key={i}>
                <div style={{ fontSize: 13.5, color: p.text, marginBottom: 6, fontWeight: 500 }}>{row.label}</div>
                <ConsentRow value={row.val} />
              </div>
            ))}
          </div>
        </div>
      </div>

      <BottomBar />
    </Screen>
  );
}

// ─── 08 Wizard: Procedures & research (consolidated) ───────────────────
function ScrWizardProcedures() {
  const { palette: p } = React.useContext(MHADContext);

  const Tile = ({ icon, title, desc, value, info }) => (
    <div style={{
      background: p.card, border: `1px solid ${p.border}`,
      borderRadius: TOK.rCard, padding: 14, marginBottom: 12,
    }}>
      <div style={{ display: 'flex', alignItems: 'flex-start', gap: 10 }}>
        <div style={{
          width: 36, height: 36, borderRadius: 10, flexShrink: 0,
          background: p.primaryTint, color: p.primary,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>{icon}</div>
        <div style={{ flex: 1 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <h3 style={{ margin: 0, fontSize: 15.5, fontWeight: 700, letterSpacing: -0.2 }}>{title}</h3>
            <Info size={14} stroke={p.textMuted} />
          </div>
          <p style={{ margin: '2px 0 10px', fontSize: 12.5, color: p.textMuted, lineHeight: 1.45 }}>{desc}</p>
          <ConsentRow value={value} />
          {info && <p style={{ margin: '8px 0 0', fontSize: 11.5, color: p.textMuted, fontStyle: 'italic' }}>{info}</p>}
        </div>
      </div>
    </div>
  );

  return (
    <Screen scroll={false}>
      <CrisisBar compact />
      <div style={{ padding: '8px 22px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <span style={{ fontSize: 13, color: p.primary, fontWeight: 600, display: 'flex', alignItems: 'center', gap: 4 }}>
          <Icon d="M15 18l-6-6 6-6" size={16} /> Back
        </span>
        <span style={{ fontSize: 13, color: p.textMuted, fontWeight: 500 }}>Save & exit</span>
      </div>
      <StepDots n={7} total={9} />

      <div style={{ overflow: 'auto', height: `calc(100% - ${HOME_H + 110}px)` }}>
        <StepHead n={7} total={9} title="Procedures & research" sub="Three treatments under PA law need your explicit consent." />

        <div style={{ padding: '0 22px 24px' }}>
          <Tile
            icon={<Zap size={18} />}
            title="Electroconvulsive therapy (ECT)"
            desc="A procedure that uses brief electrical pulses to treat severe depression and some other conditions."
            value="if"
            info="You said: only if my primary agent agrees."
          />
          <Tile
            icon={<Flask size={18} />}
            title="Experimental studies"
            desc="Research that isn't yet approved as standard care. Participation is always voluntary."
            value="no"
          />
          <Tile
            icon={<Pill size={18} />}
            title="Drug trials"
            desc="Testing new medications that aren't yet FDA-approved for your diagnosis."
            value="agent"
          />

          <div style={{
            background: p.surface, border: `1px dashed ${p.border}`,
            borderRadius: 12, padding: 12, display: 'flex', gap: 10,
          }}>
            <Info size={16} stroke={p.textMuted} />
            <div style={{ fontSize: 12, color: p.textMuted, lineHeight: 1.45 }}>
              <strong style={{ color: p.text }}>Why these three?</strong> PA Act 194 specifically calls out ECT, experimental studies, and drug trials as requiring documented consent. Other treatments fall under your general preferences.
            </div>
          </div>
        </div>
      </div>

      <BottomBar />
    </Screen>
  );
}

// ─── 09 Review ─────────────────────────────────────────────────────────
function ScrReview() {
  const { palette: p } = React.useContext(MHADContext);

  const Row = ({ icon, label, summary, ok = true, n }) => (
    <div style={{
      display: 'flex', alignItems: 'flex-start', gap: 12,
      padding: '12px 14px', background: p.card, border: `1px solid ${p.border}`,
      borderRadius: 12, marginBottom: 8,
    }}>
      <div style={{
        width: 30, height: 30, borderRadius: 8, flexShrink: 0,
        background: p.primaryTint, color: p.primary,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontFamily: SERIF, fontStyle: 'italic', fontWeight: 400, fontSize: 17,
      }}>{n}</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 13, fontWeight: 600, color: p.text }}>{label}</div>
        <div style={{ fontSize: 12, color: p.textMuted, marginTop: 1, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{summary}</div>
      </div>
      {ok ? <Check size={16} stroke={p.okText} sw={2.5} /> : <AlertTri size={16} stroke={p.warnText} />}
      <Edit size={15} stroke={p.textMuted} />
    </div>
  );

  return (
    <Screen scroll={false}>
      <CrisisBar compact />
      <div style={{ padding: '8px 22px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <span style={{ fontSize: 13, color: p.primary, fontWeight: 600, display: 'flex', alignItems: 'center', gap: 4 }}>
          <Icon d="M15 18l-6-6 6-6" size={16} /> Back
        </span>
        <span style={{ fontSize: 13, color: p.textMuted, fontWeight: 500 }}>Save & exit</span>
      </div>
      <StepDots n={9} total={9} />

      <div style={{ overflow: 'auto', height: `calc(100% - ${HOME_H + 110}px)` }}>
        <div style={{ padding: '20px 22px 12px' }}>
          <SectionLabel>Step 9 of 9 · review</SectionLabel>
          <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 40, margin: '4px 0 4px', fontWeight: 400, letterSpacing: -0.5, lineHeight: 1 }}>
            Almost there.
          </h1>
          <p style={{ fontSize: 14, color: p.textMuted, margin: 0, lineHeight: 1.5 }}>
            One last look before you sign. Tap any section to edit.
          </p>

          <div style={{
            background: p.okBg, border: `1px solid ${p.okBorder}`, borderRadius: 12,
            padding: 12, marginTop: 16, display: 'flex', gap: 10, alignItems: 'center',
          }}>
            <Check size={18} stroke={p.okText} sw={2.5} />
            <div style={{ flex: 1, fontSize: 13, color: p.okText, fontWeight: 600 }}>
              Everything looks good. 1 optional warning.
            </div>
          </div>
        </div>

        <div style={{ padding: '0 22px 20px' }}>
          <Row n="01" label="About you" summary="Alex M. Kowalski · DOB 06/14/89 · Pittsburgh PA" />
          <Row n="02" label="When this kicks in" summary="When 2 providers determine I lack capacity" />
          <Row n="03" label="People I trust" summary="Jordan Lee (sister), Sam Reyes (spouse) alt" />
          <Row n="04" label="Guardian" summary="Same as primary agent" ok={false} />
          <Row n="05" label="Where I want care" summary="UPMC Western Psych · prefer single room" />
          <Row n="06" label="Medications" summary="Avoid: Haldol. Prefer: Zoloft, Lamictal" />
          <Row n="07" label="Procedures & research" summary="ECT if agent agrees · no trials" />
          <Row n="08" label="Anything else" summary="Therapy dog visits, no restraints if avoidable" />
        </div>
      </div>

      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0,
        padding: '12px 18px 22px', display: 'flex', gap: 10,
        background: `linear-gradient(to top, ${p.scaffold} 70%, ${p.scaffold}00)`,
      }}>
        <Btn kind="ghost">Preview PDF</Btn>
        <div style={{ flex: 1 }} />
        <Btn kind="primary" trailing={<Arrow size={16} />}>Continue to sign</Btn>
      </div>
    </Screen>
  );
}

// ─── 10 Sign & witness ─────────────────────────────────────────────────
function ScrSign() {
  const { palette: p } = React.useContext(MHADContext);

  const SigPad = ({ label, name, signed }) => (
    <div style={{
      background: p.card, border: `1.5px solid ${p.border}`,
      borderRadius: TOK.rCard, padding: 12, marginBottom: 10,
    }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 8 }}>
        <div>
          <SectionLabel>{label}</SectionLabel>
          <div style={{ fontSize: 14, fontWeight: 600, marginTop: 2 }}>{name}</div>
        </div>
        {signed && <Badge tone="ok">● Signed</Badge>}
      </div>
      <div style={{
        height: 76, background: p.surface, borderRadius: 10,
        border: `1px dashed ${p.border}`,
        position: 'relative', overflow: 'hidden',
      }}>
        {signed ? (
          <svg width="100%" height="100%" viewBox="0 0 280 76" preserveAspectRatio="xMidYMid meet">
            <path d="M20 50 C 40 20, 60 70, 80 40 S 120 60, 150 30 S 200 55, 240 35" stroke={p.text} strokeWidth="2" fill="none" strokeLinecap="round" />
          </svg>
        ) : (
          <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', color: p.textMuted, fontSize: 12, fontStyle: 'italic' }}>Tap to sign</div>
        )}
        <div style={{ position: 'absolute', bottom: 8, left: 12, right: 12, borderTop: `1px solid ${p.border}` }} />
        <div style={{ position: 'absolute', bottom: 0, left: 12, color: p.textMuted, fontSize: 10, fontFamily: MONO }}>×</div>
      </div>
    </div>
  );

  return (
    <Screen>
      <CrisisBar compact />
      <div style={{ padding: '12px 22px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <span style={{ fontSize: 13, color: p.primary, fontWeight: 600, display: 'flex', alignItems: 'center', gap: 4 }}>
          <Icon d="M15 18l-6-6 6-6" size={16} /> Back to review
        </span>
      </div>

      <div style={{ padding: '12px 22px 100px' }}>
        <SectionLabel>Final step</SectionLabel>
        <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 40, margin: '4px 0 6px', fontWeight: 400, letterSpacing: -0.5, lineHeight: 1 }}>
          Make it legal.
        </h1>
        <p style={{ fontSize: 14, color: p.textMuted, margin: 0, lineHeight: 1.5 }}>
          You and two adult witnesses must sign in the same place, at the same time.
        </p>

        <div style={{ height: 18 }} />

        <SigPad label="Principal · You" name="Alex M. Kowalski" signed />
        <SigPad label="Witness 1" name="Maria Chen" signed />
        <SigPad label="Witness 2 · Add name" name="Tap to add" />

        <div style={{
          background: p.warnBg, border: `1px solid ${p.warnBorder}`,
          borderRadius: 12, padding: 12, marginTop: 4, display: 'flex', gap: 10,
        }}>
          <Info size={16} stroke={p.warnText} />
          <div style={{ fontSize: 12.5, color: p.warnText, lineHeight: 1.45 }}>
            Witnesses must be <strong>18+</strong>, present when you sign, and <strong>not</strong> your designated agent.
          </div>
        </div>

        <div style={{ height: 16 }} />
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, fontSize: 13, color: p.textMuted }}>
          <Calendar size={16} stroke={p.textMuted} />
          Signed today, <strong style={{ color: p.text }}>May 14, 2026</strong> · valid through <strong style={{ color: p.text }}>May 14, 2028</strong>
        </div>
      </div>

      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0,
        padding: '12px 18px 22px',
        background: `linear-gradient(to top, ${p.scaffold} 70%, ${p.scaffold}00)`,
      }}>
        <Btn kind="primary" size="lg" full trailing={<Arrow size={18} />}>Finish & export</Btn>
      </div>
    </Screen>
  );
}

// ─── 11 Done + wallet ─────────────────────────────────────────────────
function ScrDone() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <Screen>
      {/* No crisis bar on the celebration screen — quieter moment. */}
      <div style={{ padding: '60px 22px 32px' }}>
        <SectionLabel style={{ color: p.primary }}>● Complete</SectionLabel>
        <h1 style={{
          fontFamily: SERIF, fontStyle: 'italic', fontSize: 64, margin: '4px 0 8px',
          fontWeight: 400, letterSpacing: -1.5, lineHeight: 0.95,
        }}>
          You did<br/>it.
        </h1>
        <p style={{ fontSize: 15, color: p.textMuted, margin: 0, lineHeight: 1.5 }}>
          Your directive is legally valid. Now make sure the right people have a copy.
        </p>

        {/* Wallet card preview */}
        <div style={{ height: 26 }} />
        <SectionLabel>Wallet card</SectionLabel>
        <div style={{
          marginTop: 8,
          background: `linear-gradient(135deg, ${p.primary}, ${p.primaryDark})`,
          color: p.onPrimary, borderRadius: 14, padding: 16,
          position: 'relative', overflow: 'hidden',
          boxShadow: '0 6px 20px rgba(0,0,0,0.12)',
        }}>
          <div style={{ position: 'absolute', right: -20, top: -30, fontFamily: SERIF, fontStyle: 'italic', fontSize: 140, color: 'rgba(255,255,255,0.08)', lineHeight: 1 }}>MH</div>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', position: 'relative' }}>
            <div>
              <div style={{ fontFamily: MONO, fontSize: 10, letterSpacing: 1.4, opacity: 0.8 }}>PA MHAD · ACT 194</div>
              <div style={{ fontSize: 18, fontWeight: 700, marginTop: 4, letterSpacing: -0.2 }}>Alex M. Kowalski</div>
              <div style={{ fontSize: 11.5, opacity: 0.85, marginTop: 2 }}>Has an active directive on file</div>
            </div>
            <div style={{ width: 56, height: 56, borderRadius: 8, background: 'rgba(255,255,255,0.95)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <QR size={48} stroke={p.primaryDark} />
            </div>
          </div>
          <div style={{ height: 14 }} />
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 11, opacity: 0.9, position: 'relative' }}>
            <div>
              <div style={{ fontFamily: MONO, opacity: 0.7 }}>AGENT</div>
              <div style={{ fontWeight: 600, marginTop: 2 }}>Jordan Lee · (412) 555-0188</div>
            </div>
            <div style={{ textAlign: 'right' }}>
              <div style={{ fontFamily: MONO, opacity: 0.7 }}>EXP</div>
              <div style={{ fontWeight: 600, marginTop: 2 }}>05 · 2028</div>
            </div>
          </div>
        </div>

        <div style={{ height: 18 }} />
        <SectionLabel>Now, share copies with</SectionLabel>
        <div style={{ marginTop: 8, display: 'flex', flexDirection: 'column', gap: 8 }}>
          {[
            { who: 'Your primary agent', detail: 'Jordan Lee', done: true },
            { who: 'Your alternate agent', detail: 'Sam Reyes', done: true },
            { who: 'Your primary care doctor', detail: 'Dr. Patel · UPMC', done: false },
            { who: 'Your psychiatrist or therapist', detail: 'Add provider', done: false },
            { who: 'A trusted family member', detail: 'Optional', done: false },
          ].map((it, i) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', gap: 10,
              padding: '10px 12px', background: p.card, border: `1px solid ${p.border}`, borderRadius: 10,
            }}>
              <div style={{
                width: 22, height: 22, borderRadius: 6, flexShrink: 0,
                background: it.done ? p.primary : 'transparent',
                border: it.done ? 'none' : `1.5px solid ${p.border}`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                {it.done && <Check size={14} stroke={p.onPrimary} sw={3} />}
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 13.5, fontWeight: 600, color: p.text }}>{it.who}</div>
                <div style={{ fontSize: 11.5, color: p.textMuted }}>{it.detail}</div>
              </div>
              <span style={{ fontSize: 12, color: p.primary, fontWeight: 700 }}>{it.done ? 'Sent ✓' : 'Send →'}</span>
            </div>
          ))}
        </div>

        <div style={{ height: 18 }} />
        <div style={{ display: 'flex', gap: 10 }}>
          <Btn kind="tonal" leading={<Download size={16} />} style={{ flex: 1 }}>PDF</Btn>
          <Btn kind="tonal" leading={<Share size={16} />} style={{ flex: 1 }}>Share</Btn>
          <Btn kind="tonal" leading={<Wallet size={16} />} style={{ flex: 1 }}>Wallet</Btn>
        </div>
      </div>
    </Screen>
  );
}

// ─── 12 Crisis sheet ──────────────────────────────────────────────────
function ScrCrisis() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <Screen scroll={false} style={{ background: '#000' }}>
      {/* Backdrop: faded home screen */}
      <div style={{ position: 'absolute', inset: 0, opacity: 0.4, filter: 'blur(2px)' }}>
        <Screen>
          <CrisisBar />
          <div style={{ padding: 22, color: p.text }}>
            <div style={{ height: 100 }} />
            <h1 style={{ fontSize: 30 }}>Hi, Alex.</h1>
          </div>
        </Screen>
      </div>

      {/* Dim overlay */}
      <div style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.5)' }} />

      {/* Bottom sheet */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0,
        background: p.card, borderRadius: `${TOK.rSheet}px ${TOK.rSheet}px 0 0`,
        padding: '14px 0 30px',
        boxShadow: '0 -10px 40px rgba(0,0,0,0.3)',
      }}>
        <div style={{ width: 40, height: 4, background: p.border, borderRadius: 100, margin: '0 auto 14px' }} />

        <div style={{ padding: '0 22px' }}>
          <SectionLabel style={{ color: p.crisisAccent }}>● 24/7 free, confidential</SectionLabel>
          <h2 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 34, margin: '4px 0 4px', fontWeight: 400, letterSpacing: -0.5 }}>
            You are not alone.
          </h2>
          <p style={{ fontSize: 13, color: p.textMuted, margin: '0 0 18px', lineHeight: 1.5 }}>
            Real people are standing by — phone, text, or chat.
          </p>

          {[
            { name: '988 Suicide & Crisis Lifeline', detail: 'Call or text 988', accent: true, icon: <Phone size={20} /> },
            { name: 'Crisis Text Line', detail: 'Text HOME to 741741', icon: <Icon size={20}><path d="M21 11.5a8.4 8.4 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.4 8.4 0 0 1-3.8-.9L3 21l1.9-5.7a8.4 8.4 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.4 8.4 0 0 1 3.8-.9h.5a8.5 8.5 0 0 1 8 8z"/></Icon> },
            { name: 'SAMHSA National Helpline', detail: '1-800-662-4357 · treatment referrals', icon: <Heart size={20} /> },
            { name: 'PA Protection & Advocacy', detail: '1-800-692-7443 · know your rights', icon: <Shield size={20} /> },
          ].map((r, i) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', gap: 12,
              padding: '14px 12px', marginBottom: 8,
              background: r.accent ? p.crisisBg : p.surface,
              border: `1px solid ${r.accent ? p.crisisBorder : p.border}`,
              borderRadius: 12,
            }}>
              <div style={{
                width: 40, height: 40, borderRadius: 100, flexShrink: 0,
                background: r.accent ? p.crisisAccent : p.primaryLight,
                color: r.accent ? '#fff' : p.onPrimaryLight,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>{r.icon}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 14.5, fontWeight: 700, color: r.accent ? p.crisisText : p.text }}>{r.name}</div>
                <div style={{ fontSize: 12, color: r.accent ? p.crisisText : p.textMuted, marginTop: 1 }}>{r.detail}</div>
              </div>
              <Arrow size={16} stroke={r.accent ? p.crisisAccent : p.textMuted} />
            </div>
          ))}

          <Btn kind="ghost" full style={{ marginTop: 4 }}>Close</Btn>
        </div>
      </div>
    </Screen>
  );
}

Object.assign(window, { Mobile });
