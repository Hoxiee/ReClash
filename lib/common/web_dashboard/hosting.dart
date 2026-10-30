const webDashboardRecoveryFileName = 'sw.js';

const _zashboardSetupBootstrap = r'''
<script id="reclash-zashboard-setup">
if (location.hash.startsWith('#/setup?')) {
  const query = new URLSearchParams(location.hash.slice(8));
  if (query.has('hostname') && query.has('port') && query.has('secret')) {
    try {
      localStorage.removeItem('setup/active-uuid');
    } catch (_) {}
  }
}
</script>
''';

String prepareZashboardHtml(String html) {
  if (html.contains(_zashboardSetupBootstrap)) return html;
  final head = RegExp(r'<head\b[^>]*>', caseSensitive: false).firstMatch(html);
  final doctype = RegExp(
    r'^\s*<!doctype\b[^>]*>',
    caseSensitive: false,
  ).firstMatch(html);
  final offset = head?.end ?? doctype?.end ?? 0;
  return html.replaceRange(offset, offset, _zashboardSetupBootstrap);
}

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
        if (url.origin !== self.location.origin || !panel ||
            !url.href.startsWith(self.registration.scope)) continue;
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
