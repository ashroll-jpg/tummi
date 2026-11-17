// Copies the web app into www/, which Capacitor bundles into the iPhone app.
// The website itself is still served straight from the repo root by GitHub Pages.
const fs = require('fs'), path = require('path');
const root = path.join(__dirname, '..'), out = path.join(root, 'www');
const files = ['index.html', 'manifest.webmanifest', 'apple-touch-icon.png', 'icon-192.png', 'icon-512.png'];
fs.rmSync(out, { recursive: true, force: true }); fs.mkdirSync(out);
for (const f of files) fs.copyFileSync(path.join(root, f), path.join(out, f));
console.log('www/ ready:', files.join(', '));
