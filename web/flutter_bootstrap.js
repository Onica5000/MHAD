// Custom Flutter web bootstrap — DELIBERATELY registers NO service worker.
//
// Why: this app does not want offline caching. The default generated
// bootstrap calls `_flutter.loader.load({ serviceWorkerSettings: {...} })`,
// which installs a service worker that serves the cached app shell
// (index.html + main.dart.js) cache-first. The result is that a fresh deploy
// is NOT seen on the next visit — the SW keeps serving the previous build's
// JavaScript even though GitHub Pages already has the new bytes (a normal F5
// refresh does not fix it, because the navigation itself is served by the SW
// from cache). That staleness is exactly the bug that made layout fixes look
// like they "did nothing" on the live site.
//
// Calling `_flutter.loader.load()` with NO serviceWorkerSettings means Flutter
// never registers a service worker. The app is then always fetched from the
// network (subject only to the 10-minute GitHub Pages HTTP cache), so deploys
// show up immediately on reload. The cleanup snippet in index.html unregisters
// any service worker left over from earlier visits.
//
// {{flutter_js}} and {{flutter_build_config}} are substituted by
// `flutter build web`. Do not remove them.
{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load();
