// web-flow-screens.jsx — Desktop versions of mobile flow/app screens that
// had no web equivalent: disclaimer, form-type, quiz, AI conflict, make-it-legal,
// done, share, crisis, article reader, settings, revoke, voice input.
// Reuses WebSidebar for app screens; centered layout for pre-app flow.

// Centered flow shell (pre-app screens: disclaimer, form type, quiz, sign, done)
function WebCenter({ children, max = 720 }) {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <div style={{ flex: 1, overflow: 'auto', background: p.surface, display: 'flex', justifyContent: 'center' }}>
      <div style={{ width: '100%', maxWidth: max, padding: '40px 40px 56px' }}>{children}</div>
    </div>
  );
}

// ── Disclaimer / consent ──────────────────────────────────────────────
function WebDisclaimer() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <WebCenter max={680}>
      <SectionLabel>Before you begin</SectionLabel>
      <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 42, margin: '6px 0 8px', fontWeight: 400, letterSpacing: -0.7, lineHeight: 1.02 }}>
        A few things to understand.
      </h1>
      <p style={{ fontSize: 14.5, color: p.textMuted, margin: 0, lineHeight: 1.55 }}>
        This tool helps you write a Pennsylvania Mental Health Advance Directive under Act 194. Please read these before continuing.
      </p>
      <div style={{ height: 22 }} />
      {[
        { icon: <Shield size={18} />, t: 'This is not legal advice', s: 'We give plain-language help, not legal counsel. For complex situations, talk to an attorney or advocate.' },
        { icon: <FileText size={18} />, t: 'It becomes valid only when signed on paper', s: 'PA law requires your signature plus two qualified adult witnesses, in ink, in person. The app cannot sign for you.' },
        { icon: <Lock size={18} />, t: 'Nothing is saved or sent to us', s: 'You work anonymously in this browser tab. No account, no cloud. Download your PDF before you close it.' },
        { icon: <Heart size={18} />, t: 'You can stop or change anything, anytime', s: 'Skip questions, go back, or revoke later. This is your voice — you stay in control.' },
      ].map((row, i) => (
        <div key={i} style={{ display: 'flex', gap: 14, padding: '14px 16px', background: p.card, border: `1px solid ${p.border}`, borderRadius: 12, marginBottom: 10 }}>
          <div style={{ width: 38, height: 38, borderRadius: 10, flexShrink: 0, background: p.primaryTint, color: p.primary, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{row.icon}</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 15, fontWeight: 700, color: p.text }}>{row.t}</div>
            <div style={{ fontSize: 13, color: p.textMuted, marginTop: 2, lineHeight: 1.5 }}>{row.s}</div>
          </div>
        </div>
      ))}
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 12, padding: '12px 16px', background: p.primaryTint, border: `1px solid ${p.primaryLight}`, borderRadius: 12 }}>
        <div style={{ width: 22, height: 22, borderRadius: 6, background: p.primary, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Check size={14} sw={3} stroke={p.onPrimary} /></div>
        <span style={{ flex: 1, fontSize: 13.5, color: p.text, fontWeight: 600 }}>I understand and want to continue.</span>
      </div>
      <div style={{ display: 'flex', gap: 10, marginTop: 20 }}>
        <Btn kind="ghost">Read full disclaimer</Btn>
        <div style={{ flex: 1 }} />
        <Btn kind="primary" trailing={<Arrow size={16} />}>Get started</Btn>
      </div>
    </WebCenter>
  );
}

// ── Form type select ──────────────────────────────────────────────────
function WebFormType() {
  const { palette: p } = React.useContext(MHADContext);
  const Opt = ({ active, title, sub, tags, recommended }) => (
    <div style={{
      background: active ? p.primaryTint : p.card, border: `2px solid ${active ? p.primary : p.border}`,
      borderRadius: 14, padding: 18, display: 'flex', gap: 14, marginBottom: 12,
    }}>
      <div style={{
        width: 22, height: 22, borderRadius: 100, flexShrink: 0, marginTop: 2,
        border: `2px solid ${active ? p.primary : p.border}`, background: active ? p.primary : 'transparent',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>{active && <div style={{ width: 8, height: 8, borderRadius: 100, background: p.onPrimary }} />}</div>
      <div style={{ flex: 1 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <h3 style={{ margin: 0, fontSize: 17, fontWeight: 700, letterSpacing: -0.2 }}>{title}</h3>
          {recommended && <Badge tone="primary">Recommended</Badge>}
        </div>
        <p style={{ margin: '4px 0 0', fontSize: 13.5, color: p.textMuted, lineHeight: 1.5 }}>{sub}</p>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 5, marginTop: 10 }}>
          {tags.map((t, i) => (
            <span key={i} style={{ fontSize: 10.5, fontWeight: 600, fontFamily: MONO, color: p.textMuted, background: p.surface, padding: '2px 8px', borderRadius: 4, letterSpacing: 0.4, textTransform: 'uppercase' }}>{t}</span>
          ))}
        </div>
      </div>
    </div>
  );
  return (
    <WebCenter max={680}>
      <SectionLabel>New directive · 1 of 2</SectionLabel>
      <h1 style={{ fontFamily: SANS, fontSize: 32, fontWeight: 700, margin: '6px 0 6px', letterSpacing: -0.5 }}>Which form fits you?</h1>
      <p style={{ fontSize: 14, color: p.textMuted, margin: '0 0 22px', lineHeight: 1.5 }}>You can switch later if you change your mind. Combined is the broadest.</p>
      <Opt active recommended title="Combined" sub="Both name people I trust to speak for me, and document my treatment preferences. Most flexibility." tags={['11 steps', 'Agents + preferences', 'Most common']} />
      <Opt title="Declaration only" sub="Just document my treatment preferences — no agent. Decisions still go through doctors." tags={['9 steps', 'No agents']} />
      <Opt title="Power of Attorney only" sub="Just name people to make decisions for me. They'll decide treatment in the moment." tags={['6 steps', 'Agents only']} />
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 6, padding: '14px 16px', background: p.primaryLight, border: `1px solid ${p.primary}30`, borderRadius: 12 }}>
        <Sparkles size={18} stroke={p.primary} />
        <span style={{ flex: 1, fontSize: 13.5, color: p.onPrimaryLight, fontWeight: 500 }}>Not sure? Take the 4-question quiz.</span>
        <Btn kind="outline" size="sm">Help me choose →</Btn>
      </div>
    </WebCenter>
  );
}

// ── Help-me-choose quiz (reuses QUIZ_QUESTIONS / QUIZ_RESULTS globals) ─
function WebQuiz() {
  const { palette: p } = React.useContext(MHADContext);
  const [step, setStep] = React.useState(0);
  const [answers, setAnswers] = React.useState([null, null, null, null]);
  const totals = React.useMemo(() => {
    const t = { combined: 0, declaration: 0, poa: 0 };
    answers.forEach((ai, qi) => { if (ai == null) return; const s = QUIZ_QUESTIONS[qi].opts[ai].s; Object.keys(s).forEach((k) => { t[k] += s[k]; }); });
    return t;
  }, [answers]);
  const sum = totals.combined + totals.declaration + totals.poa;
  const winner = sum === 0 ? 'combined' : Object.keys(totals).reduce((a, b) => totals[a] >= totals[b] ? a : b);
  const confidence = sum === 0 ? 0 : Math.round((totals[winner] / sum) * 100);
  const pick = (qi, ai) => { const n = [...answers]; n[qi] = ai; setAnswers(n); setTimeout(() => setStep((s) => Math.min(s + 1, 4)), 200); };

  if (step === 4) {
    const r = QUIZ_RESULTS[winner];
    return (
      <WebCenter max={620}>
        <SectionLabel style={{ color: p.primary }}>● Your match</SectionLabel>
        <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 46, margin: '6px 0 6px', fontWeight: 400, letterSpacing: -0.8, lineHeight: 1 }}>{r.name}.</h1>
        <p style={{ fontSize: 14.5, color: p.textMuted, margin: 0, lineHeight: 1.55 }}>{r.tagline}</p>
        <div style={{ marginTop: 24, background: p.card, border: `1px solid ${p.border}`, borderRadius: 14, padding: 18 }}>
          <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
            <SectionLabel>How sure we are</SectionLabel>
            <span style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 28, color: p.primary, lineHeight: 1 }}>{confidence}%</span>
          </div>
          <div style={{ display: 'flex', height: 12, borderRadius: 100, overflow: 'hidden', marginTop: 12, background: p.surface, gap: 2 }}>
            {['combined', 'declaration', 'poa'].map((k) => (
              <div key={k} style={{ width: `${sum === 0 ? 33.3 : (totals[k] / sum) * 100}%`, background: k === winner ? p.primary : p.primaryLight, transition: 'width 0.3s' }} />
            ))}
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 8, fontFamily: MONO, fontSize: 10, color: p.textMuted, letterSpacing: 0.3 }}>
            <span>COMBINED {totals.combined}</span><span>DECLARATION {totals.declaration}</span><span>POA {totals.poa}</span>
          </div>
        </div>
        <div style={{ display: 'flex', gap: 10, marginTop: 22 }}>
          <Btn kind="ghost" onClick={() => { setAnswers([null, null, null, null]); setStep(0); }}>Retake</Btn>
          <div style={{ flex: 1 }} />
          <Btn kind="primary" trailing={<Arrow size={16} />}>Start {r.name}</Btn>
        </div>
      </WebCenter>
    );
  }

  const Q = QUIZ_QUESTIONS[step];
  const chosen = answers[step];
  return (
    <WebCenter max={620}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 14 }}>
        <span onClick={() => setStep((s) => Math.max(s - 1, 0))} style={{ fontSize: 13, color: p.primary, fontWeight: 600, cursor: 'pointer', display: 'inline-flex', alignItems: 'center', gap: 4 }}><Icon d="M15 18l-6-6 6-6" size={14} /> Back</span>
        <div style={{ flex: 1, height: 5, background: p.border, borderRadius: 100, overflow: 'hidden' }}>
          <div style={{ height: '100%', width: `${((step + 1) / 4) * 100}%`, background: p.primary, borderRadius: 100, transition: 'width 0.2s' }} />
        </div>
        <span style={{ fontSize: 12, color: p.textMuted, fontFamily: MONO }}>{step + 1} / 4</span>
      </div>
      <SectionLabel>Help me choose · question {step + 1} of 4</SectionLabel>
      <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 36, margin: '6px 0 6px', fontWeight: 400, letterSpacing: -0.6, lineHeight: 1.1 }}>{Q.q}</h1>
      <p style={{ fontSize: 14, color: p.textMuted, margin: '0 0 20px', lineHeight: 1.5 }}>{Q.hint}</p>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {Q.opts.map((o, i) => {
          const sel = chosen === i;
          return (
            <div key={i} onClick={() => pick(step, i)} style={{
              background: sel ? p.primaryTint : p.card, border: `2px solid ${sel ? p.primary : p.border}`,
              borderRadius: 12, padding: 16, cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 12,
            }}>
              <div style={{ width: 20, height: 20, borderRadius: 100, flexShrink: 0, border: `2px solid ${sel ? p.primary : p.border}`, background: sel ? p.primary : 'transparent', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{sel && <div style={{ width: 7, height: 7, borderRadius: 100, background: p.onPrimary }} />}</div>
              <div style={{ flex: 1, fontSize: 14.5, fontWeight: 600 }}>{o.t}</div>
            </div>
          );
        })}
      </div>
    </WebCenter>
  );
}

// ── AI consistency warning ────────────────────────────────────────────
function WebConflict() {
  const { palette: p } = React.useContext(MHADContext);
  const Conflict = ({ a, b, detail }) => (
    <div style={{ background: p.warnBg, border: `1px solid ${p.warnBorder}`, borderRadius: 12, padding: 16, marginBottom: 10 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
        <AlertTri size={16} stroke={p.warnText} />
        <span style={{ fontFamily: MONO, fontSize: 10.5, fontWeight: 700, letterSpacing: 0.6, color: p.warnText, textTransform: 'uppercase' }}>Possible contradiction</span>
      </div>
      <div style={{ display: 'flex', gap: 10, alignItems: 'center', marginBottom: 8 }}>
        <span style={{ flex: 1, fontSize: 13, color: p.text, background: p.card, border: `1px solid ${p.border}`, borderRadius: 8, padding: '8px 10px' }}>{a}</span>
        <span style={{ fontSize: 11, fontFamily: MONO, color: p.warnText }}>vs</span>
        <span style={{ flex: 1, fontSize: 13, color: p.text, background: p.card, border: `1px solid ${p.border}`, borderRadius: 8, padding: '8px 10px' }}>{b}</span>
      </div>
      <p style={{ margin: '0 0 10px', fontSize: 12.5, color: p.warnText, lineHeight: 1.45 }}>{detail}</p>
      <div style={{ display: 'flex', gap: 8 }}>
        <Btn kind="outline" size="sm">Keep both</Btn>
        <Btn kind="primary" size="sm">Fix it →</Btn>
      </div>
    </div>
  );
  return (
    <WebCenter max={680}>
      <SectionLabel style={{ color: p.warnText }}>● Before you generate the PDF</SectionLabel>
      <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 40, margin: '6px 0 6px', fontWeight: 400, letterSpacing: -0.7, lineHeight: 1.02 }}>
        Two things may <span style={{ color: p.warnText }}>conflict</span>.
      </h1>
      <p style={{ fontSize: 14, color: p.textMuted, margin: '0 0 22px', lineHeight: 1.55 }}>
        We scanned your answers for contradictions a care team might trip over. These won't block you — but worth a look.
      </p>
      <Conflict a="ECT only with Jordan's consent" b="Jordan can't be reached as agent in Step 3 limits" detail="If your agent is the only one who can approve ECT but their authority is restricted, ECT could stall. Consider naming who else may consent." />
      <Conflict a="Avoid UPMC facilities" b="Preferred psychiatrist practices at UPMC" detail="Your preferred provider works at a facility you asked to avoid. Clarify whether seeing them elsewhere is acceptable." />
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 12, padding: '12px 16px', background: p.okBg, border: `1px solid ${p.okBorder}`, borderRadius: 12, color: p.okText }}>
        <Check size={16} sw={2.5} stroke={p.okText} />
        <span style={{ flex: 1, fontSize: 13, fontWeight: 600 }}>Everything else is consistent.</span>
      </div>
      <div style={{ display: 'flex', gap: 10, marginTop: 20 }}>
        <Btn kind="ghost">Ignore &amp; continue</Btn>
        <div style={{ flex: 1 }} />
        <Btn kind="primary" trailing={<Arrow size={16} />}>Resolve in wizard</Btn>
      </div>
    </WebCenter>
  );
}

// ── Make it legal (print + wet-ink guide) ─────────────────────────────
function WebSign() {
  const { palette: p } = React.useContext(MHADContext);
  const Step = ({ n, title, body }) => (
    <div style={{ display: 'flex', gap: 14, marginBottom: 16 }}>
      <div style={{ width: 34, height: 34, borderRadius: 100, flexShrink: 0, background: p.primary, color: p.onPrimary, display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: SERIF, fontStyle: 'italic', fontSize: 17 }}>{n}</div>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 15.5, fontWeight: 700, color: p.text }}>{title}</div>
        <p style={{ fontSize: 13, color: p.textMuted, margin: '3px 0 0', lineHeight: 1.5 }}>{body}</p>
      </div>
    </div>
  );
  return (
    <WebCenter max={680}>
      <SectionLabel>Final step · on paper</SectionLabel>
      <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 44, margin: '6px 0 8px', fontWeight: 400, letterSpacing: -0.7, lineHeight: 1 }}>
        Make it legal — <span style={{ color: p.primary }}>with a pen.</span>
      </h1>
      <p style={{ fontSize: 14.5, color: p.textMuted, margin: '0 0 14px', lineHeight: 1.55 }}>
        Pennsylvania law requires a real signature on paper. We can't witness it for you — but here's exactly what to do.
      </p>
      <div style={{ background: p.surface, border: `1px solid ${p.border}`, borderRadius: 12, padding: 14, display: 'flex', gap: 10, marginBottom: 22 }}>
        <Info size={16} stroke={p.textMuted} />
        <div style={{ fontSize: 12.5, color: p.textMuted, lineHeight: 1.5 }}>
          <strong style={{ color: p.text }}>Why not sign in the browser?</strong> Under Act 194 the directive is valid only when you and two qualified witnesses sign the <em>same paper document</em>, together. A click-to-sign wouldn't hold up.
        </div>
      </div>
      <Step n="1" title="Print the packet" body="Print the PDF we just made. It already has signature lines for you and two witnesses." />
      <Step n="2" title="Gather two qualified witnesses" body="Both must be 18+, present at the same time, and NOT your agent, alternate, or a provider treating you." />
      <Step n="3" title="Everyone signs, same place, same time" body="Sign and date the signature page in front of both witnesses. They sign right after you, while you watch." />
      <div style={{ display: 'flex', gap: 10, marginTop: 12 }}>
        <Btn kind="primary" leading={<Download size={16} />}>Download signing packet (PDF)</Btn>
        <Btn kind="outline" leading={<Icon size={14}><path d="M6 9V2h12v7"/><rect x="6" y="14" width="12" height="8"/></Icon>}>Print now</Btn>
      </div>
      <p style={{ fontSize: 11, color: p.textMuted, fontFamily: MONO, marginTop: 14, letterSpacing: 0.3, lineHeight: 1.5 }}>
        NOT YET VALID · BECOMES LEGAL ONCE SIGNED ON PAPER BY YOU + 2 WITNESSES
      </p>
    </WebCenter>
  );
}

// ── Done ──────────────────────────────────────────────────────────────
function WebDone() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <WebCenter max={620}>
      <div style={{ width: 64, height: 64, borderRadius: 16, background: p.primaryTint, color: p.primary, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 16 }}>
        <Check size={34} sw={3} stroke={p.primary} />
      </div>
      <SectionLabel style={{ color: p.primary }}>● Packet ready</SectionLabel>
      <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 52, margin: '6px 0 8px', fontWeight: 400, letterSpacing: -1, lineHeight: 0.98 }}>One pen away.</h1>
      <p style={{ fontSize: 15, color: p.textMuted, margin: 0, lineHeight: 1.55 }}>
        Your directive is ready to print. It becomes <strong style={{ color: p.text }}>legally valid the moment you and two witnesses sign it on paper</strong> — then make sure the right people have a copy.
      </p>
      <div style={{ height: 22 }} />
      <SectionLabel>What's next</SectionLabel>
      <div style={{ marginTop: 10, display: 'flex', flexDirection: 'column', gap: 8 }}>
        {[
          { icon: <Download size={16} />, t: 'Download & print the packet', s: 'PDF · US Letter · signature page included' },
          { icon: <Share size={16} />, t: 'Share with your agent & providers', s: 'Email, print, or an emergency QR' },
          { icon: <Wallet size={16} />, t: 'Carry a wallet card', s: 'Quick summary for a crisis' },
        ].map((row, i) => (
          <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '13px 16px', background: p.card, border: `1px solid ${p.border}`, borderRadius: 12 }}>
            <div style={{ width: 34, height: 34, borderRadius: 9, background: p.primaryTint, color: p.primary, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>{row.icon}</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 700, color: p.text }}>{row.t}</div>
              <div style={{ fontSize: 12, color: p.textMuted, marginTop: 1 }}>{row.s}</div>
            </div>
            <Arrow size={15} stroke={p.primary} />
          </div>
        ))}
      </div>
      <div style={{ marginTop: 16, padding: '12px 16px', background: p.warnBg, border: `1px solid ${p.warnBorder}`, borderRadius: 12, display: 'flex', gap: 10, color: p.warnText, fontSize: 12.5, lineHeight: 1.45 }}>
        <AlertTri size={16} stroke={p.warnText} />
        <div><strong>Download before you close.</strong> Nothing is saved on our end — once this tab closes, your answers are gone.</div>
      </div>
    </WebCenter>
  );
}

// ── Share sheet (local-only) ──────────────────────────────────────────
function WebShare() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <>
      <WebSidebar active="export" />
      <div style={{ flex: 1, overflow: 'auto', padding: '32px 40px 40px' }}>
        <SectionLabel>Share my directive</SectionLabel>
        <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 40, margin: '6px 0 6px', fontWeight: 400, letterSpacing: -0.7, lineHeight: 1 }}>Who needs a copy?</h1>
        <p style={{ fontSize: 14, color: p.textMuted, margin: '0 0 22px', maxWidth: 560, lineHeight: 1.5 }}>
          Everything sends straight from your browser — your mail app, a QR, or print. Nothing goes through our servers.
        </p>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 12, maxWidth: 620 }}>
          {[
            { icon: <Icon size={20}><path d="M4 4h16v16H4z M4 4l8 8 8-8"/></Icon>, label: 'Email' },
            { icon: <Icon size={20}><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></Icon>, label: 'Show QR' },
            { icon: <Download size={20} />, label: 'Download' },
            { icon: <Icon size={20}><path d="M6 9V2h12v7"/><rect x="6" y="14" width="12" height="8"/></Icon>, label: 'Print' },
          ].map((c, i) => (
            <div key={i} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8, padding: '18px 8px', background: p.card, border: `1px solid ${p.border}`, borderRadius: 12 }}>
              <div style={{ width: 40, height: 40, borderRadius: 10, background: p.primaryTint, color: p.primary, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{c.icon}</div>
              <span style={{ fontSize: 12.5, fontWeight: 600, color: p.text }}>{c.label}</span>
            </div>
          ))}
        </div>
        <div style={{ height: 22 }} />
        <SectionLabel>They get</SectionLabel>
        <div style={{ marginTop: 8, maxWidth: 620, background: p.card, border: `1px solid ${p.border}`, borderRadius: 12, padding: '4px 16px' }}>
          {[['Full directive PDF', '6 pages'], ['Wallet-card summary', '1 page'], ['Emergency QR (works offline)', 'Self-contained']].map(([k, v], i, arr) => (
            <div key={i} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '11px 0', borderBottom: i < arr.length - 1 ? `1px dashed ${p.border}` : 'none', fontSize: 13 }}>
              <span style={{ color: p.text, fontWeight: 500 }}>{k}</span>
              <span style={{ color: p.textMuted, fontFamily: MONO, fontSize: 11 }}>{v}</span>
            </div>
          ))}
        </div>
        <div style={{ maxWidth: 620, marginTop: 12, display: 'flex', alignItems: 'center', gap: 8, padding: '10px 14px', background: p.surface, border: `1px solid ${p.border}`, borderRadius: 10 }}>
          <Lock size={14} stroke={p.textMuted} />
          <span style={{ fontSize: 11.5, color: p.textMuted, flex: 1, lineHeight: 1.4 }}>No tracking links, no expiry, no read receipts — we can't see who you send it to. The QR holds the summary itself, so it works even with no signal.</span>
        </div>
      </div>
    </>
  );
}

// ── Crisis sheet (988) ────────────────────────────────────────────────
function WebCrisis() {
  const { palette: p } = React.useContext(MHADContext);
  const Line = ({ name, sub, num, primary }) => (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 14, padding: '16px 18px', marginBottom: 10,
      background: primary ? p.crisisAccent : p.card, color: primary ? '#fff' : p.text,
      border: primary ? 'none' : `1px solid ${p.border}`, borderRadius: 14,
    }}>
      <div style={{ width: 44, height: 44, borderRadius: 100, flexShrink: 0, background: primary ? 'rgba(255,255,255,0.2)' : p.crisisBg, color: primary ? '#fff' : p.crisisAccent, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Phone size={20} stroke={primary ? '#fff' : p.crisisAccent} />
      </div>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 16, fontWeight: 700 }}>{name}</div>
        <div style={{ fontSize: 12.5, opacity: primary ? 0.9 : 0.7 }}>{sub}</div>
      </div>
      <div style={{ fontFamily: MONO, fontSize: 17, fontWeight: 700 }}>{num}</div>
    </div>
  );
  return (
    <WebCenter max={620}>
      <SectionLabel style={{ color: p.crisisAccent }}>● You're not alone</SectionLabel>
      <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 44, margin: '6px 0 8px', fontWeight: 400, letterSpacing: -0.7, lineHeight: 1 }}>Need help right now?</h1>
      <p style={{ fontSize: 14.5, color: p.textMuted, margin: '0 0 22px', lineHeight: 1.55 }}>
        If you're in crisis, reach out. These lines are free, confidential, and open 24/7. You can come back to your directive anytime.
      </p>
      <Line primary name="988 Suicide & Crisis Lifeline" sub="Call or text · 24/7 · free & confidential" num="988" />
      <Line name="Crisis Text Line" sub="Text HOME to connect with a counselor" num="741741" />
      <Line name="Veterans Crisis Line" sub="Press 1 after dialing 988" num="988" />
      <Line name="Trevor Project (LGBTQ+ youth)" sub="Call · text · chat" num="1-866-488-7386" />
      <div style={{ marginTop: 12, padding: '14px 16px', background: p.primaryTint, border: `1px solid ${p.primaryLight}`, borderRadius: 12, display: 'flex', gap: 10 }}>
        <Heart size={16} stroke={p.primary} />
        <span style={{ flex: 1, fontSize: 13, color: p.text, lineHeight: 1.5 }}>If you or someone else is in immediate danger, call <strong>911</strong>.</span>
      </div>
    </WebCenter>
  );
}

// ── Learn · article reader ────────────────────────────────────────────
function WebArticle() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <>
      <WebSidebar active="learn" />
      <div style={{ flex: 1, overflow: 'auto', display: 'flex', justifyContent: 'center', background: p.surface }}>
        <div style={{ width: '100%', maxWidth: 680, padding: '36px 40px 56px' }}>
          <span style={{ fontSize: 13, color: p.primary, fontWeight: 600, display: 'inline-flex', alignItems: 'center', gap: 4, cursor: 'pointer' }}><Icon d="M15 18l-6-6 6-6" size={14} /> Learn hub</span>
          <div style={{ height: 16 }} />
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 14 }}>
            <div style={{ width: 30, height: 30, borderRadius: 8, background: p.primary, color: p.onPrimary, display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: MONO, fontWeight: 700, fontSize: 10 }}>P&A</div>
            <div style={{ fontFamily: MONO, fontSize: 10.5, color: p.textMuted, letterSpacing: 0.6 }}>FROM THE OFFICIAL BOOKLET · 4 MIN READ</div>
          </div>
          <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 40, margin: '0 0 16px', fontWeight: 400, letterSpacing: -0.7, lineHeight: 1.05 }}>
            What is a Mental Health Advance Directive?
          </h1>
          <div style={{ fontSize: 15.5, color: p.text, lineHeight: 1.7 }}>
            <p style={{ margin: '0 0 16px' }}>A Mental Health Advance Directive (MHAD) is a legal document that lets you say, in advance, how you want to be treated during a mental health crisis — and who you trust to speak for you if you can't speak for yourself.</p>
            <p style={{ margin: '0 0 16px' }}>In Pennsylvania, the MHAD is governed by Act 194 of 2004. It has two parts you can use together or separately: a <strong>declaration</strong> of your treatment preferences, and a <strong>power of attorney</strong> naming a trusted agent.</p>
            <div style={{ background: p.primaryTint, border: `1px solid ${p.primaryLight}`, borderRadius: 12, padding: 16, margin: '20px 0' }}>
              <div style={{ fontFamily: MONO, fontSize: 10, color: p.primary, letterSpacing: 0.6, fontWeight: 700, marginBottom: 6 }}>TRY IT</div>
              <div style={{ fontSize: 14, fontWeight: 700, color: p.text }}>Ready to write yours?</div>
              <div style={{ fontSize: 13, color: p.textMuted, margin: '4px 0 10px', lineHeight: 1.5 }}>The guided wizard takes about 20 minutes and works anonymously.</div>
              <Btn kind="primary" size="sm" trailing={<Arrow size={14} />}>Start my directive</Btn>
            </div>
            <p style={{ margin: '0 0 16px' }}>Your directive only takes effect when professionals determine you can't make decisions for yourself — and stops applying as soon as you regain capacity.</p>
          </div>
          <div style={{ height: 24, borderTop: `1px solid ${p.border}`, marginTop: 8 }} />
          <SectionLabel>Up next</SectionLabel>
          <div style={{ marginTop: 10, display: 'flex', flexDirection: 'column', gap: 8 }}>
            {[['Picking the right agent', '5 min read'], ['Your rights under Act 194', '7 min read']].map(([t, s], i) => (
              <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '13px 16px', background: p.card, border: `1px solid ${p.border}`, borderRadius: 12 }}>
                <Book size={16} stroke={p.primary} />
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 14, fontWeight: 600, color: p.text }}>{t}</div>
                  <div style={{ fontSize: 12, color: p.textMuted }}>{s}</div>
                </div>
                <Arrow size={14} stroke={p.textMuted} />
              </div>
            ))}
          </div>
        </div>
      </div>
    </>
  );
}

// ── Settings (anonymous-appropriate: appearance + accessibility) ──────
function WebSettings() {
  const { palette: p } = React.useContext(MHADContext);
  const Toggle = ({ on }) => (
    <div style={{ width: 44, height: 26, borderRadius: 100, flexShrink: 0, background: on ? p.primary : p.border, padding: 3 }}>
      <div style={{ width: 20, height: 20, borderRadius: 100, background: '#fff', transform: on ? 'translateX(18px)' : 'translateX(0)', transition: 'transform 0.2s', boxShadow: '0 1px 3px rgba(0,0,0,0.15)' }} />
    </div>
  );
  const Row = ({ label, sub, trailing }) => (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '13px 16px', background: p.card, border: `1px solid ${p.border}`, borderRadius: 12, marginBottom: 8 }}>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 14, fontWeight: 600, color: p.text }}>{label}</div>
        {sub && <div style={{ fontSize: 12, color: p.textMuted, marginTop: 1 }}>{sub}</div>}
      </div>
      {trailing}
    </div>
  );
  return (
    <>
      <WebSidebar active="settings" />
      <div style={{ flex: 1, overflow: 'auto', display: 'flex', justifyContent: 'center', background: p.surface }}>
        <div style={{ width: '100%', maxWidth: 640, padding: '36px 40px 56px' }}>
          <SectionLabel>Settings</SectionLabel>
          <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 38, margin: '6px 0 6px', fontWeight: 400, letterSpacing: -0.6, lineHeight: 1 }}>Make it yours.</h1>
          <p style={{ fontSize: 14, color: p.textMuted, margin: '0 0 22px', lineHeight: 1.5 }}>This anonymous web app keeps no account — these settings apply to this session only.</p>

          <SectionLabel>Appearance</SectionLabel>
          <div style={{ marginTop: 10, marginBottom: 18 }}>
            <Row label="Color theme" sub="Warm Teal · Deep Navy · Sage" trailing={<span style={{ fontSize: 12.5, fontWeight: 700, color: p.primary }}>Change ›</span>} />
            <Row label="Light / dark" sub="Follows your system by default" trailing={<span style={{ fontSize: 12.5, fontWeight: 700, color: p.primary }}>System ›</span>} />
          </div>

          <SectionLabel>Reading &amp; accessibility</SectionLabel>
          <div style={{ marginTop: 10, marginBottom: 18 }}>
            <Row label="Larger text" sub="Scale up type across the app" trailing={<Toggle on={false} />} />
            <Row label="Dyslexia-friendly font" sub="Atkinson Hyperlegible" trailing={<Toggle on={false} />} />
            <Row label="Reduce motion" sub="No transitions or parallax" trailing={<Toggle on={true} />} />
            <Row label="High contrast" sub="Boost text/background separation" trailing={<Toggle on={false} />} />
            <Row label="Language" sub="English · Español · 中文" trailing={<span style={{ fontSize: 12.5, fontWeight: 700, color: p.primary }}>English ›</span>} />
          </div>

          <SectionLabel>Privacy</SectionLabel>
          <div style={{ marginTop: 10 }}>
            <Row label="AI assistant" sub="Off by default · sends text (PII stripped) to read" trailing={<Toggle on={false} />} />
            <Row label="Clear this session now" sub="Wipes everything in this tab immediately" trailing={<span style={{ fontSize: 12.5, fontWeight: 700, color: p.crisisAccent }}>Clear ›</span>} />
          </div>
        </div>
      </div>
    </>
  );
}

// ── Revocation ────────────────────────────────────────────────────────
function WebRevoke() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <WebCenter max={640}>
      <SectionLabel style={{ color: p.crisisAccent }}>● Revoke a directive</SectionLabel>
      <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 42, margin: '6px 0 8px', fontWeight: 400, letterSpacing: -0.7, lineHeight: 1 }}>
        Cancel this directive.
      </h1>
      <p style={{ fontSize: 14.5, color: p.textMuted, margin: '0 0 20px', lineHeight: 1.55 }}>
        You can revoke at any time while you have capacity. We'll generate a dated revocation document for you to print and sign — and a checklist of who to notify.
      </p>
      <div style={{ background: p.card, border: `1px solid ${p.border}`, borderRadius: 14, padding: 18 }}>
        <SectionLabel>How revocation works in PA</SectionLabel>
        <ol style={{ margin: '10px 0 0', paddingLeft: 18, fontSize: 13.5, color: p.text, lineHeight: 1.7 }}>
          <li>Sign &amp; date a written statement of revocation (we draft it for you).</li>
          <li>Tell your agent, providers, and anyone holding a copy.</li>
          <li>Destroy or clearly mark old copies "REVOKED".</li>
        </ol>
      </div>
      <div style={{ marginTop: 14 }}>
        <SectionLabel>Notify (you choose each)</SectionLabel>
        <div style={{ marginTop: 8, display: 'flex', flexDirection: 'column', gap: 8 }}>
          {['Jordan Lee · primary agent', 'Dr. R. Patel · psychiatrist', 'UPMC Western Psych · records'].map((n, i) => (
            <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '11px 14px', background: p.card, border: `1px solid ${p.border}`, borderRadius: 10 }}>
              <div style={{ width: 18, height: 18, borderRadius: 5, border: `1.5px solid ${p.border}`, flexShrink: 0 }} />
              <span style={{ flex: 1, fontSize: 13.5, color: p.text }}>{n}</span>
              <span style={{ fontFamily: MONO, fontSize: 10.5, color: p.textMuted, letterSpacing: 0.4 }}>OPT-IN</span>
            </div>
          ))}
        </div>
        <p style={{ fontSize: 11.5, color: p.textMuted, fontStyle: 'italic', marginTop: 8 }}>No one is notified automatically — each send opens your own mail app.</p>
      </div>
      <div style={{ display: 'flex', gap: 10, marginTop: 20 }}>
        <Btn kind="outline">Cancel</Btn>
        <div style={{ flex: 1 }} />
        <Btn kind="primary" leading={<Download size={15} />} style={{ background: p.crisisAccent }}>Generate revocation PDF</Btn>
      </div>
    </WebCenter>
  );
}

// ── Voice input ───────────────────────────────────────────────────────
function WebVoice() {
  const { palette: p } = React.useContext(MHADContext);
  const bars = Array.from({ length: 40 });
  return (
    <WebCenter max={620}>
      <SectionLabel style={{ color: p.primary }}>● Recording</SectionLabel>
      <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 40, margin: '6px 0 8px', fontWeight: 400, letterSpacing: -0.7, lineHeight: 1 }}>Say it your way.</h1>
      <p style={{ fontSize: 14.5, color: p.textMuted, margin: '0 0 24px', lineHeight: 1.55 }}>
        Speak naturally — we'll transcribe it into the "Anything else" field, where you can edit before saving.
      </p>
      <div style={{ background: p.card, border: `1px solid ${p.border}`, borderRadius: 16, padding: '28px 24px', textAlign: 'center' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 3, height: 64, marginBottom: 18 }}>
          {bars.map((_, i) => {
            const h = 8 + Math.abs(Math.sin(i * 0.9)) * 48;
            return <div key={i} style={{ width: 4, height: h, borderRadius: 100, background: i % 3 === 0 ? p.primary : p.primaryLight }} />;
          })}
        </div>
        <div style={{ fontSize: 15, color: p.text, lineHeight: 1.6, fontStyle: 'italic', maxWidth: 460, margin: '0 auto' }}>
          "Please avoid physical restraints. If I need to be calmed, my agent Jordan knows my preferences…"
        </div>
        <div style={{ marginTop: 22, display: 'flex', gap: 10, justifyContent: 'center' }}>
          <Btn kind="outline">Cancel</Btn>
          <div style={{ width: 56, height: 56, borderRadius: 100, background: p.crisisAccent, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <div style={{ width: 20, height: 20, borderRadius: 4, background: '#fff' }} />
          </div>
          <Btn kind="primary">Use transcript</Btn>
        </div>
      </div>
      <div style={{ marginTop: 14, display: 'flex', alignItems: 'center', gap: 8, padding: '10px 14px', background: p.surface, border: `1px solid ${p.border}`, borderRadius: 10 }}>
        <Lock size={14} stroke={p.textMuted} />
        <span style={{ fontSize: 11.5, color: p.textMuted, flex: 1, lineHeight: 1.4 }}>Audio isn't saved. The transcript stays in this session until you save the field.</span>
      </div>
    </WebCenter>
  );
}

// ── Data export hub (multi-format download) ───────────────────────────
function WebDataExport() {
  const { palette: p } = React.useContext(MHADContext);

  const Format = ({ icon, code, name, sub, size, recommended }) => (
    <div style={{
      background: p.card, border: `1.5px solid ${recommended ? p.primary : p.border}`,
      borderRadius: 14, padding: 16, position: 'relative',
      display: 'flex', gap: 14,
    }}>
      {recommended && (
        <div style={{
          position: 'absolute', top: -8, left: 16,
          fontFamily: MONO, fontSize: 9, fontWeight: 700, letterSpacing: 0.5,
          color: p.onPrimary, background: p.primary,
          padding: '2px 7px', borderRadius: 3,
        }}>RECOMMENDED</div>
      )}
      <div style={{
        width: 46, height: 46, borderRadius: 11, flexShrink: 0,
        background: p.primaryTint, color: p.primary,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>{icon}</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <span style={{ fontSize: 15, fontWeight: 700, color: p.text }}>{name}</span>
          <span style={{ fontFamily: MONO, fontSize: 10, color: p.textMuted, background: p.surface, padding: '1px 6px', borderRadius: 3, letterSpacing: 0.4 }}>{code}</span>
        </div>
        <p style={{ margin: '4px 0 0', fontSize: 12.5, color: p.textMuted, lineHeight: 1.45 }}>{sub}</p>
        <div style={{ fontFamily: MONO, fontSize: 10, color: p.textMuted, marginTop: 8, letterSpacing: 0.4 }}>~{size}</div>
      </div>
      <Download size={18} stroke={p.primary} />
    </div>
  );

  return (
    <>
      <WebSidebar active="export" />
      <div style={{ flex: 1, overflow: 'auto', padding: '32px 40px 40px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 6 }}>
          <span style={{ fontSize: 13, color: p.textMuted, display: 'flex', alignItems: 'center', gap: 6 }}>
            <Icon d="M15 18l-6-6 6-6" size={14} /> Download &amp; print
          </span>
          <div style={{ flex: 1 }} />
          <TabOnlyPill />
        </div>

        <SectionLabel>Export your directive</SectionLabel>
        <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 44, margin: '4px 0 6px', fontWeight: 400, letterSpacing: -0.8, lineHeight: 1 }}>
          Take it with you.
        </h1>
        <p style={{ fontSize: 14, color: p.textMuted, margin: 0, maxWidth: 620, lineHeight: 1.5 }}>
          Download your directive in whatever format you need. Nothing is sent to us — files are generated in your browser and saved straight to your computer.
        </p>

        <div style={{ height: 22 }} />
        <SectionLabel>Pick a format</SectionLabel>
        <div style={{ height: 12 }} />

        {/* Two-column grid for desktop density */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
          <Format
            recommended
            icon={<FileText size={22} />}
            code=".pdf"
            name="PDF · official form"
            sub="The 6-page document, sized for US Letter and matched to PA's official form. This is the one you print and sign."
            size="2.1 MB"
          />
          <Format
            icon={<Icon size={22}><path d="M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0z"/><path d="M8 12l3 3 5-6"/></Icon>}
            code=".json"
            name="Structured data"
            sub="All your answers as a labelled JSON object — for your own records or to re-import later."
            size="14 KB"
          />
          <Format
            icon={<Icon size={22}><path d="M3 12h6m6 0h6M9 6h6m-6 12h6M9 6v12M15 6v12"/></Icon>}
            code=".xml"
            name="HL7 FHIR R4"
            sub="Healthcare-standard bundle — Consent + RelatedPerson + Practitioner. For your provider's EHR."
            size="46 KB"
          />
          <Format
            icon={<Icon size={22}><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M9 3v18"/></Icon>}
            code=".csv"
            name="Spreadsheet"
            sub="Question-answer pairs in a flat table. Useful for review with a lawyer."
            size="6 KB"
          />
        </div>

        {/* Bundle option */}
        <div style={{
          marginTop: 12, background: p.surface, border: `1px dashed ${p.border}`,
          borderRadius: 12, padding: 14, display: 'flex', gap: 12, alignItems: 'center',
        }}>
          <Icon size={20} stroke={p.text}><rect x="3" y="7" width="18" height="13" rx="2"/><path d="M8 7V4h8v3M3 12h18"/></Icon>
          <div style={{ flex: 1, fontSize: 13, color: p.text, lineHeight: 1.4 }}>
            <strong>Bundle everything</strong> as a .zip — handy for handing off to your agent in one file.
          </div>
          <Btn kind="outline" size="sm" trailing={<Download size={13} />}>Get .zip</Btn>
        </div>

        <div style={{ height: 16 }} />
        {/* Password protection */}
        <div style={{
          background: p.card, border: `1px solid ${p.border}`,
          borderRadius: 12, padding: 16, maxWidth: 720,
        }}>
          <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
            <Lock size={18} stroke={p.primary} />
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 700, color: p.text }}>Password-protect the download</div>
              <div style={{ fontSize: 12, color: p.textMuted, marginTop: 1 }}>Encrypts the PDF and the .zip bundle with AES-256. Plain formats (JSON/XML/CSV) stay importable.</div>
            </div>
            <div style={{ display: 'flex', gap: 10, alignItems: 'center' }}>
              <input type="password" placeholder="Create a password" style={{
                width: 200, border: `1px solid ${p.border}`, borderRadius: 8, padding: '9px 12px',
                fontFamily: SANS, fontSize: 13, color: p.text, outline: 'none', background: p.surface,
              }} />
              <Btn kind="outline" size="sm">Apply</Btn>
            </div>
          </div>
          <div style={{
            marginTop: 12, padding: '8px 12px', background: p.warnBg, border: `1px solid ${p.warnBorder}`,
            borderRadius: 8, display: 'flex', gap: 8,
          }}>
            <AlertTri size={14} stroke={p.warnText} />
            <span style={{ fontSize: 11.5, color: p.warnText, lineHeight: 1.4 }}>
              There's no server, so we can't reset this password. If it's lost the file can't be opened — share it with your recipient through a separate channel.
            </span>
          </div>
        </div>

        <div style={{ height: 16 }} />
        <div style={{
          background: p.primaryTint, border: `1px solid ${p.primary}25`,
          borderRadius: 12, padding: 14, display: 'flex', gap: 10, maxWidth: 720,
        }}>
          <Lock size={16} stroke={p.primary} />
          <div style={{ flex: 1, fontSize: 12.5, color: p.text, lineHeight: 1.45 }}>
            Every format is built right here in your browser. We never see your directive, and nothing is stored once you close this tab — so download what you need before you go.
          </div>
        </div>
      </div>
    </>
  );
}

Object.assign(window, {
  WebDisclaimer, WebFormType, WebQuiz, WebConflict, WebSign, WebDone,
  WebShare, WebCrisis, WebArticle, WebSettings, WebRevoke, WebVoice,
  WebDataExport,
});
