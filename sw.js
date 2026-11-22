// Tummi service worker: makes the app open offline and pick up new versions reliably.
// The page itself is fetched fresh whenever there's a connection (falling back to the saved copy offline);
// icons, Leaflet and fonts come from the cache. Data APIs (Firebase, search, map tiles) are never cached here.
const VERSION = 'tummi-1.5.1';   // keep in step with APP_VERSION in index.html
const SHELL = ['./', './index.html', './manifest.webmanifest', './apple-touch-icon.png', './icon-192.png', './icon-512.png'];
const STATIC_HOSTS = ['cdnjs.cloudflare.com', 'fonts.googleapis.com', 'fonts.gstatic.com'];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(VERSION).then(c => c.addAll(SHELL)).then(() => self.skipWaiting()));
});
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(k => k !== VERSION).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});

async function pageFirst(req) {
  const cache = await caches.open(VERSION);
  try {
    const ctrl = new AbortController(); const t = setTimeout(() => ctrl.abort(), 5000);
    const res = await fetch(req, { cache: 'no-cache', signal: ctrl.signal }); clearTimeout(t);
    if (res.ok) cache.put('./index.html', res.clone());
    return res;
  } catch (e) {
    return (await cache.match('./index.html')) || (await cache.match('./')) || Response.error();
  }
}
async function cacheFirst(req) {
  const cache = await caches.open(VERSION);
  const hit = await cache.match(req);
  if (hit) return hit;
  const res = await fetch(req);
  if (res.ok || res.type === 'opaque') cache.put(req, res.clone());
  return res;
}

self.addEventListener('fetch', e => {
  const req = e.request; if (req.method !== 'GET') return;
  const url = new URL(req.url);
  if (req.mode === 'navigate' && url.origin === location.origin) { e.respondWith(pageFirst(req)); return; }
  if (url.origin === location.origin && /\.(png|webmanifest)$/.test(url.pathname)) { e.respondWith(cacheFirst(req)); return; }
  if (STATIC_HOSTS.includes(url.hostname)) { e.respondWith(cacheFirst(req)); return; }
  // everything else (Firestore, Photon, Overpass, Nominatim, map tiles) goes straight to the network
});
