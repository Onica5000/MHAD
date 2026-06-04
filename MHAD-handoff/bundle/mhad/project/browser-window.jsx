
// Chrome.jsx — Chrome / Edge desktop browser window (light theme, Windows chrome)
// No dependencies, no image assets. All inline styles + inline SVG.
// Deliberately Chrome/Edge-on-Windows: light tab strip, Windows min/max/close
// controls (not macOS traffic lights), and a full nav toolbar (back / forward /
// reload / URL pill with lock / extensions / profile / overflow) so the frame
// reads unambiguously as a DESKTOP WEB BROWSER.

const CHROME_C = {
  stripBg: '#dee1e6',   // tab strip
  tabBg:   '#ffffff',   // active tab + toolbar
  text:    '#1f1f1f',
  dim:     '#5f6368',
  urlBg:   '#f1f3f4',   // omnibox
};

function ChromeIcon({ d, size = 16, sw = 2, fill = 'none', stroke = CHROME_C.dim }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill={fill} stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round">
      {d}
    </svg>
  );
}

// Windows-style window controls: minimize, maximize, close
function WinControls() {
  const btn = { width: 46, height: 34, display: 'flex', alignItems: 'center', justifyContent: 'center' };
  return (
    <div style={{ display: 'flex', alignSelf: 'flex-start' }}>
      <div style={btn}><svg width="11" height="11" viewBox="0 0 11 11" stroke="#3c4043" strokeWidth="1"><line x1="1" y1="6" x2="10" y2="6"/></svg></div>
      <div style={btn}><svg width="11" height="11" viewBox="0 0 11 11" fill="none" stroke="#3c4043" strokeWidth="1"><rect x="1.5" y="1.5" width="8" height="8"/></svg></div>
      <div style={{ ...btn }}><svg width="11" height="11" viewBox="0 0 11 11" stroke="#3c4043" strokeWidth="1"><line x1="1.5" y1="1.5" x2="9.5" y2="9.5"/><line x1="9.5" y1="1.5" x2="1.5" y2="9.5"/></svg></div>
    </div>
  );
}

// Single tab (active is a white rounded card sitting on the strip)
function ChromeTab({ title = 'New Tab', active = false }) {
  return (
    <div style={{
      position: 'relative', height: 34, alignSelf: 'flex-end',
      padding: '0 12px', display: 'flex', alignItems: 'center', gap: 9,
      background: active ? CHROME_C.tabBg : 'transparent',
      borderRadius: '9px 9px 0 0', minWidth: 140, maxWidth: 240,
      fontFamily: "'Segoe UI', system-ui, sans-serif", fontSize: 12.5,
      color: active ? CHROME_C.text : CHROME_C.dim,
    }}>
      <div style={{ width: 15, height: 15, borderRadius: '50%', background: '#1a73e8', flexShrink: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', fontSize: 9, fontWeight: 700 }}>m</div>
      <span style={{ flex: 1, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{title}</span>
      <svg width="11" height="11" viewBox="0 0 11 11" stroke={active ? CHROME_C.dim : 'transparent'} strokeWidth="1.4"><line x1="1.5" y1="1.5" x2="9.5" y2="9.5"/><line x1="9.5" y1="1.5" x2="1.5" y2="9.5"/></svg>
    </div>
  );
}

function ChromeTabBar({ tabs = [{ title: 'New Tab' }], activeIndex = 0 }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'flex-end', height: 40,
      background: CHROME_C.stripBg, paddingLeft: 8, paddingTop: 6,
    }}>
      <div style={{ display: 'flex', alignItems: 'flex-end', flex: 1, gap: 2 }}>
        {tabs.map((t, i) => <ChromeTab key={i} title={t.title} active={i === activeIndex} />)}
        <div style={{ width: 28, height: 28, alignSelf: 'center', display: 'flex', alignItems: 'center', justifyContent: 'center', marginLeft: 4 }}>
          <ChromeIcon size={16} sw={2} d={<><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></>} />
        </div>
      </div>
      <WinControls />
    </div>
  );
}

function ChromeToolbar({ url = 'example.com' }) {
  const navBtn = (d, sw = 2) => (
    <div style={{ width: 30, height: 30, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      <ChromeIcon size={18} sw={sw} d={d} />
    </div>
  );
  return (
    <div style={{
      height: 44, background: CHROME_C.tabBg,
      display: 'flex', alignItems: 'center', gap: 2, padding: '0 8px',
      borderBottom: '1px solid #e3e5e8',
    }}>
      {navBtn(<polyline points="15 18 9 12 15 6"/>)}
      {navBtn(<polyline points="9 18 15 12 9 6"/>)}
      {navBtn(<><path d="M23 4v6h-6"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></>)}
      {/* omnibox */}
      <div style={{
        flex: 1, height: 32, borderRadius: 16, background: CHROME_C.urlBg,
        display: 'flex', alignItems: 'center', gap: 9, padding: '0 14px',
        margin: '0 8px',
      }}>
        <ChromeIcon size={13} sw={2.2} d={<><rect x="4" y="11" width="16" height="9" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/></>} />
        <span style={{ flex: 1, color: CHROME_C.text, fontSize: 13, fontFamily: "'Segoe UI', system-ui, sans-serif", whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{url}</span>
        <ChromeIcon size={15} sw={2} d={<><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></>} />
      </div>
      {/* extensions puzzle */}
      {navBtn(<path d="M14.5 3.5a2 2 0 1 0-4 0V5H8a2 2 0 0 0-2 2v2.5H4.5a2 2 0 1 0 0 4H6V16a2 2 0 0 0 2 2h2.5v1.5a2 2 0 1 0 4 0V18H17a2 2 0 0 0 2-2v-2.5h1.5a2 2 0 1 0 0-4H19V7a2 2 0 0 0-2-2h-2.5z"/>, 1.6)}
      {/* profile */}
      <div style={{ width: 28, height: 28, borderRadius: '50%', background: '#c2185b', color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 12, fontWeight: 600, marginLeft: 2, fontFamily: "'Segoe UI', system-ui" }}>A</div>
      {/* overflow menu (3 vertical dots = Chrome; Edge uses horizontal, dots read as either) */}
      <div style={{ width: 30, height: 30, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <svg width="4" height="16" viewBox="0 0 4 16" fill={CHROME_C.dim}><circle cx="2" cy="2" r="2"/><circle cx="2" cy="8" r="2"/><circle cx="2" cy="14" r="2"/></svg>
      </div>
    </div>
  );
}

function ChromeWindow({
  tabs = [{ title: 'New Tab' }], activeIndex = 0, url = 'example.com',
  width = 900, height = 600, children,
}) {
  return (
    <div style={{
      width, height, borderRadius: 10, overflow: 'hidden',
      boxShadow: '0 24px 80px rgba(0,0,0,0.28), 0 0 0 1px rgba(0,0,0,0.08)',
      display: 'flex', flexDirection: 'column', background: CHROME_C.tabBg,
    }}>
      <ChromeTabBar tabs={tabs} activeIndex={activeIndex} />
      <ChromeToolbar url={url} />
      <div style={{ flex: 1, background: '#fff', overflow: 'auto' }}>
        {children}
      </div>
    </div>
  );
}

Object.assign(window, {
  ChromeWindow, ChromeTabBar, ChromeToolbar, ChromeTab, WinControls,
});
