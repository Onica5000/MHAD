// ds.jsx — MHAD design system: palettes, tokens, shared atoms.
// Lifted directly from lib/ui/theme/app_theme.dart so this stays a faithful
// realization of the repo's existing tokens.

const MHAD_PALETTES = {
  teal: {
    light: {
      primary: '#1A7A6E', primaryMid: '#20A090', primaryDark: '#125A52',
      primaryLight: '#E6F4F2', primaryTint: '#F0F9F7',
      surface: '#F6FAF8', card: '#FFFFFF', border: '#E2EDEA',
      text: '#1A2E2B', textMuted: '#4C6763',
      scaffold: '#F6FAF8',
      onPrimary: '#FFFFFF', onPrimaryLight: '#0A2E2A',
      crisisBg: '#FDF2F2', crisisBorder: '#F5C6C6', crisisText: '#922B21', crisisAccent: '#C0392B',
      warnBg: '#FFF8E1', warnBorder: '#FFE082', warnText: '#B45309',
      okBg: '#F0FBF4', okText: '#15803D', okBorder: '#BBF7D0',
    },
    dark: {
      primary: '#4ABFB1', primaryMid: '#20A090', primaryDark: '#125A52',
      primaryLight: '#1B3330', primaryTint: '#142524',
      surface: '#0F1A18', card: '#172622', border: '#26342F',
      text: '#E8F2EF', textMuted: '#BCD0CB',
      scaffold: '#0A1413',
      onPrimary: '#04201C', onPrimaryLight: '#E8F2EF',
      crisisBg: '#3A1B17', crisisBorder: '#8B3A32', crisisText: '#F5B5AF', crisisAccent: '#E06B5D',
      warnBg: '#3A2F0C', warnBorder: '#8B6B1A', warnText: '#FBC67A',
      okBg: '#0F2A19', okText: '#7CD9A1', okBorder: '#2F6B46',
    },
  },
  navy: {
    light: {
      primary: '#1E3A8A', primaryMid: '#3B5BD9', primaryDark: '#152A66',
      primaryLight: '#E6EBF7', primaryTint: '#F0F3FB',
      surface: '#F7F9FC', card: '#FFFFFF', border: '#E0E5F0',
      text: '#111A2E', textMuted: '#52607A',
      scaffold: '#F7F9FC',
      onPrimary: '#FFFFFF', onPrimaryLight: '#101D3B',
      crisisBg: '#FDF2F2', crisisBorder: '#F5C6C6', crisisText: '#922B21', crisisAccent: '#C0392B',
      warnBg: '#FFF8E1', warnBorder: '#FFE082', warnText: '#B45309',
      okBg: '#F0FBF4', okText: '#15803D', okBorder: '#BBF7D0',
    },
    dark: {
      primary: '#8B9EE3', primaryMid: '#6B82D9', primaryDark: '#152A66',
      primaryLight: '#1C2442', primaryTint: '#151C33',
      surface: '#0D1220', card: '#151B2E', border: '#232B3E',
      text: '#E5EAF5', textMuted: '#BDC6DD',
      scaffold: '#0A0F1B',
      onPrimary: '#0A0F1B', onPrimaryLight: '#E5EAF5',
      crisisBg: '#3A1B17', crisisBorder: '#8B3A32', crisisText: '#F5B5AF', crisisAccent: '#E06B5D',
      warnBg: '#3A2F0C', warnBorder: '#8B6B1A', warnText: '#FBC67A',
      okBg: '#0F2A19', okText: '#7CD9A1', okBorder: '#2F6B46',
    },
  },
  sage: {
    light: {
      primary: '#4A7A5C', primaryMid: '#6BA07F', primaryDark: '#2F5A40',
      primaryLight: '#EAF3ED', primaryTint: '#F1F8F3',
      surface: '#F7FAF8', card: '#FFFFFF', border: '#DDE8E0',
      text: '#1E2E23', textMuted: '#4F6C59',
      scaffold: '#F7FAF8',
      onPrimary: '#FFFFFF', onPrimaryLight: '#112618',
      crisisBg: '#FDF2F2', crisisBorder: '#F5C6C6', crisisText: '#922B21', crisisAccent: '#C0392B',
      warnBg: '#FFF8E1', warnBorder: '#FFE082', warnText: '#B45309',
      okBg: '#F0FBF4', okText: '#15803D', okBorder: '#BBF7D0',
    },
    dark: {
      primary: '#9BC5A9', primaryMid: '#7AB38B', primaryDark: '#2F5A40',
      primaryLight: '#1E2F24', primaryTint: '#17231B',
      surface: '#0F1811', card: '#172218', border: '#243025',
      text: '#E5F0E8', textMuted: '#BDD3C4',
      scaffold: '#0A130C',
      onPrimary: '#0A130C', onPrimaryLight: '#E5F0E8',
      crisisBg: '#3A1B17', crisisBorder: '#8B3A32', crisisText: '#F5B5AF', crisisAccent: '#E06B5D',
      warnBg: '#3A2F0C', warnBorder: '#8B6B1A', warnText: '#FBC67A',
      okBg: '#0F2A19', okText: '#7CD9A1', okBorder: '#2F6B46',
    },
  },
};

const MHADContext = React.createContext({
  palette: MHAD_PALETTES.teal.light, paletteName: 'teal', mode: 'light', density: 'comfortable',
});

// ─── Type helpers ────────────────────────────────────────────────────────
const SANS = "'DM Sans', system-ui, -apple-system, sans-serif";
const SERIF = "'Instrument Serif', Georgia, serif";
const MONO = "'JetBrains Mono', ui-monospace, monospace";

// ─── Tokens ───────────────────────────────────────────────────────────────
const TOK = {
  rCard: 16, rBtn: 14, rInput: 12, rChip: 100, rSheet: 20, rTile: 12,
  hBtnMd: 52, hBtnSm: 40, hBtnLg: 56,
};

// ─── Atoms ────────────────────────────────────────────────────────────────

// A device-frame screen background
function Screen({ children, style = {}, scroll = true }) {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <div style={{
      width: '100%', height: '100%', background: p.scaffold, color: p.text,
      fontFamily: SANS, fontSize: 15, lineHeight: 1.45,
      display: 'flex', flexDirection: 'column',
      overflow: scroll ? 'auto' : 'hidden', position: 'relative',
      boxSizing: 'border-box',
      ...style,
    }}>
      {children}
      {scroll && (
        <div aria-hidden="true" style={{
          position: 'sticky', bottom: 0, left: 0, right: 0,
          height: 48, marginTop: -48, flexShrink: 0, pointerEvents: 'none',
          background: `linear-gradient(to top, ${(style && style.background) || p.scaffold} 40%, ${(style && style.background) || p.scaffold}00)`,
          zIndex: 2,
        }} />
      )}
    </div>
  );
}

function Card({ children, style = {}, pad = 16, onClick }) {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <div onClick={onClick} style={{
      background: p.card, border: `1px solid ${p.border}`, borderRadius: TOK.rCard,
      padding: pad, boxShadow: '0 1px 3px rgba(0,0,0,0.04)', ...style,
    }}>{children}</div>
  );
}

function Btn({ kind = 'primary', size = 'md', children, style = {}, leading, trailing, full }) {
  const { palette: p } = React.useContext(MHADContext);
  const h = size === 'sm' ? TOK.hBtnSm : size === 'lg' ? TOK.hBtnLg : TOK.hBtnMd;
  const base = {
    display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
    height: h, padding: '0 18px', borderRadius: TOK.rBtn,
    fontFamily: SANS, fontWeight: 600, fontSize: 15, letterSpacing: 0,
    cursor: 'pointer', border: 'none', whiteSpace: 'nowrap',
    width: full ? '100%' : 'auto',
  };
  const variants = {
    primary: { background: p.primary, color: p.onPrimary },
    outline: { background: 'transparent', color: p.primary, border: `1.5px solid ${p.primary}`, height: h - 3 },
    ghost: { background: 'transparent', color: p.primary },
    tonal: { background: p.primaryLight, color: p.onPrimaryLight },
    dark: { background: p.text, color: p.card },
    danger: { background: p.crisisAccent, color: p.onPrimary },
    dangerOutline: { background: 'transparent', color: p.crisisAccent, border: `1.5px solid ${p.crisisAccent}`, height: h - 3 },
  };
  return <button style={{ ...base, ...variants[kind], ...style }}>{leading}{children}{trailing}</button>;
}

function Chip({ children, active, style = {}, onClick, icon }) {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <span onClick={onClick} style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      padding: '6px 12px', borderRadius: TOK.rChip,
      fontSize: 12, fontWeight: 600, lineHeight: 1, fontFamily: SANS,
      background: active ? p.primary : p.primaryLight,
      color: active ? p.onPrimary : p.onPrimaryLight,
      border: `1px solid ${active ? p.primary : 'transparent'}`,
      cursor: 'pointer', ...style,
    }}>{icon}{children}</span>
  );
}

function Badge({ children, tone = 'primary', style = {} }) {
  const { palette: p } = React.useContext(MHADContext);
  const tones = {
    primary: { bg: p.primaryLight, fg: p.onPrimaryLight },
    ok: { bg: p.okBg, fg: p.okText },
    warn: { bg: p.warnBg, fg: p.warnText },
    crisis: { bg: p.crisisBg, fg: p.crisisText },
    neutral: { bg: p.surface, fg: p.textMuted },
  }[tone];
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 4,
      padding: '4px 9px', borderRadius: 6,
      fontSize: 11, fontWeight: 700, letterSpacing: 0.4, textTransform: 'uppercase',
      background: tones.bg, color: tones.fg, fontFamily: SANS,
      ...style,
    }}>{children}</span>
  );
}

// Persistent crisis bar — calm, not alarming.
// Includes 54px top spacer so it clears the iOS status bar + dynamic island.
function CrisisBar({ compact }) {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 10,
      paddingTop: (compact ? 8 : 10) + 54,
      paddingBottom: compact ? 8 : 10,
      paddingLeft: compact ? 14 : 16,
      paddingRight: compact ? 14 : 16,
      background: p.crisisBg, borderBottom: `1px solid ${p.crisisBorder}`,
      color: p.crisisText, fontSize: 12.5, fontWeight: 500,
    }}>
      <Phone size={13} stroke={p.crisisAccent} />
      <span style={{ flex: 1 }}>Need help now? <strong style={{ fontWeight: 700 }}>Call or text 988</strong></span>
      <span style={{ fontFamily: MONO, fontSize: 11, color: p.crisisAccent, fontWeight: 600 }}>24/7</span>
    </div>
  );
}

// Editorial step header with oversized serif numeral
function StepHead({ n, total, title, sub }) {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <div style={{ padding: '24px 22px 16px' }}>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 14, marginBottom: 6 }}>
        <span style={{
          fontFamily: SERIF, fontStyle: 'italic', fontSize: 54, lineHeight: 1,
          color: p.primary, letterSpacing: -1,
        }}>{String(n).padStart(2, '0')}</span>
        <span style={{
          fontFamily: MONO, fontSize: 11, color: p.textMuted, letterSpacing: 1,
          textTransform: 'uppercase',
        }}>Step {n} of {total}</span>
      </div>
      <h2 style={{
        fontFamily: SANS, fontWeight: 700, fontSize: 26, margin: '4px 0 6px',
        letterSpacing: -0.4, lineHeight: 1.15,
      }}>{title}</h2>
      {sub && <p style={{ fontSize: 14, color: p.textMuted, margin: 0, lineHeight: 1.45 }}>{sub}</p>}
    </div>
  );
}

// Progress dots
function StepDots({ n, total }) {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <div style={{ display: 'flex', gap: 4, padding: '12px 22px 0' }}>
      {Array.from({ length: total }).map((_, i) => (
        <div key={i} style={{
          flex: 1, height: 3, borderRadius: 2,
          background: i < n ? p.primary : p.border,
        }} />
      ))}
    </div>
  );
}

// Wizard top header — Back link + right-side action (default "Save & exit").
// Centralizes the row repeated across ~25 wizard/content screens.
function WizardHeader({ back = 'Back', onBack, right, action = 'Save & exit', onAction, pad = '8px 22px 0' }) {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <div style={{ padding: pad, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
      <span onClick={onBack} style={{ fontSize: 13, color: p.primary, fontWeight: 600, display: 'flex', alignItems: 'center', gap: 4, cursor: onBack ? 'pointer' : 'default' }}>
        <Icon d="M15 18l-6-6 6-6" size={16} /> {back}
      </span>
      {right !== undefined
        ? right
        : (action && <span onClick={onAction} style={{ fontSize: 13, color: p.textMuted, fontWeight: 500, cursor: onAction ? 'pointer' : 'default' }}>{action}</span>)}
    </div>
  );
}

// Anonymous-session pill — "nothing saved" indicator for the web app.
function TabOnlyPill({ label = 'THIS TAB ONLY' }) {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 5,
      fontSize: 11, fontFamily: MONO, color: p.textMuted, letterSpacing: 0.4,
      padding: '4px 8px', background: p.surface, borderRadius: 100,
    }}>
      <Lock size={10} stroke={p.textMuted} /> {label}
    </span>
  );
}

// Bottom sticky action bar
function BottomBar({ left, right, primary, secondary }) {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <div style={{
      flexShrink: 0, marginTop: 'auto',
      padding: '12px 18px 40px', display: 'flex', gap: 10,
      background: p.scaffold, borderTop: `1px solid ${p.border}`,
    }}>
      {left || (secondary ? <Btn kind="ghost">{secondary}</Btn> : null)}
      <div style={{ flex: 1 }} />
      {right || <Btn kind="primary">{primary || 'Continue'} <Arrow /></Btn>}
    </div>
  );
}

// Form field
function Field({ label, value, placeholder, suffix, hint, multiline, source }) {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <div style={{ marginBottom: 14 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 6 }}>
        <label style={{ fontSize: 12, fontWeight: 600, color: p.textMuted, letterSpacing: 0.2 }}>
          {label}
        </label>
        {source && (typeof SourcePill !== 'undefined') && <SourcePill source={source} />}
      </div>
      <div style={{
        display: 'flex', alignItems: multiline ? 'flex-start' : 'center', gap: 8,
        background: p.card, border: `1.5px solid ${p.border}`, borderRadius: TOK.rInput,
        padding: multiline ? '12px 14px' : '0 14px',
        height: multiline ? 'auto' : 48,
        minHeight: multiline ? 80 : undefined,
      }}>
        <span style={{ flex: 1, color: value ? p.text : p.textMuted, fontSize: 15 }}>
          {value || placeholder}
        </span>
        {suffix}
      </div>
      {hint && <p style={{ fontSize: 11.5, color: p.textMuted, margin: '6px 2px 0' }}>{hint}</p>}
    </div>
  );
}

// Consent picker: 4 chip options
function ConsentRow({ value }) {
  const { palette: p } = React.useContext(MHADContext);
  const opts = [
    { id: 'yes', label: 'Yes' },
    { id: 'no', label: 'No' },
    { id: 'agent', label: 'Agent decides' },
    { id: 'if', label: 'If…' },
  ];
  return (
    <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
      {opts.map((o) => (
        <span key={o.id} style={{
          padding: '8px 14px', borderRadius: TOK.rChip,
          fontSize: 12.5, fontWeight: 600, lineHeight: 1, fontFamily: SANS,
          background: value === o.id ? p.primary : 'transparent',
          color: value === o.id ? p.onPrimary : p.textMuted,
          border: `1.5px solid ${value === o.id ? p.primary : p.border}`,
        }}>{o.label}</span>
      ))}
    </div>
  );
}

function SectionLabel({ children, style = {} }) {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <div style={{
      fontFamily: MONO, fontSize: 10.5, fontWeight: 600,
      textTransform: 'uppercase', letterSpacing: 1.2, color: p.textMuted,
      ...style,
    }}>{children}</div>
  );
}

// Editorial pull-quote style heading
function Editorial({ children, size = 56, italic = true, style = {} }) {
  return (
    <h1 style={{
      fontFamily: SERIF, fontStyle: italic ? 'italic' : 'normal',
      fontSize: size, lineHeight: 1.02, letterSpacing: -1,
      margin: 0, fontWeight: 400, ...style,
    }}>{children}</h1>
  );
}

// ─── Tiny inline icons (stroke style, ~16-20px) ─────────────────────────
function Icon({ d, size = 18, stroke = 'currentColor', fill = 'none', sw = 1.75, vb = '0 0 24 24', children }) {
  return (
    <svg width={size} height={size} viewBox={vb} fill={fill} stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" style={{ flexShrink: 0 }}>
      {children || <path d={d} />}
    </svg>
  );
}
const Arrow = (p) => <Icon {...p} d="M5 12h14M13 6l6 6-6 6" />;
const Plus = (p) => <Icon {...p} d="M12 5v14M5 12h14" />;
const Check = (p) => <Icon {...p} d="M5 12l5 5L20 7" />;
const ChevR = (p) => <Icon {...p} d="M9 6l6 6-6 6" />;
const ChevD = (p) => <Icon {...p} d="M6 9l6 6 6-6" />;
const Phone = (p) => <Icon {...p} d="M5 4h4l2 5-2.5 1.5a11 11 0 0 0 5 5L15 13l5 2v4a2 2 0 0 1-2 2A16 16 0 0 1 3 6a2 2 0 0 1 2-2z" />;
const Lock = (p) => <Icon {...p}><rect x="4" y="11" width="16" height="10" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/></Icon>;
const Eye = (p) => <Icon {...p}><path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/></Icon>;
const EyeOff = (p) => <Icon {...p}><path d="M3 3l18 18"/><path d="M10.7 5.2A10.4 10.4 0 0 1 12 5c6 0 10 7 10 7a17 17 0 0 1-3.4 4M6.7 6.7C3.7 8.6 2 12 2 12s4 7 10 7c1.5 0 2.8-.4 4-.9"/><path d="M9.9 9.9a3 3 0 0 0 4.2 4.2"/></Icon>;
const Sparkles = (p) => <Icon {...p}><path d="M12 3v4M12 17v4M3 12h4M17 12h4M5.6 5.6l2.8 2.8M15.6 15.6l2.8 2.8M5.6 18.4l2.8-2.8M15.6 8.4l2.8-2.8"/></Icon>;
const Mic = (p) => <Icon {...p}><rect x="9" y="3" width="6" height="12" rx="3"/><path d="M5 11a7 7 0 0 0 14 0M12 18v3"/></Icon>;
const FileText = (p) => <Icon {...p}><path d="M14 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"/><path d="M14 3v6h6M8 13h8M8 17h5"/></Icon>;
const Heart = (p) => <Icon {...p} d="M12 21s-7-5-9.5-9.5C.8 8 3 4 6.5 4c2 0 3.5 1 5.5 3 2-2 3.5-3 5.5-3C21 4 23.2 8 21.5 11.5 19 16 12 21 12 21z" />;
const Users = (p) => <Icon {...p}><circle cx="9" cy="8" r="4"/><path d="M2 21a7 7 0 0 1 14 0"/><path d="M16 4a4 4 0 0 1 0 8M22 21a7 7 0 0 0-5-6.7"/></Icon>;
const Pill = (p) => <Icon {...p}><rect x="3" y="9" width="18" height="6" rx="3" transform="rotate(-45 12 12)"/><path d="M8.5 8.5l7 7" transform="rotate(-45 12 12)"/></Icon>;
const Calendar = (p) => <Icon {...p}><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 9h18M8 3v4M16 3v4"/></Icon>;
const Shield = (p) => <Icon {...p} d="M12 3l8 3v6c0 5-4 8.5-8 9-4-.5-8-4-8-9V6l8-3z" />;
const Edit = (p) => <Icon {...p}><path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 1 1 3 3L7 19l-4 1 1-4 12.5-12.5z"/></Icon>;
const QR = (p) => <Icon {...p}><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><path d="M14 14h3v3M20 14v3M14 20h3M20 20v1"/></Icon>;
const DotsH = (p) => <Icon {...p}><circle cx="5" cy="12" r="1.5"/><circle cx="12" cy="12" r="1.5"/><circle cx="19" cy="12" r="1.5"/></Icon>;
const Home = (p) => <Icon {...p}><path d="M3 11l9-7 9 7v9a2 2 0 0 1-2 2h-4v-7h-6v7H5a2 2 0 0 1-2-2v-9z"/></Icon>;
const Book = (p) => <Icon {...p}><path d="M4 4h12a2 2 0 0 1 2 2v14a2 2 0 0 0-2-2H4z"/><path d="M4 4v14"/></Icon>;
const Gear = (p) => <Icon {...p}><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.6 1.6 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.6 1.6 0 0 0-1.8-.3 1.6 1.6 0 0 0-1 1.5V21a2 2 0 0 1-4 0v-.1A1.6 1.6 0 0 0 9 19.4a1.6 1.6 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.6 1.6 0 0 0 .3-1.8 1.6 1.6 0 0 0-1.5-1H3a2 2 0 0 1 0-4h.1A1.6 1.6 0 0 0 4.6 9 1.6 1.6 0 0 0 4.3 7.2l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.6 1.6 0 0 0 1.8.3H9a1.6 1.6 0 0 0 1-1.5V3a2 2 0 0 1 4 0v.1a1.6 1.6 0 0 0 1 1.5 1.6 1.6 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.6 1.6 0 0 0-.3 1.8V9a1.6 1.6 0 0 0 1.5 1H21a2 2 0 0 1 0 4h-.1a1.6 1.6 0 0 0-1.5 1z"/></Icon>;
const Bookmark = (p) => <Icon {...p}><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></Icon>;
const Download = (p) => <Icon {...p}><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3"/></Icon>;
const Share = (p) => <Icon {...p}><circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><path d="M8.6 13.5l6.8 4M15.4 6.5l-6.8 4"/></Icon>;
const Search = (p) => <Icon {...p}><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></Icon>;
const X = (p) => <Icon {...p} d="M6 6l12 12M18 6L6 18" />;
const AlertTri = (p) => <Icon {...p}><path d="M12 3l10 18H2L12 3z"/><path d="M12 10v5M12 18v.5"/></Icon>;
const Info = (p) => <Icon {...p}><circle cx="12" cy="12" r="9"/><path d="M12 8v.5M11.5 12h.5v4"/></Icon>;
const MapPin = (p) => <Icon {...p}><path d="M12 22s8-7 8-13a8 8 0 1 0-16 0c0 6 8 13 8 13z"/><circle cx="12" cy="9" r="3"/></Icon>;
const Flask = (p) => <Icon {...p}><path d="M10 3v6L4 20a1 1 0 0 0 1 1.5h14A1 1 0 0 0 20 20l-6-11V3"/><path d="M8 3h8M7 14h10"/></Icon>;
const Zap = (p) => <Icon {...p} d="M13 2L4 14h7l-1 8 9-12h-7l1-8z" />;
const Brain = (p) => <Icon {...p}><path d="M9 3a3 3 0 0 0-3 3 3 3 0 0 0-3 4 3 3 0 0 0 0 4 3 3 0 0 0 3 4 3 3 0 0 0 3 3 3 3 0 0 0 3-3V3z"/><path d="M15 3a3 3 0 0 1 3 3 3 3 0 0 1 3 4 3 3 0 0 1 0 4 3 3 0 0 1-3 4 3 3 0 0 1-3 3 3 3 0 0 1-3-3V3z"/></Icon>;
const Wallet = (p) => <Icon {...p}><rect x="3" y="6" width="18" height="14" rx="2"/><path d="M3 10h18M16 14h2"/></Icon>;
const SwapV = (p) => <Icon {...p} d="M7 4v16M7 4l-3 3M7 4l3 3M17 20V4M17 20l-3-3M17 20l3-3" />;

// ─── Cards used in the cover section ────────────────────────────────────
function BriefCard() {
  const { palette: p } = React.useContext(MHADContext);
  return (
    <div style={{ background: p.scaffold, padding: '40px 44px', height: '100%', boxSizing: 'border-box', color: p.text, fontFamily: SANS }}>
      <SectionLabel>Design brief · v1</SectionLabel>
      <div style={{ height: 16 }} />
      <Editorial style={{ color: p.text, fontSize: 64 }}>
        In your <span style={{ color: p.primary }}>words</span>.
      </Editorial>
      <Editorial style={{ color: p.textMuted, fontSize: 32, marginTop: 6 }}>
        A document that stays loyal to you.
      </Editorial>
      <div style={{ height: 28 }} />
      <p style={{ fontSize: 15, lineHeight: 1.55, maxWidth: 560, margin: 0, color: p.textMuted }}>
        PA Mental Health Advance Directive — redesigned around the idea that this is the user's <em>voice</em>, written in advance.
        Plain-language microcopy, an editorial step layout, and a wizard that's been re-sequenced from 15 screens into 11 logical steps — including dedicated diagnoses and allergies intake powered by ICD-10 and RxTerms autocomplete.
      </p>
      <div style={{ height: 36 }} />
      <div style={{ display: 'flex', gap: 28, fontFamily: MONO, fontSize: 11.5, color: p.textMuted, letterSpacing: 0.8 }}>
        <div><div style={{ color: p.primary, fontFamily: SERIF, fontStyle: 'italic', fontSize: 40, lineHeight: 1, marginBottom: 4 }}>9</div>WIZARD STEPS<br/>(WAS 15)</div>
        <div><div style={{ color: p.primary, fontFamily: SERIF, fontStyle: 'italic', fontSize: 40, lineHeight: 1, marginBottom: 4 }}>3</div>PALETTES<br/>TEAL · NAVY · SAGE</div>
        <div><div style={{ color: p.primary, fontFamily: SERIF, fontStyle: 'italic', fontSize: 40, lineHeight: 1, marginBottom: 4 }}>2</div>SURFACES<br/>MOBILE · WEB</div>
        <div><div style={{ color: p.primary, fontFamily: SERIF, fontStyle: 'italic', fontSize: 40, lineHeight: 1, marginBottom: 4 }}>988</div>CRISIS LINE<br/>EVERY SCREEN</div>
      </div>
    </div>
  );
}

function SystemCard() {
  const { palette: p, paletteName } = React.useContext(MHADContext);
  return (
    <div style={{ background: p.scaffold, padding: '36px 40px', height: '100%', boxSizing: 'border-box', color: p.text, fontFamily: SANS, overflow: 'hidden' }}>
      <SectionLabel>Visual system</SectionLabel>
      <div style={{ height: 14 }} />
      <h2 style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 38, margin: 0, fontWeight: 400, letterSpacing: -0.5 }}>
        Calm. Generous. <span style={{ color: p.primary }}>Quietly editorial.</span>
      </h2>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 22, marginTop: 26 }}>
        {/* Type pairing */}
        <div>
          <SectionLabel style={{ marginBottom: 8 }}>Type</SectionLabel>
          <div style={{ fontFamily: SERIF, fontStyle: 'italic', fontSize: 40, color: p.text, lineHeight: 1, letterSpacing: -0.5 }}>
            Instrument Serif
          </div>
          <div style={{ fontFamily: MONO, fontSize: 10.5, color: p.textMuted, marginTop: 4, letterSpacing: 0.6 }}>ITALIC · DISPLAY · STEP NUMERALS · PULL QUOTES</div>
          <div style={{ height: 16 }} />
          <div style={{ fontFamily: SANS, fontWeight: 700, fontSize: 24, color: p.text, letterSpacing: -0.3 }}>DM Sans</div>
          <div style={{ fontFamily: SANS, fontWeight: 400, fontSize: 14, color: p.textMuted, marginTop: 2 }}>400 · 500 · 600 · 700 — body, UI, microcopy</div>
          <div style={{ height: 12 }} />
          <div style={{ fontFamily: MONO, fontSize: 12, color: p.textMuted }}>JetBrains Mono — labels &amp; tags</div>
        </div>

        {/* Palette swatches */}
        <div>
          <SectionLabel style={{ marginBottom: 8 }}>Palette · {paletteName === 'teal' ? 'Warm Teal' : paletteName === 'navy' ? 'Deep Navy' : 'Sage'}</SectionLabel>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: 6 }}>
            {[
              ['primaryDark', p.primaryDark],
              ['primary', p.primary],
              ['primaryMid', p.primaryMid],
              ['primaryLight', p.primaryLight],
              ['primaryTint', p.primaryTint],
            ].map(([n, c]) => (
              <div key={n} style={{ height: 56, borderRadius: 8, background: c, border: `1px solid ${p.border}` }} title={c} />
            ))}
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: 6, marginTop: 6 }}>
            {[
              ['text', p.text],
              ['textMuted', p.textMuted],
              ['border', p.border],
              ['card', p.card],
              ['scaffold', p.scaffold],
            ].map(([n, c]) => (
              <div key={n} style={{ height: 36, borderRadius: 6, background: c, border: `1px solid ${p.border}` }} title={c} />
            ))}
          </div>
          <div style={{ display: 'flex', gap: 6, marginTop: 12 }}>
            <div style={{ flex: 1, height: 28, borderRadius: 6, background: p.crisisBg, border: `1px solid ${p.crisisBorder}`, color: p.crisisText, fontSize: 11, fontWeight: 600, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>crisis</div>
            <div style={{ flex: 1, height: 28, borderRadius: 6, background: p.warnBg, border: `1px solid ${p.warnBorder}`, color: p.warnText, fontSize: 11, fontWeight: 600, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>warn</div>
            <div style={{ flex: 1, height: 28, borderRadius: 6, background: p.okBg, border: `1px solid ${p.okBorder}`, color: p.okText, fontSize: 11, fontWeight: 600, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>ok</div>
          </div>
        </div>
      </div>

      <div style={{ height: 24 }} />
      <SectionLabel>Microcopy rewrites</SectionLabel>
      <div style={{ marginTop: 8, display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 6, fontSize: 13 }}>
        {[
          ['Agent Designation', 'People I trust'],
          ['Effective Condition', 'When this kicks in'],
          ['Execution', 'Sign &amp; witness'],
          ['Drug Trials', 'Research drug trials'],
          ['ECT Preferences', 'Electroconvulsive therapy'],
          ['Form Type', 'Which form fits you?'],
        ].map(([from, to], i) => (
          <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <span style={{ color: p.textMuted, textDecoration: 'line-through', fontSize: 12.5 }}>{from}</span>
            <Arrow size={12} stroke={p.primary} />
            <span style={{ color: p.text, fontWeight: 600, fontSize: 13 }} dangerouslySetInnerHTML={{ __html: to }} />
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── Handoff annotation: platform/surface tag baked into every screen ───
// Captured inside the artboard itself (PNG/HTML export grabs only the card),
// so anyone — or Claude Code — recreating a screen from a single frame can
// always tell what surface it targets. Three kinds:
//   ios         → native mobile app screen
//   web-desktop → website, desktop browser
//   web-mobile  → website, phone browser (same bezel as native — this is the
//                 one that's otherwise impossible to tell apart)
const SURFACE_TAGS = {
  android:       { dot: '#3DDC84', a: 'ANDROID', b: 'Native Android app screen' },
  'web-desktop': { dot: '#0A84FF', a: 'WEB',     b: 'Website · Chrome / Edge desktop' },
  'web-mobile':  { dot: '#0A84FF', a: 'WEB',     b: 'Website · Chrome mobile (responsive)' },
};

function FrameTag({ kind }) {
  const t = SURFACE_TAGS[kind] || SURFACE_TAGS.ios;
  return (
    <div style={{
      flexShrink: 0, height: 34, boxSizing: 'border-box',
      display: 'flex', alignItems: 'center', gap: 9, padding: '0 16px',
      background: '#15171c', color: '#eef0f4',
      fontFamily: MONO, fontSize: 11, lineHeight: 1,
      borderBottom: '1px solid rgba(255,255,255,0.06)',
    }}>
      <span style={{ width: 8, height: 8, borderRadius: 4, background: t.dot, flexShrink: 0 }} />
      <span style={{ fontWeight: 600, letterSpacing: 1.4 }}>{t.a}</span>
      <span style={{ opacity: 0.35 }}>—</span>
      <span style={{ opacity: 0.62, letterSpacing: 0.3, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{t.b}</span>
    </div>
  );
}

// Wraps a device/browser frame with the platform tag bar. The frame inside
// is sized to (cardHeight − 34) by the router so the bar + frame fill the
// artboard exactly with no clipping or letterbox.
function Surface({ kind, children }) {
  return (
    <div style={{ width: '100%', height: '100%', display: 'flex', flexDirection: 'column', background: '#0c0d10', overflow: 'hidden' }}>
      <FrameTag kind={kind} />
      <div style={{ flex: 1, minHeight: 0, display: 'flex', alignItems: 'flex-start', justifyContent: 'center', overflow: 'hidden' }}>
        {children}
      </div>
    </div>
  );
}

// ─── Android (Material 3) device shell ──────────────────────────────────
// Deliberately mirrors the IOSDevice layout *contract* so every existing
// mobile screen drops in unchanged: status bar is absolutely positioned over
// the top (screens already reserve STATUSBAR_H=60 to clear it), content fills
// 100% height, and a gesture-nav pill floats at the bottom inside the HOME_H
// =34 region the screens leave free. Only the chrome is Material — no app bar
// or keyboard is injected (screens render their own).
function AndroidShell({ children, width = 412, height = 860, dark = false }) {
  const c = dark ? '#ffffff' : '#1a1c1e';
  return (
    <div style={{
      width, height, borderRadius: 40, overflow: 'hidden', position: 'relative',
      background: dark ? '#000000' : '#ffffff',
      boxShadow: '0 40px 80px rgba(0,0,0,0.18), 0 0 0 1px rgba(0,0,0,0.12)',
      fontFamily: "Roboto, 'DM Sans', system-ui, sans-serif",
      WebkitFontSmoothing: 'antialiased',
    }}>
      {/* centered punch-hole camera (Material — no notch / dynamic island) */}
      <div style={{
        position: 'absolute', top: 13, left: '50%', transform: 'translateX(-50%)',
        width: 11, height: 11, borderRadius: '50%', background: '#0a0a0a', zIndex: 50,
      }} />
      {/* status bar — absolute, ~34px row within the 60px the screens reserve */}
      <div style={{
        position: 'absolute', top: 0, left: 0, right: 0, height: 34, zIndex: 10,
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        padding: '0 16px 0 22px',
      }}>
        <span style={{ fontFamily: "Roboto, system-ui", fontSize: 14, fontWeight: 600, letterSpacing: 0.2, color: c }}>9:30</span>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          {/* wifi */}
          <svg width="15" height="12" viewBox="0 0 16 13" fill={c}><path d="M8 12.4L0.6 4.5a10.4 10.4 0 0 1 14.8 0L8 12.4z"/></svg>
          {/* signal */}
          <svg width="15" height="12" viewBox="0 0 16 13" fill={c}><path d="M15 1.2v10.6H1.4L15 1.2z"/></svg>
          {/* battery */}
          <svg width="22" height="12" viewBox="0 0 24 13" fill={c}><rect x="1" y="1.6" width="19" height="9.8" rx="2.6"/><rect x="21" y="4.6" width="2.2" height="3.8" rx="1"/></svg>
        </div>
      </div>
      {/* content */}
      <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
        <div style={{ flex: 1, overflow: 'auto' }}>{children}</div>
      </div>
      {/* gesture nav pill — absolute, inside the HOME_H region */}
      <div style={{
        position: 'absolute', bottom: 0, left: 0, right: 0, zIndex: 60, height: 24,
        display: 'flex', justifyContent: 'center', alignItems: 'flex-end',
        paddingBottom: 9, pointerEvents: 'none',
      }}>
        <div style={{ width: 120, height: 4, borderRadius: 2, background: dark ? 'rgba(255,255,255,0.65)' : 'rgba(0,0,0,0.55)' }} />
      </div>
    </div>
  );
}

// Expose to other scripts
Object.assign(window, {
  MHAD_PALETTES, MHADContext, SANS, SERIF, MONO, TOK,
  FrameTag, Surface, AndroidShell,
  Screen, Card, Btn, Chip, Badge, CrisisBar, StepHead, StepDots, WizardHeader, TabOnlyPill, BottomBar, Field, ConsentRow, SectionLabel, Editorial,
  BriefCard, SystemCard,
  Arrow, Plus, Check, ChevR, ChevD, Phone, Lock, Eye, EyeOff, Sparkles, Mic, FileText, Heart, Users, Pill, Calendar, Shield, Edit, QR, DotsH, Home, Book, Gear, Bookmark, Download, Share, Search, X, AlertTri, Info, MapPin, Flask, Zap, Brain, Wallet, SwapV, Icon,
});
