// web-wizard-steps.jsx — Desktop versions of the wizard steps that only
// existed on mobile: 01 About, 02 When, 04 Guardian, 05 Care, 09 Procedures,
// 10 Anything else, 11 Review. Reuses WebHealthShell (3-pane) for consistency.

// ── shared desktop helpers (unique names to avoid global collisions) ──
function WwField({ label, value, placeholder, hint, multiline, half }) {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <div style={{ flex: half ? 1 : 'none', marginBottom: 14 }}>
      <div style={{ fontSize: 12, fontWeight: 600, color: p.textMuted, marginBottom: 6, letterSpacing: 0.2 }}>{label}</div>
      <div style={{
        background: p.card, border: `1.5px solid ${p.border}`, borderRadius: 10,
        padding: multiline ? '12px 14px' : '0 14px', height: multiline ? 'auto' : 46,
        minHeight: multiline ? 96 : 46, display: 'flex', alignItems: multiline ? 'flex-start' : 'center',
      }}>
        <span style={{ fontSize: 14.5, color: value ? p.text : p.textMuted, fontWeight: value ? 600 : 400, lineHeight: 1.5 }}>
          {value || placeholder}
        </span>
      </div>
      {hint && <div style={{ fontSize: 11.5, color: p.textMuted, marginTop: 4 }}>{hint}</div>}
    </div>
  );
}

function WwAIHead({ kicker }) {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 14 }}>
      <div style={{ width: 28, height: 28, borderRadius: 8, background: p.primaryTint, color: p.primary, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Sparkles size={16} />
      </div>
      <div>
        <div style={{ fontSize: 13, fontWeight: 700 }}>AI assistant</div>
        <div style={{ fontSize: 10.5, color: p.textMuted, fontFamily: MONO, letterSpacing: 0.4 }}>{kicker}</div>
      </div>
    </div>
  );
}

function WwPrivacyNote({ children }) {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <div style={{
      background: p.primaryTint, border: `1px solid ${p.primary}25`, borderRadius: 10,
      padding: 12, marginTop: 8, display: 'flex', alignItems: 'flex-start', gap: 8,
    }}>
      <Lock size={14} stroke={p.primary} />
      <p style={{ margin: 0, fontSize: 12, color: p.text, lineHeight: 1.45 }}>{children}</p>
    </div>
  );
}

// ── 01 · About you ────────────────────────────────────────────────────
function WebWizAbout() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <WebHealthShell
      stepN={1}
      title="About you"
      subtitle="Just the basics so this document is uniquely yours. Drop a photo of your ID and we'll read these for you."
      footer={
        <div style={{ display: 'flex', gap: 10 }}>
          <Btn kind="outline">← Back to start</Btn>
          <div style={{ flex: 1 }} />
          <Btn kind="primary" trailing={<Arrow size={16} />}>Continue to step 02</Btn>
        </div>
      }
      aiPanel={
        <>
          <WwAIHead kicker="SNAP TO FILL" />
          <div style={{ background: p.primaryTint, border: `2px dashed ${p.primary}`, borderRadius: 12, padding: 16, textAlign: 'center' }}>
            <Icon size={24} stroke={p.primary} sw={1.8} style={{ margin: '0 auto' }}><path d="M12 3v13M7 8l5-5 5 5M3 17v2a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-2"/></Icon>
            <div style={{ fontSize: 13, fontWeight: 700, color: p.text, marginTop: 8 }}>Drop a photo of your ID</div>
            <div style={{ fontSize: 11.5, color: p.textMuted, marginTop: 3, lineHeight: 1.4 }}>Fills name, DOB & address. Sent to AI to read, then discarded.</div>
            <Btn kind="primary" size="sm" style={{ marginTop: 10 }}>Browse files</Btn>
          </div>
          <WwPrivacyNote>Nothing here leaves your browser unless you use Snap-to-fill. No account, nothing saved.</WwPrivacyNote>
        </>
      }
    >
      <SectionLabel>Your details</SectionLabel>
      <div style={{ height: 12 }} />
      <WwField label="Full legal name" value="Alex M. Kowalski" />
      <div style={{ display: 'flex', gap: 14 }}>
        <WwField half label="Date of birth" value="06 / 14 / 1989" />
        <WwField half label="Phone" value="(412) 555-0143" />
      </div>
      <WwField label="Street address" value="412 Maple St" />
      <div style={{ display: 'flex', gap: 14 }}>
        <WwField half label="City" value="Pittsburgh" />
        <WwField half label="County" value="Allegheny" />
      </div>
      <div style={{ display: 'flex', gap: 14 }}>
        <WwField half label="State" value="Pennsylvania" />
        <WwField half label="ZIP" value="15217" />
      </div>
    </WebHealthShell>
  );
}

// ── 02 · When this kicks in ───────────────────────────────────────────
function WebWizWhen() {
  const { palette: p } = React.useContext(MHADContext);
  const Trigger = ({ checked, title, desc }) => (
    <div style={{
      display: 'flex', gap: 12, padding: 14, marginBottom: 10,
      background: checked ? p.primaryTint : p.card,
      border: `1.5px solid ${checked ? p.primary : p.border}`, borderRadius: 12,
    }}>
      <div style={{
        width: 22, height: 22, borderRadius: 6, flexShrink: 0, marginTop: 1,
        background: checked ? p.primary : 'transparent', border: checked ? 'none' : `1.5px solid ${p.border}`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>{checked && <Check size={13} sw={3} stroke={p.onPrimary} />}</div>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 14.5, fontWeight: 600, color: p.text }}>{title}</div>
        <div style={{ fontSize: 12.5, color: p.textMuted, marginTop: 2, lineHeight: 1.4 }}>{desc}</div>
      </div>
    </div>
  );
  return (
    <WebHealthShell
      stepN={2}
      title="When this kicks in"
      subtitle="The conditions under which your directive becomes active. You can pick more than one."
      aiPanel={
        <>
          <WwAIHead kicker="PLAIN LANGUAGE" />
          <div style={{ background: p.surface, border: `1px solid ${p.border}`, borderRadius: 10, padding: 12, fontSize: 12.5, color: p.text, lineHeight: 1.5 }}>
            "Incapable of making decisions" means two professionals agree you can't understand or communicate a treatment choice right now. It's temporary — your directive steps in only for that window.
          </div>
          <div style={{ height: 14 }} />
          <SectionLabel>Note</SectionLabel>
          <WwPrivacyNote>Your diagnoses and doctor go in Step 6. This step is only about what switches your directive on.</WwPrivacyNote>
        </>
      }
    >
      <SectionLabel>My directive takes effect when…</SectionLabel>
      <div style={{ height: 12 }} />
      <Trigger checked title="A psychiatrist + one other professional find I lack capacity" desc="A psychiatrist and one of: another psychiatrist, psychologist, family physician, attending physician, or mental health treatment professional. When possible, one is already treating me." />
      <Trigger title="A court determines I lack capacity" desc="An adjudication of incapacity by a Pennsylvania court." />
      <Trigger checked title="I'm involuntarily committed" desc="Under sections 302, 303, or 304 of the Mental Health Procedures Act." />
      <div style={{ height: 8 }} />
      <WwField label="Anything else providers should know about timing" placeholder="e.g. I recover quickly once stabilized — revisit capacity often" multiline />
    </WebHealthShell>
  );
}

// ── 04 · Guardian ─────────────────────────────────────────────────────
function WebWizGuardian() {
  const { palette: p } = React.useContext(MHADContext);
  const Opt = ({ active, title, sub, tag }) => (
    <div style={{
      background: active ? p.primaryTint : p.card,
      border: `2px solid ${active ? p.primary : p.border}`,
      borderRadius: 12, padding: 14, marginBottom: 10, display: 'flex', gap: 12,
    }}>
      <div style={{
        width: 20, height: 20, borderRadius: 100, flexShrink: 0, marginTop: 2,
        border: `2px solid ${active ? p.primary : p.border}`, background: active ? p.primary : 'transparent',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>{active && <div style={{ width: 7, height: 7, borderRadius: 100, background: p.onPrimary }} />}</div>
      <div style={{ flex: 1 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <h3 style={{ margin: 0, fontSize: 14.5, fontWeight: 700, color: p.text }}>{title}</h3>
          {tag && <span style={{ fontSize: 10, fontFamily: MONO, fontWeight: 700, color: p.textMuted, letterSpacing: 0.4, background: p.surface, padding: '2px 6px', borderRadius: 4, textTransform: 'uppercase' }}>{tag}</span>}
        </div>
        <p style={{ margin: '3px 0 0', fontSize: 12.5, color: p.textMuted, lineHeight: 1.45 }}>{sub}</p>
      </div>
    </div>
  );
  return (
    <WebHealthShell
      stepN={4}
      title="If a court appoints a guardian"
      subtitle="Rare, but worth planning for. A guardian is named by a court — not by you — and has broader authority than an agent."
      aiPanel={
        <>
          <WwAIHead kicker="GUIDANCE" />
          <div style={{ background: p.primaryTint, border: `1px solid ${p.primary}25`, borderRadius: 10, padding: 12, fontSize: 12.5, color: p.text, lineHeight: 1.5 }}>
            <strong>Most people pick their primary agent.</strong> Keeping the roles consistent reduces conflict if both ever activate at once.
          </div>
          <div style={{ height: 14 }} />
          <SectionLabel>Form types</SectionLabel>
          <div style={{ background: p.surface, border: `1px solid ${p.border}`, borderRadius: 10, padding: 12, marginTop: 8, fontSize: 12, color: p.textMuted, lineHeight: 1.5 }}>
            This step appears on <strong style={{ color: p.text }}>Combined &amp; POA</strong> forms. Declaration-only skips it, since it names no people.
          </div>
        </>
      }
    >
      <SectionLabel>My preferred guardian, if needed</SectionLabel>
      <div style={{ height: 12 }} />
      <Opt title="Same as my primary agent" sub="Jordan Lee — the simplest path. The court isn't required to follow this, but it's strong guidance." tag="Recommended" />
      <Opt title="Same as my alternate agent" sub="Sam Reyes — use this if your alternate would be a better fit for a longer-term role." />
      <Opt active title="Someone different" sub="Choose another person — e.g. an attorney, sibling, or close friend not already named." />
      <div style={{
        margin: '-2px 0 10px', padding: '14px 16px 4px',
        background: p.primaryTint, border: `1.5px solid ${p.primary}`, borderTop: 'none',
        borderRadius: '0 0 12px 12px',
      }}>
        <WwField label="Full name" value="Dana Okafor" />
        <div style={{ display: 'flex', gap: 14 }}>
          <WwField half label="Relationship" value="Attorney" />
          <WwField half label="Phone · optional" placeholder="(412) 555-0000" />
        </div>
      </div>
      <Opt title="No preference" sub="Let the court decide. They'll usually appoint a family member or county guardianship office." />

      <div style={{ height: 14 }} />
      <SectionLabel>Conditions on the guardianship</SectionLabel>
      <div style={{ marginTop: 10, display: 'flex', flexDirection: 'column', gap: 12 }}>
        {[
          { label: 'Can change my agent', val: 'no' },
          { label: 'Can override this directive', val: 'no' },
          { label: 'Must consult my agent first', val: 'yes' },
        ].map((row, i) => (
          <div key={i}>
            <div style={{ fontSize: 13.5, color: p.text, marginBottom: 6, fontWeight: 500 }}>{row.label}</div>
            <ConsentRow value={row.val} />
          </div>
        ))}
      </div>
    </WebHealthShell>
  );
}

// ── 05 · Where I want care ────────────────────────────────────────────
function WebWizCare() {
  const { palette: p } = React.useContext(MHADContext);
  const Facility = ({ name, sub, tone }) => (
    <div style={{
      background: p.card, border: `1px solid ${p.border}`, borderRadius: 10,
      padding: '12px 14px', display: 'flex', alignItems: 'center', gap: 12, marginBottom: 8,
    }}>
      <div style={{ width: 8, height: 8, borderRadius: 100, background: tone === 'prefer' ? p.okText : p.crisisAccent }} />
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 14, fontWeight: 600, color: p.text }}>{name}</div>
        <div style={{ fontSize: 12, color: p.textMuted }}>{sub}</div>
      </div>
      <Edit size={14} stroke={p.textMuted} />
    </div>
  );
  return (
    <WebHealthShell
      stepN={5}
      title="Where I want care"
      subtitle="Facilities you prefer — and any you specifically want to avoid — plus room and environment preferences."
      aiPanel={
        <>
          <WwAIHead kicker="INCLUSIVE BY DEFAULT" />
          <div style={{ background: p.surface, border: `1px solid ${p.border}`, borderRadius: 10, padding: 12, fontSize: 12.5, color: p.text, lineHeight: 1.5 }}>
            Room preferences are honored "where possible" — facilities can't always guarantee them, but your directive makes the request part of your record.
          </div>
          <div style={{ height: 14 }} />
          <SectionLabel>Search facilities</SectionLabel>
          <div style={{ background: p.card, border: `1px solid ${p.border}`, borderRadius: 10, padding: '10px 12px', marginTop: 8, display: 'flex', alignItems: 'center', gap: 8 }}>
            <Icon size={15} stroke={p.textMuted} sw={2}><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></Icon>
            <span style={{ fontSize: 12.5, color: p.textMuted }}>Find a PA facility by name or county…</span>
          </div>
        </>
      }
    >
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
        <div style={{ width: 8, height: 8, borderRadius: 100, background: p.okText }} />
        <SectionLabel>Preferred</SectionLabel>
      </div>
      <Facility tone="prefer" name="UPMC Western Psychiatric" sub="Pittsburgh PA · primary choice" />
      <Facility tone="prefer" name="Allegheny Health Network" sub="Pittsburgh PA · second choice" />

      <div style={{ height: 16 }} />
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
        <div style={{ width: 8, height: 8, borderRadius: 100, background: p.crisisAccent }} />
        <SectionLabel>Avoid if possible</SectionLabel>
      </div>
      <Facility tone="avoid" name="St. Margaret's State Hospital" sub="Prior negative experience" />

      <div style={{ height: 16 }} />
      <SectionLabel>Room &amp; environment</SectionLabel>
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, marginTop: 10 }}>
        {[['Single room', true], ['Window if possible', true], ['Quiet floor', true], ['No roommate', false], ['Same-gender roommate', true], ['Trans-affirming staff', true], ['Low-stimulation unit', false]].map(([l, a], i) => (
          <span key={i} style={{
            fontSize: 12.5, fontWeight: 600, padding: '7px 12px', borderRadius: 100,
            background: a ? p.primary : p.card, color: a ? p.onPrimary : p.textMuted,
            border: `1.5px solid ${a ? p.primary : p.border}`,
          }}>{l}</span>
        ))}
      </div>
      <div style={{ marginTop: 10, paddingLeft: 12, borderLeft: `2px solid ${p.primaryLight}` }}>
        <div style={{ fontSize: 12, color: p.textMuted, marginBottom: 6 }}>For "same-gender", match me with:</div>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
          {[['Women', true], ['Men', false], ['Same as my gender identity', false], ['Let me specify', false]].map(([l, a], i) => (
            <span key={i} style={{
              fontSize: 12, fontWeight: 600, padding: '6px 11px', borderRadius: 100,
              background: a ? p.primary : p.card, color: a ? p.onPrimary : p.textMuted,
              border: `1.5px solid ${a ? p.primary : p.border}`,
            }}>{l}</span>
          ))}
        </div>
      </div>
    </WebHealthShell>
  );
}

// ── 09 · Procedures & research ────────────────────────────────────────
function WebWizProcedures() {
  const { palette: p } = React.useContext(MHADContext);
  const Tile = ({ icon, title, desc, value, info }) => (
    <div style={{ background: p.card, border: `1px solid ${p.border}`, borderRadius: 12, padding: 16, marginBottom: 12 }}>
      <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12 }}>
        <div style={{ width: 38, height: 38, borderRadius: 10, flexShrink: 0, background: p.primaryTint, color: p.primary, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{icon}</div>
        <div style={{ flex: 1 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <h3 style={{ margin: 0, fontSize: 16, fontWeight: 700, letterSpacing: -0.2 }}>{title}</h3>
            <Info size={14} stroke={p.textMuted} />
          </div>
          <p style={{ margin: '3px 0 12px', fontSize: 13, color: p.textMuted, lineHeight: 1.45 }}>{desc}</p>
          <ConsentRow value={value} />
          {info && <p style={{ margin: '10px 0 0', fontSize: 12, color: p.textMuted, fontStyle: 'italic' }}>{info}</p>}
        </div>
      </div>
    </div>
  );
  return (
    <WebHealthShell
      stepN={9}
      title="Procedures & research"
      subtitle="Three treatments under PA law need your explicit consent. Set each one — your agent fills any gaps."
      aiPanel={
        <>
          <WwAIHead kicker="WHY THESE THREE" />
          <div style={{ background: p.surface, border: `1px solid ${p.border}`, borderRadius: 10, padding: 12, fontSize: 12.5, color: p.text, lineHeight: 1.5 }}>
            PA Act 194 specifically calls out <strong>ECT, experimental studies, and drug trials</strong> as requiring documented consent. Everything else falls under your general preferences.
          </div>
        </>
      }
    >
      <Tile icon={<Zap size={18} />} title="Electroconvulsive therapy (ECT)" desc="Brief electrical pulses to treat severe depression and some other conditions." value="if" info="You said: only if my primary agent agrees." />
      <Tile icon={<Flask size={18} />} title="Experimental studies" desc="Research that isn't yet approved as standard care. Participation is always voluntary." value="no" />
      <Tile icon={<Pill size={18} />} title="Drug trials" desc="Testing new medications not yet FDA-approved for your diagnosis." value="agent" />
    </WebHealthShell>
  );
}

// ── 10 · Anything else ────────────────────────────────────────────────
function WebWizElse() {
  const { palette: p } = React.useContext(MHADContext);
  const Prompt = ({ used, title }) => (
    <div style={{
      background: used ? p.primaryTint : p.card,
      border: `1px solid ${used ? p.primary + '40' : p.border}`, borderRadius: 10,
      padding: '10px 12px', display: 'flex', alignItems: 'center', gap: 10, marginBottom: 8,
    }}>
      <span style={{ flex: 1, fontSize: 13, fontWeight: 600, color: p.text }}>{title}</span>
      {used ? <Check size={14} stroke={p.primary} sw={3} /> : <Plus size={14} stroke={p.textMuted} />}
    </div>
  );
  return (
    <WebHealthShell
      stepN={10}
      title="Anything else"
      subtitle="Free-form preferences not covered above. This is your voice — write it how you'd say it."
      aiPanel={
        <>
          <WwAIHead kicker="REPHRASE WITH AI" />
          <div style={{ background: p.primaryTint, border: `1px solid ${p.primary}25`, borderRadius: 10, padding: 12, fontSize: 12.5, color: p.text, lineHeight: 1.5 }}>
            Tap "Rephrase with AI" on any block and we'll tighten the wording — with names and addresses stripped before anything is sent.
          </div>
          <div style={{ height: 14 }} />
          <SectionLabel>Optional add-ons</SectionLabel>
          {[['Crisis plan & wellness toolbox', 'Warning signs, triggers, what helps'], ['Self-binding (Ulysses) clause', 'Pre-consent even if future-you objects']].map(([t, s], i) => (
            <div key={i} style={{ background: p.surface, border: `1px solid ${p.border}`, borderRadius: 10, padding: 12, marginTop: 8 }}>
              <div style={{ fontSize: 12.5, fontWeight: 700, color: p.text }}>{t}</div>
              <div style={{ fontSize: 11.5, color: p.textMuted, marginTop: 2 }}>{s}</div>
              <span style={{ fontSize: 11.5, fontWeight: 700, color: p.primary }}>Add ›</span>
            </div>
          ))}
        </>
      }
    >
      <SectionLabel>Your instructions</SectionLabel>
      <div style={{ height: 10 }} />
      <div style={{
        background: p.card, border: `1.5px solid ${p.border}`, borderRadius: 12,
        padding: '16px 18px', minHeight: 180, fontSize: 14.5, color: p.text, lineHeight: 1.6,
      }}>
        <strong style={{ color: p.primary }}>Restraints &amp; seclusion:</strong> Avoid physical restraints. Use them only if I pose an immediate safety risk and de-escalation has failed.
        <br /><br />
        <strong style={{ color: p.primary }}>Comfort items:</strong> Please allow my therapy dog, Olive, when the facility permits — my agent Jordan can coordinate.
      </div>
      <div style={{ height: 16 }} />
      <SectionLabel>Common things to consider</SectionLabel>
      <p style={{ fontSize: 12.5, color: p.textMuted, margin: '6px 0 10px', lineHeight: 1.45 }}>
        Click one to drop a labeled heading into your text above — the PDF prints each as its own sub-section.
      </p>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
        <Prompt used title="Restraints & seclusion" />
        <Prompt used title="Comfort items (pets, photos…)" />
        <Prompt title="Visitors I want / don't want" />
        <Prompt title="Who to contact (and who not to)" />
        <Prompt title="Religious or spiritual practices" />
        <Prompt title="Care of pets, kids, plants at home" />
      </div>
    </WebHealthShell>
  );
}

// ── 11 · Review ───────────────────────────────────────────────────────
function WebReview() {
  const { palette: p } = React.useContext(MHADContext);
  const Row = ({ n, label, summary, ok = true }) => (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 14, padding: '12px 16px',
      background: p.card, border: `1px solid ${p.border}`, borderRadius: 12, marginBottom: 8,
    }}>
      <div style={{
        width: 30, height: 30, borderRadius: 8, flexShrink: 0,
        background: p.primaryTint, color: p.primary,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontFamily: SERIF, fontStyle: 'italic', fontSize: 16,
      }}>{n}</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 13.5, fontWeight: 600, color: p.text }}>{label}</div>
        <div style={{ fontSize: 12.5, color: p.textMuted, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{summary}</div>
      </div>
      {ok ? <Check size={16} stroke={p.okText} sw={2.5} /> : <AlertTri size={16} stroke={p.warnText} />}
      <Edit size={15} stroke={p.textMuted} />
    </div>
  );
  return (
    <WebHealthShell
      stepN={11}
      title="Almost there."
      subtitle="One last look, then we'll make your signing packet. Click any section to edit."
      footer={
        <div style={{ display: 'flex', gap: 10 }}>
          <Btn kind="outline">← Back to step 10</Btn>
          <div style={{ flex: 1 }} />
          <Btn kind="ghost" leading={<FileText size={14} />}>Preview PDF</Btn>
          <Btn kind="primary" trailing={<Arrow size={16} />}>Generate signing packet</Btn>
        </div>
      }
      aiPanel={
        <>
          <WwAIHead kicker="CONSISTENCY CHECK" />
          <div style={{ background: p.okBg, border: `1px solid ${p.okBorder}`, borderRadius: 10, padding: 12, display: 'flex', gap: 8, color: p.okText }}>
            <Check size={16} sw={2.5} stroke={p.okText} />
            <div style={{ fontSize: 12.5, lineHeight: 1.45 }}><strong>No contradictions found.</strong> 1 optional item left blank (Guardian).</div>
          </div>
          <div style={{ height: 14 }} />
          <WwPrivacyNote>Generating the packet creates a PDF on your device. It becomes legal only after you print and sign it in ink with two witnesses.</WwPrivacyNote>
        </>
      }
    >
      <div style={{ background: p.okBg, border: `1px solid ${p.okBorder}`, borderRadius: 12, padding: 14, marginBottom: 16, display: 'flex', gap: 10, alignItems: 'center' }}>
        <Check size={18} stroke={p.okText} sw={2.5} />
        <div style={{ flex: 1, fontSize: 13.5, color: p.okText, fontWeight: 600 }}>Everything looks good. 1 optional warning.</div>
      </div>
      <Row n="01" label="About you" summary="Alex M. Kowalski · DOB 06/14/89 · Pittsburgh PA" />
      <Row n="02" label="When this kicks in" summary="When 2 providers determine I lack capacity" />
      <Row n="03" label="People I trust" summary="Jordan Lee (sister), Sam Reyes (spouse) alt" />
      <Row n="04" label="Guardian" summary="Dana Okafor (attorney)" ok={false} />
      <Row n="05" label="Where I want care" summary="UPMC Western Psych · single room" />
      <Row n="06" label="Diagnoses" summary="Bipolar II, GAD, insomnia" />
      <Row n="07" label="Medications" summary="Current: Zoloft, Lamictal. Avoid: Haldol" />
      <Row n="08" label="Allergies" summary="Haldol (severe), latex, shellfish" />
      <Row n="09" label="Procedures & research" summary="ECT if agent agrees · no trials" />
      <Row n="10" label="Anything else" summary="Therapy dog visits, no restraints if avoidable" />
    </WebHealthShell>
  );
}

Object.assign(window, {
  WebWizAbout, WebWizWhen, WebWizGuardian, WebWizCare,
  WebWizProcedures, WebWizElse, WebReview,
});
