// mobile-extra2.jsx — Round-3 mobile screens for full coverage.
// Apple Wallet handoff, permissions prompt, AI conflict warning, data export hub.

// ─── X · Add to Apple Wallet handoff ───────────────────────────────────
function ScrAppleWallet() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <Screen scroll={false} style={{ background: '#000' }}>
      {/* OS-level system sheet — black, premium */}
      <div style={{ height: STATUSBAR_H }} />
      <div style={{ padding: '14px 18px 8px', display: 'flex', alignItems: 'center', gap: 10, color: '#fff' }}>
        <X size={20} stroke="#fff" />
        <div style={{ flex: 1, textAlign: 'center' }}>
          <div style={{ fontSize: 13, fontWeight: 600 }}>Add to Wallet</div>
        </div>
        <Btn kind="ghost" size="sm" style={{ color: '#fff' }}>Add</Btn>
      </div>

      {/* Pass preview — emulates Apple Wallet pass card */}
      <div style={{ padding: '24px 28px 12px' }}>
        <div style={{
          background: `linear-gradient(155deg, ${p.primary} 0%, ${p.primaryDark} 100%)`,
          color: p.onPrimary, borderRadius: 16,
          padding: '18px 18px 20px',
          boxShadow: '0 24px 60px rgba(0,0,0,0.5)',
          position: 'relative', overflow: 'hidden',
        }}>
          <div style={{
            position: 'absolute', right: -16, top: -32,
            fontFamily: SERIF, fontStyle: 'italic', fontSize: 180,
            color: 'rgba(255,255,255,0.08)', lineHeight: 1, fontWeight: 400,
          }}>MH</div>
          <div style={{ position: 'relative', display: 'flex', alignItems: 'flex-start', gap: 12 }}>
            <div style={{
              width: 28, height: 28, borderRadius: 6,
              background: 'rgba(255,255,255,0.18)', display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontFamily: SERIF, fontStyle: 'italic', fontSize: 16, fontWeight: 400,
            }}>m</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontFamily: MONO, fontSize: 9, letterSpacing: 1.3, opacity: 0.85 }}>PA MHAD · ACT 194</div>
              <div style={{ fontSize: 12, opacity: 0.9, marginTop: 1 }}>Mental Health Advance Directive</div>
            </div>
          </div>

          <div style={{ position: 'relative', display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', marginTop: 20 }}>
            <div>
              <div style={{ fontFamily: MONO, fontSize: 9, opacity: 0.7, letterSpacing: 0.7 }}>HOLDER</div>
              <div style={{ fontSize: 18, fontWeight: 700, letterSpacing: -0.2, marginTop: 2 }}>Alex M. Kowalski</div>
              <div style={{ fontSize: 11, opacity: 0.85, marginTop: 4 }}>Agent: Jordan Lee · (412) 555-0188</div>
            </div>
          </div>

          {/* Faux barcode strip */}
          <div style={{
            position: 'relative', marginTop: 16, background: '#fff', borderRadius: 6,
            padding: '8px 10px', display: 'flex', alignItems: 'center', gap: 10,
          }}>
            <QR size={36} stroke={p.primaryDark} />
            <div style={{ flex: 1 }}>
              <div style={{ fontFamily: MONO, fontSize: 9, color: p.textMuted, letterSpacing: 0.5 }}>VERIFICATION CODE</div>
              <div style={{ fontFamily: MONO, fontSize: 13, color: p.primaryDark, fontWeight: 600, marginTop: 1 }}>AK · 2026 · 1414</div>
            </div>
            <div style={{ fontFamily: MONO, fontSize: 10, color: p.textMuted, textAlign: 'right' }}>
              EXP<br/>
              <span style={{ fontSize: 13, color: p.primaryDark, fontWeight: 600 }}>05/28</span>
            </div>
          </div>
        </div>
      </div>

      {/* Details (back of pass) */}
      <div style={{ padding: '8px 28px 16px', color: '#fff' }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          {[
            ['Issued by', 'mhad.gov · sandboxed'],
            ['Updates', 'When you renew or revoke'],
            ['Where it shows up', 'Lock screen near hospitals'],
            ['Privacy', 'No location tracking · no sharing'],
          ].map(([k, v], i) => (
            <div key={i} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: 12, paddingBottom: 10, borderBottom: '1px solid rgba(255,255,255,0.1)' }}>
              <span style={{ color: 'rgba(255,255,255,0.6)' }}>{k}</span>
              <span style={{ fontWeight: 600 }}>{v}</span>
            </div>
          ))}
        </div>

        <div style={{
          marginTop: 14, background: 'rgba(255,255,255,0.08)',
          borderRadius: 10, padding: '10px 12px',
          display: 'flex', gap: 10, alignItems: 'center',
        }}>
          <Lock size={14} stroke="#fff" />
          <span style={{ fontSize: 12, color: 'rgba(255,255,255,0.85)', flex: 1 }}>
            First responders can scan the QR. They never see your draft answers.
          </span>
        </div>

        {/* Big primary CTA */}
        <div style={{ height: 16 }} />
        <button style={{
          width: '100%', background: '#fff', color: '#000', border: 'none',
          borderRadius: 14, padding: '14px',
          fontSize: 15, fontWeight: 700, fontFamily: SANS,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
        }}>
          <Wallet size={18} stroke="#000" /> Add to Wallet
        </button>
      </div>
    </Screen>
  );
}

// ─── X · OS permissions prompt ─────────────────────────────────────────
function ScrPermission() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <Screen scroll={false} style={{ background: '#000' }}>
      {/* Backdrop: ID-scan-ish dark camera surface */}
      <div style={{ position: 'absolute', inset: 0, opacity: 0.4, background: 'radial-gradient(ellipse at center, #2a2520, #0a0908)' }} />
      <div style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.55)' }} />

      <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 28 }}>
        {/* Native-style alert dialog */}
        <div style={{
          width: '100%', maxWidth: 320,
          background: 'rgba(40, 38, 35, 0.92)',
          backdropFilter: 'blur(40px) saturate(180%)',
          borderRadius: 16, color: '#fff', overflow: 'hidden',
        }}>
          {/* Content */}
          <div style={{ padding: '22px 20px 16px', textAlign: 'center' }}>
            <div style={{ display: 'flex', justifyContent: 'center', marginBottom: 12 }}>
              <div style={{
                width: 48, height: 48, borderRadius: 11,
                background: 'rgba(255,255,255,0.1)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <Icon size={26} stroke="#fff" sw={1.6}><circle cx="12" cy="13" r="4"/><path d="M3 7h4l2-3h6l2 3h4v12H3z"/></Icon>
              </div>
            </div>
            <h3 style={{ fontSize: 16, fontWeight: 700, margin: '0 0 6px', letterSpacing: -0.2, fontFamily: 'SF Pro, system-ui, sans-serif' }}>
              "PA MHAD" Would Like to Access the Camera
            </h3>
            <p style={{ fontSize: 13.5, margin: 0, color: 'rgba(255,255,255,0.78)', lineHeight: 1.45, fontFamily: 'SF Pro, system-ui, sans-serif' }}>
              Used to snap your ID, medication labels, condition lists, or anything else. The photo is sent to our AI to read it, then discarded.
            </p>
          </div>

          {/* What we use it for · plain language */}
          <div style={{ padding: '0 20px 18px' }}>
            <div style={{
              background: 'rgba(255,255,255,0.08)', borderRadius: 10,
              padding: '10px 12px', display: 'flex', flexDirection: 'column', gap: 8,
              fontSize: 11.5, lineHeight: 1.4,
            }}>
              {[
                ['Photo sent to AI only to read it', true],
                ['Photo discarded right after extraction', true],
                ['Nothing is saved or stored', true],
                ['You review every field before it\'s used', true],
              ].map(([l, ok], i) => (
                <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 8, color: ok ? '#fff' : 'rgba(255,255,255,0.6)' }}>
                  {ok ? <Check size={12} sw={3} stroke="#7CD9A1" /> : <X size={11} sw={2.5} stroke="rgba(255,255,255,0.6)" />}
                  {l}
                </div>
              ))}
            </div>
          </div>

          {/* iOS-style stacked buttons */}
          <div style={{ borderTop: '0.5px solid rgba(255,255,255,0.15)' }}>
            <button style={{
              width: '100%', background: 'transparent', border: 'none',
              padding: '13px', color: 'rgba(255,255,255,0.85)', fontSize: 15,
              fontFamily: 'SF Pro, system-ui, sans-serif',
              borderBottom: '0.5px solid rgba(255,255,255,0.15)',
            }}>Don't Allow</button>
            <button style={{
              width: '100%', background: 'transparent', border: 'none',
              padding: '13px', color: '#4ABFB1', fontSize: 15, fontWeight: 600,
              fontFamily: 'SF Pro, system-ui, sans-serif',
            }}>Allow</button>
          </div>
        </div>
      </div>

      {/* Annotation pill */}
      <div style={{
        position: 'absolute', top: STATUSBAR_H + 16, left: 16,
        background: 'rgba(255,255,255,0.1)', backdropFilter: 'blur(20px)',
        borderRadius: 100, padding: '5px 12px',
        fontFamily: MONO, fontSize: 10, color: '#fff',
        letterSpacing: 0.5, fontWeight: 600,
        display: 'inline-flex', alignItems: 'center', gap: 5,
      }}>
        <Info size={10} stroke="#fff" /> SYSTEM PERMISSION
      </div>
    </Screen>
  );
}

// ─── X · AI conflict warning ───────────────────────────────────────────
function ScrAIConflict() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <Screen scroll={false}>
      <CrisisBar compact />
      <WizardHeader back="Review" pad="10px 22px 0" action="Skip checks" />

      <div style={{ padding: '14px 22px 24px', flex: 1, minHeight: 0, overflow: 'auto' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <Sparkles size={16} stroke={p.primary} />
          <SectionLabel>AI consistency check</SectionLabel>
        </div>
        <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 36, margin: '6px 0 6px', fontWeight: 400, letterSpacing: -0.5, lineHeight: 1.05 }}>
          I noticed <span style={{ color: p.warnText }}>two things</span>.
        </h1>
        <p style={{ fontSize: 13.5, color: p.textMuted, margin: 0, lineHeight: 1.5 }}>
          Your answers may contradict each other. You can keep them, edit them, or ignore the warning.
        </p>

        {/* Conflict 1 */}
        <div style={{
          marginTop: 18,
          background: p.warnBg, border: `1px solid ${p.warnBorder}`,
          borderRadius: TOK.rCard, padding: 14, color: p.warnText,
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <AlertTri size={16} stroke={p.warnText} />
            <span style={{ fontFamily: MONO, fontSize: 10, fontWeight: 700, letterSpacing: 0.5 }}>CONFLICT · 1 OF 2</span>
            <div style={{ flex: 1 }} />
            <span style={{ fontFamily: MONO, fontSize: 9, fontWeight: 700, background: '#fff', padding: '2px 5px', borderRadius: 3, color: p.warnText, border: `1px solid ${p.warnBorder}` }}>STEPS 3 + 9</span>
          </div>
          <h3 style={{ margin: '8px 0 8px', fontSize: 15, fontWeight: 700, color: p.text, letterSpacing: -0.2 }}>
            Your agent can't consent to ECT, but you also said "Agent decides."
          </h3>
          <div style={{ background: p.card, border: `1px solid ${p.border}`, borderRadius: 10, padding: 12, color: p.text }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
              <span style={{ fontFamily: MONO, fontSize: 9, color: p.textMuted, letterSpacing: 0.4 }}>STEP 3</span>
              <span style={{ fontSize: 12.5 }}>"Consent to ECT" → <strong>No</strong></span>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 6 }}>
              <span style={{ fontFamily: MONO, fontSize: 9, color: p.textMuted, letterSpacing: 0.4 }}>STEP 9</span>
              <span style={{ fontSize: 12.5 }}>ECT preference → <strong>Agent decides</strong></span>
            </div>
            <div style={{
              marginTop: 10, paddingTop: 10, borderTop: `1px dashed ${p.border}`,
              fontSize: 12, lineHeight: 1.5, color: p.textMuted,
            }}>
              <strong style={{ color: p.text }}>What this means:</strong> Doctors might not know which to follow. Most people pick one and remove the other.
            </div>
          </div>
          <div style={{ display: 'flex', gap: 6, marginTop: 10 }}>
            <Btn kind="primary" size="sm" trailing={<Arrow size={12} />}>Edit step 9</Btn>
            <Btn kind="outline" size="sm" style={{ color: p.warnText, borderColor: p.warnBorder }}>Edit step 3</Btn>
            <Btn kind="ghost" size="sm" style={{ color: p.textMuted }}>Keep both</Btn>
          </div>
        </div>

        {/* Conflict 2 */}
        <div style={{
          marginTop: 12,
          background: p.warnBg, border: `1px solid ${p.warnBorder}`,
          borderRadius: TOK.rCard, padding: 14, color: p.warnText,
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <AlertTri size={16} stroke={p.warnText} />
            <span style={{ fontFamily: MONO, fontSize: 10, fontWeight: 700, letterSpacing: 0.5 }}>CONFLICT · 2 OF 2</span>
            <div style={{ flex: 1 }} />
            <span style={{ fontFamily: MONO, fontSize: 9, fontWeight: 700, background: '#fff', padding: '2px 5px', borderRadius: 3, color: p.warnText, border: `1px solid ${p.warnBorder}` }}>STEPS 5 + 10</span>
          </div>
          <h3 style={{ margin: '8px 0 8px', fontSize: 15, fontWeight: 700, color: p.text, letterSpacing: -0.2 }}>
            UPMC is on your "avoid" list but also your free-text mentions a UPMC therapist.
          </h3>
          <div style={{ background: p.card, border: `1px solid ${p.border}`, borderRadius: 10, padding: 12, color: p.text, fontSize: 12.5, lineHeight: 1.5 }}>
            <strong>Step 5</strong> · "Avoid UPMC Western Psychiatric"
            <br/>
            <strong>Step 10</strong> · <span style={{ background: p.warnBg, padding: '0 4px' }}>"…coordinate with Dr. Patel at UPMC."</span>
          </div>
        </div>

        <div style={{ height: 14 }} />
        <div style={{
          background: p.primaryTint, border: `1px solid ${p.primary}25`,
          borderRadius: 12, padding: 12, display: 'flex', gap: 10,
        }}>
          <Sparkles size={16} stroke={p.primary} />
          <div style={{ fontSize: 12.5, color: p.text, lineHeight: 1.45, flex: 1 }}>
            <strong style={{ color: p.primaryDark }}>How this works.</strong> I check consistency when you reach Review — these are warnings, not blocks. You can fix them or generate your PDF anyway. I'm not a lawyer.
          </div>
        </div>
      </div>

      <div style={{
        flexShrink: 0, marginTop: 'auto',
        padding: '12px 18px 40px',
        background: p.scaffold, borderTop: `1px solid ${p.border}`,
        display: 'flex', gap: 8,
      }}>
        <Btn kind="ghost" style={{ flex: 1 }}>Ignore &amp; continue</Btn>
        <Btn kind="primary" style={{ flex: 1.4 }} trailing={<Arrow size={16} />}>Resolve in order</Btn>
      </div>
    </Screen>
  );
}

// ─── X · Data export hub ───────────────────────────────────────────────
function ScrDataExport() {
  const { palette: p } = React.useContext(MHADContext);
  const [encrypt, setEncrypt] = React.useState(false);
  const [pw, setPw] = React.useState('');

  // Simple strength heuristic for the meter.
  const strength = (() => {
    let s = 0;
    if (pw.length >= 8) s++;
    if (/[A-Z]/.test(pw) && /[a-z]/.test(pw)) s++;
    if (/[0-9]/.test(pw)) s++;
    if (/[^A-Za-z0-9]/.test(pw)) s++;
    return Math.min(s, 4);
  })();
  const strengthLabel = ['Too short', 'Weak', 'Fair', 'Good', 'Strong'][strength];

  const Format = ({ icon, code, name, sub, size, recommended }) => (
    <div style={{
      background: p.card, border: `1.5px solid ${recommended ? p.primary : p.border}`,
      borderRadius: TOK.rCard, padding: 14, marginBottom: 10,
      display: 'flex', gap: 12, position: 'relative',
    }}>
      {recommended && (
        <div style={{
          position: 'absolute', top: -7, left: 14,
          fontFamily: MONO, fontSize: 9, fontWeight: 700, letterSpacing: 0.5,
          color: p.onPrimary, background: p.primary,
          padding: '2px 6px', borderRadius: 3,
        }}>RECOMMENDED</div>
      )}
      <div style={{
        width: 44, height: 44, borderRadius: 10, flexShrink: 0,
        background: p.primaryTint, color: p.primary,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>{icon}</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <span style={{ fontSize: 14.5, fontWeight: 700, color: p.text }}>{name}</span>
          <span style={{ fontFamily: MONO, fontSize: 9.5, color: p.textMuted, background: p.surface, padding: '1px 5px', borderRadius: 3, letterSpacing: 0.4 }}>{code}</span>
        </div>
        <p style={{ margin: '4px 0 0', fontSize: 12, color: p.textMuted, lineHeight: 1.45 }}>{sub}</p>
        <div style={{ fontFamily: MONO, fontSize: 10, color: p.textMuted, marginTop: 6, letterSpacing: 0.4 }}>~{size}</div>
      </div>
      <Download size={18} stroke={p.primary} />
    </div>
  );

  return (
    <Screen>
      <CrisisBar compact />
      <WizardHeader back="Settings" pad="10px 22px 0" right={null} />

      <div style={{ padding: '12px 22px 100px' }}>
        <SectionLabel>Export my data</SectionLabel>
        <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 36, margin: '6px 0 6px', fontWeight: 400, letterSpacing: -0.5, lineHeight: 1 }}>
          Take it with you.
        </h1>
        <p style={{ fontSize: 13.5, color: p.textMuted, margin: 0, lineHeight: 1.5 }}>
          Your directive in any format. Everything stays on your device until you choose to send it somewhere.
        </p>

        <div style={{ height: 18 }} />
        <SectionLabel>Pick a format</SectionLabel>
        <div style={{ height: 12 }} />

        <Format
          recommended
          icon={<FileText size={22} />}
          code=".pdf"
          name="PDF · official form"
          sub="The 6-page signed document, pixel-matched to PA's official form."
          size="2.1 MB"
        />
        <Format
          icon={<Icon size={22}><path d="M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0z"/><path d="M8 12l3 3 5-6"/></Icon>}
          code=".json"
          name="Structured data"
          sub="All your answers as a labelled JSON object. For your own records or import to a new app."
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
          icon={<Wallet size={22} />}
          code=".pkpass"
          name="Wallet pass"
          sub="The verifiable QR wallet card. Add to Apple Wallet or Google Wallet."
          size="8 KB"
        />
        <Format
          icon={<Icon size={22}><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M9 3v18"/></Icon>}
          code=".csv"
          name="Spreadsheet"
          sub="Question-answer pairs in a flat table. Useful for review with a lawyer."
          size="6 KB"
        />

        {/* Bundle option */}
        <div style={{
          marginTop: 8, background: p.surface, border: `1px dashed ${p.border}`,
          borderRadius: 12, padding: 12, display: 'flex', gap: 10, alignItems: 'center',
        }}>
          <Icon size={18} stroke={p.text}><rect x="3" y="7" width="18" height="13" rx="2"/><path d="M8 7V4h8v3M3 12h18"/></Icon>
          <div style={{ flex: 1, fontSize: 12.5, color: p.text, lineHeight: 1.4 }}>
            <strong>Bundle everything</strong> as a zip — handy for handoff to your agent.
          </div>
          <span style={{ fontSize: 12, fontWeight: 700, color: p.primary }}>Get .zip →</span>
        </div>

        <div style={{ height: 14 }} />
        {/* Encryption — toggle reveals password capture */}
        <div style={{
          background: encrypt ? p.card : p.primaryTint,
          border: `1px solid ${encrypt ? p.primary : p.primary + '25'}`,
          borderRadius: 12, padding: 12,
        }}>
          <div style={{ display: 'flex', gap: 10, alignItems: 'center' }}>
            <Lock size={16} stroke={p.primary} />
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 13, fontWeight: 700, color: p.text }}>Password-protect the file</div>
              <div style={{ fontSize: 11.5, color: p.textMuted, lineHeight: 1.4, marginTop: 1 }}>
                Encrypts the PDF and the .zip bundle. JSON/XML/CSV stay plain for import.
              </div>
            </div>
            <div onClick={() => setEncrypt(!encrypt)} style={{
              width: 44, height: 26, borderRadius: 100, flexShrink: 0,
              background: encrypt ? p.primary : p.border, padding: 3, cursor: 'pointer', transition: 'all 0.2s',
            }}>
              <div style={{ width: 20, height: 20, borderRadius: 100, background: '#fff', transform: encrypt ? 'translateX(18px)' : 'translateX(0)', transition: 'transform 0.2s', boxShadow: '0 1px 3px rgba(0,0,0,0.15)' }} />
            </div>
          </div>

          {encrypt && (
            <div style={{ marginTop: 12 }}>
              <div style={{
                display: 'flex', alignItems: 'center', gap: 8,
                background: p.surface, border: `1px solid ${p.border}`, borderRadius: 10, padding: '10px 12px',
              }}>
                <Icon size={15} stroke={p.textMuted}><rect x="4" y="10" width="16" height="10" rx="2"/><path d="M8 10V7a4 4 0 0 1 8 0v3"/></Icon>
                <input
                  type="password"
                  value={pw}
                  onChange={(e) => setPw(e.target.value)}
                  placeholder="Create a password"
                  style={{ flex: 1, border: 'none', outline: 'none', background: 'transparent', fontFamily: SANS, fontSize: 14, color: p.text }}
                />
              </div>
              {/* Strength meter */}
              <div style={{ display: 'flex', gap: 4, marginTop: 8 }}>
                {[0, 1, 2, 3].map((i) => (
                  <div key={i} style={{
                    flex: 1, height: 4, borderRadius: 100,
                    background: pw && i < strength
                      ? (strength <= 1 ? p.crisisAccent : strength === 2 ? p.warnText : p.okText)
                      : p.border,
                  }} />
                ))}
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 6 }}>
                <span style={{ fontSize: 10.5, color: p.textMuted, fontFamily: MONO, letterSpacing: 0.4 }}>{pw ? strengthLabel.toUpperCase() : 'AT LEAST 8 CHARACTERS'}</span>
                <span style={{ fontSize: 10.5, color: p.textMuted, fontFamily: MONO, letterSpacing: 0.4 }}>AES-256</span>
              </div>
              <div style={{
                marginTop: 10, padding: '8px 10px', background: p.warnBg, border: `1px solid ${p.warnBorder}`,
                borderRadius: 8, display: 'flex', gap: 8,
              }}>
                <AlertTri size={13} stroke={p.warnText} />
                <span style={{ fontSize: 11, color: p.warnText, lineHeight: 1.4 }}>
                  We can't recover this password — there's no server. If you lose it, the file can't be opened. Tell your recipient separately (not in the same email).
                </span>
              </div>
            </div>
          )}
        </div>

        <div style={{ height: 14 }} />
        <Btn kind="primary" size="lg" full trailing={<Download size={18} />}>
          {encrypt ? 'Download encrypted PDF' : 'Download PDF'}
        </Btn>
      </div>
    </Screen>
  );
}

// Extend the existing MobileExtra router by re-exporting these cases.
// (We append them via a wrapper component that the canvas calls directly.)
function MobileExtra2({ name }) {
  return (
    <IOSDevice width={422} height={894}>
      {(() => {
        switch (name) {
          case 'wallet':      return <ScrAppleWallet />;
          case 'permission':  return <ScrPermission />;
          case 'conflict':    return <ScrAIConflict />;
          case 'export':      return <ScrDataExport />;
          default: return null;
        }
      })()}
    </IOSDevice>
  );
}

Object.assign(window, { MobileExtra2 });
