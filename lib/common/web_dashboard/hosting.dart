const webDashboardRecoveryFileName = 'sw.js';

// Firefox recovery needs an activated worker and a different document path.
const webDashboardRecoveryWorker = r'''
self.addEventListener('install', event => {
  event.waitUntil(self.skipWaiting());
});

self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    const windows = await self.clients.matchAll({
      type: 'window',
      includeUncontrolled: true,
    });
    await self.clients.claim();
    const worker = self.registration.active;
    const reopen = () => {
      if (worker.state !== 'activated') return;
      worker.removeEventListener('statechange', reopen);
      for (const client of windows) {
        const url = new URL(client.url);
        const panel = url.pathname.match(
          /^\/ui\/(zashboard|metacubexd)\/(?:index\.html)?$/,
        );
        if (url.origin !== self.location.origin || !panel) continue;
        url.pathname = `/ui/${panel[1]}/` +
          (url.pathname.endsWith('index.html') ? '' : 'index.html');
        client.navigate(url.href).catch(() => {});
      }
    };
    worker.addEventListener('statechange', reopen);
    reopen();
  })());
});
''';
