import assert from 'node:assert/strict';
import { mkdir, writeFile } from 'node:fs/promises';
import { resolve, join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { parseArgs } from 'node:util';
import { filterFeatures } from '../assets/model.mjs';

const { values } = parseArgs({ options: {
  url: { type: 'string', default: 'http://127.0.0.1:8788/fork/' },
  playwright: { type: 'string' },
  out: { type: 'string' },
} });
if (!values.out) throw new Error('Pass --out with a scratch directory outside the repository.');
const target = new URL(values.url);
assert.ok(['127.0.0.1', 'localhost'].includes(target.hostname), 'Smoke tests must use the local server.');
const out = resolve(values.out);
await mkdir(out, { recursive: true });
const { chromium } = values.playwright
  ? await import(pathToFileURL(resolve(values.playwright)).href)
  : await import('playwright');
const report = { url: target.href, checks: [], errors: [], skipped: [], expectedErrors: [] };
const expectedFailures = new Set();
const browser = await chromium.launch({ headless: true });

function observe(page) {
  page.on('pageerror', error => report.errors.push(error.message));
  page.on('console', message => {
    if (message.type() !== 'error') return;
    const location = message.location().url;
    if (expectedFailures.has(location) && message.text().includes('status of 400')) report.expectedErrors.push(message.text());
    else report.errors.push(message.text());
  });
  page.on('request', request => assert.equal(new URL(request.url()).origin, target.origin, 'Atlas must not send repository data outside loopback.'));
}

async function ready(page) {
  await page.waitForSelector('#contract-list button');
  await page.waitForFunction(() => !document.body.classList.contains('busy'));
  assert.equal(await page.locator('#error-banner').isVisible(), false, 'Initial repository read must succeed.');
}

async function api(page, endpoint, query = {}) {
  const token = await page.locator('meta[name="atlas-token"]').getAttribute('content');
  const url = new URL(`/api/${endpoint}`, target);
  for (const [key, value] of Object.entries(query)) url.searchParams.set(key, value);
  const response = await page.request.get(url.href, { headers: { 'X-Atlas-Token': token } });
  assert.equal(response.status(), 200, `${endpoint} must be readable`);
  return response.json();
}

async function overflow(page, label) {
  const measure = await page.evaluate(() => ({ width: innerWidth, content: document.documentElement.scrollWidth }));
  assert.ok(measure.content <= measure.width + 1, `${label}: page overflow ${JSON.stringify(measure)}`);
}

async function view(page, name) {
  await page.locator(`[data-view="${name}"]`).click();
  await page.waitForSelector(`#view-${name}:not([hidden])`);
}

async function submitImpact(page, mode, fields = {}) {
  await page.locator('#impact-mode').selectOption(mode);
  for (const [key, value] of Object.entries(fields)) await page.locator(`#impact-${key}`).fill(value);
  const response = page.waitForResponse(response => new URL(response.url()).pathname === '/api/impact' && response.ok());
  await page.locator('#impact-form button[type="submit"]').click();
  const result = await (await response).json();
  await page.waitForFunction(() => !document.querySelector('#impact-form button').disabled);
  assert.equal(await page.locator('#error-banner').isVisible(), false);
  if (result.changes.length) await page.waitForSelector('#file-detail .file-reasons');
  return result;
}

async function capture(page, name) {
  await overflow(page, name);
  await page.screenshot({ path: join(out, `${name}.png`), fullPage: true });
}

try {
  const context = await browser.newContext({ viewport: { width: 1440, height: 960 }, colorScheme: 'light', reducedMotion: 'reduce', permissions: ['clipboard-read', 'clipboard-write'] });
  const page = await context.newPage();
  observe(page);
  await page.goto(target.href);
  await ready(page);
  const snapshot = await api(page, 'snapshot');
  report.head = snapshot.head;
  report.registry = snapshot.registry;
  report.features = snapshot.features.length;
  report.relations = snapshot.relations.length;
  assert.equal(await page.locator('#contract-list button').count(), snapshot.features.length);
  await capture(page, 'desktop-map-light');

  const related = snapshot.relations[0];
  if (related) {
    await page.locator(`#contract-list button[data-feature="${related.from}"]`).click();
    await page.waitForSelector(`#graph g[data-feature="${related.to}"]`);
    await page.locator(`#graph g[data-feature="${related.to}"]`).focus();
    assert.equal(await page.locator('#graph .graph-tooltip').isVisible(), true);
    await page.keyboard.press('Enter');
    assert.equal(await page.locator('#contract-detail h2').textContent(), related.to);
    await page.locator('[data-graph-view="table"]').click();
    assert.ok(await page.locator('#relation-table .relation-row').count() > 0);
    await page.locator('[data-graph-view="graph"]').click();
  }
  await page.locator('#graph-scope').selectOption('all');
  assert.equal(await page.locator('#graph .graph-node').count(), snapshot.features.length);
  const graph = page.locator('#graph > svg');
  const initial = await graph.getAttribute('viewBox');
  const bounds = await graph.boundingBox();
  await page.mouse.move(bounds.x + bounds.width / 2, bounds.y + bounds.height / 2);
  await page.keyboard.down('Control');
  await page.mouse.wheel(0, -120);
  await page.keyboard.up('Control');
  await page.waitForFunction(before => document.querySelector('#graph > svg').getAttribute('viewBox') !== before, initial);
  await page.locator('#graph-fit').click();
  assert.equal(await graph.getAttribute('viewBox'), initial);
  await page.mouse.move(bounds.x + 10, bounds.y + 10);
  await page.mouse.down();
  await page.mouse.move(bounds.x + 55, bounds.y + 30, { steps: 5 });
  await page.mouse.up();
  assert.notEqual(await graph.getAttribute('viewBox'), initial);
  await page.locator('#graph-fit').click();
  await page.keyboard.press('/');
  assert.equal(await page.locator('#contract-search').evaluate(element => element === document.activeElement), true);
  await page.locator('#contract-search').fill(snapshot.features[0].id);
  const searchMatches = filterFeatures(snapshot.features, { query: snapshot.features[0].id });
  await page.waitForFunction(count => document.querySelectorAll('#contract-list button').length === count, searchMatches.length);
  assert.ok(await page.locator(`#contract-list button[data-feature="${snapshot.features[0].id}"]`).count());
  await page.locator('#contract-search').fill('');
  await page.waitForFunction(count => document.querySelectorAll('#contract-list button').length === count, snapshot.features.length);
  await page.locator('#risk-filter').selectOption('critical');
  assert.equal(await page.locator('#contract-list button').count(), snapshot.features.filter(item => item.risk === 'critical').length);
  await page.locator('#risk-filter').selectOption('all');
  report.checks.push('Contract search, keyboard selection, dependency table, filters, zoom, pan and fit');

  await view(page, 'changes');
  await page.waitForFunction(() => !document.querySelector('#impact-form button').disabled);
  const working = await submitImpact(page, 'working');
  await capture(page, 'desktop-working');
  const staged = await submitImpact(page, 'staged');
  assert.ok((await page.locator('#impact-summary').textContent()).includes('Контракты из index'));
  const path = snapshot.features.flatMap(feature => feature.files).find(path => path?.endsWith('.dart') && !path.includes('/generated/'));
  if (path) {
    await submitImpact(page, 'paths', { path });
    assert.equal(await page.locator('#file-detail h2').textContent(), path);
    await page.locator('#file-detail .file-mode button').filter({ hasText: 'До' }).click();
    assert.equal(await page.locator('#file-detail .file-content').count(), 1);
    await page.locator('#file-detail .file-mode button').filter({ hasText: 'После' }).click();
    await page.locator('#file-detail .file-mode button').filter({ hasText: 'Diff' }).click();
    await page.locator('#file-detail .file-mode button').filter({ hasText: 'Скопировать путь' }).click();
    assert.equal(await page.evaluate(() => navigator.clipboard.readText()), path);
  }
  if (snapshot.repository.vendor) {
    const downstream = await submitImpact(page, 'downstream');
    assert.ok(downstream.selection.from && downstream.selection.to, 'Endpoint OIDs must be resolved.');
    await capture(page, 'desktop-downstream');
    const count = downstream.changes.filter(change => !change.direct.length).length;
    await page.locator('#change-filter').selectOption('unclassified');
    await page.waitForFunction(count => document.querySelectorAll('#change-list button').length === count, count);
    if (count) {
      await page.waitForFunction(() => {
        const current = document.querySelector('#change-list button.selected');
        return current && document.querySelector('#file-detail h2')?.textContent === current.dataset.path;
      });
      assert.ok((await page.locator('#file-detail .file-reasons').textContent()).includes('unclassified'));
    }
    await page.locator('#change-search').fill('__atlas_no_matching_path__');
    await page.waitForFunction(() => document.querySelectorAll('#change-list button').length === 0);
    await page.waitForFunction(() => !document.querySelector('#file-detail h2'));
    assert.ok((await page.locator('#file-detail').textContent()).includes('Фильтр исключил все файлы'));
    await page.locator('#change-search').fill('');
    await page.locator('#change-filter').selectOption('all');
    await submitImpact(page, 'refs', { from: snapshot.repository.vendor, to: snapshot.head });
  }
  report.checks.push(`Impact: working ${working.changes.length}, staged ${staged.changes.length}, path, downstream, refs, diff tabs, literal copy and filtered selection`);

  await view(page, 'sync');
  const runs = await api(page, 'syncs');
  const usable = runs.runs.find(run => run.checks && Object.keys(run.checks).length);
  if (usable) {
    const detail = await api(page, 'sync', { id: usable.id });
    await page.locator(`#sync-list button[data-run="${usable.id}"]`).click();
    await page.waitForSelector('#sync-detail .sync-flow');
    assert.equal(await page.locator('#sync-detail h2').textContent(), usable.id);
    if (detail.legacy) assert.ok((await page.locator('#sync-detail').textContent()).includes('не достраивает отсутствующую историю'));
    await capture(page, 'desktop-sync');
    const comparison = page.locator('#sync-detail .detail-actions button').first();
    if (await comparison.count()) {
      await comparison.click();
      await page.waitForSelector('#view-changes:not([hidden])');
      await page.waitForFunction(() => !document.querySelector('#impact-form button').disabled);
    }
    await view(page, 'checks');
    await page.locator('#check-run').selectOption(usable.id);
    assert.ok((await page.locator('#checks-table').textContent()).includes('Исторический результат'));
    await page.locator('#checks-table button').filter({ hasText: 'Открыть лог' }).first().click();
    await page.waitForSelector('#log-dialog[open]');
    await page.waitForFunction(() => document.querySelector('#log-content').textContent !== 'Читаю архивный лог…');
    assert.ok((await page.locator('#log-content').textContent()).length > 0);
    await page.locator('#close-log').click();
  } else report.skipped.push('No existing receipt with check results for archived-log UI');
  await view(page, 'checks');
  await page.locator('#check-run').selectOption('');
  assert.equal(await page.locator('#checks-table .badge.passed').count(), 0);
  assert.equal(await page.locator('#checks-table .badge').count(), Object.keys(snapshot.checks).length);
  await page.locator('#check-filter').selectOption('baseline');
  assert.equal(await page.locator('#checks-table .check-row').count(), Object.values(snapshot.checks).filter(check => check.baseline).length);
  await page.locator('#check-filter').selectOption('all');
  await capture(page, 'desktop-checks');
  report.checks.push('Existing sync receipts, raw comparison, legacy evidence, archived logs, declaration-only checks and baseline filter');

  await view(page, 'attention');
  assert.equal(await page.locator('#attention-list .attention-item').count(), snapshot.notices.length);
  await capture(page, 'desktop-attention');
  await view(page, 'map');
  await page.locator('#theme-toggle').click();
  assert.equal(await page.locator('html').getAttribute('data-theme'), 'dark');
  await capture(page, 'desktop-map-dark');
  await page.reload();
  await ready(page);
  assert.equal(await page.locator('html').getAttribute('data-theme'), 'dark');
  report.checks.push('Attention notices, explicit dark palette and persisted per-viewer theme');

  await page.route('**/api/stamp*', async route => {
    const response = await route.fetch();
    const data = await response.json();
    await route.fulfill({ json: { ...data, fingerprint: 'browser-stale-regression' } });
  });
  await page.evaluate(() => window.dispatchEvent(new Event('focus')));
  await page.waitForSelector('#stale-banner:not([hidden])');
  await page.unroute('**/api/stamp*');
  await page.locator('#refresh-stale').click();
  await ready(page);
  assert.equal(await page.locator('#stale-banner').isVisible(), false);
  expectedFailures.add(new URL('/api/snapshot', target).href);
  await page.route('**/api/snapshot', route => route.fulfill({ status: 400, json: { error: 'Browser read-error regression' } }));
  await page.locator('#refresh').click();
  await page.waitForSelector('#error-banner:not([hidden])');
  assert.equal(await page.locator('#error-banner').textContent(), 'Browser read-error regression');
  await page.unroute('**/api/snapshot');
  expectedFailures.delete(new URL('/api/snapshot', target).href);
  await page.locator('#refresh').click();
  await ready(page);
  report.checks.push('Stale and read-error presentation with intercepted HTTP responses; no live checkout writes');

  const mobile = await browser.newContext({ viewport: { width: 390, height: 844 }, isMobile: true, hasTouch: true, colorScheme: 'light', reducedMotion: 'reduce' });
  const phone = await mobile.newPage();
  observe(phone);
  await phone.addInitScript(() => {
    Object.defineProperty(Storage.prototype, 'getItem', { value() { throw new Error('Blocked storage'); } });
    Object.defineProperty(Storage.prototype, 'setItem', { value() { throw new Error('Blocked storage'); } });
  });
  await phone.goto(target.href);
  await ready(phone);
  for (const name of ['map', 'changes', 'sync', 'checks', 'attention']) {
    await view(phone, name);
    if (name === 'changes') await phone.waitForFunction(() => !document.querySelector('#impact-form button').disabled);
    await capture(phone, `phone-${name}`);
  }
  await phone.locator('#theme-toggle').click();
  assert.equal(await phone.locator('html').getAttribute('data-theme'), 'dark');
  await overflow(phone, 'phone-dark');
  await phone.setViewportSize({ width: 320, height: 740 });
  await view(phone, 'map');
  await capture(phone, 'phone-320-map');
  report.checks.push('All five views at phone width, 320px layout, reduced motion and blocked browser storage');
  assert.deepEqual(report.errors, [], 'Browser must have no runtime or console errors.');
  report.status = 'passed';
  console.log(JSON.stringify(report, null, 2));
} catch (error) {
  report.status = 'failed';
  report.failure = error.stack;
  throw error;
} finally {
  await writeFile(join(out, 'browser-report.json'), `${JSON.stringify(report, null, 2)}\n`);
  await browser.close();
}
