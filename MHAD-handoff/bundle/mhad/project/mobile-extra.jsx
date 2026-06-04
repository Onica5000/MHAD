// mobile-extra.jsx — Additional mobile screens identified by the function audit.
// Covers: Face ID unlock, first-time empty home, past directive detail, renewal,
// revocation, share sheet, mobile AI assistant, mobile Learn hub, mobile Settings,
// mobile PDF preview, form-type quiz.
//
// Reuses atoms from ds.jsx and STATUSBAR_H / HOME_H from mobile.jsx.

// ─── X · Face ID unlock ────────────────────────────────────────────────
function ScrFaceID() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <Screen scroll={false} style={{ background: p.scaffold }}>
      <div style={{ height: STATUSBAR_H }} />
      <div style={{ padding: '40px 28px 0', display: 'flex', flexDirection: 'column', height: `calc(100% - ${STATUSBAR_H}px - ${HOME_H}px)`, boxSizing: 'border-box' }}>
        {/* Brand mark */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <div style={{
            width: 36, height: 36, borderRadius: 9,
            background: p.primary, color: p.onPrimary,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontFamily: SERIF, fontStyle: 'italic', fontSize: 20, fontWeight: 400,
          }}>m</div>
          <div>
            <div style={{ fontSize: 13, fontWeight: 700, letterSpacing: -0.2 }}>PA MHAD</div>
            <div style={{ fontSize: 10, color: p.textMuted, fontFamily: MONO, letterSpacing: 0.6 }}>PRIVATE MODE · LOCKED</div>
          </div>
        </div>

        <div style={{ flex: 1 }} />

        {/* Face ID glyph */}
        <div style={{ display: 'flex', justifyContent: 'center' }}>
          <div style={{
            width: 124, height: 124, borderRadius: 28,
            background: p.card, border: `2px solid ${p.primary}`,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            position: 'relative',
          }}>
            <svg width="64" height="64" viewBox="0 0 64 64" fill="none" stroke={p.primary} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <path d="M16 8h-4a4 4 0 0 0-4 4v4M48 8h4a4 4 0 0 1 4 4v4M16 56h-4a4 4 0 0 1-4-4v-4M48 56h4a4 4 0 0 0 4-4v-4"/>
              <path d="M22 26v4M42 26v4"/>
              <path d="M32 26v10l-3 2"/>
              <path d="M24 42c2 2 5 3 8 3s6-1 8-3"/>
            </svg>
            {/* pulse */}
            <div style={{
              position: 'absolute', inset: -8, borderRadius: 32,
              border: `2px solid ${p.primary}`, opacity: 0.3,
            }} />
          </div>
        </div>

        <div style={{ height: 24 }} />
        <h1 style={{
          fontFamily: SERIF, fontStyle: 'italic', fontSize: 38,
          margin: 0, fontWeight: 400, letterSpacing: -0.5, textAlign: 'center', lineHeight: 1.05,
        }}>
          Welcome back, <span style={{ color: p.primary }}>Alex.</span>
        </h1>
        <p style={{ fontSize: 13.5, color: p.textMuted, margin: '8px 0 0', textAlign: 'center', lineHeight: 1.5 }}>
          Look at your phone to unlock your draft.
        </p>

        <div style={{ height: 8 }} />
        <div style={{ display: 'flex', justifyContent: 'center' }}>
          <span style={{
            display: 'inline-flex', alignItems: 'center', gap: 6,
            fontFamily: MONO, fontSize: 10.5, fontWeight: 600,
            color: p.primary, letterSpacing: 0.8,
            background: p.primaryTint, padding: '4px 10px', borderRadius: 100,
          }}>
            <span style={{ width: 6, height: 6, borderRadius: 100, background: p.primary }} /> SCANNING…
          </span>
        </div>

        <div style={{ flex: 1 }} />

        <Btn kind="ghost" full>Use passcode instead</Btn>
        <div style={{ height: 4 }} />
        <Btn kind="ghost" full style={{ color: p.textMuted, fontSize: 13 }}>Switch to public mode</Btn>
        <div style={{ height: 14 }} />
        <p style={{ fontSize: 10.5, color: p.textMuted, textAlign: 'center', margin: 0, lineHeight: 1.5 }}>
          Last unlocked 2 hours ago · auto-locks after 5 min
        </p>
      </div>
    </Screen>
  );
}

// ─── X · First-time empty home ─────────────────────────────────────────
function ScrEmpty() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <Screen>
      <CrisisBar />
      <div style={{ padding: '20px 22px 100px' }}>
        <SectionLabel>Saturday · May 14, 2026</SectionLabel>
        <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', marginTop: 4 }}>
          <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 38, fontWeight: 400, margin: 0, lineHeight: 1.05, letterSpacing: -0.5 }}>
            Hi, Alex.<br/>
            <span style={{ color: p.textMuted, fontSize: 22 }}>Let's get started.</span>
          </h1>
          <div style={{
            width: 40, height: 40, borderRadius: 100, background: p.primaryLight,
            color: p.onPrimaryLight, display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontFamily: SANS, fontWeight: 700, fontSize: 14,
          }}>AK</div>
        </div>

        <div style={{ height: 22 }} />

        {/* Hero empty state */}
        <div style={{
          background: p.card, border: `1.5px dashed ${p.primary}`,
          borderRadius: TOK.rCard, padding: 22, position: 'relative', overflow: 'hidden',
        }}>
          <div style={{
            position: 'absolute', right: -16, top: -32,
            fontFamily: SERIF, fontStyle: 'italic', fontSize: 200, lineHeight: 1,
            color: p.primaryTint, fontWeight: 400, pointerEvents: 'none',
          }}>1</div>
          <div style={{ position: 'relative' }}>
            <SectionLabel style={{ color: p.primary }}>Your first directive</SectionLabel>
            <h2 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 30, margin: '6px 0 6px', fontWeight: 400, letterSpacing: -0.5, lineHeight: 1.05 }}>
              About 15 minutes.<br/>That's all.
            </h2>
            <p style={{ fontSize: 13.5, color: p.textMuted, margin: '0 0 16px', lineHeight: 1.5, maxWidth: 280 }}>
              Eleven short steps, plain language. About 20 minutes — save and come back anytime.
            </p>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 8, marginBottom: 16 }}>
              {[
                ['~5 min', 'The basics, your agents & guardian (steps 1–4)'],
                ['~8 min', 'Health: care, diagnoses, meds, allergies (5–8)'],
                ['~6 min', 'Procedures, anything else & review (9–11)'],
              ].map(([t, label], i) => (
                <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                  <span style={{
                    fontFamily: MONO, fontSize: 10, fontWeight: 700, color: p.primary,
                    background: p.primaryTint, padding: '2px 7px', borderRadius: 4,
                    letterSpacing: 0.4, width: 52, textAlign: 'center',
                  }}>{t}</span>
                  <span style={{ fontSize: 13, color: p.text, flex: 1 }}>{label}</span>
                </div>
              ))}
            </div>
            <Btn kind="primary" size="lg" full trailing={<Arrow size={18} />}>Start my directive</Btn>
          </div>
        </div>

        <div style={{ height: 14 }} />
        <Btn kind="outline" full leading={<Icon size={16}><path d="M14 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"/><path d="M14 3v6h6"/></Icon>}>
          I have a directive — import it
        </Btn>

        {/* Learn primer */}
        <div style={{ height: 22 }} />
        <SectionLabel>Before you start</SectionLabel>
        <div style={{ marginTop: 8, display: 'flex', flexDirection: 'column', gap: 8 }}>
          {[
            { icon: <Book size={16} />, t: 'What is an MHAD?', sub: '4 min read · plain language' },
            { icon: <Users size={16} />, t: 'Picking the right agent', sub: '5 min read' },
            { icon: <Shield size={16} />, t: 'Your rights under Act 194', sub: '7 min read' },
          ].map((it, i) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', gap: 12,
              padding: '12px 14px', background: p.card, border: `1px solid ${p.border}`, borderRadius: 12,
            }}>
              <div style={{ width: 32, height: 32, borderRadius: 8, background: p.primaryTint, color: p.primary, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{it.icon}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 13.5, fontWeight: 600 }}>{it.t}</div>
                <div style={{ fontSize: 11.5, color: p.textMuted }}>{it.sub}</div>
              </div>
              <Arrow size={14} stroke={p.textMuted} />
            </div>
          ))}
        </div>
      </div>
    </Screen>
  );
}

// ─── X · Past directive detail (expired) ───────────────────────────────
function ScrPastDetail() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <Screen>
      <CrisisBar compact />
      <div style={{ padding: '10px 22px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <span style={{ fontSize: 13, color: p.primary, fontWeight: 600, display: 'flex', alignItems: 'center', gap: 4 }}>
          <Icon d="M15 18l-6-6 6-6" size={16} /> Past directives
        </span>
        <DotsH size={18} stroke={p.textMuted} />
      </div>

      <div style={{ padding: '14px 22px 100px' }}>
        <Badge tone="warn">● Expired</Badge>
        <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 38, margin: '8px 0 4px', fontWeight: 400, letterSpacing: -0.5, lineHeight: 1.05 }}>
          Directive · <span style={{ color: p.primary }}>2023</span>
        </h1>
        <p style={{ fontSize: 13.5, color: p.textMuted, margin: 0, lineHeight: 1.5 }}>
          Combined form · signed May 2, 2023 · expired May 2, 2025
        </p>

        {/* Document preview card */}
        <div style={{
          marginTop: 16, background: p.card, border: `1px solid ${p.border}`,
          borderRadius: TOK.rCard, padding: 14,
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 12 }}>
            <FileText size={20} stroke={p.textMuted} />
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 13.5, fontWeight: 600 }}>Directive_2023_Kowalski.pdf</div>
              <div style={{ fontSize: 11.5, color: p.textMuted }}>6 pages · 2.1 MB</div>
            </div>
            <Btn kind="ghost" size="sm" leading={<Eye size={14} />}>Preview</Btn>
          </div>

          {/* Mini sig + witness summary */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 8, paddingTop: 10, borderTop: `1px dashed ${p.border}` }}>
            {[
              ['Signed by', 'You'],
              ['Witness 1', 'M. Chen'],
              ['Witness 2', 'D. Park'],
            ].map(([k, v]) => (
              <div key={k}>
                <div style={{ fontFamily: MONO, fontSize: 9.5, color: p.textMuted, letterSpacing: 0.4 }}>{k.toUpperCase()}</div>
                <div style={{ fontSize: 12, fontWeight: 600, color: p.text, marginTop: 1 }}>{v}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Distribution audit — private mode only */}
        <div style={{ height: 18 }} />
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <SectionLabel>Who had a copy</SectionLabel>
          <span style={{ fontFamily: MONO, fontSize: 9, fontWeight: 700, letterSpacing: 0.5, color: p.primary, background: p.primaryTint, padding: '2px 6px', borderRadius: 3 }}>PRIVATE MODE ONLY</span>
        </div>
        <p style={{ fontSize: 11.5, color: p.textMuted, margin: '6px 2px 8px', lineHeight: 1.4 }}>
          This list lives only on your device. In the anonymous web app, no share history is kept at all.
        </p>
        <div style={{ background: p.card, border: `1px solid ${p.border}`, borderRadius: 12 }}>
          {[
            ['Jordan Lee', 'Primary agent', 'Sent May 3 2023', 'Email'],
            ['Dr. Patel · UPMC', 'PCP', 'Sent May 5 2023', 'AirDrop'],
            ['Dr. Singh · psychiatry', 'Provider', 'Sent May 5 2023', 'Print'],
          ].map(([who, role, when, method], i, arr) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', gap: 10,
              padding: '12px 14px',
              borderBottom: i < arr.length - 1 ? `1px solid ${p.border}` : 'none',
            }}>
              <Check size={14} sw={3} stroke={p.okText} />
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 13, fontWeight: 600 }}>{who}</div>
                <div style={{ fontSize: 11, color: p.textMuted }}>{role} · {when} · {method}</div>
              </div>
              <span style={{ fontSize: 11.5, fontWeight: 700, color: p.textMuted }}>Redact</span>
            </div>
          ))}
        </div>
        <p style={{ fontSize: 10.5, color: p.textMuted, margin: '8px 2px 0', lineHeight: 1.4, fontStyle: 'italic' }}>
          We log only what you told us to send and how — never confirmation that it was received (that would need a server). Tap <strong>Redact</strong> to remove any recipient's details.
        </p>

        {/* Actions */}
        <div style={{ height: 18 }} />
        <SectionLabel>Actions</SectionLabel>
        <div style={{ marginTop: 8, display: 'flex', flexDirection: 'column', gap: 8 }}>
          <ActionRow
            tone="primary"
            icon={<SwapV size={18} />}
            title="Copy to a new directive"
            sub="Start with these answers — recommended"
          />
          <ActionRow
            icon={<Download size={18} />}
            title="Download the PDF"
            sub="Keep for your records"
          />
          <ActionRow
            icon={<Share size={18} />}
            title="Re-send to someone"
            sub="If your agent lost their copy"
          />
          <ActionRow
            tone="danger"
            icon={<Icon size={18}><path d="M3 6h18M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/></Icon>}
            title="Delete from this device"
            sub="The directive remains expired regardless"
          />
        </div>
      </div>
    </Screen>
  );
}

// shared action row used by past-detail + settings
function ActionRow({ icon, title, sub, tone }) {
  const { palette: p } = React.useContext(MHADContext);
  const accent = tone === 'primary' ? p.primary : tone === 'danger' ? p.crisisAccent : p.textMuted;
  const bg = tone === 'primary' ? p.primaryTint : tone === 'danger' ? p.crisisBg : p.surface;
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12,
      padding: '12px 14px', background: p.card, border: `1px solid ${p.border}`,
      borderRadius: 12, cursor: 'pointer',
    }}>
      <div style={{
        width: 36, height: 36, borderRadius: 9, flexShrink: 0,
        background: bg, color: accent,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>{icon}</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 13.5, fontWeight: 600, color: tone === 'danger' ? p.crisisAccent : p.text }}>{title}</div>
        {sub && <div style={{ fontSize: 11.5, color: p.textMuted, marginTop: 1 }}>{sub}</div>}
      </div>
      <ChevR size={16} stroke={p.textMuted} />
    </div>
  );
}

// ─── X · Renewal nudge (30-day reminder) ──────────────────────────────
function ScrRenew() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <Screen scroll={false} style={{ background: '#000' }}>
      {/* Faded home backdrop */}
      <div style={{ position: 'absolute', inset: 0, opacity: 0.5, filter: 'blur(2px)' }}>
        <Screen>
          <CrisisBar />
          <div style={{ padding: 22, color: p.text }}>
            <div style={{ height: 80 }} />
            <h1 style={{ fontSize: 30, fontFamily: SERIF, fontStyle: 'italic', margin: 0 }}>Hi, Alex.</h1>
          </div>
        </Screen>
      </div>
      <div style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.55)' }} />

      {/* Sheet */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0,
        background: p.card, borderRadius: `${TOK.rSheet}px ${TOK.rSheet}px 0 0`,
        padding: '14px 0 40px', boxShadow: '0 -10px 40px rgba(0,0,0,0.35)',
      }}>
        <div style={{ width: 40, height: 4, background: p.border, borderRadius: 100, margin: '0 auto 14px' }} />

        <div style={{ padding: '0 22px' }}>
          <div style={{ display: 'flex', alignItems: 'flex-start', gap: 14 }}>
            <div style={{
              width: 56, height: 56, borderRadius: 14, flexShrink: 0,
              background: p.warnBg, color: p.warnText,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <Calendar size={26} />
            </div>
            <div style={{ flex: 1 }}>
              <SectionLabel style={{ color: p.warnText }}>● Expires in 28 days</SectionLabel>
              <h2 style={{
                fontFamily: SERIF, fontStyle: 'italic', fontSize: 30, margin: '4px 0 4px',
                fontWeight: 400, letterSpacing: -0.5, lineHeight: 1.05,
              }}>
                Time to renew, Alex.
              </h2>
              <p style={{ fontSize: 13, color: p.textMuted, margin: 0, lineHeight: 1.5 }}>
                PA directives expire after 2 years. Yours runs out on <strong style={{ color: p.text }}>June 11, 2026</strong>.
              </p>
            </div>
          </div>

          <div style={{ height: 18 }} />
          <div style={{
            background: p.primaryTint, border: `1px solid ${p.primary}25`,
            borderRadius: 12, padding: 14,
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
              <Sparkles size={16} stroke={p.primary} />
              <span style={{ fontSize: 13, fontWeight: 700, color: p.primaryDark }}>Quick renew · ~5 min</span>
            </div>
            <p style={{ margin: 0, fontSize: 12.5, color: p.text, lineHeight: 1.5 }}>
              Most people keep the same answers. We'll pre-fill all 11 sections from your current directive — tap any card to change it, then print and sign the new copy in ink with two witnesses.
            </p>
            <div style={{ display: 'flex', gap: 14, marginTop: 12, fontSize: 11, color: p.textMuted }}>
              <span><strong style={{ color: p.text }}>11</strong> sections to confirm</span>
              <span>·</span>
              <span><strong style={{ color: p.text }}>wet-ink</strong> signing</span>
              <span>·</span>
              <span><strong style={{ color: p.text }}>~5</strong> min</span>
            </div>
          </div>

          <div style={{ height: 14 }} />
          <Btn kind="primary" size="lg" full trailing={<Arrow size={18} />}>Start quick renew</Btn>
          <div style={{ height: 8 }} />
          <Btn kind="outline" full>Make changes first</Btn>
          <div style={{ height: 8 }} />
          <Btn kind="ghost" full style={{ color: p.textMuted }}>Remind me next week</Btn>

          <div style={{ height: 8 }} />
          <p style={{ fontSize: 10.5, color: p.textMuted, textAlign: 'center', margin: 0, lineHeight: 1.5 }}>
            We'll remind you again 7 days before expiration.
          </p>
        </div>
      </div>
    </Screen>
  );
}

// ─── X · Quarterly check-in (soft, every 3 months) ────────────────────
// Distinct from the hard renewal: no expiry pressure, no re-signing. Just
// "anything changed?" — confirm-and-dismiss, or jump to a step to edit.
function ScrCheckIn() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <Screen scroll={false} style={{ background: '#000' }}>
      {/* Faded home backdrop */}
      <div style={{ position: 'absolute', inset: 0, opacity: 0.5, filter: 'blur(2px)' }}>
        <Screen>
          <CrisisBar />
          <div style={{ padding: 22, color: p.text }}>
            <div style={{ height: 80 }} />
            <h1 style={{ fontSize: 30, fontFamily: SERIF, fontStyle: 'italic', margin: 0 }}>Hi, Alex.</h1>
          </div>
        </Screen>
      </div>
      <div style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.55)' }} />

      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0,
        background: p.card, borderRadius: `${TOK.rSheet}px ${TOK.rSheet}px 0 0`,
        padding: '14px 0 40px', boxShadow: '0 -10px 40px rgba(0,0,0,0.35)',
      }}>
        <div style={{ width: 40, height: 4, background: p.border, borderRadius: 100, margin: '0 auto 14px' }} />

        <div style={{ padding: '0 22px' }}>
          <div style={{ display: 'flex', alignItems: 'flex-start', gap: 14 }}>
            <div style={{
              width: 56, height: 56, borderRadius: 14, flexShrink: 0,
              background: p.primaryTint, color: p.primary,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <Heart size={26} />
            </div>
            <div style={{ flex: 1 }}>
              <SectionLabel style={{ color: p.primary }}>● 3-month check-in</SectionLabel>
              <h2 style={{
                fontFamily: SERIF, fontStyle: 'italic', fontSize: 30, margin: '4px 0 4px',
                fontWeight: 400, letterSpacing: -0.5, lineHeight: 1.05,
              }}>
                Anything changed?
              </h2>
              <p style={{ fontSize: 13, color: p.textMuted, margin: 0, lineHeight: 1.5 }}>
                Your directive is still valid through <strong style={{ color: p.text }}>May 2028</strong> — no signing needed. Just a quick gut-check that it still fits your life.
              </p>
            </div>
          </div>

          <div style={{ height: 16 }} />
          <SectionLabel>Common things that change</SectionLabel>
          <div style={{ marginTop: 8, display: 'flex', flexDirection: 'column', gap: 8 }}>
            {[
              { icon: <Users size={15} />, t: 'Still the right people?', sub: 'Agents: Jordan Lee, Sam Reyes', step: 'Step 3' },
              { icon: <Pill size={15} />, t: 'Medications up to date?', sub: 'Sertraline, Lamotrigine, Hydroxyzine', step: 'Step 7' },
              { icon: <Icon size={15} sw={2}><path d="M12 22s7-7 7-12a7 7 0 0 0-14 0c0 5 7 12 7 12z"/></Icon>, t: 'Care preferences still right?', sub: 'UPMC Western · single room', step: 'Step 5' },
            ].map((row, i) => (
              <div key={i} style={{
                display: 'flex', alignItems: 'center', gap: 12,
                padding: '11px 14px', background: p.surface, border: `1px solid ${p.border}`, borderRadius: 12,
              }}>
                <div style={{ width: 30, height: 30, borderRadius: 8, background: p.primaryTint, color: p.primary, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>{row.icon}</div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 13, fontWeight: 600, color: p.text }}>{row.t}</div>
                  <div style={{ fontSize: 11.5, color: p.textMuted, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{row.sub}</div>
                </div>
                <span style={{ fontSize: 11.5, fontWeight: 700, color: p.primary, flexShrink: 0 }}>{row.step} ›</span>
              </div>
            ))}
          </div>

          <div style={{ height: 14 }} />
          <Btn kind="primary" size="lg" full leading={<Check size={17} sw={2.5} stroke={p.onPrimary} />}>Still accurate — all good</Btn>
          <div style={{ height: 8 }} />
          <Btn kind="ghost" full style={{ color: p.textMuted }}>Remind me next quarter</Btn>

          <div style={{ height: 8 }} />
          <p style={{ fontSize: 10.5, color: p.textMuted, textAlign: 'center', margin: 0, lineHeight: 1.5 }}>
            If you edit anything, you'll re-print and sign that updated copy in ink. Small changes can wait for your 2-year renewal.
          </p>
        </div>
      </div>
    </Screen>
  );
}

// ─── X · Revocation flow ───────────────────────────────────────────────
function ScrRevoke() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <Screen>
      <CrisisBar compact />
      <WizardHeader back="My directive" pad="10px 22px 0" right={null} />

      <div style={{ padding: '12px 22px 24px' }}>
        <Badge tone="crisis">● Permanent action</Badge>
        <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 38, margin: '8px 0 6px', fontWeight: 400, letterSpacing: -0.5, lineHeight: 1.05 }}>
          Revoke this directive?
        </h1>
        <p style={{ fontSize: 14, color: p.textMuted, margin: 0, lineHeight: 1.5 }}>
          Your directive will no longer be legally binding. We'll generate a signed revocation document — then <strong style={{ color: p.text }}>you choose who to tell</strong>. Nothing is sent automatically.
        </p>

        {/* What happens */}
        <div style={{ height: 18 }} />
        <SectionLabel>Here's what happens</SectionLabel>
        <div style={{ marginTop: 8, background: p.card, border: `1px solid ${p.border}`, borderRadius: 12, padding: '4px 14px' }}>
          {[
            { icon: <Icon size={14}><path d="M3 6h18M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></Icon>, label: 'Your directive is marked revoked, today.' },
            { icon: <Share size={14} />, label: 'A notice goes only to recipients you tick below.' },
            { icon: <FileText size={14} />, label: 'A signed revocation PDF is generated.' },
            { icon: <Wallet size={14} />, label: 'Wallet card flips to "no active directive."' },
            { icon: <Bookmark size={14} />, label: 'You keep a copy of the revoked document.' },
          ].map((it, i, arr) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', gap: 12, padding: '10px 0',
              borderBottom: i < arr.length - 1 ? `1px solid ${p.border}` : 'none',
            }}>
              <div style={{ width: 22, height: 22, borderRadius: 6, background: p.primaryTint, color: p.primary, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>{it.icon}</div>
              <span style={{ fontSize: 13, color: p.text, flex: 1, lineHeight: 1.4 }}>{it.label}</span>
            </div>
          ))}
        </div>

        {/* Who will be notified */}
        <div style={{ height: 16 }} />
        <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
          <SectionLabel>Tell people · your choice</SectionLabel>
          <span style={{ fontFamily: MONO, fontSize: 9.5, color: p.textMuted, letterSpacing: 0.4 }}>OPT-IN PER PERSON</span>
        </div>
        <p style={{ fontSize: 11.5, color: p.textMuted, margin: '6px 0 8px', lineHeight: 1.4 }}>
          Each opens your mail or messages app with the revocation PDF attached — you press send.
        </p>

        {/* Named in the directive */}
        <div style={{ fontFamily: MONO, fontSize: 10, color: p.textMuted, letterSpacing: 0.5, margin: '4px 2px 6px' }}>NAMED IN YOUR DIRECTIVE</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
          {[
            ['Jordan Lee', 'Primary agent', true],
            ['Sam Reyes', 'Alternate agent', true],
            ['Dr. R. Patel · UPMC', 'Primary care doctor', false],
            ['Dr. Singh', 'Psychiatry', false],
          ].map(([who, role, on], i) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', gap: 10,
              padding: '8px 12px', background: p.card, border: `1px solid ${p.border}`, borderRadius: 10,
            }}>
              <div style={{
                width: 20, height: 20, borderRadius: 5,
                background: on ? p.primary : 'transparent',
                border: on ? 'none' : `1.5px solid ${p.border}`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>{on && <Check size={13} sw={3} stroke={p.onPrimary} />}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 13, fontWeight: 600 }}>{who}</div>
                <div style={{ fontSize: 11, color: p.textMuted }}>{role}</div>
              </div>
              <span style={{ fontFamily: MONO, fontSize: 9.5, color: p.textMuted, letterSpacing: 0.4 }}>{on ? 'EMAIL' : 'OFF'}</span>
            </div>
          ))}
        </div>

        {/* Generic suggestions */}
        <div style={{ fontFamily: MONO, fontSize: 10, color: p.textMuted, letterSpacing: 0.5, margin: '14px 2px 6px' }}>ALSO CONSIDER TELLING</div>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
          {['Your therapist', 'Nearest ER', 'County crisis line', 'Family who hold a copy', 'Your pharmacy'].map((s, i) => (
            <span key={i} style={{
              display: 'inline-flex', alignItems: 'center', gap: 5,
              fontSize: 12, fontWeight: 600, color: p.text,
              background: p.surface, border: `1px dashed ${p.border}`,
              padding: '6px 10px', borderRadius: 100,
            }}>
              <Plus size={11} stroke={p.primary} /> {s}
            </span>
          ))}
        </div>
        <p style={{ fontSize: 10.5, color: p.textMuted, fontStyle: 'italic', margin: '8px 2px 0', lineHeight: 1.4 }}>
          These are reminders, not contacts we store — tap one to add an address and queue an email.
        </p>

        {/* Canonical statutory wording */}
        <div style={{ height: 16 }} />
        <SectionLabel>What revocation means under PA law</SectionLabel>
        <div style={{
          marginTop: 8, background: p.card, border: `1px solid ${p.border}`,
          borderRadius: 12, padding: 14,
        }}>
          <p style={{ margin: 0, fontSize: 13, color: p.text, lineHeight: 1.6, fontFamily: SERIF, fontStyle: 'italic' }}>
            "This declaration may be revoked in whole or in part at any time, either orally or in writing, as long as I have not been found to be incapable of making mental health decisions. My revocation will be effective upon communication to my attending physician or other mental health care provider, either by me or a witness to my revocation, of the intent to revoke."
          </p>
          <div style={{ fontFamily: MONO, fontSize: 9.5, color: p.textMuted, letterSpacing: 0.4, marginTop: 10 }}>
            20 Pa.C.S. CH. 58 · STANDARD MHAD REVOCATION CLAUSE
          </div>
        </div>
        <div style={{
          marginTop: 8, background: p.warnBg, border: `1px solid ${p.warnBorder}`,
          borderRadius: 10, padding: 12, display: 'flex', gap: 10, color: p.warnText,
        }}>
          <Info size={15} stroke={p.warnText} />
          <span style={{ fontSize: 12, lineHeight: 1.45 }}>
            You can only revoke while you <strong>have not</strong> been found incapable of making mental-health decisions. If you're unsure how this applies to you, it's wise to ask an attorney.
          </span>
        </div>
        <Field label='Type REVOKE to confirm' value="REVOKE" hint="Case-sensitive. Lets us make sure this isn't a mis-tap." />

        <div style={{ height: 4 }} />
        <div style={{
          background: p.crisisBg, border: `1px solid ${p.crisisBorder}`,
          borderRadius: 12, padding: 12, color: p.crisisText, fontSize: 12.5, lineHeight: 1.45,
          display: 'flex', gap: 10,
        }}>
          <AlertTri size={16} stroke={p.crisisAccent} />
          <span><strong>This cannot be undone.</strong> You'll need to start a new directive from scratch.</span>
        </div>

        <div style={{ display: 'flex', gap: 8, marginTop: 18 }}>
          <Btn kind="ghost" size="lg" style={{ flex: 1 }}>Cancel</Btn>
          <Btn kind="danger" size="lg" style={{ flex: 1.4 }}>Revoke now</Btn>
        </div>
      </div>
    </Screen>
  );
}

// ─── X · Share sheet (agent + provider) ────────────────────────────────
function ScrShare() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <Screen scroll={false} style={{ background: '#000' }}>
      <div style={{ position: 'absolute', inset: 0, opacity: 0.45, filter: 'blur(2px)' }}>
        <Screen>
          <CrisisBar />
          <div style={{ padding: 22 }}>
            <div style={{ height: 80 }} />
            <h1 style={{ fontSize: 30, fontFamily: SERIF, fontStyle: 'italic', margin: 0 }}>You did it.</h1>
          </div>
        </Screen>
      </div>
      <div style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.5)' }} />

      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0,
        background: p.card, borderRadius: `${TOK.rSheet}px ${TOK.rSheet}px 0 0`,
        padding: '14px 0 40px', boxShadow: '0 -10px 40px rgba(0,0,0,0.35)',
        maxHeight: '88%', overflow: 'auto',
      }}>
        <div style={{ width: 40, height: 4, background: p.border, borderRadius: 100, margin: '0 auto 14px' }} />

        <div style={{ padding: '0 22px' }}>
          <SectionLabel>Share my directive</SectionLabel>
          <h2 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 30, margin: '4px 0 4px', fontWeight: 400, letterSpacing: -0.5 }}>
            Who needs a copy?
          </h2>
          <p style={{ fontSize: 13, color: p.textMuted, margin: 0, lineHeight: 1.45 }}>
            Everything sends straight from your phone — your mail or messages app, a QR, or print. Nothing goes through our servers.
          </p>

          {/* Quick-add suggestions from contacts */}
          <div style={{ height: 16 }} />
          <SectionLabel>From your contacts &amp; care team</SectionLabel>
          <div style={{ fontSize: 10.5, color: p.textMuted, fontFamily: MONO, letterSpacing: 0.3, margin: '2px 0 0' }}>SESSION ONLY · NOT STORED</div>
          <div style={{ display: 'flex', gap: 10, marginTop: 10, overflowX: 'auto', paddingBottom: 4 }}>
            {[
              ['JL', 'Jordan Lee', 'Agent', p.primary, p.onPrimary],
              ['SR', 'Sam Reyes', 'Alt', p.primaryLight, p.onPrimaryLight],
              ['DP', 'Dr. Patel', 'PCP', p.primaryLight, p.onPrimaryLight],
              ['DS', 'Dr. Singh', 'Psych', p.primaryLight, p.onPrimaryLight],
              ['+', 'Add', '', p.surface, p.textMuted],
            ].map(([ini, name, role, bg, fg], i) => (
              <div key={i} style={{ width: 76, flexShrink: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6 }}>
                <div style={{
                  width: 56, height: 56, borderRadius: 100,
                  background: bg, color: fg,
                  border: name === 'Add' ? `1.5px dashed ${p.border}` : 'none',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontFamily: SANS, fontWeight: 700, fontSize: 18,
                }}>{ini}</div>
                <div style={{ fontSize: 11.5, fontWeight: 600, color: p.text, textAlign: 'center', lineHeight: 1.1 }}>{name}</div>
                {role && <div style={{ fontSize: 9.5, fontFamily: MONO, color: p.textMuted, letterSpacing: 0.5 }}>{role.toUpperCase()}</div>}
              </div>
            ))}
          </div>

          {/* Channels */}
          <div style={{ height: 18 }} />
          <SectionLabel>Send via</SectionLabel>
          <div style={{ marginTop: 8, display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 8 }}>
            {[
              { icon: <Icon size={18}><path d="M4 4h16v16H4z M4 4l8 8 8-8"/></Icon>, label: 'Email' },
              { icon: <Icon size={18}><path d="M21 11.5a8 8 0 0 1-.9 3.7 8 8 0 0 1-7.1 4.3 8 8 0 0 1-3.7-.9L3 21l1.9-5.7A8 8 0 0 1 4 11.5a8 8 0 0 1 4.3-7.1 8 8 0 0 1 3.7-.9 8 8 0 0 1 7.1 4.3 8 8 0 0 1 .9 3.7z"/></Icon>, label: 'Text' },
              { icon: <Icon size={18}><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></Icon>, label: 'QR' },
              { icon: <Icon size={18}><path d="M16 6V4a2 2 0 0 0-2-2H10a2 2 0 0 0-2 2v2M3 6h18M5 6v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V6"/></Icon>, label: 'Print' },
            ].map((c, i) => (
              <div key={i} style={{
                display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
                padding: '14px 8px', background: p.surface,
                border: `1px solid ${p.border}`, borderRadius: 12,
              }}>
                <div style={{ width: 36, height: 36, borderRadius: 9, background: p.primaryLight, color: p.onPrimaryLight, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{c.icon}</div>
                <span style={{ fontSize: 11.5, fontWeight: 600, color: p.text }}>{c.label}</span>
              </div>
            ))}
          </div>

          {/* What gets sent */}
          <div style={{ height: 18 }} />
          <SectionLabel>They get</SectionLabel>
          <div style={{ marginTop: 8, background: p.surface, border: `1px solid ${p.border}`, borderRadius: 12, padding: 12 }}>
            {[
              ['Full directive PDF', '6 pages'],
              ['Wallet-card summary', '1 page'],
              ['Emergency QR (works offline)', 'Self-contained'],
            ].map(([k, v], i, arr) => (
              <div key={i} style={{
                display: 'flex', justifyContent: 'space-between', alignItems: 'center',
                padding: '7px 0', borderBottom: i < arr.length - 1 ? `1px dashed ${p.border}` : 'none', fontSize: 12.5,
              }}>
                <span style={{ color: p.text, fontWeight: 500 }}>{k}</span>
                <span style={{ color: p.textMuted, fontFamily: MONO, fontSize: 10.5 }}>{v}</span>
              </div>
            ))}
          </div>

          <div style={{ height: 10 }} />
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '10px 12px', background: p.surface, border: `1px solid ${p.border}`, borderRadius: 10 }}>
            <Lock size={13} stroke={p.textMuted} />
            <span style={{ fontSize: 11, color: p.textMuted, flex: 1, lineHeight: 1.4 }}>
              No tracking links, no expiry, no read receipts — we can't see who you send it to. The QR holds the summary itself, so it works even with no signal.
            </span>
          </div>

          <div style={{ height: 14 }} />
          <Btn kind="primary" size="lg" full trailing={<Arrow size={18} />}>Send to 2 selected</Btn>
        </div>
      </div>
    </Screen>
  );
}

// ─── X · AI assistant (mobile) + first-time consent ────────────────────
function ScrAI() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <Screen scroll={false}>
      {/* Top header */}
      <div style={{ height: STATUSBAR_H }} />
      <div style={{
        padding: '8px 18px 14px', display: 'flex', alignItems: 'center', gap: 12,
        borderBottom: `1px solid ${p.border}`, background: p.card,
      }}>
        <div style={{ width: 36, height: 36, borderRadius: 9, background: p.primaryTint, color: p.primary, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Sparkles size={18} />
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: 14.5, fontWeight: 700, letterSpacing: -0.2 }}>AI assistant</div>
          <div style={{ fontSize: 10, color: p.textMuted, fontFamily: MONO, letterSpacing: 0.5 }}>● ON · GEMINI · PII STRIPPED</div>
        </div>
        <X size={18} stroke={p.textMuted} />
      </div>

      <div style={{ flex: 1, overflow: 'auto', padding: '14px 18px', display: 'flex', flexDirection: 'column', gap: 14, height: `calc(100% - ${STATUSBAR_H + 64 + 72}px)` }}>
        {/* First-time consent banner */}
        <div style={{
          background: p.warnBg, border: `1px solid ${p.warnBorder}`,
          borderRadius: 12, padding: 12, display: 'flex', gap: 10,
        }}>
          <Shield size={18} stroke={p.warnText} />
          <div style={{ flex: 1, fontSize: 12, color: p.warnText, lineHeight: 1.45 }}>
            <strong>Heads up.</strong> Messages go to Google Gemini. Names, addresses &amp; dates are auto-stripped, but review suggestions before accepting.
            <div style={{ marginTop: 6 }}>
              <span style={{ fontSize: 11, fontWeight: 700, color: p.warnText, textDecoration: 'underline' }}>Privacy details</span>
              <span style={{ margin: '0 8px', color: p.warnBorder }}>·</span>
              <span style={{ fontSize: 11, fontWeight: 700, color: p.warnText, textDecoration: 'underline' }}>Turn off</span>
            </div>
          </div>
        </div>

        {/* AI greeting */}
        <div style={{ display: 'flex', gap: 10 }}>
          <div style={{ width: 28, height: 28, borderRadius: 7, background: p.primaryTint, color: p.primary, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
            <Sparkles size={14} />
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: MONO, fontSize: 9.5, color: p.textMuted, letterSpacing: 0.5, marginBottom: 4 }}>GEMINI · NOT LEGAL ADVICE</div>
            <div style={{
              background: p.card, border: `1px solid ${p.border}`, borderRadius: 12,
              padding: '10px 12px', fontSize: 13.5, color: p.text, lineHeight: 1.5,
            }}>
              Hi Alex. I can help word any section in plain language, explain a legal term, or sanity-check your preferences. What's on your mind?
            </div>
          </div>
        </div>

        {/* User msg */}
        <div style={{ display: 'flex', gap: 10, justifyContent: 'flex-end' }}>
          <div style={{ maxWidth: '80%' }}>
            <div style={{ fontFamily: MONO, fontSize: 9.5, color: p.textMuted, letterSpacing: 0.5, marginBottom: 4, textAlign: 'right' }}>YOU</div>
            <div style={{
              background: p.primary, color: p.onPrimary, borderRadius: 12,
              padding: '10px 12px', fontSize: 13.5, lineHeight: 1.5,
            }}>
              Help me explain "least restrictive setting" — I want to mention it in step 8.
            </div>
          </div>
        </div>

        {/* AI response with PII redaction badge */}
        <div style={{ display: 'flex', gap: 10 }}>
          <div style={{ width: 28, height: 28, borderRadius: 7, background: p.primaryTint, color: p.primary, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
            <Sparkles size={14} />
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: MONO, fontSize: 9.5, color: p.textMuted, letterSpacing: 0.5, marginBottom: 4, display: 'flex', gap: 6, alignItems: 'center' }}>
              <span>GEMINI</span>
              <span style={{ color: p.primary }}>·</span>
              <span style={{ color: p.primary, display: 'flex', alignItems: 'center', gap: 3 }}>
                <Lock size={9} stroke={p.primary} /> 3 FIELDS REDACTED
              </span>
            </div>
            <div style={{
              background: p.card, border: `1px solid ${p.border}`, borderRadius: 12,
              padding: '10px 12px', fontSize: 13.5, color: p.text, lineHeight: 1.5,
            }}>
              It means: the doctors should use the calmest, least-locked-down option that still keeps you safe. Outpatient before inpatient, voluntary before involuntary, regular room before seclusion.
              <div style={{ marginTop: 10, padding: '10px 12px', background: p.primaryTint, borderRadius: 8, border: `1px solid ${p.primary}25` }}>
                <div style={{ fontFamily: MONO, fontSize: 9.5, fontWeight: 700, color: p.primary, letterSpacing: 0.5, marginBottom: 4 }}>SUGGESTED FOR STEP 8</div>
                <div style={{ fontSize: 12.5, fontStyle: 'italic', lineHeight: 1.5 }}>
                  "Use the least restrictive setting that keeps me safe. Outpatient or voluntary admission before involuntary; standard room before seclusion."
                </div>
                <div style={{ display: 'flex', gap: 6, marginTop: 10 }}>
                  <Btn kind="primary" size="sm">Use this</Btn>
                  <Btn kind="ghost" size="sm">Edit</Btn>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Suggested chips */}
        <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
          {['Sanity-check my agent setup', 'Plain-language my meds list', 'Common backup-plan wording'].map((s, i) => (
            <Chip key={i}>{s}</Chip>
          ))}
        </div>
      </div>

      {/* Input bar */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0,
        padding: '10px 16px 22px', background: p.scaffold,
        borderTop: `1px solid ${p.border}`,
      }}>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 6,
          background: p.card, border: `1.5px solid ${p.border}`, borderRadius: 100,
          padding: '4px 4px 4px 14px',
        }}>
          <Sparkles size={14} stroke={p.textMuted} />
          <input style={{
            flex: 1, border: 'none', outline: 'none', background: 'transparent',
            fontFamily: SANS, fontSize: 14, color: p.text, padding: '8px 0',
          }} placeholder="Ask about your directive…" />
          <Mic size={18} stroke={p.textMuted} />
          <div style={{ width: 32, height: 32, borderRadius: 100, background: p.primary, color: p.onPrimary, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Arrow size={14} stroke={p.onPrimary} />
          </div>
        </div>
      </div>
    </Screen>
  );
}

// ─── X · Mobile Learn hub ──────────────────────────────────────────────
function ScrLearn() {
  const { palette: p } = React.useContext(MHADContext);

  const Card2 = ({ icon, title, sub, minutes, featured }) => (
    <div style={{
      background: featured ? p.primary : p.card,
      color: featured ? p.onPrimary : p.text,
      border: featured ? 'none' : `1px solid ${p.border}`,
      borderRadius: TOK.rCard, padding: featured ? 18 : 14,
      position: 'relative', overflow: 'hidden',
      gridColumn: featured ? '1 / -1' : 'auto',
    }}>
      {featured && (
        <div style={{
          position: 'absolute', right: -8, top: -22,
          fontFamily: SERIF, fontStyle: 'italic', fontSize: 130, lineHeight: 1,
          color: 'rgba(255,255,255,0.1)', fontWeight: 400,
        }}>?</div>
      )}
      <div style={{ position: 'relative' }}>
        <div style={{
          width: 32, height: 32, borderRadius: 8,
          background: featured ? 'rgba(255,255,255,0.18)' : p.primaryTint,
          color: featured ? p.onPrimary : p.primary,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          marginBottom: 10,
        }}>{icon}</div>
        <div style={{ fontSize: featured ? 17 : 14, fontWeight: 700, letterSpacing: -0.2, lineHeight: 1.2 }}>{title}</div>
        <div style={{ fontSize: 11.5, color: featured ? 'rgba(255,255,255,0.8)' : p.textMuted, marginTop: 4, lineHeight: 1.4 }}>{sub}</div>
        <div style={{
          fontFamily: MONO, fontSize: 10, color: featured ? 'rgba(255,255,255,0.7)' : p.textMuted,
          letterSpacing: 0.6, marginTop: 8,
        }}>{minutes}</div>
      </div>
    </div>
  );

  return (
    <Screen>
      <CrisisBar compact />
      <div style={{ padding: '20px 22px 100px' }}>
        <SectionLabel>Learn</SectionLabel>
        <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 42, margin: '4px 0 6px', fontWeight: 400, letterSpacing: -0.8, lineHeight: 1 }}>
          Understand <span style={{ color: p.primary }}>before</span> you sign.
        </h1>
        <p style={{ fontSize: 13.5, color: p.textMuted, margin: 0, lineHeight: 1.5 }}>
          Everything below comes verbatim from the PA MHAD booklet.
        </p>

        {/* Search */}
        <div style={{ height: 16 }} />
        <div style={{
          display: 'flex', alignItems: 'center', gap: 10,
          background: p.card, border: `1px solid ${p.border}`, borderRadius: 100,
          padding: '10px 14px',
        }}>
          <Search size={16} stroke={p.textMuted} />
          <input style={{
            flex: 1, border: 'none', outline: 'none', background: 'transparent',
            fontFamily: SANS, fontSize: 13.5, color: p.text,
          }} placeholder="Search articles, glossary, FAQs…" />
        </div>

        {/* Category tabs */}
        <div style={{ height: 14 }} />
        <div style={{ display: 'flex', gap: 6, overflowX: 'auto', paddingBottom: 2 }}>
          {[
            { label: 'All', active: true },
            { label: 'Articles', active: false },
            { label: 'Glossary', active: false },
            { label: 'FAQ', active: false },
            { label: 'Checklists', active: false },
          ].map((t, i) => (
            <span key={i} style={{
              flexShrink: 0, fontSize: 12.5, fontWeight: 700,
              padding: '7px 14px', borderRadius: 100, cursor: 'pointer',
              background: t.active ? p.primary : p.card,
              color: t.active ? p.onPrimary : p.textMuted,
              border: `1px solid ${t.active ? p.primary : p.border}`,
            }}>{t.label}</span>
          ))}
        </div>

        <div style={{ height: 18 }} />
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          <Card2 featured icon={<Book size={18} />} title="What is an MHAD?" sub="The 4-minute version. Plain-language intro to what a Mental Health Advance Directive is, who can make one, and what makes it legally binding under Act 194." minutes="4 MIN · MOST READ" />
          <Card2 icon={<Users size={16} />} title="Picking the right agent" sub="Who can be your agent, who can't." minutes="5 MIN" />
          <Card2 icon={<Shield size={16} />} title="Your rights" sub="Under PA Act 194." minutes="7 MIN" />
          <Card2 icon={<Brain size={16} />} title="When does it activate?" sub="The exact trigger conditions." minutes="3 MIN" />
          <Card2 icon={<FileText size={16} />} title="Glossary" sub="Every legal term, defined." minutes="2 MIN" />
        </div>

        {/* Quick glossary — compact, mono-styled content type */}
        <div style={{ height: 20 }} />
        <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
          <SectionLabel>Glossary · quick reference</SectionLabel>
          <span style={{ fontSize: 11.5, fontWeight: 700, color: p.primary }}>See all 24 ›</span>
        </div>
        <div style={{ marginTop: 8, display: 'flex', flexDirection: 'column', gap: 6 }}>
          {[
            ['Agent', 'The person you name to make mental-health decisions if you can\'t.'],
            ['Capacity', 'Whether two clinicians find you able to make informed decisions.'],
            ['Declaration', 'Your written treatment instructions — the part without an agent.'],
          ].map(([term, def], i) => (
            <div key={i} style={{
              display: 'flex', gap: 10, padding: '10px 12px',
              background: p.card, border: `1px solid ${p.border}`, borderRadius: 10,
            }}>
              <span style={{
                fontFamily: MONO, fontSize: 11, fontWeight: 700, color: p.primary,
                flexShrink: 0, minWidth: 78, letterSpacing: 0.2,
              }}>{term}</span>
              <span style={{ fontSize: 12, color: p.textMuted, lineHeight: 1.4 }}>{def}</span>
            </div>
          ))}
        </div>

        {/* FAQ teaser */}
        <div style={{ height: 16 }} />
        <div style={{
          display: 'flex', alignItems: 'center', gap: 12,
          padding: '12px 14px', background: p.surface, border: `1px solid ${p.border}`, borderRadius: 12,
        }}>
          <div style={{ width: 30, height: 30, borderRadius: 8, background: p.primaryTint, color: p.primary, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
            <Icon size={15}><circle cx="12" cy="12" r="9"/><path d="M9.5 9a2.5 2.5 0 1 1 4 2c-1 .8-1.5 1.5-1.5 2.5M12 17.5h.01"/></Icon>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 13, fontWeight: 700, color: p.text }}>Frequently asked</div>
            <div style={{ fontSize: 11.5, color: p.textMuted }}>Can I change it later? Does it expire? 11 more ›</div>
          </div>
        </div>

        {/* Pull-quote */}
        <div style={{ height: 18 }} />
        <div style={{
          background: p.primaryTint, border: `1px solid ${p.primary}25`,
          borderRadius: TOK.rCard, padding: '18px 18px 14px',
        }}>
          <div style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 19, color: p.primaryDark, lineHeight: 1.3 }}>
            "Your directive is your voice — written in advance, kept safe, honored when you can't speak for yourself."
          </div>
          <div style={{ fontFamily: MONO, fontSize: 10, color: p.textMuted, letterSpacing: 0.6, marginTop: 8 }}>
            — PA MHAD BOOKLET · OMHSAS
          </div>
        </div>
      </div>
    </Screen>
  );
}

// ─── X · Mobile Settings ───────────────────────────────────────────────
function ScrSettings() {
  const { palette: p } = React.useContext(MHADContext);

  const Row = ({ icon, title, sub, value, danger, tone = 'default' }) => (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12,
      padding: '12px 14px',
      borderBottom: `1px solid ${p.border}`, background: p.card,
    }}>
      <div style={{
        width: 32, height: 32, borderRadius: 8, flexShrink: 0,
        background: tone === 'danger' ? p.crisisBg : p.primaryTint,
        color: tone === 'danger' ? p.crisisAccent : p.primary,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>{icon}</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 13.5, fontWeight: 600, color: tone === 'danger' ? p.crisisAccent : p.text }}>{title}</div>
        {sub && <div style={{ fontSize: 11.5, color: p.textMuted, marginTop: 1 }}>{sub}</div>}
      </div>
      {value && <span style={{ fontSize: 12.5, color: p.textMuted, fontFamily: SANS, fontWeight: 500 }}>{value}</span>}
      <ChevR size={16} stroke={p.textMuted} />
    </div>
  );

  const Group = ({ label, children }) => (
    <div style={{ marginBottom: 18 }}>
      <SectionLabel style={{ padding: '0 22px 8px' }}>{label}</SectionLabel>
      <div style={{ border: `1px solid ${p.border}`, borderRadius: TOK.rCard, margin: '0 14px', overflow: 'hidden' }}>
        {children}
      </div>
    </div>
  );

  return (
    <Screen>
      <CrisisBar compact />
      <div style={{ padding: '20px 22px 6px' }}>
        <SectionLabel>Account</SectionLabel>
        <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 38, margin: '4px 0 6px', fontWeight: 400, letterSpacing: -0.5, lineHeight: 1 }}>
          Settings
        </h1>
      </div>

      {/* Profile chip */}
      <div style={{ padding: '6px 22px 18px' }}>
        <div style={{
          background: p.primary, color: p.onPrimary, borderRadius: TOK.rCard, padding: 14,
          display: 'flex', alignItems: 'center', gap: 12,
        }}>
          <div style={{ width: 44, height: 44, borderRadius: 100, background: 'rgba(255,255,255,0.18)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 700, fontSize: 15 }}>AK</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 15, fontWeight: 700 }}>Alex M. Kowalski</div>
            <div style={{ fontSize: 11, fontFamily: MONO, opacity: 0.85, letterSpacing: 0.4 }}>● PRIVATE MODE · FACE ID</div>
          </div>
        </div>
      </div>

      <div style={{ paddingBottom: 100 }}>
        <Group label="My directive">
          <Row icon={<FileText size={16} />} title="View current directive" sub="Combined · expires May 14 2028" value="Active" />
          <Row icon={<SwapV size={16} />} title="Renew or replace" sub="Make changes &amp; re-print to sign" />
          <Row icon={<Bookmark size={16} />} title="Past directives" value="2" />
          <Row icon={<Icon size={16}><path d="M3 6h18M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></Icon>} title="Revoke directive" tone="danger" />
        </Group>

        <Group label="Appearance">
          <Row icon={<Icon size={16}><circle cx="12" cy="12" r="5"/><path d="M12 1v2M12 21v2M4.2 4.2l1.4 1.4M18.4 18.4l1.4 1.4M1 12h2M21 12h2M4.2 19.8l1.4-1.4M18.4 5.6l1.4-1.4"/></Icon>} title="Brightness" sub="Match system, or pick light / dark" value="System" />
          <Row icon={<Icon size={16}><circle cx="13.5" cy="6.5" r="2.5"/><circle cx="17.5" cy="10.5" r="2.5"/><circle cx="8.5" cy="7.5" r="2.5"/><circle cx="6.5" cy="12.5" r="2.5"/><path d="M12 2a10 10 0 1 0 0 20 4 4 0 0 1 0-8 6 6 0 0 0 0-12z"/></Icon>} title="Color theme" sub="Teal · Navy · Sage" value="Teal" />
          <Row icon={<Icon size={16}><path d="M4 7V4h16v3M9 20h6M12 4v16"/></Icon>} title="Text size" sub="Affects the whole app" value="Default" />
          <Row icon={<Icon size={16}><path d="M2 12h20M12 2a15 15 0 0 1 0 20M12 2a15 15 0 0 0 0 20"/></Icon>} title="Accessibility" sub="Dyslexia font, read-aloud, language" />
        </Group>

        <Group label="Data & privacy">
          <Row icon={<Lock size={16} />} title="Mode" sub="How your data is stored" value="Private" />
          <Row icon={<EyeOff size={16} />} title="Biometric unlock" value="Face ID" />
          <Row icon={<Sparkles size={16} />} title="AI assistant" sub="Gemini · PII auto-redacted" value="On" />
          <Row icon={<Calendar size={16} />} title="Auto-lock after" value="5 min" />
          <Row icon={<Download size={16} />} title="Export my data" sub="JSON, PDF, FHIR" />
          <Row icon={<Icon size={16}><path d="M3 6h18M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></Icon>} title="Delete all my data" tone="danger" />
        </Group>

        <Group label="Reminders">
          <Row icon={<Calendar size={16} />} title="Expiration reminder" sub="30 days before" value="On" />
          <Row icon={<Icon size={16}><path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9M13 21h-2"/></Icon>} title="Annual check-in" sub="Each May" value="On" />
        </Group>

        <Group label="About">
          <Row icon={<Info size={16} />} title="Re-read disclaimer" sub="The 8 sections you agreed to" />
          <Row icon={<Shield size={16} />} title="Your rights · Act 194" />
          <Row icon={<Heart size={16} />} title="Crisis resources" />
          <Row icon={<Book size={16} />} title="Open-source &amp; credits" />
          <Row icon={<FileText size={16} />} title="Version" value="1.4.2" />
        </Group>
      </div>
    </Screen>
  );
}

// ─── X · Mobile PDF preview ────────────────────────────────────────────
function ScrPdfPreview() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <Screen scroll={false}>
      <div style={{ height: STATUSBAR_H }} />

      {/* Top toolbar */}
      <div style={{
        padding: '10px 14px', display: 'flex', alignItems: 'center', gap: 10,
        borderBottom: `1px solid ${p.border}`, background: p.card,
      }}>
        <X size={20} stroke={p.text} />
        <div style={{ flex: 1, textAlign: 'center' }}>
          <div style={{ fontSize: 14, fontWeight: 700 }}>Preview</div>
          <div style={{ fontSize: 10, color: p.textMuted, fontFamily: MONO, letterSpacing: 0.5 }}>PAGE 1 OF 6 · US LETTER 8.5×11″</div>
        </div>
        <Search size={18} stroke={p.text} />
        <DotsH size={20} stroke={p.text} />
      </div>

      {/* PDF body */}
      <div style={{ flex: 1, overflow: 'auto', background: p.surface, padding: 18, height: `calc(100% - ${STATUSBAR_H + 56 + 80}px)` }}>
        {/* True US Letter page: 8.5 × 11 in aspect ratio, ~1in margins */}
        <div style={{
          background: '#fff', boxShadow: '0 4px 20px rgba(0,0,0,0.10)',
          borderRadius: 2,
          width: '100%', aspectRatio: '8.5 / 11',
          padding: '9% 11.7%', boxSizing: 'border-box', overflow: 'hidden',
          fontFamily: 'Times, Georgia, serif', color: '#1a1a1a',
        }}>
          <div style={{ textAlign: 'center', fontSize: 8, letterSpacing: 1, color: '#555' }}>COMMONWEALTH OF PENNSYLVANIA · ACT 194 OF 2004</div>
          <h1 style={{ textAlign: 'center', fontSize: 14, fontWeight: 700, margin: '9px 0 3px' }}>MENTAL HEALTH ADVANCE DIRECTIVE</h1>
          <div style={{ textAlign: 'center', fontSize: 8.5, color: '#555', marginBottom: 12 }}>Combined Declaration &amp; Power of Attorney</div>

          <div style={{ fontSize: 8.5, lineHeight: 1.5 }}>
            <p style={{ margin: '5px 0' }}><strong>I, ALEX M. KOWALSKI</strong>, of Allegheny County, Pennsylvania, being of sound mind, voluntarily make this Mental Health Advance Directive under the provisions of Act 194 of 2004.</p>
            <p style={{ margin: '9px 0 3px', fontWeight: 700 }}>SECTION 1. EFFECTIVE CONDITION</p>
            <p style={{ margin: '3px 0' }}>This directive shall become effective upon examination by a psychiatrist and one of the following — another psychiatrist, psychologist, family physician, attending physician or mental health treatment professional — determining that I am incapable of making mental health care decisions.</p>
            <p style={{ margin: '9px 0 3px', fontWeight: 700 }}>SECTION 2. DESIGNATION OF AGENT</p>
            <p style={{ margin: '3px 0' }}>I hereby appoint <strong>JORDAN LEE</strong>, my sister, residing at 87 Forbes Ave, Pittsburgh PA, telephone (412) 555-0188, as my mental health treatment agent…</p>
          </div>
        </div>
        <div style={{ textAlign: 'center', fontSize: 9, color: p.textMuted, fontFamily: MONO, marginTop: 6, letterSpacing: 0.4 }}>— continued on page 2 —</div>

        {/* Page thumbs */}
        <div style={{ display: 'flex', gap: 4, justifyContent: 'center', marginTop: 14 }}>
          {Array.from({ length: 6 }).map((_, i) => (
            <div key={i} style={{
              width: 22, height: 30,
              background: i === 0 ? p.primary : p.card,
              border: `1px solid ${i === 0 ? p.primary : p.border}`,
              borderRadius: 3,
              color: i === 0 ? p.onPrimary : p.textMuted,
              fontSize: 10, fontFamily: MONO, fontWeight: 600,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>{i + 1}</div>
          ))}
        </div>
      </div>

      {/* Bottom action bar */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0,
        padding: '12px 14px 22px',
        background: p.card, borderTop: `1px solid ${p.border}`,
        display: 'flex', gap: 8,
      }}>
        <Btn kind="tonal" leading={<Download size={14} />} style={{ flex: 1 }}>Save</Btn>
        <Btn kind="tonal" leading={<Icon size={14}><path d="M6 9V2h12v7"/><rect x="6" y="14" width="12" height="8"/></Icon>} style={{ flex: 1 }}>Print</Btn>
        <Btn kind="primary" leading={<Share size={14} />} style={{ flex: 1.4 }}>Share</Btn>
      </div>
    </Screen>
  );
}

// ─── X · Form-type quiz (4 questions + result) ─────────────────────────
// Scoring: each answer adds points to combined / declaration / poa.
// Winner = highest total. Confidence = winnerScore / sum(all scores).
const QUIZ_QUESTIONS = [
  {
    q: 'What are you here to do?',
    hint: 'Pick the closest. There are no wrong answers.',
    opts: [
      { t: 'Name people I trust to decide for me', s: { poa: 2, combined: 1 } },
      { t: 'Write down exactly what I do and don\'t want', s: { declaration: 2, combined: 1 } },
      { t: 'Both — name people and write my wishes', s: { combined: 2 } },
      { t: 'I\'m not sure yet', s: {} },
    ],
  },
  {
    q: 'Do you have someone to speak for you?',
    hint: 'A family member, partner, or close friend who could decide if you can\'t.',
    opts: [
      { t: 'Yes — and I trust them completely', s: { poa: 2, combined: 1 } },
      { t: 'Yes, but I want to set firm limits', s: { combined: 2 } },
      { t: 'No — I\'d rather providers follow my written wishes', s: { declaration: 2 } },
      { t: 'I\'m not sure yet', s: {} },
    ],
  },
  {
    q: 'How specific are your treatment wishes?',
    hint: 'Medications, ECT, facilities, things to avoid.',
    opts: [
      { t: 'Very — I have specific dos and don\'ts', s: { declaration: 2, combined: 1 } },
      { t: 'Some general preferences', s: { combined: 1 } },
      { t: 'I\'d rather a person decide in the moment', s: { poa: 2 } },
      { t: 'I haven\'t thought about it yet', s: {} },
    ],
  },
  {
    q: 'Should the person you name override your written wishes?',
    hint: 'In a crisis, if your written wishes and their judgment disagree.',
    opts: [
      { t: 'Yes — I trust their judgment in the moment', s: { poa: 2 } },
      { t: 'Only within limits I set', s: { combined: 2 } },
      { t: 'No — my written wishes come first', s: { declaration: 1, combined: 1 } },
      { t: 'I won\'t be naming anyone', s: { declaration: 2 } },
    ],
  },
];

const QUIZ_RESULTS = {
  combined:    { name: 'Combined form', steps: '11 steps', tagline: 'Agents + treatment preferences. The most flexible — and the most common choice.' },
  declaration: { name: 'Declaration only', steps: '9 steps', tagline: 'Your treatment wishes in writing. Providers follow them; no agent named.' },
  poa:         { name: 'Power of Attorney only', steps: '6 steps', tagline: 'You name people to decide for you; they choose treatment in the moment.' },
};

function ScrQuiz() {
  const { palette: p } = React.useContext(MHADContext);
  const [step, setStep] = React.useState(0);          // 0..3 questions, 4 = result
  const [answers, setAnswers] = React.useState([null, null, null, null]);

  const totals = React.useMemo(() => {
    const t = { combined: 0, declaration: 0, poa: 0 };
    answers.forEach((ai, qi) => {
      if (ai == null) return;
      const s = QUIZ_QUESTIONS[qi].opts[ai].s;
      Object.keys(s).forEach((k) => { t[k] += s[k]; });
    });
    return t;
  }, [answers]);

  const sum = totals.combined + totals.declaration + totals.poa;
  const winner = sum === 0 ? 'combined'
    : Object.keys(totals).reduce((a, b) => totals[a] >= totals[b] ? a : b);
  const confidence = sum === 0 ? 0 : Math.round((totals[winner] / sum) * 100);

  const pick = (qi, ai) => {
    const next = [...answers]; next[qi] = ai; setAnswers(next);
    setTimeout(() => setStep((s) => Math.min(s + 1, 4)), 220);
  };

  // ---- Result screen ----
  if (step === 4) {
    const r = QUIZ_RESULTS[winner];
    return (
      <Screen>
        <CrisisBar compact />
        <div style={{ padding: '8px 22px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <span onClick={() => setStep(3)} style={{ fontSize: 13, color: p.primary, fontWeight: 600, display: 'flex', alignItems: 'center', gap: 4, cursor: 'pointer' }}>
            <Icon d="M15 18l-6-6 6-6" size={16} /> Back
          </span>
          <span style={{ fontSize: 13, color: p.textMuted, fontWeight: 500, fontFamily: MONO }}>DONE</span>
        </div>

        <div style={{ padding: '20px 22px 24px' }}>
          <SectionLabel style={{ color: p.primary }}>● Your match</SectionLabel>
          <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 40, margin: '6px 0 4px', fontWeight: 400, letterSpacing: -0.6, lineHeight: 1 }}>
            {r.name}.
          </h1>
          <p style={{ fontSize: 14, color: p.textMuted, margin: 0, lineHeight: 1.5 }}>{r.tagline}</p>

          {/* Confidence meter */}
          <div style={{ marginTop: 22, background: p.card, border: `1px solid ${p.border}`, borderRadius: 14, padding: 16 }}>
            <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
              <SectionLabel>How sure we are</SectionLabel>
              <span style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 26, color: p.primary, lineHeight: 1 }}>{confidence}%</span>
            </div>
            {/* Stacked bar across the three types */}
            <div style={{ display: 'flex', height: 10, borderRadius: 100, overflow: 'hidden', marginTop: 12, background: p.surface, gap: 2 }}>
              {['combined', 'declaration', 'poa'].map((k) => (
                <div key={k} style={{
                  width: `${sum === 0 ? 33.3 : (totals[k] / sum) * 100}%`,
                  background: k === winner ? p.primary : p.primaryLight,
                  transition: 'width 0.3s',
                }} />
              ))}
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 8, fontFamily: MONO, fontSize: 9.5, color: p.textMuted, letterSpacing: 0.3 }}>
              <span>COMBINED {totals.combined}</span>
              <span>DECLARATION {totals.declaration}</span>
              <span>POA {totals.poa}</span>
            </div>
            {confidence < 50 && (
              <div style={{ fontSize: 11.5, color: p.textMuted, marginTop: 10, lineHeight: 1.4, fontStyle: 'italic' }}>
                It's close — your answers point a few ways. Combined keeps every option open, so we suggest starting there.
              </div>
            )}
          </div>

          {/* What you get */}
          <div style={{ marginTop: 14, display: 'flex', alignItems: 'center', gap: 10, padding: '12px 14px', background: p.primaryTint, border: `1px solid ${p.primaryLight}`, borderRadius: 12 }}>
            <FileText size={16} stroke={p.primary} />
            <span style={{ flex: 1, fontSize: 13, color: p.text, fontWeight: 600 }}>{r.name} · {r.steps}</span>
            <span style={{ fontSize: 11.5, color: p.textMuted, fontFamily: MONO }}>~20 MIN</span>
          </div>

          <div style={{ display: 'flex', gap: 10, marginTop: 18, alignItems: 'center' }}>
            <Btn kind="ghost" onClick={() => { setAnswers([null, null, null, null]); setStep(0); }}>Retake</Btn>
            <div style={{ flex: 1 }} />
            <Btn kind="primary" trailing={<Arrow size={16} />}>Start {r.name}</Btn>
          </div>
        </div>
      </Screen>
    );
  }

  // ---- Question screen ----
  const Q = QUIZ_QUESTIONS[step];
  const chosen = answers[step];
  return (
    <Screen>
      <CrisisBar compact />
      <div style={{ padding: '8px 22px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <span onClick={() => setStep((s) => Math.max(s - 1, 0))} style={{ fontSize: 13, color: p.primary, fontWeight: 600, display: 'flex', alignItems: 'center', gap: 4, cursor: 'pointer' }}>
          <Icon d="M15 18l-6-6 6-6" size={16} /> Back
        </span>
        <span style={{ fontSize: 13, color: p.textMuted, fontWeight: 500, fontFamily: MONO }}>{step + 1} / 4</span>
      </div>
      <StepDots n={step + 1} total={4} />

      <div style={{ padding: '24px 22px 100px' }}>
        <SectionLabel>Help me choose · question {step + 1} of 4</SectionLabel>
        <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 34, margin: '6px 0 6px', fontWeight: 400, letterSpacing: -0.5, lineHeight: 1.1 }}>
          {Q.q}
        </h1>
        <p style={{ fontSize: 13.5, color: p.textMuted, margin: 0, lineHeight: 1.5 }}>{Q.hint}</p>

        <div style={{ height: 22 }} />
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {Q.opts.map((o, i) => {
            const sel = chosen === i;
            return (
              <div key={i} onClick={() => pick(step, i)} style={{
                background: sel ? p.primaryTint : p.card,
                border: `2px solid ${sel ? p.primary : p.border}`,
                borderRadius: TOK.rCard, padding: 14, cursor: 'pointer',
                display: 'flex', alignItems: 'flex-start', gap: 12,
              }}>
                <div style={{
                  width: 20, height: 20, borderRadius: 100, flexShrink: 0, marginTop: 1,
                  border: `2px solid ${sel ? p.primary : p.border}`,
                  background: sel ? p.primary : 'transparent',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  {sel && <div style={{ width: 7, height: 7, borderRadius: 100, background: p.onPrimary }} />}
                </div>
                <div style={{ flex: 1, fontSize: 14, fontWeight: 600, lineHeight: 1.35 }}>{o.t}</div>
              </div>
            );
          })}
        </div>

        {/* Running confidence preview after first answer */}
        {sum > 0 && (
          <>
            <div style={{ height: 18 }} />
            <div style={{ background: p.card, border: `1px solid ${p.border}`, borderRadius: 12, padding: 14 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
                <Sparkles size={14} stroke={p.primary} />
                <SectionLabel>Leaning toward</SectionLabel>
                <div style={{ flex: 1 }} />
                <span style={{ fontSize: 13, fontWeight: 700, color: p.text }}>{QUIZ_RESULTS[winner].name}</span>
              </div>
              <div style={{ height: 4, background: p.border, borderRadius: 100, overflow: 'hidden' }}>
                <div style={{ height: '100%', width: `${confidence}%`, background: p.primary, borderRadius: 100, transition: 'width 0.3s' }} />
              </div>
              <div style={{ fontSize: 10.5, color: p.textMuted, marginTop: 6, fontFamily: MONO, letterSpacing: 0.4 }}>
                {confidence}% CONFIDENT · {4 - answers.filter((a) => a != null).length} MORE QUESTION{4 - answers.filter((a) => a != null).length === 1 ? '' : 'S'}
              </div>
            </div>
          </>
        )}
      </div>

      <BottomBar />
    </Screen>
  );
}

// ─── X · Coverage audit artboard (for the design canvas) ───────────────
function CoverageAudit() {
  const { palette: p } = React.useContext(MHADContext);

  const rows = [
    { group: 'Onboarding & auth', items: [
      ['Welcome', 'm-welcome', true],
      ['Mode select (private / public)', 'm-mode', true],
      ['Initial disclaimer / consent', 'm-disclaimer', true],
      ['Face ID unlock', 'm-faceid', true],
      ['Public mode home', 'm-public', true, 'new'],
    ]},
    { group: 'Home & navigation', items: [
      ['Home · active draft', 'm-home', true],
      ['Home · first-time empty', 'm-empty', true],
      ['Bottom tab · Learn', 'm-learn', true],
      ['Bottom tab · Ask (AI)', 'm-ai', true],
      ['Bottom tab · Settings', 'm-settings', true],
    ]},
    { group: 'Creation flow', items: [
      ['Form-type select', 'm-formtype', true],
      ['"Help me choose" quiz', 'm-quiz', true],
      ['Camera permission prompt', 'm-permission', true, 'new'],
      ['ID scan + OCR', 'm-scan', true],
      ['Contact picker (agent)', 'm-contacts', true],
      ['Voice input recording', 'm-voice', true],
      ['Step 1 · About you', 'm-wizard-about', true],
      ['Step 2 · When this kicks in', 'm-wizard-when', true],
      ['Step 3 · People I trust', 'm-wizard-people', true],
      ['Step 4 · Guardian', 'm-wizard-guardian', true],
      ['Step 5 · Where I want care', 'm-wizard-care', true],
      ['Step 6 · Diagnoses (ICD-10)', 'm-diagnoses', true, 'new'],
      ['Step 7 · Allergies (RxTerms)', 'm-allergies', true, 'new'],
      ['Step 8 · Medications (current + prefs)', 'm-medications', true, 'new'],
      ['Step 9 · Procedures & research', 'm-wizard-procedures', true],
      ['Step 10 · Anything else', 'm-wizard-else', true],
      ['Step 11 · Review', 'm-review', true],
      ['AI consistency warning', 'm-conflict', true, 'new'],
      ['Sign & witness · summary', 'm-sign', true],
      ['Signature canvas (full)', 'm-sign-canvas', true, 'new'],
      ['Witness picker + eligibility', 'm-witness', true, 'new'],
    ]},
    { group: 'Document operations', items: [
      ['Done + wallet handoff', 'm-done', true],
      ['Add to Apple Wallet', 'm-wallet', true, 'new'],
      ['Share sheet', 'm-share', true],
      ['PDF preview (mobile)', 'm-pdf', true],
      ['Past directive detail', 'm-past', true],
      ['Wallet QR · verifier view', 'm-verify', true],
      ['Agent invite acceptance', 'm-invite', true],
      ['Data export hub', 'm-export', true, 'new'],
    ]},
    { group: 'Lifecycle', items: [
      ['Renewal nudge (30-day)', 'm-renew', true],
      ['Revocation flow', 'm-revoke', true],
    ]},
    { group: 'Learn & support', items: [
      ['Learn hub', 'm-learn', true],
      ['Article reader', 'm-article', true, 'new'],
    ]},
    { group: 'Safety', items: [
      ['Crisis sheet (988)', 'm-crisis', true],
    ]},
    { group: 'Desktop / web', items: [
      ['Dashboard', 'w-home', true],
      ['Wizard · People I trust', 'w-wizard', true],
      ['Export · PDF preview', 'w-export', true],
      ['Learn hub', 'w-learn', true],
      ['AI assistant', 'w-ai', true],
    ]},
  ];

  const totalCount = rows.reduce((n, g) => n + g.items.length, 0);
  const newCount = rows.reduce((n, g) => n + g.items.filter(i => i[3] === 'new').length, 0);

  return (
    <div style={{ background: p.scaffold, padding: '32px 40px', height: '100%', boxSizing: 'border-box', color: p.text, fontFamily: SANS, overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
      <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 24 }}>
        <div style={{ flex: 1 }}>
          <SectionLabel>Coverage audit · v2</SectionLabel>
          <h2 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 38, margin: '4px 0 4px', fontWeight: 400, letterSpacing: -0.5 }}>
            Every function — <span style={{ color: p.primary }}>drawn at least once.</span>
          </h2>
          <p style={{ fontSize: 13.5, color: p.textMuted, margin: 0, maxWidth: 620, lineHeight: 1.45 }}>
            Cross-referenced every interactive surface in the existing artboards (every nav target, settings switch, button, lifecycle hook) and ensured each has a visual home. {newCount} screens added in this pass.
          </p>
        </div>
        {/* Big stat */}
        <div style={{ display: 'flex', gap: 22, alignItems: 'baseline' }}>
          <div style={{ textAlign: 'right' }}>
            <div style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 64, color: p.primary, lineHeight: 1, letterSpacing: -2 }}>{totalCount}</div>
            <div style={{ fontFamily: MONO, fontSize: 10.5, color: p.textMuted, letterSpacing: 0.7, marginTop: 4 }}>SCREENS<br/>COVERED</div>
          </div>
          <div style={{ textAlign: 'right' }}>
            <div style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 64, color: p.text, lineHeight: 1, letterSpacing: -2 }}>+{newCount}</div>
            <div style={{ fontFamily: MONO, fontSize: 10.5, color: p.textMuted, letterSpacing: 0.7, marginTop: 4 }}>NEW IN<br/>THIS PASS</div>
          </div>
        </div>
      </div>

      <div style={{ height: 18 }} />

      {/* Grid of groups */}
      <div style={{ flex: 1, overflow: 'auto', display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 14, alignContent: 'start' }}>
        {rows.map((g) => (
          <div key={g.group} style={{
            background: p.card, border: `1px solid ${p.border}`,
            borderRadius: TOK.rCard, padding: 14,
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 10 }}>
              <SectionLabel>{g.group}</SectionLabel>
              <div style={{ flex: 1 }} />
              <span style={{ fontFamily: MONO, fontSize: 9.5, color: p.textMuted, letterSpacing: 0.4 }}>
                {g.items.length}
              </span>
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 5 }}>
              {g.items.map(([label, id, covered, flag], i) => (
                <div key={i} style={{
                  display: 'flex', alignItems: 'center', gap: 8,
                  padding: '5px 8px', borderRadius: 6,
                  background: flag === 'new' ? p.primaryTint : 'transparent',
                }}>
                  <Check size={12} sw={3} stroke={covered ? (flag === 'new' ? p.primary : p.okText) : p.textMuted} />
                  <span style={{ flex: 1, fontSize: 12, color: p.text, fontWeight: flag === 'new' ? 600 : 400, minWidth: 0, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                    {label}
                  </span>
                  {flag === 'new' && (
                    <span style={{ fontFamily: MONO, fontSize: 8.5, fontWeight: 700, color: p.primary, letterSpacing: 0.4, padding: '1px 5px', borderRadius: 3, background: '#fff', border: `1px solid ${p.primary}40` }}>NEW</span>
                  )}
                  <span style={{ fontFamily: MONO, fontSize: 9, color: p.textMuted, letterSpacing: 0.3 }}>{id}</span>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── X · Public mode home ──────────────────────────────────────────────
function ScrPublic() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <Screen>
      {/* Distinct "ephemeral" bar above the crisis bar */}
      <div style={{
        display: 'flex', alignItems: 'center', gap: 8,
        padding: '8px 16px', background: p.text, color: p.scaffold,
        fontSize: 12, fontWeight: 600,
      }}>
        <EyeOff size={13} stroke={p.scaffold} />
        <span style={{ flex: 1 }}>Public mode · nothing is saved</span>
        <span style={{ fontFamily: MONO, fontSize: 10.5, opacity: 0.7, letterSpacing: 0.5 }}>EPHEMERAL</span>
      </div>
      <CrisisBar compact />

      <div style={{ padding: '20px 22px 100px' }}>
        <SectionLabel>Saturday · May 14, 2026</SectionLabel>
        <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 38, fontWeight: 400, margin: '4px 0 0', lineHeight: 1.05, letterSpacing: -0.5 }}>
          Welcome, guest.<br/>
          <span style={{ color: p.textMuted, fontSize: 22 }}>Quick draft, no trace.</span>
        </h1>

        <div style={{ height: 22 }} />

        {/* Privacy promise hero */}
        <div style={{
          background: p.card, border: `1.5px solid ${p.text}`,
          borderRadius: TOK.rCard, padding: 18,
        }}>
          <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12 }}>
            <div style={{
              width: 44, height: 44, borderRadius: 11, flexShrink: 0,
              background: p.text, color: p.scaffold,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <EyeOff size={22} />
            </div>
            <div style={{ flex: 1 }}>
              <SectionLabel>Public mode promises</SectionLabel>
              <h2 style={{ fontSize: 17, fontWeight: 700, margin: '4px 0 6px', letterSpacing: -0.2 }}>
                Nothing leaves this session.
              </h2>
              <p style={{ fontSize: 12.5, color: p.textMuted, margin: 0, lineHeight: 1.5 }}>
                Your answers live in memory only. Close the app and they're gone.
              </p>
            </div>
          </div>
          <div style={{ height: 12 }} />
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            {[
              ['Nothing saved to disk', true],
              ['No analytics, no tracking', true],
              ['Cleared when you close or lock the tab', true],
              ['AI assistant is off by default', true],
            ].map(([l, ok], i) => (
              <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 8, fontSize: 12.5, color: p.text }}>
                <Check size={13} sw={3} stroke={p.okText} /> {l}
              </div>
            ))}
          </div>
        </div>

        <div style={{ height: 14 }} />
        <Btn kind="primary" size="lg" full trailing={<Arrow size={18} />}>Start a one-time directive</Btn>
        <div style={{ height: 8 }} />
        <Btn kind="outline" full leading={<Lock size={16} />}>Switch to private mode</Btn>

        <div style={{ height: 22 }} />
        <SectionLabel>What you can still do</SectionLabel>
        <div style={{ marginTop: 8, display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          {[
            { icon: <FileText size={16} />, t: 'Fill the form', s: 'All 11 steps' },
            { icon: <Download size={16} />, t: 'Print or save PDF', s: 'To your device' },
            { icon: <Share size={16} />, t: 'Share once', s: 'Email or AirDrop' },
            { icon: <Book size={16} />, t: 'Read Learn hub', s: 'No login needed' },
          ].map((it, i) => (
            <div key={i} style={{
              background: p.card, border: `1px solid ${p.border}`, borderRadius: 12,
              padding: 12,
            }}>
              <div style={{ width: 28, height: 28, borderRadius: 7, background: p.primaryTint, color: p.primary, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 8 }}>{it.icon}</div>
              <div style={{ fontSize: 13, fontWeight: 600 }}>{it.t}</div>
              <div style={{ fontSize: 11, color: p.textMuted }}>{it.s}</div>
            </div>
          ))}
        </div>
      </div>
    </Screen>
  );
}

// ─── X · Wallet card · verifier view ───────────────────────────────────
// What a paramedic / ER nurse sees when they scan the QR on the wallet card.
function ScrVerify() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <Screen scroll={false} style={{ background: p.text }}>
      {/* Dark verifier surface — this isn't the principal's phone */}
      <div style={{ height: STATUSBAR_H }} />
      <div style={{ padding: '12px 18px', display: 'flex', alignItems: 'center', gap: 10 }}>
        <div style={{
          width: 30, height: 30, borderRadius: 7,
          background: p.scaffold, color: p.text,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontFamily: SERIF, fontStyle: 'italic', fontWeight: 400, fontSize: 17,
        }}>m</div>
        <div style={{ flex: 1, color: p.scaffold }}>
          <div style={{ fontFamily: MONO, fontSize: 9.5, opacity: 0.6, letterSpacing: 0.6 }}>PA MHAD · FROM WALLET QR</div>
          <div style={{ fontSize: 13, fontWeight: 700 }}>Provider view</div>
        </div>
        <X size={20} stroke={p.scaffold} />
      </div>

      {/* Status banner */}
      <div style={{
        margin: '4px 18px 14px', padding: '12px 14px',
        background: p.okBg, border: `1px solid ${p.okBorder}`,
        borderRadius: 12, display: 'flex', alignItems: 'center', gap: 10,
      }}>
        <div style={{
          width: 32, height: 32, borderRadius: 100,
          background: p.okText, color: '#fff',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <Check size={18} sw={3.5} stroke="#fff" />
        </div>
        <div style={{ flex: 1, color: p.okText }}>
          <div style={{ fontSize: 14, fontWeight: 700 }}>Signed &amp; in effect</div>
          <div style={{ fontSize: 11.5, opacity: 0.85 }}>Signed May 14 2026 · expires May 14 2028</div>
        </div>
        <span style={{ fontFamily: MONO, fontSize: 10, fontWeight: 700, color: p.okText, letterSpacing: 0.5, background: '#fff', padding: '3px 7px', borderRadius: 4, border: `1px solid ${p.okBorder}` }}>ACT 194</span>
      </div>

      <div style={{ overflow: 'auto', padding: '0 18px 22px', height: `calc(100% - ${STATUSBAR_H + 56 + 70 + HOME_H}px)` }}>
        {/* Principal */}
        <div style={{ background: p.scaffold, borderRadius: TOK.rCard, padding: 16 }}>
          <SectionLabel>Principal</SectionLabel>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginTop: 6 }}>
            <div style={{
              width: 48, height: 48, borderRadius: 100,
              background: p.primary, color: p.onPrimary,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontFamily: SANS, fontWeight: 700, fontSize: 16,
            }}>AK</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 17, fontWeight: 700, color: p.text }}>Alex M. Kowalski</div>
              <div style={{ fontSize: 12, color: p.textMuted, fontFamily: MONO, letterSpacing: 0.3 }}>DOB 06/14/1989 · F · ALLEGHENY CO PA</div>
            </div>
          </div>

          <div style={{ height: 14, borderTop: `1px dashed ${p.border}`, marginTop: 14 }} />
          <SectionLabel>Call first</SectionLabel>
          <div style={{ marginTop: 6, display: 'flex', alignItems: 'center', gap: 10, padding: '12px 12px', background: p.primaryTint, border: `1px solid ${p.primary}30`, borderRadius: 10 }}>
            <div style={{ width: 36, height: 36, borderRadius: 100, background: p.primary, color: p.onPrimary, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Phone size={16} stroke={p.onPrimary} />
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 13, fontWeight: 700, color: p.text }}>Jordan Lee — sister, primary agent</div>
              <div style={{ fontSize: 11.5, color: p.textMuted, fontFamily: MONO, letterSpacing: 0.4 }}>(412) 555-0188</div>
            </div>
            <Arrow size={16} stroke={p.primary} />
          </div>
        </div>

        {/* Top-of-mind clinical flags */}
        <div style={{ height: 12 }} />
        <SectionLabel style={{ color: p.scaffold }}>Treatment flags</SectionLabel>
        <div style={{ marginTop: 8, display: 'flex', flexDirection: 'column', gap: 6 }}>
          {[
            { tone: 'crisis', t: 'Avoid: Haloperidol (Haldol)', s: 'Severe akathisia reaction · 2021' },
            { tone: 'crisis', t: 'No ECT consent on file', s: 'Cannot proceed without principal/agent' },
            { tone: 'warn', t: 'Drug trials require agent consent', s: 'Jordan Lee' },
            { tone: 'ok', t: 'Restraints: minimum-use preference', s: 'See full directive · sec. 8' },
          ].map((f, i) => {
            const bg = f.tone === 'crisis' ? p.crisisBg : f.tone === 'warn' ? p.warnBg : p.okBg;
            const fg = f.tone === 'crisis' ? p.crisisText : f.tone === 'warn' ? p.warnText : p.okText;
            const border = f.tone === 'crisis' ? p.crisisBorder : f.tone === 'warn' ? p.warnBorder : p.okBorder;
            return (
              <div key={i} style={{
                background: bg, border: `1px solid ${border}`,
                borderRadius: 10, padding: '10px 12px',
                display: 'flex', alignItems: 'flex-start', gap: 10, color: fg,
              }}>
                {f.tone === 'ok'
                  ? <Check size={15} sw={3} stroke={fg} />
                  : <AlertTri size={15} stroke={fg} />}
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 13, fontWeight: 700 }}>{f.t}</div>
                  <div style={{ fontSize: 11, opacity: 0.85, marginTop: 1 }}>{f.s}</div>
                </div>
              </div>
            );
          })}
        </div>

        <div style={{ height: 12 }} />
        <button style={{
          width: '100%', background: p.scaffold,
          color: p.text, border: 'none', borderRadius: 12,
          padding: '13px', fontSize: 13.5, fontWeight: 600, fontFamily: SANS,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
        }}>
          <FileText size={15} stroke={p.text} /> Open full directive (6 pp)
        </button>

        <div style={{ height: 10 }} />
        <p style={{ fontSize: 10, color: 'rgba(255,255,255,0.55)', textAlign: 'center', margin: 0, fontFamily: MONO, letterSpacing: 0.5, lineHeight: 1.5 }}>
          READ FROM THE QR ITSELF · NO INTERNET NEEDED · SIGNED BY THE HOLDER'S DEVICE
        </p>
      </div>
    </Screen>
  );
}

// ─── X · Camera capture (multi-target: ID / meds / conditions / other) ─
// User picks what they're photographing; AI extracts the fields it sees and
// routes them to the matching wizard steps. Same flow, four targets.
function ScrScanID() {
  const { palette: p } = React.useContext(MHADContext);

  // Mock target for this artboard: prescription label.
  // (Other targets — id / conditions / other — switch the inner frame.)
  const target = 'meds';

  const TARGETS = [
    { id: 'id',         label: 'ID',         fills: 'Name · DOB · address',     icon: <Icon size={13} sw={2}><rect x="3" y="5" width="18" height="14" rx="2"/><circle cx="9" cy="12" r="2"/><path d="M14 10h5M14 14h3"/></Icon> },
    { id: 'meds',       label: 'Rx label',   fills: 'Drug · dose · schedule',   icon: <Icon size={13} sw={2}><rect x="4" y="3" width="16" height="18" rx="2"/><path d="M8 8h8M8 12h8M8 16h5"/></Icon> },
    { id: 'conditions', label: 'Conditions', fills: 'Diagnoses · allergies',    icon: <Icon size={13} sw={2}><path d="M9 2h6v3H9zM6 5h12v17H6zM9 11h6M9 15h6"/></Icon> },
    { id: 'other',      label: 'Other',      fills: 'Notes, old directive…',    icon: <Icon size={13} sw={2}><circle cx="12" cy="12" r="9"/><path d="M9.5 9a2.5 2.5 0 1 1 4 2c-1 .8-1.5 1.5-1.5 2.5M12 17.5h.01"/></Icon> },
  ];
  const current = TARGETS.find(t => t.id === target);

  return (
    <Screen scroll={false} style={{ background: '#000' }}>
      <div style={{ height: STATUSBAR_H }} />

      {/* Top bar */}
      <div style={{ padding: '8px 18px', display: 'flex', alignItems: 'center', gap: 10, color: '#fff' }}>
        <X size={22} stroke="#fff" />
        <div style={{ flex: 1, textAlign: 'center' }}>
          <div style={{ fontSize: 14, fontWeight: 700 }}>Snap to fill</div>
          <div style={{ fontSize: 10, color: 'rgba(255,255,255,0.6)', fontFamily: MONO, letterSpacing: 0.5 }}>
            AI WILL READ THIS PHOTO
          </div>
        </div>
        <Icon size={20} stroke="#fff"><path d="M21 6h-3.2l-1.4-2.1A2 2 0 0 0 14.7 3H9.3a2 2 0 0 0-1.7.9L6.2 6H3a2 2 0 0 0-2 2v11a2 2 0 0 0 2 2h18a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2z"/><circle cx="12" cy="13" r="4"/></Icon>
      </div>

      {/* Target picker pills */}
      <div style={{ padding: '4px 14px 8px', display: 'flex', gap: 6, overflowX: 'auto' }}>
        {TARGETS.map((t) => {
          const active = t.id === target;
          return (
            <div key={t.id} style={{
              display: 'inline-flex', alignItems: 'center', gap: 5, flexShrink: 0,
              padding: '7px 11px', borderRadius: 100,
              background: active ? '#fff' : 'rgba(255,255,255,0.10)',
              color: active ? p.primaryDark : '#fff',
              border: active ? 'none' : '1px solid rgba(255,255,255,0.18)',
              fontSize: 12, fontWeight: 700,
            }}>
              {t.icon}<span>{t.label}</span>
            </div>
          );
        })}
      </div>

      {/* Camera viewport */}
      <div style={{
        flex: 1, position: 'relative', overflow: 'hidden',
        background: 'radial-gradient(ellipse at center, #2a2520 0%, #0a0908 100%)',
        height: 360, margin: '4px 18px 0', borderRadius: 14,
      }}>
        {/* Mock subject in frame — Rx label */}
        <div style={{
          position: 'absolute', top: '50%', left: '50%', transform: 'translate(-50%, -50%) rotate(-1deg)',
          width: 240, height: 220, borderRadius: 6,
          background: 'linear-gradient(180deg, #fff 0%, #f5f1e8 100%)',
          boxShadow: '0 8px 28px rgba(0,0,0,0.6)',
          padding: '12px 14px', color: '#2a2520', fontFamily: SANS, overflow: 'hidden',
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', borderBottom: '1px solid #d8d4c8', paddingBottom: 4 }}>
            <div style={{ fontSize: 8, fontWeight: 700, letterSpacing: 0.4 }}>RITE AID PHARMACY · #12498</div>
            <div style={{ fontFamily: MONO, fontSize: 7, opacity: 0.7 }}>Rx 4729183</div>
          </div>
          <div style={{ marginTop: 6, fontSize: 8.5, lineHeight: 1.5 }}>
            <div style={{ fontWeight: 700, fontSize: 10 }}>KOWALSKI, ALEX M.</div>
            <div style={{ opacity: 0.75 }}>Dr. R. Patel · UPMC</div>
          </div>
          <div style={{
            marginTop: 8, padding: 6, background: '#fffbf0',
            border: '1px solid #e3dcc0', borderRadius: 3,
          }}>
            <div style={{ fontWeight: 700, fontSize: 12 }}>SERTRALINE 100MG</div>
            <div style={{ fontSize: 9, marginTop: 2 }}>Take 1 tablet by mouth daily in morning</div>
          </div>
          <div style={{ marginTop: 6, fontSize: 7.5, lineHeight: 1.5, opacity: 0.85 }}>
            <div>Qty 30 · Refills 3 · Exp 11/26</div>
            <div>Take with food. May cause drowsiness.</div>
          </div>
          {/* fake barcode */}
          <div style={{ display: 'flex', gap: 1, marginTop: 6, height: 14 }}>
            {Array.from({ length: 38 }).map((_, i) => (
              <div key={i} style={{ width: i % 3 ? 1.5 : 2.5, background: '#1a1a1a', height: '100%' }} />
            ))}
          </div>
        </div>

        {/* Corner frame brackets */}
        {['tl', 'tr', 'bl', 'br'].map((k, i) => {
          const isLeft = k.includes('l');
          const isTop = k.includes('t');
          return (
            <div key={i} style={{
              position: 'absolute', width: 28, height: 28,
              top: isTop ? 16 : 'auto', bottom: isTop ? 'auto' : 16,
              left: isLeft ? 16 : 'auto', right: isLeft ? 'auto' : 16,
              borderTop: isTop ? '3px solid #fff' : 'none',
              borderBottom: !isTop ? '3px solid #fff' : 'none',
              borderLeft: isLeft ? '3px solid #fff' : 'none',
              borderRight: !isLeft ? '3px solid #fff' : 'none',
              borderRadius: 4,
            }} />
          );
        })}

        {/* AI-callout boxes — show what's being detected */}
        <div style={{
          position: 'absolute', top: 78, left: 78, width: 130, height: 18,
          border: `1.5px solid ${p.primary}`, borderRadius: 3,
          boxShadow: `0 0 0 1px rgba(0,0,0,0.4) inset, 0 0 14px ${p.primary}55`,
        }}>
          <div style={{
            position: 'absolute', top: -16, left: -1, fontFamily: MONO,
            fontSize: 8.5, fontWeight: 700, letterSpacing: 0.4,
            color: '#000', background: p.primary, padding: '2px 5px', borderRadius: 2,
          }}>DRUG</div>
        </div>
        <div style={{
          position: 'absolute', top: 102, left: 78, width: 130, height: 14,
          border: `1.5px solid ${p.primary}`, borderRadius: 3,
        }}>
          <div style={{
            position: 'absolute', bottom: -15, left: -1, fontFamily: MONO,
            fontSize: 8.5, fontWeight: 700, letterSpacing: 0.4,
            color: '#000', background: p.primary, padding: '2px 5px', borderRadius: 2,
          }}>DOSE · SCHEDULE</div>
        </div>

        {/* Scanning bar */}
        <div style={{
          position: 'absolute', left: 16, right: 16, top: '50%',
          height: 2, background: `linear-gradient(to right, transparent, ${p.primary}, transparent)`,
          boxShadow: `0 0 12px ${p.primary}`,
        }} />

        {/* Status */}
        <div style={{
          position: 'absolute', left: 16, right: 16, bottom: 14,
          background: 'rgba(0,0,0,0.5)', borderRadius: 100,
          padding: '8px 14px', backdropFilter: 'blur(8px)',
          color: '#fff', fontSize: 12, fontWeight: 600,
          display: 'flex', alignItems: 'center', gap: 8, justifyContent: 'center',
        }}>
          <div style={{ width: 8, height: 8, borderRadius: 100, background: p.primary, boxShadow: `0 0 6px ${p.primary}` }} />
          <span>Reading {current.fills.toLowerCase()}… hold steady</span>
        </div>
      </div>

      {/* Footer */}
      <div style={{
        padding: '12px 18px 40px', display: 'flex', alignItems: 'center', gap: 12,
        justifyContent: 'space-between',
      }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 2, color: '#fff', flex: '0 0 auto', alignItems: 'center' }}>
          <Icon size={20} stroke="#fff" sw={2}><rect x="3" y="5" width="18" height="14" rx="2"/><circle cx="12" cy="12" r="3"/></Icon>
          <span style={{ fontSize: 9.5, fontFamily: MONO, letterSpacing: 0.4 }}>UPLOAD</span>
        </div>
        <div style={{ width: 64, height: 64, borderRadius: 100, border: '4px solid #fff', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <div style={{ width: 50, height: 50, borderRadius: 100, background: '#fff' }} />
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 2, color: '#fff', flex: '0 0 auto', alignItems: 'center' }}>
          <Lock size={18} stroke="#fff" />
          <span style={{ fontSize: 9.5, fontFamily: MONO, letterSpacing: 0.4 }}>NOT SAVED</span>
        </div>
      </div>
    </Screen>
  );
}

// ─── X · Snap-to-fill review (AI extracted, user confirms) ─────────────
// After capture, AI shows what it read and which wizard steps it will fill.
function ScrSnapReview() {
  const { palette: p } = React.useContext(MHADContext);

  return (
    <Screen>
      <CrisisBar compact />

      <div style={{ padding: '12px 22px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <span style={{ fontSize: 13, color: p.primary, fontWeight: 600, display: 'flex', alignItems: 'center', gap: 4 }}>
          <Icon d="M15 18l-6-6 6-6" size={16} /> Retake
        </span>
        <span style={{
          fontSize: 10.5, fontFamily: MONO, color: p.primary, letterSpacing: 0.6, fontWeight: 700,
          display: 'inline-flex', alignItems: 'center', gap: 5,
          padding: '4px 9px', background: p.primaryTint, borderRadius: 100,
        }}>
          <Sparkles size={11} stroke={p.primary} /> AI READ THIS PHOTO
        </span>
      </div>

      <div style={{ padding: '14px 22px 32px' }}>
        <SectionLabel>Step 8 of 11 · Medications</SectionLabel>
        <h2 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 32, margin: '4px 0 4px', fontWeight: 400, letterSpacing: -0.4, lineHeight: 1.05 }}>
          Here's what we read.
        </h2>
        <p style={{ fontSize: 13, color: p.textMuted, margin: 0, lineHeight: 1.5 }}>
          Tap any field to fix it. Nothing is added to your directive until you confirm.
        </p>

        {/* Photo thumbnail + provenance */}
        <div style={{
          marginTop: 16, display: 'flex', gap: 12,
          background: p.card, border: `1px solid ${p.border}`, borderRadius: TOK.rCard, padding: 12,
        }}>
          <div style={{
            width: 76, height: 90, borderRadius: 8, flexShrink: 0,
            background: 'linear-gradient(180deg, #fff 0%, #f5f1e8 100%)',
            border: `1px solid ${p.border}`, position: 'relative', overflow: 'hidden',
            padding: '6px 7px', color: '#2a2520', fontSize: 5.5, lineHeight: 1.4,
          }}>
            <div style={{ fontWeight: 700, fontSize: 6 }}>RITE AID #12498</div>
            <div style={{ marginTop: 3, opacity: 0.8 }}>KOWALSKI, ALEX</div>
            <div style={{
              marginTop: 4, padding: 3, background: '#fffbf0',
              border: '0.5px solid #e3dcc0', borderRadius: 1,
            }}>
              <div style={{ fontWeight: 700, fontSize: 7 }}>SERTRALINE 100MG</div>
              <div style={{ fontSize: 5 }}>1 tab daily AM</div>
            </div>
            <div style={{ display: 'flex', gap: 0.5, marginTop: 4, height: 6 }}>
              {Array.from({ length: 22 }).map((_, i) => (
                <div key={i} style={{ width: 0.8, background: '#1a1a1a', height: '100%' }} />
              ))}
            </div>
          </div>
          <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
            <div style={{ fontFamily: MONO, fontSize: 10, color: p.primary, fontWeight: 700, letterSpacing: 0.6 }}>SOURCE</div>
            <div style={{ fontSize: 13.5, fontWeight: 700, marginTop: 2 }}>Prescription label · captured just now</div>
            <div style={{ fontSize: 11.5, color: p.textMuted, marginTop: 4, lineHeight: 1.4 }}>
              Confidence <strong style={{ color: p.text }}>94%</strong> · 4 fields detected
            </div>
            <div style={{ display: 'flex', gap: 6, marginTop: 8 }}>
              <span style={{ fontSize: 11, fontWeight: 700, color: p.primary, cursor: 'pointer' }}>View full text</span>
              <span style={{ fontSize: 11, color: p.textMuted }}>·</span>
              <span style={{ fontSize: 11, fontWeight: 700, color: p.crisisAccent, cursor: 'pointer' }}>Delete photo</span>
            </div>
          </div>
        </div>

        {/* Extracted fields */}
        <div style={{ height: 16 }} />
        <SectionLabel>Add to your directive</SectionLabel>

        <div style={{ marginTop: 8, background: p.card, border: `1px solid ${p.border}`, borderRadius: TOK.rCard, padding: '4px 14px' }}>
          {[
            { field: 'Current medication', value: 'Sertraline 100mg', sub: 'Take 1 tablet daily in the morning', target: 'Step 8 · Medications', ok: true },
            { field: 'Prescribed by',      value: 'Dr. R. Patel · UPMC',  sub: 'Pulled from "DOCTOR" line',                target: 'Step 8 · Medications', ok: true },
            { field: 'Refills',            value: '3 remaining · expires 11/2026', sub: 'For your records — not in directive', target: 'Not added',           ok: false },
            { field: 'Pharmacy',           value: 'Rite Aid #12498',      sub: '5837 Forbes Ave, Pittsburgh',                target: 'Step 10 · Anything else', ok: true },
          ].map((row, i, arr) => (
            <div key={i} style={{
              display: 'flex', gap: 12, padding: '12px 0',
              borderBottom: i < arr.length - 1 ? `1px solid ${p.border}` : 'none',
            }}>
              <div style={{
                width: 22, height: 22, borderRadius: 6, flexShrink: 0, marginTop: 1,
                background: row.ok ? p.primary : p.surface,
                color: row.ok ? p.onPrimary : p.textMuted,
                border: row.ok ? 'none' : `1.5px solid ${p.border}`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                {row.ok ? <Check size={13} sw={3} stroke={p.onPrimary} /> : <X size={11} sw={2.5} stroke={p.textMuted} />}
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', gap: 8 }}>
                  <div style={{ fontSize: 11, fontFamily: MONO, color: p.textMuted, letterSpacing: 0.5, textTransform: 'uppercase', fontWeight: 600 }}>{row.field}</div>
                  <div style={{ fontSize: 10, fontFamily: MONO, color: row.ok ? p.primary : p.textMuted, fontWeight: 700, letterSpacing: 0.4, textAlign: 'right', flexShrink: 0 }}>
                    {row.ok ? '→ ' + row.target : row.target}
                  </div>
                </div>
                <div style={{ fontSize: 14, fontWeight: 600, color: row.ok ? p.text : p.textMuted, marginTop: 2, textDecoration: row.ok ? 'none' : 'line-through' }}>
                  {row.value}
                </div>
                <div style={{ fontSize: 11.5, color: p.textMuted, marginTop: 1, lineHeight: 1.35 }}>{row.sub}</div>
              </div>
              <div style={{ alignSelf: 'center' }}>
                <Edit size={14} stroke={p.textMuted} />
              </div>
            </div>
          ))}
        </div>

        {/* Suggested follow-up */}
        <div style={{
          marginTop: 14, padding: 12, display: 'flex', gap: 10,
          background: p.primaryTint, border: `1px solid ${p.primaryLight}`, borderRadius: 12,
        }}>
          <Sparkles size={16} stroke={p.primary} />
          <div style={{ flex: 1, fontSize: 12.5, color: p.text, lineHeight: 1.45 }}>
            <strong>Have a reaction history?</strong> Snap a note or your allergy bracelet next — I'll add what to avoid on the same step.
          </div>
        </div>

        <div style={{ height: 14 }} />
        {/* Privacy reassurance */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '10px 12px', background: p.surface, border: `1px solid ${p.border}`, borderRadius: 10 }}>
          <Lock size={14} stroke={p.textMuted} />
          <span style={{ fontSize: 11.5, color: p.textMuted, flex: 1, lineHeight: 1.4 }}>
            Your photo was sent to the AI to read, then discarded. Nothing is stored after you confirm or discard.
          </span>
        </div>

        <div style={{ height: 16 }} />
        <div style={{ display: 'flex', gap: 8 }}>
          <Btn kind="outline" style={{ flex: 1 }}>Discard</Btn>
          <Btn kind="primary" style={{ flex: 2 }} trailing={<Arrow size={14} />}>Add 3 fields</Btn>
        </div>
      </div>
    </Screen>
  );
}

// ─── X · Article reader (Learn) ────────────────────────────────────────
function ScrArticle() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <Screen>
      {/* Reading progress bar */}
      <div style={{
        position: 'absolute', top: STATUSBAR_H, left: 0, right: 0,
        height: 2, background: p.border, zIndex: 5,
      }}>
        <div style={{ height: '100%', width: '34%', background: p.primary }} />
      </div>

      {/* Top bar */}
      <div style={{ height: STATUSBAR_H }} />
      <div style={{ padding: '10px 18px', display: 'flex', alignItems: 'center', gap: 10 }}>
        <Icon d="M15 18l-6-6 6-6" size={18} stroke={p.text} />
        <div style={{ flex: 1 }}>
          <div style={{ fontFamily: MONO, fontSize: 10, color: p.textMuted, letterSpacing: 0.6 }}>LEARN · 4 MIN</div>
        </div>
        <Bookmark size={18} stroke={p.text} />
        <Share size={18} stroke={p.text} />
      </div>

      <div style={{ overflow: 'auto', padding: '8px 22px 60px', height: `calc(100% - ${STATUSBAR_H + 56 + HOME_H}px)` }}>
        <SectionLabel>Most read · this week</SectionLabel>
        <h1 style={{
          fontFamily: SERIF, fontStyle: 'italic', fontSize: 42,
          margin: '6px 0 8px', fontWeight: 400, letterSpacing: -0.8, lineHeight: 1.02,
        }}>
          What is an MHAD, really?
        </h1>
        <p style={{ fontSize: 14, color: p.textMuted, margin: 0, lineHeight: 1.5, fontFamily: SERIF, fontStyle: 'italic' }}>
          The 4-minute version. Plain language, no legalese.
        </p>

        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 14 }}>
          <div style={{ width: 28, height: 28, borderRadius: 100, background: p.primaryLight, color: p.onPrimaryLight, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 11, fontWeight: 700 }}>P&amp;A</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 12, fontWeight: 600 }}>PA Protection &amp; Advocacy</div>
            <div style={{ fontSize: 10.5, color: p.textMuted, fontFamily: MONO, letterSpacing: 0.4 }}>FROM THE OFFICIAL BOOKLET</div>
          </div>
        </div>

        <div style={{ height: 22, borderTop: `1px solid ${p.border}`, marginTop: 18 }} />

        {/* Body */}
        <div style={{ fontSize: 15, color: p.text, lineHeight: 1.65 }}>
          <p style={{ margin: '0 0 14px' }}>
            A Mental Health Advance Directive — MHAD — is a document you write while you're well that says how you want to be treated if a mental-health crisis ever leaves you unable to decide for yourself.
          </p>

          {/* Pull-quote */}
          <div style={{
            margin: '20px -6px', padding: '14px 18px',
            borderLeft: `3px solid ${p.primary}`,
          }}>
            <div style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 22, color: p.primaryDark, lineHeight: 1.3 }}>
              "It's your voice — written in advance, kept safe, honored when you can't speak for yourself."
            </div>
          </div>

          <p style={{ margin: '0 0 14px' }}>
            Under PA Act 194 of 2004, doctors and hospitals must follow what's in your directive. Two things matter most: you sign it while you have capacity, and two adult witnesses sign with you.
          </p>

          <h3 style={{ fontFamily: SANS, fontSize: 18, fontWeight: 700, margin: '20px 0 8px', letterSpacing: -0.2 }}>
            Two things it does
          </h3>
          <ol style={{ paddingLeft: 18, margin: '0 0 14px' }}>
            <li style={{ marginBottom: 6 }}><strong>Names someone you trust</strong> — your "agent" — to speak for you.</li>
            <li><strong>Documents what you want</strong> — and don't want — for facilities, medications, procedures.</li>
          </ol>

          <div style={{
            background: p.primaryTint, border: `1px solid ${p.primary}25`,
            borderRadius: 12, padding: 14, marginTop: 18,
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 6 }}>
              <Sparkles size={14} stroke={p.primary} />
              <span style={{ fontFamily: MONO, fontSize: 10, fontWeight: 700, color: p.primary, letterSpacing: 0.6 }}>TRY IT</span>
              <span style={{ fontFamily: MONO, fontSize: 8.5, color: p.textMuted, letterSpacing: 0.4, marginLeft: 'auto' }}>PER-ARTICLE FLAG</span>
            </div>
            <div style={{ fontSize: 13, color: p.text, lineHeight: 1.5 }}>
              Most people draft theirs in about 15 minutes. You can save and come back.
            </div>
            <div style={{ height: 10 }} />
            <Btn kind="primary" size="sm" trailing={<Arrow size={13} />}>Start mine</Btn>
          </div>
        </div>

        <div style={{ height: 20 }} />
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <SectionLabel>Up next</SectionLabel>
          <span style={{ fontFamily: MONO, fontSize: 9, color: p.textMuted, letterSpacing: 0.4 }}>SAME CATEGORY · EDITOR-CURATED</span>
        </div>
        <div style={{ marginTop: 8, display: 'flex', flexDirection: 'column', gap: 8 }}>
          {[
            ['Picking the right agent', '5 min', 'Article'],
            ['Your rights under Act 194', '7 min', 'Article'],
          ].map(([t, m, kind], i) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', gap: 10,
              padding: '12px 14px', background: p.card, border: `1px solid ${p.border}`, borderRadius: 12,
            }}>
              <Book size={16} stroke={p.primary} />
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 13.5, fontWeight: 600 }}>{t}</div>
                <div style={{ fontSize: 11, color: p.textMuted, fontFamily: MONO, letterSpacing: 0.4 }}>{kind.toUpperCase()} · {m.toUpperCase()}</div>
              </div>
              <Arrow size={14} stroke={p.textMuted} />
            </div>
          ))}
        </div>
      </div>
    </Screen>
  );
}

// ─── X · Voice recording overlay ───────────────────────────────────────
function ScrVoice() {
  const { palette: p } = React.useContext(MHADContext);
  // Decorative waveform bars
  const bars = [12, 28, 18, 44, 36, 52, 30, 58, 42, 24, 38, 50, 22, 46, 32, 18, 40, 26, 12];
  return (
    <Screen scroll={false} style={{ background: '#000' }}>
      {/* Backdrop = faded wizard screen */}
      <div style={{ position: 'absolute', inset: 0, opacity: 0.35, filter: 'blur(3px)' }}>
        <Screen>
          <CrisisBar compact />
          <div style={{ padding: 22, color: p.text }}>
            <SectionLabel>Step 10 of 11 · anything else</SectionLabel>
            <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 30, margin: '6px 0 4px' }}>Anything else</h1>
          </div>
        </Screen>
      </div>
      <div style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.55)' }} />

      {/* Bottom sheet */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0,
        background: p.card, borderRadius: `${TOK.rSheet}px ${TOK.rSheet}px 0 0`,
        padding: '14px 0 32px', boxShadow: '0 -10px 40px rgba(0,0,0,0.35)',
      }}>
        <div style={{ width: 40, height: 4, background: p.border, borderRadius: 100, margin: '0 auto 18px' }} />

        <div style={{ padding: '0 28px', textAlign: 'center' }}>
          <SectionLabel style={{ color: p.primary }}>● Recording</SectionLabel>
          <h2 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 28, margin: '6px 0 6px', fontWeight: 400, letterSpacing: -0.5 }}>
            Say it your way.
          </h2>
          <p style={{ fontSize: 12.5, color: p.textMuted, margin: 0, lineHeight: 1.5 }}>
            We'll transcribe locally — you can edit before saving.
          </p>

          {/* Waveform */}
          <div style={{
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 3,
            height: 80, margin: '20px 0',
          }}>
            {bars.map((h, i) => (
              <div key={i} style={{
                width: 4, height: h, background: i < 13 ? p.primary : p.border,
                borderRadius: 100,
                opacity: i < 13 ? 1 : 0.5,
              }} />
            ))}
          </div>

          {/* Timer */}
          <div style={{
            fontFamily: MONO, fontSize: 22, fontWeight: 600,
            color: p.text, letterSpacing: 1.5,
          }}>0:14</div>

          {/* Live caption */}
          <div style={{
            marginTop: 12, background: p.surface, border: `1px solid ${p.border}`,
            borderRadius: 12, padding: '12px 14px',
            fontSize: 13.5, color: p.text, lineHeight: 1.5, textAlign: 'left',
            minHeight: 70,
          }}>
            "If I'm admitted, please don't use restraints unless I'm a danger to myself or someone else.{' '}
            <span style={{ color: p.textMuted, fontStyle: 'italic' }}>And bring my therapy dog Olive if the facility allows…</span>
            <span style={{
              display: 'inline-block', width: 2, height: 14, background: p.primary,
              marginLeft: 2, verticalAlign: 'middle',
            }} />
          </div>
        </div>

        {/* Big record controls */}
        <div style={{
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 26,
          marginTop: 22, padding: '0 22px',
        }}>
          <div style={{
            width: 52, height: 52, borderRadius: 100,
            background: p.surface, border: `1px solid ${p.border}`,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            color: p.textMuted, fontSize: 12, fontWeight: 700, fontFamily: SANS,
          }}>Cancel</div>
          <div style={{
            width: 76, height: 76, borderRadius: 100,
            background: p.crisisAccent, color: '#fff',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: `0 0 0 4px ${p.card}, 0 0 0 6px ${p.crisisAccent}40`,
          }}>
            <div style={{ width: 26, height: 26, borderRadius: 4, background: '#fff' }} />
          </div>
          <div style={{
            width: 52, height: 52, borderRadius: 100,
            background: p.primary, color: p.onPrimary,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <Check size={22} sw={3} stroke={p.onPrimary} />
          </div>
        </div>

        <div style={{ marginTop: 12, fontSize: 10.5, color: p.textMuted, textAlign: 'center', fontFamily: MONO, letterSpacing: 0.5 }}>
          AUDIO ISN'T SAVED · TRANSCRIPT STAYS IN THIS SESSION
        </div>
      </div>
    </Screen>
  );
}

// ─── X · Contact picker (for naming an agent) ──────────────────────────
function ScrContactPicker() {
  const { palette: p } = React.useContext(MHADContext);

  const Person = ({ ini, name, rel, sub, selected, eligible, warn }) => (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12,
      padding: '12px 14px', background: p.card,
      border: `1.5px solid ${selected ? p.primary : (warn ? p.warnBorder : p.border)}`,
      borderRadius: 12, marginBottom: 6, opacity: eligible === false ? 0.55 : 1,
    }}>
      <div style={{
        width: 42, height: 42, borderRadius: 100,
        background: selected ? p.primary : p.primaryLight,
        color: selected ? p.onPrimary : p.onPrimaryLight,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontFamily: SANS, fontWeight: 700, fontSize: 14, flexShrink: 0,
      }}>{ini}</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 14, fontWeight: 600, color: p.text }}>{name}</div>
        <div style={{ fontSize: 11.5, color: p.textMuted, fontFamily: MONO, letterSpacing: 0.3 }}>{rel.toUpperCase()}</div>
        {sub && <div style={{ fontSize: 11, color: warn ? p.warnText : (eligible === false ? p.crisisAccent : p.textMuted), marginTop: 2 }}>{sub}</div>}
      </div>
      <div style={{
        width: 22, height: 22, borderRadius: 100, flexShrink: 0,
        border: `2px solid ${selected ? p.primary : (warn ? p.warnText : p.border)}`,
        background: selected ? p.primary : 'transparent',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        {selected
          ? <Check size={13} sw={3} stroke={p.onPrimary} />
          : (warn && <span style={{ fontSize: 12, fontWeight: 800, color: p.warnText, lineHeight: 1 }}>!</span>)}
      </div>
    </div>
  );

  return (
    <Screen scroll={false} style={{ background: '#000' }}>
      <div style={{ position: 'absolute', inset: 0, opacity: 0.35, filter: 'blur(3px)' }}>
        <Screen>
          <CrisisBar compact />
          <div style={{ padding: 22 }}>
            <SectionLabel>Step 3 of 11 · people I trust</SectionLabel>
            <h1 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 26, margin: '6px 0' }}>People I trust</h1>
          </div>
        </Screen>
      </div>
      <div style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.55)' }} />

      {/* Picker sheet */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0, top: 90,
        background: p.card, borderRadius: `${TOK.rSheet}px ${TOK.rSheet}px 0 0`,
        boxShadow: '0 -10px 40px rgba(0,0,0,0.35)',
        display: 'flex', flexDirection: 'column',
      }}>
        <div style={{ width: 40, height: 4, background: p.border, borderRadius: 100, margin: '14px auto 12px' }} />

        <div style={{ padding: '0 22px 8px' }}>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: 8 }}>
            <h2 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 28, margin: 0, fontWeight: 400, letterSpacing: -0.5 }}>
              Pick your <span style={{ color: p.primary }}>primary agent.</span>
            </h2>
          </div>
          <p style={{ fontSize: 12.5, color: p.textMuted, margin: '4px 0 12px', lineHeight: 1.45 }}>
            From your phone's contacts. We never upload them — search runs locally.
          </p>

          {/* Search */}
          <div style={{
            display: 'flex', alignItems: 'center', gap: 8,
            background: p.surface, border: `1px solid ${p.border}`, borderRadius: 100,
            padding: '8px 14px', marginBottom: 10,
          }}>
            <Search size={14} stroke={p.textMuted} />
            <input style={{
              flex: 1, border: 'none', outline: 'none', background: 'transparent',
              fontFamily: SANS, fontSize: 13, color: p.text,
            }} defaultValue="jor" />
            <X size={12} stroke={p.textMuted} />
          </div>
        </div>

        <div style={{ flex: 1, overflow: 'auto', padding: '0 22px 14px' }}>
          <SectionLabel style={{ marginBottom: 8 }}>Suggested</SectionLabel>
          <Person ini="JL" name="Jordan Lee" rel="Sister · favorited" sub="✓ Eligible · 18+" selected />
          <Person ini="SR" name="Sam Reyes" rel="Spouse" sub="✓ Eligible · 18+" />

          <div style={{ height: 12 }} />
          <SectionLabel style={{ marginBottom: 8 }}>Other matches · 3</SectionLabel>
          <Person ini="JM" name="Jorge Martinez" rel="Coworker" sub="✓ Eligible" />
          <Person ini="JT" name="Jordana Tran" rel="College friend" sub="✓ Eligible" />
          <Person ini="DJ" name="Dr. Jordan Patel" rel="Looks like a provider" sub="⚠ Confirm they're not treating you" warn />

          <div style={{ height: 8 }} />
          <button style={{
            width: '100%', background: 'transparent',
            border: `1.5px dashed ${p.border}`, borderRadius: 12,
            padding: '12px', fontSize: 13, fontWeight: 600, color: p.primary,
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
            cursor: 'pointer', fontFamily: SANS,
          }}>
            <Plus size={14} /> Enter someone manually
          </button>

          {/* Eligibility rules — PA Act 194 disqualifications */}
          <div style={{ height: 14 }} />
          <div style={{
            background: p.surface, border: `1px solid ${p.border}`, borderRadius: 12, padding: 12,
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 8 }}>
              <Info size={14} stroke={p.textMuted} />
              <span style={{ fontFamily: MONO, fontSize: 10, fontWeight: 700, color: p.textMuted, letterSpacing: 0.5 }}>WHO CAN'T BE YOUR AGENT</span>
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
              {[
                ['Under 18', 'hard block'],
                ['Your current treating provider or their employee', 'soft warn'],
                ['An owner/operator of a facility where you receive care', 'soft warn'],
              ].map(([rule, kind], i) => (
                <div key={i} style={{ display: 'flex', alignItems: 'flex-start', gap: 8 }}>
                  <span style={{ width: 5, height: 5, borderRadius: 100, background: kind === 'hard block' ? p.crisisAccent : p.warnText, marginTop: 6, flexShrink: 0 }} />
                  <span style={{ flex: 1, fontSize: 12, color: p.text, lineHeight: 1.4 }}>{rule}</span>
                  <span style={{ fontFamily: MONO, fontSize: 8.5, fontWeight: 700, letterSpacing: 0.4, color: kind === 'hard block' ? p.crisisAccent : p.warnText, textTransform: 'uppercase' }}>{kind}</span>
                </div>
              ))}
            </div>
            <p style={{ fontSize: 10.5, color: p.textMuted, margin: '8px 0 0', lineHeight: 1.4, fontStyle: 'italic' }}>
              Under-18 is blocked automatically (from the contact's birthday). We can't tell who your providers are, so anything that looks like a provider is a <strong>soft warning you can override</strong> — confirm only if they truly aren't treating you.
            </p>
          </div>
        </div>

        {/* Footer */}
        <div style={{
          padding: '12px 18px 40px', borderTop: `1px solid ${p.border}`,
          display: 'flex', gap: 8,
        }}>
          <Btn kind="ghost" style={{ flex: 1 }}>Cancel</Btn>
          <Btn kind="primary" style={{ flex: 1.6 }} trailing={<Arrow size={16} />}>Use Jordan Lee</Btn>
        </div>
      </div>
    </Screen>
  );
}

// ─── Mobile-extra router ───────────────────────────────────────────────
function MobileExtra({ name }) {
  return (
    <Surface kind="android">
    <AndroidShell width={422} height={860}>
      {(() => {
        switch (name) {
          case 'faceid':     return <ScrFaceID />;
          case 'empty':      return <ScrEmpty />;
          case 'past':       return <ScrPastDetail />;
          case 'renew':      return <ScrRenew />;
          case 'checkin':    return <ScrCheckIn />;
          case 'revoke':     return <ScrRevoke />;
          case 'share':      return <ScrShare />;
          case 'ai':         return <ScrAI />;
          case 'learn':      return <ScrLearn />;
          case 'settings':   return <ScrSettings />;
          case 'pdf':        return <ScrPdfPreview />;
          case 'quiz':       return <ScrQuiz />;
          case 'public':     return <ScrPublic />;
          case 'verify':     return <ScrVerify />;
          case 'scan':       return <ScrScanID />;
          case 'snap-review':return <ScrSnapReview />;
          case 'article':    return <ScrArticle />;
          case 'voice':      return <ScrVoice />;
          case 'contacts':   return <ScrContactPicker />;
          default: return null;
        }
      })()}
    </AndroidShell>
    </Surface>
  );
}

Object.assign(window, { MobileExtra, CoverageAudit });
