// web-snapfill.jsx — Web-app image upload (desktop) + capture (mobile web).
// Adds three artboards: desktop upload, mobile-web capture chooser, desktop review.

// ─── DESKTOP · Snap / upload to fill ──────────────────────────────────
function WebSnapFill() {
  const { palette: p } = React.useContext(MHADContext);

  const Target = ({ icon, label, fills, recommended }) => (
    <div style={{
      flex: 1, minWidth: 0, background: p.card,
      border: `1.5px solid ${recommended ? p.primary : p.border}`,
      borderRadius: 12, padding: '14px 14px 13px',
      display: 'flex', flexDirection: 'column', gap: 6, position: 'relative',
      cursor: 'pointer',
    }}>
      {recommended && (
        <div style={{
          position: 'absolute', top: -8, right: 10,
          fontFamily: MONO, fontSize: 9, fontWeight: 700, letterSpacing: 0.6,
          color: p.onPrimary, background: p.primary,
          padding: '2px 6px', borderRadius: 3,
        }}>START HERE</div>
      )}
      <div style={{
        width: 32, height: 32, borderRadius: 8,
        background: p.primaryTint, color: p.primary,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>{icon}</div>
      <div style={{ fontSize: 13.5, fontWeight: 700, color: p.text, lineHeight: 1.2 }}>{label}</div>
      <div style={{ fontSize: 11, color: p.textMuted, fontFamily: MONO, letterSpacing: 0.3, lineHeight: 1.35 }}>
        {fills}
      </div>
    </div>
  );

  return (
    <>
      <WebSidebar active="home" />
      <div style={{ flex: 1, overflow: 'auto', padding: '28px 40px 40px' }}>
        {/* Top bar w/ progress */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 18 }}>
          <span style={{ fontSize: 13, color: p.textMuted, display: 'flex', alignItems: 'center', gap: 6 }}>
            <Icon d="M15 18l-6-6 6-6" size={14} /> Wizard
          </span>
          <div style={{ flex: 1, height: 6, background: p.border, borderRadius: 100, overflow: 'hidden', maxWidth: 360 }}>
            <div style={{ height: '100%', width: '8%', background: p.primary, borderRadius: 100 }} />
          </div>
          <span style={{ fontSize: 12, color: p.textMuted, fontFamily: MONO }}>Step 1 of 11</span>
          <div style={{ flex: 1 }} />
          <TabOnlyPill />
        </div>

        <SectionLabel>Step 1 · Snap to fill (optional)</SectionLabel>
        <h1 style={{
          fontFamily: SERIF, fontStyle: 'italic', fontSize: 44, margin: '4px 0 6px',
          fontWeight: 400, letterSpacing: -0.8, lineHeight: 1,
        }}>
          Have a photo handy? <span style={{ color: p.primary }}>We'll read it.</span>
        </h1>
        <p style={{ fontSize: 14, color: p.textMuted, margin: 0, maxWidth: 660, lineHeight: 1.5 }}>
          Drop a photo or PDF — ID, medication list, prescription label, an old directive — and the AI will extract what it can. You review every field before it lands in the form. Or skip and type it all yourself.
        </p>

        <div style={{ height: 22 }} />

        {/* Two-column: drop zone + side info */}
        <div style={{ display: 'grid', gridTemplateColumns: '1.5fr 1fr', gap: 16 }}>
          {/* Drag-and-drop zone */}
          <div style={{
            background: p.primaryTint, border: `2px dashed ${p.primary}`,
            borderRadius: 16, padding: '34px 26px 28px',
            position: 'relative', overflow: 'hidden',
          }}>
            {/* decorative numeral */}
            <div style={{
              position: 'absolute', right: -18, top: -52,
              fontFamily: SERIF, fontStyle: 'italic', fontSize: 220, lineHeight: 1,
              color: `${p.primary}15`, fontWeight: 400, pointerEvents: 'none',
            }}>AI</div>

            <div style={{ position: 'relative', textAlign: 'center' }}>
              <div style={{
                width: 60, height: 60, borderRadius: 16, margin: '0 auto 14px',
                background: p.primary, color: p.onPrimary,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <Icon size={28} stroke={p.onPrimary} sw={1.8}>
                  <path d="M12 3v13M7 8l5-5 5 5M3 17v2a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-2"/>
                </Icon>
              </div>
              <div style={{ fontSize: 22, fontWeight: 700, color: p.text, letterSpacing: -0.3 }}>
                Drop a photo, PDF, or screenshot
              </div>
              <div style={{ fontSize: 13, color: p.textMuted, marginTop: 6, lineHeight: 1.5 }}>
                JPG · PNG · HEIC · PDF · up to 10 MB. Or paste an image with <strong style={{ color: p.text, fontFamily: MONO, fontSize: 11.5, background: p.card, padding: '1px 6px', borderRadius: 4, border: `1px solid ${p.border}` }}>⌘ V</strong>
              </div>

              <div style={{ display: 'inline-flex', alignItems: 'center', gap: 10, marginTop: 20 }}>
                <Btn kind="primary" leading={<Icon size={14} sw={2}><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6"/></Icon>}>
                  Browse files
                </Btn>
                <span style={{ fontSize: 12, color: p.textMuted }}>or</span>
                <Btn kind="outline" leading={<Icon size={14} sw={2}><rect x="2" y="6" width="14" height="12" rx="2"/><path d="M16 10l6-3v10l-6-3z"/></Icon>}>
                  Use webcam
                </Btn>
              </div>
            </div>

            {/* Privacy reassurance inside zone */}
            <div style={{
              marginTop: 22, padding: '10px 12px',
              background: 'rgba(255,255,255,0.6)', border: `1px solid ${p.primaryLight}`,
              borderRadius: 10, display: 'flex', alignItems: 'center', gap: 8,
            }}>
              <Lock size={14} stroke={p.primary} />
              <span style={{ fontSize: 11.5, color: p.text, flex: 1, lineHeight: 1.4 }}>
                Your file is sent to the AI <strong>only to read it</strong>, then discarded. Nothing is saved — it's gone when this tab closes.
              </span>
            </div>
          </div>

          {/* Side: what to capture */}
          <div>
            <SectionLabel>What you can drop here</SectionLabel>
            <div style={{ marginTop: 8, display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
              <Target
                recommended
                icon={<Icon size={16} sw={2}><rect x="3" y="5" width="18" height="14" rx="2"/><circle cx="9" cy="12" r="2.5"/><path d="M14 10h5M14 14h3M14 17h4"/></Icon>}
                label="Photo of ID"
                fills="Name · DOB · address"
              />
              <Target
                icon={<Icon size={16} sw={2}><rect x="4" y="3" width="16" height="18" rx="2"/><path d="M8 8h8M8 12h8M8 16h5"/></Icon>}
                label="Rx bottle / label"
                fills="Drug · dose · schedule"
              />
              <Target
                icon={<Icon size={16} sw={2}><path d="M12 2v4M12 18v4M4.9 4.9l2.8 2.8M16.3 16.3l2.8 2.8M2 12h4M18 12h4"/><circle cx="12" cy="12" r="3"/></Icon>}
                label="Conditions list"
                fills="Diagnoses · allergies"
              />
              <Target
                icon={<Icon size={16} sw={2}><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6M9 13h6M9 17h4"/></Icon>}
                label="Anything else"
                fills="Notes, old directive…"
              />
            </div>

            <div style={{ height: 14 }} />

            {/* On mobile — different surface */}
            <div style={{
              background: p.card, border: `1px solid ${p.border}`, borderRadius: 12,
              padding: '12px 14px', display: 'flex', gap: 12, alignItems: 'flex-start',
            }}>
              <div style={{
                width: 28, height: 28, borderRadius: 7, flexShrink: 0,
                background: p.surface, color: p.primary,
                border: `1px solid ${p.border}`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <Icon size={14} sw={2}><rect x="6" y="2" width="12" height="20" rx="2"/><path d="M11 18h2"/></Icon>
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 12.5, fontWeight: 700, color: p.text }}>On a phone?</div>
                <div style={{ fontSize: 11.5, color: p.textMuted, marginTop: 2, lineHeight: 1.4 }}>
                  Same form, but with a real camera button — tap the field and snap directly.
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Already-uploaded files row */}
        <div style={{ height: 22 }} />
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
          <SectionLabel>In this session</SectionLabel>
          <span style={{ fontFamily: MONO, fontSize: 10, color: p.textMuted, letterSpacing: 0.4 }}>
            2 FILES · CLEARED ON TAB CLOSE
          </span>
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 10 }}>
          {[
            { name: 'PA-ID-front.jpg', status: '4 fields added', kind: 'ID', done: true,
              thumb: 'linear-gradient(135deg, #d8d6cf, #f1efe7)' },
            { name: 'sertraline-rx.heic', status: 'Review · 4 fields read', kind: 'Rx label', done: false,
              thumb: 'linear-gradient(180deg, #fff 0%, #f5f1e8 100%)' },
            { name: '+ Add another', placeholder: true },
          ].map((f, i) => (
            f.placeholder ? (
              <div key={i} style={{
                background: p.surface, border: `1.5px dashed ${p.border}`,
                borderRadius: 12, padding: 14, display: 'flex', alignItems: 'center', justifyContent: 'center',
                gap: 8, color: p.textMuted, fontSize: 13, fontWeight: 600, cursor: 'pointer',
              }}>
                <Plus size={16} stroke={p.textMuted} /> {f.name}
              </div>
            ) : (
              <div key={i} style={{
                background: p.card, border: `1px solid ${p.border}`, borderRadius: 12,
                padding: 12, display: 'flex', gap: 12,
              }}>
                <div style={{
                  width: 54, height: 64, borderRadius: 6, flexShrink: 0,
                  background: f.thumb, border: `1px solid ${p.border}`,
                  position: 'relative', overflow: 'hidden',
                }}>
                  {f.kind === 'ID' && (
                    <div style={{ padding: 4, fontSize: 4.5, color: '#2a2520', lineHeight: 1.4 }}>
                      <div style={{ fontWeight: 700, fontSize: 5.5 }}>PENNSYLVANIA</div>
                      <div style={{ display: 'flex', gap: 3, marginTop: 3 }}>
                        <div style={{ width: 14, height: 18, background: '#9b9183', borderRadius: 1 }} />
                        <div style={{ flex: 1, lineHeight: 1.3 }}>
                          <div style={{ fontWeight: 700 }}>KOWALSKI</div>
                          <div>412 MAPLE ST</div>
                          <div>DOB 06-14-89</div>
                        </div>
                      </div>
                    </div>
                  )}
                  {f.kind === 'Rx label' && (
                    <div style={{ padding: 4, fontSize: 4, color: '#2a2520', lineHeight: 1.4 }}>
                      <div style={{ fontWeight: 700, fontSize: 4.5 }}>RITE AID</div>
                      <div style={{ marginTop: 4, padding: 2, background: '#fffbf0', border: '0.5px solid #e3dcc0' }}>
                        <div style={{ fontWeight: 700, fontSize: 5 }}>SERTRALINE 100MG</div>
                        <div>1 tab AM</div>
                      </div>
                    </div>
                  )}
                </div>
                <div style={{ flex: 1, minWidth: 0, display: 'flex', flexDirection: 'column' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                    <span style={{
                      fontFamily: MONO, fontSize: 9, fontWeight: 700, letterSpacing: 0.5,
                      color: p.primary, background: p.primaryTint, padding: '1px 5px', borderRadius: 3,
                    }}>{f.kind.toUpperCase()}</span>
                  </div>
                  <div style={{ fontSize: 12, fontWeight: 600, color: p.text, marginTop: 4, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{f.name}</div>
                  <div style={{ fontSize: 11, color: f.done ? p.okText : p.warnText, marginTop: 2, fontWeight: 600 }}>
                    {f.done ? '● ' + f.status : '● ' + f.status}
                  </div>
                  <div style={{ flex: 1 }} />
                  <div style={{ display: 'flex', gap: 8, marginTop: 6 }}>
                    {!f.done && <span style={{ fontSize: 11, fontWeight: 700, color: p.primary, cursor: 'pointer' }}>Review →</span>}
                    <span style={{ fontSize: 11, color: p.textMuted, cursor: 'pointer' }}>{f.done ? 'View' : 'Discard'}</span>
                  </div>
                </div>
              </div>
            )
          ))}
        </div>

        <div style={{ height: 22 }} />
        <div style={{ display: 'flex', gap: 10 }}>
          <Btn kind="ghost">Skip — I'll type it all</Btn>
          <div style={{ flex: 1 }} />
          <Btn kind="primary" trailing={<Arrow size={16} />}>Continue to step 2</Btn>
        </div>
      </div>
    </>
  );
}

// ─── DESKTOP · AI extraction review (post-upload) ─────────────────────
function WebSnapReview() {
  const { palette: p } = React.useContext(MHADContext);

  return (
    <>
      <WebSidebar active="home" />
      <div style={{ flex: 1, overflow: 'auto', padding: '28px 40px 40px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 18 }}>
          <span style={{ fontSize: 13, color: p.primary, fontWeight: 600, display: 'flex', alignItems: 'center', gap: 4 }}>
            <Icon d="M15 18l-6-6 6-6" size={14} /> Snap to fill
          </span>
          <div style={{ flex: 1 }} />
          <span style={{
            display: 'inline-flex', alignItems: 'center', gap: 6,
            fontSize: 11, fontFamily: MONO, color: p.primary, letterSpacing: 0.6, fontWeight: 700,
            padding: '5px 10px', background: p.primaryTint, borderRadius: 100,
          }}>
            <Sparkles size={11} stroke={p.primary} /> AI READ THIS PHOTO
          </span>
        </div>

        <SectionLabel>Reviewing · sertraline-rx.heic</SectionLabel>
        <h1 style={{
          fontFamily: SERIF, fontStyle: 'italic', fontSize: 38, margin: '4px 0 4px',
          fontWeight: 400, letterSpacing: -0.6, lineHeight: 1,
        }}>
          Here's what we read.
        </h1>
        <p style={{ fontSize: 13.5, color: p.textMuted, margin: 0, maxWidth: 640, lineHeight: 1.5 }}>
          Untick anything we got wrong. Nothing is added to your directive until you confirm.
        </p>

        <div style={{ height: 20 }} />

        {/* Two-pane: photo preview + extracted fields */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1.4fr', gap: 18 }}>
          {/* Photo preview */}
          <div style={{
            background: p.card, border: `1px solid ${p.border}`, borderRadius: 14,
            padding: 14,
          }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10 }}>
              <span style={{ fontSize: 12, color: p.textMuted, fontWeight: 600 }}>Original file</span>
              <div style={{ display: 'flex', gap: 6 }}>
                <span style={{ fontSize: 11, fontWeight: 700, color: p.primary, cursor: 'pointer' }}>Rotate</span>
                <span style={{ fontSize: 11, color: p.textMuted }}>·</span>
                <span style={{ fontSize: 11, fontWeight: 700, color: p.crisisAccent, cursor: 'pointer' }}>Delete</span>
              </div>
            </div>

            {/* Mock photo with bounding boxes */}
            <div style={{
              background: 'linear-gradient(180deg, #fff 0%, #f5f1e8 100%)',
              border: `1px solid ${p.border}`, borderRadius: 6,
              padding: '16px 18px', color: '#2a2520', fontFamily: SANS,
              position: 'relative', overflow: 'hidden',
            }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', borderBottom: '1px solid #d8d4c8', paddingBottom: 6 }}>
                <div style={{ fontSize: 10, fontWeight: 700, letterSpacing: 0.4 }}>RITE AID PHARMACY · #12498</div>
                <div style={{ fontFamily: MONO, fontSize: 9, opacity: 0.7 }}>Rx 4729183</div>
              </div>
              <div style={{ marginTop: 10, fontSize: 11, lineHeight: 1.6, position: 'relative' }}>
                <div style={{ fontWeight: 700, fontSize: 13, position: 'relative' }}>
                  KOWALSKI, ALEX M.
                </div>
                <div style={{ opacity: 0.75 }}>Dr. R. Patel · UPMC</div>
              </div>
              <div style={{
                marginTop: 12, padding: 10, background: '#fffbf0',
                border: `2px solid ${p.primary}`, borderRadius: 4, position: 'relative',
                boxShadow: `0 0 0 1px rgba(0,0,0,0.05), 0 0 18px ${p.primary}33`,
              }}>
                <div style={{
                  position: 'absolute', top: -16, left: -2, fontFamily: MONO,
                  fontSize: 9.5, fontWeight: 700, letterSpacing: 0.4,
                  color: p.onPrimary, background: p.primary, padding: '2px 6px', borderRadius: 3,
                }}>DRUG · DOSE · SCHEDULE · 96%</div>
                <div style={{ fontWeight: 700, fontSize: 16 }}>SERTRALINE 100MG</div>
                <div style={{ fontSize: 11, marginTop: 3 }}>Take 1 tablet by mouth daily in morning</div>
              </div>
              <div style={{ marginTop: 10, fontSize: 10, lineHeight: 1.6, opacity: 0.85 }}>
                <div>Qty 30 · Refills 3 · Exp 11/26</div>
                <div>Take with food. May cause drowsiness.</div>
              </div>
              {/* fake barcode */}
              <div style={{ display: 'flex', gap: 1, marginTop: 10, height: 18 }}>
                {Array.from({ length: 50 }).map((_, i) => (
                  <div key={i} style={{ width: i % 3 ? 1.5 : 2.5, background: '#1a1a1a', height: '100%' }} />
                ))}
              </div>
            </div>

            <div style={{ marginTop: 10, display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: 11, color: p.textMuted }}>
              <span style={{ fontFamily: MONO, letterSpacing: 0.4 }}>HEIC · 2.4 MB · 3024 × 4032</span>
              <span>Confidence <strong style={{ color: p.text }}>94%</strong></span>
            </div>
          </div>

          {/* Extracted fields */}
          <div>
            <div style={{ background: p.card, border: `1px solid ${p.border}`, borderRadius: 14, padding: '6px 18px' }}>
              {[
                { field: 'Current medication', value: 'Sertraline 100mg', sub: 'Take 1 tablet daily in the morning', target: 'Step 8 · Medications', ok: true },
                { field: 'Prescribed by',      value: 'Dr. R. Patel · UPMC',  sub: 'Pulled from "DOCTOR" line',                target: 'Step 8 · Medications', ok: true },
                { field: 'Refills',            value: '3 remaining · expires 11/2026', sub: 'For your records — not part of the legal directive', target: 'Not added',          ok: false },
                { field: 'Pharmacy',           value: 'Rite Aid #12498',      sub: '5837 Forbes Ave, Pittsburgh',                target: 'Step 10 · Anything else', ok: true },
              ].map((row, i, arr) => (
                <div key={i} style={{
                  display: 'flex', gap: 14, padding: '14px 0',
                  borderBottom: i < arr.length - 1 ? `1px solid ${p.border}` : 'none',
                }}>
                  <div style={{
                    width: 22, height: 22, borderRadius: 6, flexShrink: 0, marginTop: 2,
                    background: row.ok ? p.primary : p.surface,
                    color: row.ok ? p.onPrimary : p.textMuted,
                    border: row.ok ? 'none' : `1.5px solid ${p.border}`,
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                  }}>
                    {row.ok ? <Check size={13} sw={3} stroke={p.onPrimary} /> : <X size={11} sw={2.5} stroke={p.textMuted} />}
                  </div>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', gap: 10 }}>
                      <div style={{ fontSize: 10.5, fontFamily: MONO, color: p.textMuted, letterSpacing: 0.5, textTransform: 'uppercase', fontWeight: 600 }}>{row.field}</div>
                      <div style={{ fontSize: 10, fontFamily: MONO, color: row.ok ? p.primary : p.textMuted, fontWeight: 700, letterSpacing: 0.4, textAlign: 'right' }}>
                        {row.ok ? '→ ' + row.target : row.target}
                      </div>
                    </div>
                    <div style={{ fontSize: 15, fontWeight: 600, color: row.ok ? p.text : p.textMuted, marginTop: 3, textDecoration: row.ok ? 'none' : 'line-through' }}>
                      {row.value}
                    </div>
                    <div style={{ fontSize: 12, color: p.textMuted, marginTop: 2, lineHeight: 1.4 }}>{row.sub}</div>
                  </div>
                  <div style={{ alignSelf: 'center' }}>
                    <Edit size={14} stroke={p.textMuted} />
                  </div>
                </div>
              ))}
            </div>

            <div style={{
              marginTop: 12, padding: 12, display: 'flex', gap: 10,
              background: p.primaryTint, border: `1px solid ${p.primaryLight}`, borderRadius: 10,
            }}>
              <Sparkles size={16} stroke={p.primary} />
              <div style={{ flex: 1, fontSize: 12.5, color: p.text, lineHeight: 1.45 }}>
                <strong>Have a reaction history?</strong> Drop a note or your allergy bracelet next — I'll add what to avoid on the same step.
              </div>
            </div>

            <div style={{
              marginTop: 10, display: 'flex', alignItems: 'center', gap: 8,
              padding: '10px 12px', background: p.surface, border: `1px solid ${p.border}`, borderRadius: 10,
            }}>
              <Lock size={14} stroke={p.textMuted} />
              <span style={{ fontSize: 11.5, color: p.textMuted, flex: 1, lineHeight: 1.4 }}>
                Your file is sent to the AI to read, then discarded — no copy is kept. Nothing is saved after you confirm or discard.
              </span>
            </div>

            <div style={{ height: 14 }} />
            <div style={{ display: 'flex', gap: 10 }}>
              <Btn kind="outline">Discard all</Btn>
              <div style={{ flex: 1 }} />
              <Btn kind="ghost">Edit before adding</Btn>
              <Btn kind="primary" trailing={<Arrow size={16} />}>Add 3 fields to directive</Btn>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}

// ─── MOBILE-WEB · Capture + upload chooser ────────────────────────────
// Same web app, viewed in mobile Safari. Adds a real camera capture path.
function WebSnapFillMobile() {
  const { palette: p } = React.useContext(MHADContext);

  // Mobile Chrome (Android) URL bar
  const SafariBar = () => (
    <div style={{
      paddingTop: 38,
      background: '#f1f3f4',
      borderBottom: `1px solid rgba(0,0,0,0.07)`,
    }}>
      <div style={{
        margin: '8px 12px 9px',
        background: '#ffffff', borderRadius: 100,
        padding: '8px 12px', display: 'flex', alignItems: 'center', gap: 9,
        fontFamily: 'Roboto, system-ui, sans-serif',
        boxShadow: '0 1px 2px rgba(0,0,0,0.10)',
      }}>
        <Icon size={13} stroke="#5f6368" sw={2.2}><rect x="4" y="11" width="16" height="9" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/></Icon>
        <span style={{ flex: 1, fontSize: 13, color: '#202124', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
          onica5000.github.io
        </span>
        <Icon size={15} stroke="#5f6368" sw={2}><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18"/></Icon>
        {/* Chrome 3-dot overflow */}
        <svg width="4" height="16" viewBox="0 0 4 16" fill="#5f6368"><circle cx="2" cy="2" r="2"/><circle cx="2" cy="8" r="2"/><circle cx="2" cy="14" r="2"/></svg>
      </div>
    </div>
  );

  return (
    <Screen scroll={true} style={{ background: '#fff' }}>
      <SafariBar />

      <div style={{ padding: '14px 18px 32px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 6 }}>
          <div style={{
            width: 26, height: 26, borderRadius: 6,
            background: p.primary, color: p.onPrimary,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontFamily: SERIF, fontStyle: 'italic', fontSize: 14,
          }}>m</div>
          <div style={{ fontSize: 12, fontWeight: 700 }}>PA MHAD</div>
          <div style={{ flex: 1 }} />
          <span style={{
            display: 'inline-flex', alignItems: 'center', gap: 4,
            fontSize: 9.5, fontFamily: MONO, color: p.textMuted, letterSpacing: 0.4,
            padding: '3px 7px', background: p.surface, borderRadius: 100,
            border: `1px solid ${p.border}`,
          }}>
            <Lock size={9} stroke={p.textMuted} /> TAB ONLY
          </span>
        </div>

        <SectionLabel>Step 1 of 11 · Snap to fill</SectionLabel>
        <h1 style={{
          fontFamily: SERIF, fontStyle: 'italic', fontSize: 30, margin: '4px 0 4px',
          fontWeight: 400, letterSpacing: -0.5, lineHeight: 1.05,
        }}>
          Snap a photo or pick a file.
        </h1>
        <p style={{ fontSize: 13, color: p.textMuted, margin: 0, lineHeight: 1.5 }}>
          AI reads it on this device and fills the form for you to review. Skip if you'd rather type.
        </p>

        <div style={{ height: 16 }} />

        {/* Two main actions — camera + library */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
          <div style={{
            background: p.primary, color: p.onPrimary,
            borderRadius: 14, padding: '16px 14px 14px',
            display: 'flex', flexDirection: 'column', gap: 6, position: 'relative', overflow: 'hidden',
          }}>
            <div style={{
              position: 'absolute', right: -4, top: -10,
              fontFamily: SERIF, fontStyle: 'italic', fontSize: 80, lineHeight: 1,
              color: 'rgba(255,255,255,0.10)', pointerEvents: 'none',
            }}>★</div>
            <div style={{
              width: 32, height: 32, borderRadius: 8,
              background: 'rgba(255,255,255,0.20)', color: p.onPrimary,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <Icon size={18} stroke={p.onPrimary} sw={2}><path d="M21 6h-3.2l-1.4-2.1A2 2 0 0 0 14.7 3H9.3a2 2 0 0 0-1.7.9L6.2 6H3a2 2 0 0 0-2 2v11a2 2 0 0 0 2 2h18a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2z"/><circle cx="12" cy="13" r="4"/></Icon>
            </div>
            <div style={{ fontSize: 14, fontWeight: 700, marginTop: 4 }}>Take a photo</div>
            <div style={{ fontSize: 11, opacity: 0.85, lineHeight: 1.35 }}>
              Opens your camera. Snap your ID, Rx label, anything.
            </div>
          </div>

          <div style={{
            background: p.card, color: p.text,
            border: `1.5px solid ${p.border}`,
            borderRadius: 14, padding: '16px 14px 14px',
            display: 'flex', flexDirection: 'column', gap: 6,
          }}>
            <div style={{
              width: 32, height: 32, borderRadius: 8,
              background: p.primaryTint, color: p.primary,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <Icon size={18} stroke={p.primary} sw={2}><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><path d="M21 15l-5-5L5 21"/></Icon>
            </div>
            <div style={{ fontSize: 14, fontWeight: 700, marginTop: 4 }}>Pick a file</div>
            <div style={{ fontSize: 11, color: p.textMuted, lineHeight: 1.35 }}>
              From Photos, Files, or iCloud. JPG, PNG, HEIC, PDF.
            </div>
          </div>
        </div>

        {/* What to capture */}
        <div style={{ height: 18 }} />
        <SectionLabel>What helps most</SectionLabel>
        <div style={{ marginTop: 8, display: 'flex', flexDirection: 'column', gap: 6 }}>
          {[
            { icon: <Icon size={14} sw={2}><rect x="3" y="5" width="18" height="14" rx="2"/><circle cx="9" cy="12" r="2.5"/><path d="M14 10h5M14 14h3"/></Icon>, label: 'Photo of ID', fills: 'Name · DOB · address', tag: 'FASTEST' },
            { icon: <Icon size={14} sw={2}><rect x="4" y="3" width="16" height="18" rx="2"/><path d="M8 8h8M8 12h8M8 16h5"/></Icon>, label: 'Rx bottle / label', fills: 'Drug · dose · schedule' },
            { icon: <Icon size={14} sw={2}><path d="M12 2v4M12 18v4"/><circle cx="12" cy="12" r="3"/></Icon>, label: 'Conditions list', fills: 'Diagnoses · allergies' },
            { icon: <Icon size={14} sw={2}><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6"/></Icon>, label: 'Anything else', fills: 'Old directive, notes…' },
          ].map((row, i) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', gap: 10,
              padding: '10px 12px', background: p.card, border: `1px solid ${p.border}`,
              borderRadius: 10,
            }}>
              <div style={{
                width: 28, height: 28, borderRadius: 7, flexShrink: 0,
                background: p.primaryTint, color: p.primary,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>{row.icon}</div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                  <span style={{ fontSize: 13, fontWeight: 700, color: p.text }}>{row.label}</span>
                  {row.tag && (
                    <span style={{
                      fontFamily: MONO, fontSize: 8.5, fontWeight: 700, letterSpacing: 0.5,
                      color: p.primary, background: p.primaryLight,
                      padding: '1px 5px', borderRadius: 3,
                    }}>{row.tag}</span>
                  )}
                </div>
                <div style={{ fontSize: 11.5, color: p.textMuted, marginTop: 1 }}>{row.fills}</div>
              </div>
              <Arrow size={12} stroke={p.textMuted} />
            </div>
          ))}
        </div>

        {/* iOS native sheet — what tapping "Take a photo" looks like */}
        <div style={{ height: 16 }} />
        <SectionLabel>What happens when you tap</SectionLabel>
        <div style={{
          marginTop: 8,
          background: 'rgba(247,247,250,0.95)',
          border: `1px solid ${p.border}`,
          borderRadius: 14, padding: 6, overflow: 'hidden',
        }}>
          {[
            { icon: <Icon size={16} stroke="#1a1a1a" sw={2}><path d="M21 6h-3.2l-1.4-2.1A2 2 0 0 0 14.7 3H9.3a2 2 0 0 0-1.7.9L6.2 6H3a2 2 0 0 0-2 2v11a2 2 0 0 0 2 2h18a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2z"/><circle cx="12" cy="13" r="4"/></Icon>, label: 'Take Photo' },
            { icon: <Icon size={16} stroke="#1a1a1a" sw={2}><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><path d="M21 15l-5-5L5 21"/></Icon>, label: 'Photo Library' },
            { icon: <Icon size={16} stroke="#1a1a1a" sw={2}><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6"/></Icon>, label: 'Choose File' },
          ].map((row, i, arr) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', gap: 12,
              padding: '11px 12px',
              borderBottom: i < arr.length - 1 ? '0.5px solid rgba(0,0,0,0.08)' : 'none',
              fontFamily: 'system-ui, sans-serif', fontSize: 15, color: '#1a1a1a',
            }}>
              <div style={{
                width: 30, height: 30, borderRadius: 7,
                background: '#fff', border: '0.5px solid rgba(0,0,0,0.1)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>{row.icon}</div>
              <span style={{ flex: 1 }}>{row.label}</span>
            </div>
          ))}
        </div>
        <p style={{ fontSize: 10.5, color: p.textMuted, fontStyle: 'italic', marginTop: 6, textAlign: 'center' }}>
          ↑ The browser's native iOS sheet — no app install required.
        </p>

        {/* Privacy footer */}
        <div style={{ height: 14 }} />
        <div style={{
          display: 'flex', alignItems: 'center', gap: 8,
          padding: '10px 12px', background: p.surface, border: `1px solid ${p.border}`, borderRadius: 10,
        }}>
          <Lock size={14} stroke={p.textMuted} />
          <span style={{ fontSize: 11, color: p.textMuted, flex: 1, lineHeight: 1.4 }}>
            Your photo is sent to the AI only to read it, then discarded. Nothing is saved.
          </span>
        </div>

        <div style={{ height: 16 }} />
        <Btn kind="ghost" full>Skip — type it myself</Btn>
      </div>
    </Screen>
  );
}

// ─── MOBILE-WEB · Wizard (right-rail collapses to a bottom sheet) ──────
// On desktop the wizard is 3 columns (step rail · form · AI rail). Below the
// 1000px breakpoint the step rail becomes a top progress bar and the AI rail
// collapses into a peeking bottom sheet the user taps to expand. This artboard
// answers #33c: where the layout forks and what happens to the right rail.
function WebWizMobile() {
  const { palette: p } = React.useContext(MHADContext);
  const [sheetOpen, setSheetOpen] = React.useState(false);

  const SafariBar = () => (
    <div style={{ paddingTop: 38, background: '#f1f3f4', borderBottom: `1px solid rgba(0,0,0,0.07)` }}>
      <div style={{ margin: '8px 12px 9px', background: '#ffffff', borderRadius: 100, padding: '8px 12px', display: 'flex', alignItems: 'center', gap: 9, fontFamily: 'Roboto, system-ui, sans-serif', boxShadow: '0 1px 2px rgba(0,0,0,0.10)' }}>
        <Icon size={13} stroke="#5f6368" sw={2.2}><rect x="4" y="11" width="16" height="9" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/></Icon>
        <span style={{ flex: 1, fontSize: 13, color: '#202124', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>onica5000.github.io</span>
        <Icon size={15} stroke="#5f6368" sw={2}><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18"/></Icon>
        <svg width="4" height="16" viewBox="0 0 4 16" fill="#5f6368"><circle cx="2" cy="2" r="2"/><circle cx="2" cy="8" r="2"/><circle cx="2" cy="14" r="2"/></svg>
      </div>
    </div>
  );

  return (
    <Screen scroll={false} style={{ background: p.scaffold }}>
      <SafariBar />

      {/* Step rail → top progress bar on mobile-web */}
      <div style={{ padding: '12px 18px 10px', borderBottom: `1px solid ${p.border}`, background: p.card }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <span style={{ fontSize: 12.5, color: p.textMuted, fontWeight: 600 }}>Step 3 of 11</span>
          <div style={{ flex: 1, height: 6, background: p.border, borderRadius: 100, overflow: 'hidden' }}>
            <div style={{ height: '100%', width: '27%', background: p.primary, borderRadius: 100 }} />
          </div>
          <TabOnlyPill />
        </div>
        <div style={{ fontSize: 10, color: p.textMuted, fontFamily: MONO, letterSpacing: 0.4, marginTop: 6 }}>
          ◂ RAIL COLLAPSED · 3-COLUMN DESKTOP LAYOUT FORKS AT 1000px ▸
        </div>
      </div>

      {/* Form body */}
      <div style={{ flex: 1, overflow: 'auto', padding: '18px 18px 90px' }}>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 12 }}>
          <span style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 52, lineHeight: 1, color: p.primary, letterSpacing: -1 }}>03</span>
          <div>
            <div style={{ fontFamily: MONO, fontSize: 10, color: p.textMuted, letterSpacing: 1, textTransform: 'uppercase' }}>People I trust</div>
            <h1 style={{ fontFamily: SANS, fontSize: 22, fontWeight: 700, margin: '2px 0 0', letterSpacing: -0.3 }}>Who speaks for you?</h1>
          </div>
        </div>
        <p style={{ fontSize: 13, color: p.textMuted, margin: '10px 0 0', lineHeight: 1.5 }}>
          Name a primary agent and an alternate. They make decisions only if two professionals find you unable to.
        </p>

        <div style={{ height: 16 }} />
        {[['Primary agent', 'Jordan Lee', 'Sister'], ['Alternate agent', 'Sam Reyes', 'Spouse']].map(([label, name, rel], i) => (
          <div key={i} style={{ background: p.card, border: `1px solid ${p.border}`, borderRadius: 12, padding: 14, marginBottom: 10, display: 'flex', alignItems: 'center', gap: 12 }}>
            <div style={{ width: 40, height: 40, borderRadius: 100, background: p.primary, color: p.onPrimary, display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 700, fontSize: 14 }}>{name.split(' ').map(w => w[0]).join('')}</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontFamily: MONO, fontSize: 9.5, color: p.primary, letterSpacing: 0.5, fontWeight: 700 }}>{label.toUpperCase()}</div>
              <div style={{ fontSize: 15, fontWeight: 700, color: p.text, marginTop: 1 }}>{name}</div>
              <div style={{ fontSize: 12, color: p.textMuted }}>{rel}</div>
            </div>
            <Edit size={15} stroke={p.textMuted} />
          </div>
        ))}
      </div>

      {/* AI rail → peeking bottom sheet (the desktop right rail, collapsed) */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0, zIndex: 10,
        background: p.card, borderTop: `1px solid ${p.border}`,
        borderRadius: sheetOpen ? `${TOK.rSheet}px ${TOK.rSheet}px 0 0` : 0,
        boxShadow: sheetOpen ? '0 -12px 40px rgba(0,0,0,0.22)' : '0 -4px 16px rgba(0,0,0,0.06)',
        transition: 'all 0.2s',
      }}>
        <div onClick={() => setSheetOpen(!sheetOpen)} style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '12px 18px', cursor: 'pointer' }}>
          <div style={{ width: 30, height: 30, borderRadius: 8, background: p.primaryTint, color: p.primary, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
            <Sparkles size={16} stroke={p.primary} />
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontSize: 13, fontWeight: 700, color: p.text }}>AI assistant</div>
            <div style={{ fontSize: 11.5, color: p.textMuted, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
              {sheetOpen ? 'Tap to collapse' : 'Who can be my agent? Tap for help.'}
            </div>
          </div>
          <Icon size={18} stroke={p.textMuted} sw={2}>
            {sheetOpen ? <path d="M6 9l6 6 6-6"/> : <path d="M18 15l-6-6-6 6"/>}
          </Icon>
        </div>

        {sheetOpen && (
          <div style={{ padding: '0 18px 28px' }}>
            <div style={{ background: p.surface, border: `1px solid ${p.border}`, borderRadius: 10, padding: 12, fontSize: 12.5, color: p.text, lineHeight: 1.5 }}>
              Your agent must be 18+, and can't be a provider currently treating you. Most people pick a close family member or friend who knows their wishes.
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6, marginTop: 10 }}>
              {['Who should I NOT pick?', 'Can my agent override my written wishes?', 'What if both agents are unavailable?'].map((q, i) => (
                <div key={i} style={{ background: p.card, border: `1px solid ${p.border}`, borderRadius: 8, padding: '9px 12px', fontSize: 12.5, color: p.text }}>{q}</div>
              ))}
            </div>
          </div>
        )}
      </div>
    </Screen>
  );
}

// Wrap mobile-web in an Android device frame. Tagged WEB · mobile browser. The
// screens render their own browser URL bar, so they read as a website in a
// phone browser — the tag makes the surface explicit too.
function WebMobileFrame({ children }) {
  return (
    <Surface kind="web-mobile">
      <AndroidShell width={422} height={860}>{children}</AndroidShell>
    </Surface>
  );
}

Object.assign(window, {
  WebSnapFill, WebSnapReview, WebSnapFillMobile, WebWizMobile, WebMobileFrame,
});
