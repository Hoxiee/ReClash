import { filterFeatures, neighbourhood, layoutGraph, changesMatching, patchLines, shortOid, commandText, superellipsePath } from './model.mjs';

const $ = id => document.getElementById(id);
const token = document.querySelector('meta[name="atlas-token"]').content;
const state = {
  snapshot: null, features: new Map(), selected: null, view: 'map', graphView: 'graph', graphScope: 'near',
  impact: null, impactLoading: false, selection: { mode: 'working' }, impactRequest: 0, fileRequest: 0, file: null, filePath: null, fileMode: 'patch',
  runs: [], run: null, syncRequest: 0, checkRun: null, checkFocus: null, stale: false, graphViewport: null,
};

function node(tag, className, text) {
  const element = document.createElement(tag);
  if (className) element.className = className;
  if (text !== undefined && text !== null) element.textContent = String(text);
  return element;
}

function svgNode(tag, attributes = {}) {
  const element = document.createElementNS('http://www.w3.org/2000/svg', tag);
  for (const [key, value] of Object.entries(attributes)) element.setAttribute(key, String(value));
  return element;
}

function button(text, handler, className = 'text-link') {
  const element = node('button', className, text);
  element.type = 'button';
  element.addEventListener('click', handler);
  return element;
}

function badge(text, kind = '') {
  return node('span', `badge ${kind}`, text);
}

function empty(target, title, detail) {
  const wrapper = node('div', 'empty-state');
  wrapper.append(node('strong', '', title), node('span', '', detail));
  target.replaceChildren(wrapper);
}

function section(title, className = 'detail-section') {
  const element = node('section', className);
  element.append(node('h3', '', title));
  return element;
}

const statusNames = { passed: '✓ Passed', failed: '× Failed', waived: '↷ Waived', 'not-run': 'Не запускалась', accepted: 'Принято', verified: 'Verified', stale: 'Устарело', candidate: 'Кандидат', unverified: 'Не проверено', 'missing-receipt': 'Receipt отсутствует', unavailable: 'Недоступно' };
const riskNames = { critical: '! Critical', routine: 'Routine' };
const noticeNames = { blocker: 'Блокирует sync', review: 'Нужен review', info: 'К сведению' };
const noticeCopy = {
  normalizer: ['Fingerprint normalizer изменился', 'Обычная подготовка sync заблокирована. Нужна отдельно согласованная recipe migration на точном принятом raw source.'],
  unclassified: ['Неклассифицированные downstream-пути', 'Для этих файлов нет active watch или sentinel. Нужно уточнить контракт либо провести явный unclassified review.'],
  vendor: ['Нет принятого vendor snapshot', 'В этой копии ещё не установлена нормализованная vendor-база.'],
  base: ['Product base требует проверки', 'Для обычного sync нужен отдельный parentless product base, соответствующий принятому vendor.'],
  source: ['Источник не совпадает с config', 'Проверьте remote и URL источника. Atlas ничего не загружает и не исправляет автоматически.'],
  ancestry: ['Product base вне downstream-истории', 'Принятая база должна находиться в first-parent истории development.'],
  linearity: ['В downstream-стеке есть merge commits', 'Sync ожидает линейный replay поверх принятой product base.'],
  provenance: ['Provenance vendor требует проверки', 'Сохранённые идентификаторы источника и деревьев не прошли проверку.'],
};

async function api(endpoint, query = {}) {
  if (token === '__ATLAS_TOKEN__') throw new Error('Откройте Atlas через локальный сервер: dart run site/fork/server.dart');
  const url = new URL(`/api/${endpoint}`, location.origin);
  for (const [key, value] of Object.entries(query)) if (value !== null && value !== undefined) url.searchParams.set(key, value);
  const response = await fetch(url, { headers: { 'X-Atlas-Token': token }, cache: 'no-store' });
  const data = await response.json();
  if (!response.ok) throw new Error(data.error || `Ошибка чтения: ${response.status}`);
  return data;
}

function error(message) {
  $('error-banner').textContent = message;
  $('error-banner').hidden = false;
}

function toast(message) {
  $('toast').textContent = message;
  $('toast').hidden = false;
  clearTimeout(toast.timer);
  toast.timer = setTimeout(() => { $('toast').hidden = true; }, 2600);
}

async function copy(text) {
  try { await navigator.clipboard.writeText(text); toast('Скопировано'); }
  catch { toast('Не удалось скопировать. Выделите текст вручную.'); }
}

function date(value) {
  if (!value) return '—';
  const parsed = new Date(value);
  return Number.isNaN(parsed.valueOf()) ? String(value) : parsed.toLocaleString('ru', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' });
}

function setBusy(value) {
  document.body.classList.toggle('busy', value);
  $('refresh').disabled = value;
  $('workspace').setAttribute('aria-busy', value ? 'true' : 'false');
}

async function refresh() {
  setBusy(true);
  $('error-banner').hidden = true;
  try {
    const data = await api('snapshot');
    ++state.impactRequest;
    ++state.fileRequest;
    state.impact = null; state.file = null; state.filePath = null; state.impactLoading = false;
    $('impact-form').querySelector('button').disabled = false;
    state.snapshot = data;
    state.features = new Map(data.features.map(feature => [feature.id, feature]));
    if (!state.features.has(state.selected)) state.selected = state.features.has('tools.catalog') ? 'tools.catalog' : data.features[0]?.id;
    state.stale = false;
    $('stale-banner').hidden = true;
    renderRepository();
    renderContractList();
    renderGraph();
    renderContractDetail();
    renderAttention();
    await loadRuns();
    renderChecks();
    renderCurrentHistory();
    if (state.view === 'changes') await loadImpact(state.selection);
    if (state.view === 'sync' && state.run) await loadRun(state.run.id);
  } catch (exception) { error(exception.message); }
  finally { setBusy(false); }
}

function renderRepository() {
  const { repository: repo, features } = state.snapshot;
  $('repo-context').replaceChildren(node('span', 'live-dot'), node('span', '', repo.branch), node('code', '', shortOid(repo.head)));
  $('feature-count').textContent = `${features.length} контрактов / ${features.filter(feature => feature.risk === 'critical').length} critical`;
  $('footer-source').textContent = `${repo.name} / ${repo.branch} / ${shortOid(repo.head)}`;
  $('footer-time').textContent = `Снимок: ${date(state.snapshot.generatedAt)}`;
  $('git-refs').replaceChildren(...repo.refs.map(ref => { const item = node('option'); item.value = ref; return item; }));
}

function filteredContracts() {
  return filterFeatures(state.snapshot?.features || [], { query: $('contract-search').value, risk: $('risk-filter').value, state: $('state-filter').value });
}

function renderContractList() {
  const features = filteredContracts();
  $('contract-list-count').textContent = `Показано ${features.length} из ${state.features.size}`;
  $('contract-list').replaceChildren();
  if (!features.length) return empty($('contract-list'), 'Контракты не найдены', 'Измените запрос или фильтры.');
  let group = null;
  for (const feature of features) {
    const next = feature.id.split('.')[0];
    if (next !== group) { $('contract-list').append(node('p', 'contract-group', next)); group = next; }
    const item = button('', () => selectFeature(feature.id), 'contract-item');
    item.setAttribute('aria-pressed', String(feature.id === state.selected));
    item.dataset.feature = feature.id;
    item.append(node('i', `contract-symbol ${feature.risk === 'critical' ? 'critical' : ''}`, feature.risk === 'critical' ? '!' : '·'), node('span', '', feature.id), node('small', '', feature.state));
    $('contract-list').append(item);
  }
}

function selectFeature(id) {
  if (!state.features.has(id)) return;
  state.selected = id;
  state.graphViewport = null;
  renderContractList();
  renderGraph();
  renderContractDetail();
}

function openFeature(id) {
  if (state.features.has(id)) selectFeature(id);
  location.hash = 'map';
}

function graphFeatures() {
  const features = filteredContracts();
  if (state.graphScope === 'all' || !state.selected) return features;
  const scope = neighbourhood(state.snapshot.features, state.snapshot.relations, state.selected, state.graphScope === 'cluster' ? state.features.size : 1);
  return features.filter(feature => scope.has(feature.id));
}

function renderGraph() {
  if (!state.snapshot) return;
  const features = graphFeatures();
  const layout = layoutGraph(features, state.snapshot.relations);
  const ids = new Set(features.map(feature => feature.id));
  const relations = layout.edges;
  $('graph-summary').replaceChildren(node('strong', '', state.selected || 'Контракты'), node('span', '', `${features.length} узлов / ${relations.length} связей`));
  $('graph').hidden = state.graphView !== 'graph';
  $('relation-table').hidden = state.graphView !== 'table';
  for (const item of document.querySelectorAll('[data-graph-view]')) item.setAttribute('aria-pressed', String(item.dataset.graphView === state.graphView));
  renderRelationTable(relations, ids);
  $('graph').replaceChildren();
  if (!features.length) return empty($('graph'), 'В этом срезе нет контрактов', 'Сбросьте фильтр или выберите «Все контракты».');
  const svg = svgNode('svg', { viewBox: `0 0 ${layout.width} ${layout.height}`, role: 'group', 'aria-label': `Карта ${features.length} контрактов. Стрелки указывают на зависимости.` });
  const defs = svgNode('defs');
  for (const [name, color] of [['edge', 'var(--line-strong)'], ['selected', 'var(--atlas-edge)']]) {
    const marker = svgNode('marker', { id: `arrow-${name}`, viewBox: '0 0 8 8', refX: 7, refY: 4, markerWidth: 5, markerHeight: 5, orient: 'auto-start-reverse' });
    marker.append(svgNode('path', { d: 'M1 1 7 4 1 7', fill: 'none', stroke: color, 'stroke-width': 1.5 }));
    defs.append(marker);
  }
  svg.append(defs);
  const positions = new Map(layout.nodes.map(item => [item.id, item]));
  const tooltip = node('div', 'graph-tooltip');
  tooltip.hidden = true;
  function showTooltip(text, event) {
    tooltip.textContent = text;
    tooltip.hidden = false;
    const bounds = $('graph').getBoundingClientRect();
    const x = event.clientX || bounds.left + 20;
    const y = event.clientY || bounds.top + 20;
    tooltip.style.left = `${Math.max(8, Math.min(bounds.width - 280, x - bounds.left + 12))}px`;
    tooltip.style.top = `${Math.max(8, Math.min(bounds.height - 60, y - bounds.top + 12))}px`;
  }
  for (const relation of relations) {
    const from = positions.get(relation.from), to = positions.get(relation.to);
    const x1 = from.x + from.width, y1 = from.y + from.height / 2, x2 = to.x, y2 = to.y + to.height / 2;
    const curve = Math.max(25, (x2 - x1) / 2);
    const path = `M${x1} ${y1} C${x1 + curve} ${y1}, ${x2 - curve} ${y2}, ${x2 - 5} ${y2}`;
    const connected = relation.from === state.selected || relation.to === state.selected;
    const edge = svgNode('path', { d: path, class: `graph-edge ${connected ? 'connected' : ''}`, 'marker-end': `url(#arrow-${connected ? 'selected' : 'edge'})` });
    const hit = svgNode('path', { d: path, class: 'graph-edge-hit' });
    const title = `${relation.from} зависит от ${relation.to} — явный deps`;
    hit.append(svgNode('title'));
    hit.firstChild.textContent = title;
    hit.addEventListener('pointermove', event => showTooltip(title, event));
    hit.addEventListener('pointerleave', () => { tooltip.hidden = true; });
    svg.append(edge, hit);
  }
  for (const item of layout.nodes) {
    const group = svgNode('g', { transform: `translate(${item.x} ${item.y})`, class: `graph-node ${item.id === state.selected ? 'selected' : ''}`, tabindex: 0, role: 'button', 'aria-label': `${item.id}, ${item.risk}, ${item.state}` });
    group.dataset.feature = item.id;
    group.append(svgNode('path', { d: superellipsePath(item.width, item.height), class: 'node-outline' }));
    const title = svgNode('text', { x: 12, y: 21, class: 'node-title' }); title.textContent = item.id;
    const meta = svgNode('text', { x: 12, y: 38, class: 'node-meta' }); meta.textContent = `${item.kind} / ${item.state}`;
    group.append(title, meta);
    if (item.risk === 'critical') { const mark = svgNode('text', { x: 194, y: 21, class: 'critical-mark' }); mark.textContent = '!'; group.append(mark); }
    group.addEventListener('click', () => { if (!svg.dataset.wasDragged) selectFeature(item.id); });
    group.addEventListener('keydown', event => { if (event.key === 'Enter' || event.key === ' ') { event.preventDefault(); selectFeature(item.id); } });
    group.addEventListener('pointermove', event => showTooltip(`${item.id}: ${Object.values(item.must || {})[0] || item.kind}`, event));
    group.addEventListener('focus', event => showTooltip(`${item.id}: ${Object.values(item.must || {})[0] || item.kind}`, event));
    group.addEventListener('pointerleave', () => { tooltip.hidden = true; });
    group.addEventListener('blur', () => { tooltip.hidden = true; });
    svg.append(group);
  }
  attachGraphViewport(svg, layout);
  $('graph').append(svg, tooltip);
}

function attachGraphViewport(svg, layout) {
  let view = { x: 0, y: 0, width: layout.width, height: layout.height };
  function update() { svg.setAttribute('viewBox', `${view.x} ${view.y} ${view.width} ${view.height}`); }
  state.graphViewport = { fit: () => { view = { x: 0, y: 0, width: layout.width, height: layout.height }; update(); } };
  svg.addEventListener('wheel', event => {
    if (!event.ctrlKey && !event.metaKey) return;
    event.preventDefault();
    const scale = event.deltaY > 0 ? 1.12 : 0.88;
    const width = Math.max(layout.width * 0.25, Math.min(layout.width * 2, view.width * scale));
    const height = view.height * width / view.width;
    view.x += (view.width - width) / 2; view.y += (view.height - height) / 2;
    view.width = width; view.height = height; update();
  }, { passive: false });
  let drag = null;
  svg.addEventListener('pointerdown', event => {
    if (event.button !== 0) return;
    drag = { x: event.clientX, y: event.clientY, viewX: view.x, viewY: view.y, moved: false };
    delete svg.dataset.wasDragged;
  });
  svg.addEventListener('pointermove', event => {
    if (!drag || !(event.buttons & 1)) return;
    const bounds = svg.getBoundingClientRect();
    if (Math.abs(event.clientX - drag.x) + Math.abs(event.clientY - drag.y) > 5) drag.moved = true;
    if (!drag.moved) return;
    svg.classList.add('dragging');
    view.x = drag.viewX - (event.clientX - drag.x) / bounds.width * view.width;
    view.y = drag.viewY - (event.clientY - drag.y) / bounds.height * view.height;
    update();
  });
  function finish() { if (drag?.moved) { svg.dataset.wasDragged = 'true'; setTimeout(() => delete svg.dataset.wasDragged, 50); } drag = null; svg.classList.remove('dragging'); }
  svg.addEventListener('pointerup', finish);
  svg.addEventListener('pointerleave', finish);
}

function renderRelationTable(relations, ids) {
  $('relation-table').replaceChildren();
  if (!relations.length) return empty($('relation-table'), 'Явных deps в этом срезе нет', 'Watch и sentinel остаются доступными в инспекторе.');
  for (const relation of relations) {
    if (!ids.has(relation.from) || !ids.has(relation.to)) continue;
    const row = node('div', 'relation-row');
    row.append(button(relation.from, () => selectFeature(relation.from)), node('span', '', 'зависит от — deps'), button(relation.to, () => selectFeature(relation.to)));
    $('relation-table').append(row);
  }
}

function renderContractDetail() {
  const feature = state.features.get(state.selected);
  const target = $('contract-detail');
  target.replaceChildren();
  if (!feature) return empty(target, 'Выберите контракт', 'Намерение и связи появятся здесь.');
  const heading = node('div', 'detail-heading');
  heading.append(node('h2', '', feature.id));
  const tags = node('div', 'detail-tags'); tags.append(badge(riskNames[feature.risk], feature.risk), badge(feature.kind), badge(feature.state)); heading.append(tags);
  target.append(heading);
  const invariants = section('Что должно сохраниться');
  for (const [id, statement] of Object.entries(feature.must)) {
    const definition = node('dl', 'invariant');
    const detail = node('dd', '', statement);
    const checks = Object.entries(feature.checks || {}).filter(([, covered]) => covered.includes(id)).map(([check]) => check);
    const covered = node('div', 'invariant-checks');
    if (!checks.length) covered.append(badge('Нет привязки к проверке', 'review'));
    else { covered.append(node('span', '', 'Заявлено: ')); checks.forEach((check, i) => { if (i) covered.append(document.createTextNode(', ')); covered.append(button(check, () => openCheck(check))); }); }
    detail.append(covered); definition.append(node('dt', '', id), detail); invariants.append(definition);
  }
  target.append(invariants);
  const connections = section('Связи контракта');
  const dependencies = state.snapshot.relations.filter(edge => edge.from === feature.id).map(edge => edge.to);
  const dependents = state.snapshot.relations.filter(edge => edge.to === feature.id).map(edge => edge.from);
  for (const [name, ids] of [['Зависит от', dependencies], ['От него зависят', dependents]]) {
    const list = node('div', 'path-list');
    list.append(node('span', 'small-muted', name));
    if (!ids.length) list.append(node('span', 'small-muted', 'Нет явных deps'));
    else for (const id of ids) list.append(button(id, () => selectFeature(id)));
    connections.append(list);
  }
  target.append(connections);
  const paths = section('Где искать реализацию');
  const watch = node('details'); watch.append(node('summary', '', `Watch: ${feature.watch.length} шаблонов`));
  const patterns = node('div', 'path-list');
  for (const pattern of feature.watch) patterns.append(node('code', '', pattern));
  watch.append(patterns); paths.append(watch);
  const files = node('details'); files.append(node('summary', '', `Файлы checkout: ${feature.files?.length || 0}`));
  const fileList = node('div', 'path-list');
  for (const path of (feature.files || []).slice(0, 80)) fileList.append(button(path, () => inspectPath(path)));
  if ((feature.files || []).length > 80) fileList.append(node('span', 'small-muted', 'Первые 80 файлов. Поиск по пути доступен во «Влиянии изменений».'));
  files.append(fileList); paths.append(files);
  const sentinels = Object.entries(state.snapshot.sentinels).filter(([, ids]) => ids.includes(feature.id));
  const sentinel = node('details'); sentinel.append(node('summary', '', `Sentinels: ${sentinels.length}`));
  const sentinelList = node('div', 'path-list'); for (const [pattern] of sentinels) sentinelList.append(node('code', '', pattern)); sentinel.append(sentinelList); paths.append(sentinel);
  target.append(paths);
  const intent = section('Решение о собственном коде');
  if (feature.why) intent.append(node('p', '', feature.why));
  intent.append(node('p', '', feature.drop || 'Условие удаления downstream-реализации не задано.'));
  if (feature.evidence) intent.append(node('p', '', `Evidence: ${feature.evidence}`));
  const actions = node('div', 'detail-actions');
  actions.append(button('Скопировать context', () => copy(`dart run tool/fork.dart context --id ${feature.id}`), 'action-button compact'));
  intent.append(actions); target.append(intent);
  const source = section('Исходный контракт');
  const disclosure = node('details'); disclosure.append(node('summary', '', `.fork/features/${feature.id}.yaml`), node('pre', 'yaml-source', feature.yaml)); source.append(disclosure); target.append(source);
}

function openCheck(id) { state.checkFocus = id; $('check-search').value = id; renderChecks(); location.hash = 'checks'; }

async function inspectPath(path) {
  $('impact-mode').value = 'paths'; $('impact-path').value = path; updateComparisonFields();
  state.selection = { mode: 'paths', path };
  location.hash = 'changes';
  await loadImpact(state.selection);
}

function updateComparisonFields() {
  const mode = $('impact-mode').value;
  for (const item of document.querySelectorAll('.ref-field')) item.hidden = mode !== 'refs';
  for (const item of document.querySelectorAll('.path-field')) item.hidden = mode !== 'paths';
}

async function loadImpact(selection) {
  const request = ++state.impactRequest;
  ++state.fileRequest;
  state.impactLoading = true;
  state.selection = selection;
  $('impact-form').querySelector('button').disabled = true;
  $('error-banner').hidden = true;
  try {
    const result = await api('impact', selection);
    if (request !== state.impactRequest) return;
    state.impact = result; state.file = null; state.filePath = null;
    $('impact-stamp').textContent = `Снимок ${shortOid(result.head)} / ${date(result.generatedAt)}`;
    renderImpactSummary(); renderChanges(); renderImpactDetail();
    const visible = visibleChanges();
    if (visible.length) await loadFile(visible[0].path);
    else empty($('file-detail'), 'В этом срезе нет изменений', 'Выберите другой источник или снимите фильтры.');
  } catch (exception) { if (request === state.impactRequest) error(exception.message); }
  finally { if (request === state.impactRequest) { state.impactLoading = false; $('impact-form').querySelector('button').disabled = false; } }
}

function visibleChanges() {
  if (!state.impact) return [];
  const features = new Map(state.impact.features.map(feature => [feature.id, feature]));
  return changesMatching(state.impact.changes, { query: $('change-search').value, filter: $('change-filter').value }, features);
}

async function applyChangeFilter() {
  const changes = visibleChanges();
  if (changes.some(change => change.path === state.filePath)) { renderChanges(); return; }
  ++state.fileRequest;
  state.file = null; state.filePath = null;
  renderChanges();
  if (changes.length) await loadFile(changes[0].path);
  else empty($('file-detail'), 'Фильтр исключил все файлы', 'Снимите фильтр или измените поиск.');
}

function renderImpactSummary() {
  if (!state.impact) return;
  const result = state.impact.impact;
  const target = $('impact-summary'); target.replaceChildren();
  for (const [amount, label] of [[state.impact.changes.length, 'файлов'], [Object.keys(result.features).length, 'контрактов'], [result.critical.length, 'critical'], [result.unclassified.length, 'unclassified'], [result.checks.length, 'проверок']]) {
    const item = node('span'); item.append(node('b', '', amount), document.createTextNode(` ${label}`)); target.append(item);
  }
  if (state.selection.mode === 'staged') target.append(badge('Контракты из index'));
  if (state.selection.mode === 'sync' && state.selection.lens === 'raw') target.append(badge('Raw paths: до нормализации', 'review'));
}

function renderChanges() {
  const changes = visibleChanges();
  $('change-count').textContent = `Показано ${changes.length} из ${state.impact?.changes.length || 0}`;
  const target = $('change-list'); target.replaceChildren();
  if (!changes.length) return empty(target, 'Файлы не найдены', 'Измените фильтр или источник.');
  for (const change of changes) {
    const item = button('', () => loadFile(change.path), `change-item ${state.filePath === change.path ? 'selected' : ''}`);
    item.dataset.path = change.path;
    item.append(node('span', 'change-status', { add: '+', delete: '−', modify: '~', inspect: '·' }[change.status] || '~'));
    const detail = node('span'); detail.append(node('span', 'path', change.path));
    const direct = new Set((change.direct || []).map(reason => reason.feature));
    detail.append(node('div', 'change-meta', direct.size ? `${change.kind} / ${direct.size} прямых контрактов` : `${change.kind} / unclassified`)); item.append(detail); target.append(item);
  }
}

async function loadFile(path) {
  const request = ++state.fileRequest;
  state.filePath = path;
  renderChanges();
  if (!state.file) empty($('file-detail'), path, 'Читаю ограниченный diff preview…');
  try {
    const endpoints = state.impact?.selection;
    const selection = endpoints?.to ? { mode: 'refs', from: endpoints.from, to: endpoints.to } : state.selection;
    const result = await api('file', { ...selection, path });
    if (request !== state.fileRequest) return;
    state.file = result; state.fileMode = 'patch'; renderFile();
  } catch (exception) { if (request === state.fileRequest) { state.file = null; empty($('file-detail'), 'Файл не удалось прочитать', exception.message); } }
}

function renderFile() {
  const file = state.file;
  if (!file) return;
  const target = $('file-detail'); target.replaceChildren();
  const heading = node('div', 'file-heading'); heading.append(node('h2', '', file.path));
  const tags = node('div', 'detail-tags'); tags.append(badge(file.before.kind), node('span', 'small-muted', '→'), badge(file.after.kind)); heading.append(tags); target.append(heading);
  const modes = node('div', 'file-mode');
  for (const [key, label] of [['patch', 'Diff'], ['before', 'До'], ['after', 'После']]) { const item = button(label, () => { state.fileMode = key; renderFile(); }, ''); item.setAttribute('aria-pressed', String(state.fileMode === key)); modes.append(item); }
  modes.append(button('Скопировать путь', () => copy(file.path), 'text-link')); target.append(modes);
  if (state.fileMode === 'patch') {
    const preview = node('div', 'diff-preview');
    if (!file.patch) preview.append(node('span', 'diff-line context', 'Нет текстового diff: файл не изменён в этом сравнении.'));
    else for (const line of patchLines(file.patch)) preview.append(node('span', `diff-line ${line.kind}`, line.text));
    target.append(preview);
  } else {
    const data = file[state.fileMode];
    const preview = node('pre', 'file-content', data.content); target.append(preview);
    if (data.truncated) target.append(node('p', 'small-muted', 'Preview ограничен по размеру. Исходный файл не изменён.'));
  }
  const reasons = node('section', 'file-reasons'); reasons.append(node('h3', '', 'Почему этот путь влияет на контракты'));
  if (!file.direct.length) reasons.append(node('p', 'small-muted', 'Нет watch или sentinel: путь unclassified. Это не означает, что он безопасен.'));
  const seen = new Set();
  for (const reason of file.direct) {
    const key = `${reason.feature}/${reason.via}/${reason.pattern}`;
    if (seen.has(key)) continue; seen.add(key);
    const row = node('div', 'reason-row'); row.append(button(reason.feature, () => openFeature(reason.feature)), node('code', '', `${reason.via}: ${reason.pattern}`)); reasons.append(row);
  }
  const indirect = Object.keys(file.impact.features).filter(id => !file.direct.some(reason => reason.feature === id));
  if (indirect.length) {
    reasons.append(node('p', 'small-muted', 'Транзитивное влияние через deps / dependents:'));
    const list = node('div', 'path-list'); for (const id of indirect) list.append(button(id, () => openFeature(id))); reasons.append(list);
  }
  target.append(reasons);
}

function renderImpactDetail() {
  const target = $('impact-detail'); target.replaceChildren();
  if (!state.impact) return;
  const affected = section('Затронутые контракты');
  affected.append(node('p', 'reason-note', 'Для всего сравнения, независимо от фильтра файлов.'));
  for (const [id, impact] of Object.entries(state.impact.impact.features)) {
    const item = node('div', 'affected-item'); item.append(button(id, () => openFeature(id)), badge(impact.risk === 'critical' ? '! Critical' : impact.state, impact.risk)); affected.append(item);
    const direct = state.impact.changes.some(change => change.direct.some(reason => reason.feature === id));
    affected.append(node('p', 'reason-note', direct ? 'Прямое watch / sentinel совпадение' : 'Через зависимости / зависимые контракты'));
    if (impact.uncovered.length) affected.append(badge(`Unmapped: ${impact.uncovered.join(', ')}`, 'review'));
  }
  if (!Object.keys(state.impact.impact.features).length) affected.append(node('p', 'small-muted', 'Нет классифицированного влияния.'));
  target.append(affected);
  const checks = section('Что нужно проверить');
  for (const check of state.impact.impact.checks) checks.append(button(check, () => openCheck(check), 'check-chip'));
  checks.append(node('p', 'reason-note', 'Baseline включён всегда. Здесь список требований, а не результаты запуска.')); target.append(checks);
  const groups = section('Кластеры разрешения');
  const list = node('ul', 'cluster-list');
  for (const cluster of state.impact.clusters) list.append(node('li', '', cluster.join(', ')));
  if (!state.impact.clusters.length) list.append(node('li', '', 'Нет кластеров в этом сравнении.'));
  groups.append(list); target.append(groups);
}

async function loadRuns() {
  const data = await api('syncs');
  state.runs = data.runs;
  renderRuns();
  const selected = $('check-run').value;
  $('check-run').replaceChildren();
  const option = node('option', '', 'Без запуска: только декларации'); option.value = ''; $('check-run').append(option);
  for (const run of state.runs) { const item = node('option', '', `${run.id} (${statusNames[run.status] || run.status})`); item.value = run.id; $('check-run').append(item); }
  $('check-run').value = state.runs.some(run => run.id === selected) ? selected : '';
  if ($('check-run').value) state.checkRun = state.runs.find(run => run.id === $('check-run').value);
  else state.checkRun = null;
}

function renderRuns() {
  const target = $('sync-list'); target.replaceChildren();
  if (!state.runs.length) return empty(target, 'Архивов sync пока нет', 'Atlas читает существующие наблюдения из Git common-dir.');
  for (const run of state.runs) {
    const item = button('', () => loadRun(run.id), `sync-item ${state.run?.id === run.id ? 'selected' : ''}`);
    item.dataset.run = run.id;
    item.append(node('strong', '', run.id), badge(statusNames[run.status] || run.status, run.status), node('span', '', `raw ${shortOid(run.source)} / vendor ${shortOid(run.prepared)}`));
    target.append(item);
  }
}

async function loadRun(id) {
  const request = ++state.syncRequest;
  const known = state.runs.find(run => run.id === id);
  if (known?.status === 'missing-receipt' || known?.status === 'unavailable') { state.run = known; renderRuns(); empty($('sync-detail'), statusNames[known.status], known.note); return; }
  empty($('sync-detail'), id, 'Читаю receipt и доступные Git-объекты…');
  try {
    const detail = await api('sync', { id });
    if (request !== state.syncRequest) return;
    state.run = detail; renderRuns(); renderRun();
  } catch (exception) { if (request === state.syncRequest) empty($('sync-detail'), 'Наблюдение недоступно', exception.message); }
}

function appendIdentity(target, name, value) {
  const item = node('dl'); item.append(node('dt', '', name), node('dd', '', shortOid(value))); if (value) item.title = value; target.append(item);
}

function renderRun() {
  const run = state.run, target = $('sync-detail'); target.replaceChildren();
  const heading = node('div', 'sync-heading');
  const title = node('div'); title.append(node('h2', '', run.id), node('p', '', run.historical ? 'Принятое историческое наблюдение. Проверки не относятся к текущему HEAD.' : 'Локальный кандидат: статус по архивному receipt.'));
  heading.append(title, badge(statusNames[run.status], run.status)); target.append(heading);
  if (run.legacy) target.append(node('p', 'interpretation-note', 'Этот receipt создан ранней версией протокола: отдельный prepared product base и replay inventory в нём не записаны. Atlas не достраивает отсутствующую историю.'));
  for (const reason of run.staleReasons || []) target.append(node('p', 'interpretation-note', reason));
  const identity = node('div', 'identity-grid');
  appendIdentity(identity, 'Raw source', run.source); appendIdentity(identity, 'Vendor snapshot', run.prepared); appendIdentity(identity, 'Product base', run.preparedBase); appendIdentity(identity, 'Candidate', run.candidate); appendIdentity(identity, 'Accepted', run.accepted); appendIdentity(identity, 'Captured dev', run.receipt.dev); target.append(identity);
  const flow = node('div', 'sync-flow');
  for (const [name, detail, oid] of [
    ['Исходник FlClash', 'Raw ancestry — provenance. Сам исходник не становится родителем продуктовой истории.', run.source],
    ['Нормализованный vendor', 'Append-only цепочка наблюдений; механические правила меняют имена и пути.', run.prepared],
    ['Продуктовая база', run.legacy ? 'Не записана в этом receipt. Нельзя выводить её из vendor ancestry.' : 'Отдельный коммит без родителей с тем же деревом, что vendor. Сверху replay ReClash.', run.preparedBase],
  ]) {
    const item = node('section', 'flow-step'); item.append(node('h3', '', name), node('p', '', detail), node('code', '', shortOid(oid))); flow.append(item);
  }
  target.append(flow);
  const comparisons = section('Посмотреть изменения');
  const controls = node('div', 'detail-actions');
  for (const comparison of run.comparisons) controls.append(button({ raw: 'Raw upstream', normalized: 'После нормализации', product: 'Результат ReClash' }[comparison.lens], async () => { state.selection = { mode: 'sync', id: run.id, lens: comparison.lens }; location.hash = 'changes'; await loadImpact(state.selection); }, 'action-button'));
  if (!run.comparisons.length) controls.append(node('p', 'small-muted', 'Нет доступных endpoint-объектов для сравнения.'));
  comparisons.append(controls); target.append(comparisons);
  const review = section('Зафиксированные review / waivers');
  for (const label of run.reviews) review.append(badge(label));
  for (const waiver of run.waivers) review.append(badge(`Waived: ${waiver}`, 'waived'));
  if (!run.reviews.length && !run.waivers.length) review.append(node('p', 'small-muted', 'Labels не записаны.'));
  review.append(node('p', 'reason-note', 'Labels фиксируют уже полученное разрешение, не выдают его. Waived никогда не означает passed.')); target.append(review);
  const checks = section('Архивные результаты');
  const rows = node('div');
  for (const [id, result] of Object.entries(run.checks)) {
    const row = node('div', 'affected-item');
    row.append(button(id, () => { $('check-run').value = run.id; state.checkRun = run; openCheck(id); }), badge(statusNames[result.status], result.status), button('Лог', () => showLog(run.id, id)));
    rows.append(row);
  }
  if (!Object.keys(run.checks).length) rows.append(node('p', 'small-muted', 'Проверки не записаны.')); checks.append(rows); target.append(checks);
  const replay = node('div', 'replay-columns');
  for (const [name, commits] of [['Вход replay', run.replaySource], ['Результат replay', run.replayed]]) {
    const column = section(`${name}: ${commits.length}`, 'history-column');
    for (const commit of commits) column.append(commitItem(commit));
    if (!commits.length) column.append(node('p', 'small-muted', run.legacy ? 'В раннем receipt этот список отсутствует.' : 'Коммиты не записаны или объекты недоступны.'));
    replay.append(column);
  }
  target.append(replay);
  const raw = node('details'); raw.append(node('summary', '', 'Исходный receipt'), node('pre', 'yaml-source', JSON.stringify(run.receipt, null, 2))); target.append(raw);
}

function commitItem(commit) { const item = node('div', 'commit-item'); item.append(node('code', '', shortOid(commit.oid)), node('p', '', commit.subject)); item.title = `${commit.oid}\n${date(commit.date)}`; return item; }

function renderCurrentHistory() {
  const target = $('current-history'); target.replaceChildren();
  for (const [title, commits] of [['Vendor: наблюдения', state.snapshot.histories.vendor], ['Product: downstream-коммиты', state.snapshot.histories.product]]) {
    const column = node('div', 'history-column'); column.append(node('h3', '', title));
    for (const commit of commits.slice(0, 40)) column.append(commitItem(commit));
    target.append(column);
  }
  if (state.snapshot.histories.productBase) {
    const column = node('div', 'history-column'); column.append(node('h3', '', 'Parentless product base'), commitItem(state.snapshot.histories.productBase)); target.append(column);
  }
}

function renderChecks() {
  if (!state.snapshot) return;
  const target = $('checks-table'); target.replaceChildren();
  const query = $('check-search').value.toLocaleLowerCase();
  const filter = $('check-filter').value;
  const run = state.checkRun;
  const results = run?.checks || {};
  let count = 0;
  for (const [id, check] of Object.entries(state.snapshot.checks)) {
    const command = commandText(check.argv, check.cwd);
    const searchable = `${id} ${command} ${check.covers.map(cover => `${cover.feature} ${cover.invariants.join(' ')}`).join(' ')}`.toLocaleLowerCase();
    if (!query.split(/\s+/).filter(Boolean).every(word => searchable.includes(word))) continue;
    const result = results[id];
    if (filter === 'baseline' && !check.baseline) continue;
    if (filter === 'host' && check.availableHost) continue;
    if (filter === 'failed' && !['failed', 'waived'].includes(result?.status)) continue;
    count++;
    const row = node('section', 'check-row'); row.dataset.check = id;
    const name = node('div', 'check-name', id); name.append(node('small', '', `${check.baseline ? 'Baseline / ' : ''}${check.host || 'Любой host'}${!check.availableHost ? ' / нужна другая ОС' : ''}`));
    row.append(name, node('pre', 'check-command', command));
    const covers = node('div', 'check-coverage');
    for (const coverage of check.covers) { const item = node('div'); item.append(button(coverage.feature, () => openFeature(coverage.feature)), node('span', '', ` / ${coverage.invariants.join(', ')}`)); covers.append(item); }
    if (!check.covers.length) covers.append(node('span', '', check.baseline ? 'Общий baseline' : 'Платформенная / вспомогательная проверка'));
    row.append(covers);
    const actions = node('div', 'check-actions');
    actions.append(badge(statusNames[result?.status || 'not-run'], result?.status || ''));
    if (run) actions.append(node('span', 'reason-note', run.historical ? 'Исторический результат' : run.status === 'stale' ? 'Receipt устарел' : 'Из выбранного receipt'));
    actions.append(button('Скопировать команду', () => copy(command)));
    if (result) actions.append(button('Открыть лог', () => showLog(run.id, id)));
    row.append(actions); target.append(row);
  }
  if (!count) empty(target, 'Проверки не найдены', 'Измените запрос или фильтр результатов.');
}

async function showLog(id, check) {
  $('log-title').textContent = check;
  $('log-meta').textContent = id;
  $('log-content').textContent = 'Читаю архивный лог…';
  if (!$('log-dialog').open) $('log-dialog').showModal();
  try {
    const data = await api('log', { id, check });
    if ($('log-title').textContent !== check || $('log-meta').textContent !== id) return;
    $('log-content').textContent = data.content;
    $('log-meta').textContent = `${id}${data.truncated ? ' / первые 256 KiB; лог длиннее preview' : ''}`;
  } catch (exception) { $('log-content').textContent = exception.message; }
}

function renderAttention() {
  const notices = state.snapshot.notices;
  $('attention-count').textContent = notices.length;
  $('attention-count').hidden = !notices.length;
  const target = $('attention-list'); target.replaceChildren();
  if (!notices.length) return empty(target, 'В этом снимке нет выявленных препятствий', 'Это не разрешение принять sync и не доказательство семантической эквивалентности.');
  for (const notice of notices) {
    const item = node('section', `attention-item ${notice.level}`);
    item.append(node('span', 'attention-icon', notice.level === 'blocker' ? '×' : notice.level === 'review' ? '!' : 'i'));
    const content = node('div');
    const translation = noticeCopy[notice.id];
    content.append(node('h2', '', translation ? translation[0] : notice.title), node('p', '', translation ? translation[1] : notice.detail));
    if (notice.id === 'normalizer') {
      const details = node('details'); details.append(node('summary', '', 'Fingerprint и рецепт'));
      details.append(node('pre', 'yaml-source', `Accepted: ${state.snapshot.normalization.acceptedFingerprint}\nCurrent:  ${state.snapshot.normalization.fingerprint}`));
      details.append(node('p', 'small-muted', 'Fingerprint включает рецепт и реализацию normalize.dart / model.dart / git.dart. Изменение digest само по себе не доказывает изменение дерева.'));
      content.append(details);
    }
    if (notice.paths?.length) {
      const details = node('details'); details.append(node('summary', '', `${notice.paths.length} путей`));
      const paths = node('div', 'path-list'); for (const path of notice.paths) paths.append(button(path, () => inspectPath(path))); details.append(paths); content.append(details);
      content.append(button('Открыть unclassified impact', async () => { $('impact-mode').value = 'downstream'; $('change-filter').value = 'unclassified'; updateComparisonFields(); location.hash = 'changes'; await loadImpact({ mode: 'downstream' }); }, 'action-button compact'));
    }
    for (const id of notice.features || []) content.append(button(id, () => openFeature(id)));
    item.append(content, badge(noticeNames[notice.level] || notice.level, notice.level)); target.append(item);
  }
}

async function switchView() {
  const view = location.hash.slice(1).split('/')[0] || 'map';
  state.view = ['map', 'changes', 'sync', 'checks', 'attention'].includes(view) ? view : 'map';
  for (const panel of document.querySelectorAll('.view-panel')) panel.hidden = panel.id !== `view-${state.view}`;
  for (const link of document.querySelectorAll('[data-view]')) {
    if (link.dataset.view === state.view) link.setAttribute('aria-current', 'page'); else link.removeAttribute('aria-current');
  }
  if (!state.snapshot) return;
  if (state.view === 'changes' && !state.impact && !state.impactLoading) await loadImpact(state.selection);
  if (state.view === 'sync' && !state.run) {
    if (state.runs.length) await loadRun(state.runs[0].id);
    else empty($('sync-detail'), 'Наблюдения пока не созданы', 'Здесь будут существующие snapshots, receipts и результаты проверок.');
  }
}

function setupTheme() {
  try { const saved = localStorage.getItem('reclash.atlas.theme'); if (saved === 'light' || saved === 'dark') document.documentElement.dataset.theme = saved; } catch {}
  $('theme-toggle').addEventListener('click', () => {
    const dark = document.documentElement.dataset.theme === 'dark' || (!document.documentElement.dataset.theme && matchMedia('(prefers-color-scheme: dark)').matches);
    document.documentElement.dataset.theme = dark ? 'light' : 'dark';
    try { localStorage.setItem('reclash.atlas.theme', dark ? 'light' : 'dark'); } catch {}
  });
}

function debounce(handler, delay = 100) { let timer; return (...args) => { clearTimeout(timer); timer = setTimeout(() => handler(...args), delay); }; }

setupTheme();
$('refresh').addEventListener('click', refresh);
$('refresh-stale').addEventListener('click', refresh);
$('contract-search').addEventListener('input', debounce(() => { renderContractList(); renderGraph(); }));
for (const id of ['risk-filter', 'state-filter']) $(id).addEventListener('change', () => { renderContractList(); renderGraph(); });
$('graph-scope').addEventListener('change', () => { state.graphScope = $('graph-scope').value; renderGraph(); });
$('graph-fit').addEventListener('click', () => state.graphViewport?.fit());
for (const item of document.querySelectorAll('[data-graph-view]')) item.addEventListener('click', () => { state.graphView = item.dataset.graphView; renderGraph(); });
$('impact-mode').addEventListener('change', updateComparisonFields);
$('impact-form').addEventListener('submit', event => {
  event.preventDefault();
  const selection = { mode: $('impact-mode').value };
  if (selection.mode === 'refs') { selection.from = $('impact-from').value; selection.to = $('impact-to').value; }
  if (selection.mode === 'paths') selection.path = $('impact-path').value;
  loadImpact(selection);
});
$('change-search').addEventListener('input', debounce(applyChangeFilter));
$('change-filter').addEventListener('change', applyChangeFilter);
$('check-search').addEventListener('input', debounce(renderChecks));
$('check-filter').addEventListener('change', renderChecks);
$('check-run').addEventListener('change', () => { state.checkRun = state.runs.find(run => run.id === $('check-run').value) || null; renderChecks(); });
$('close-log').addEventListener('click', () => $('log-dialog').close());
$('log-dialog').addEventListener('click', event => { if (event.target === $('log-dialog')) { const bounds = $('log-dialog').getBoundingClientRect(); if (event.clientX < bounds.left || event.clientX > bounds.right || event.clientY < bounds.top || event.clientY > bounds.bottom) $('log-dialog').close(); } });
window.addEventListener('hashchange', switchView);
window.addEventListener('keydown', event => {
  if (event.key === '/' && !['INPUT', 'TEXTAREA', 'SELECT'].includes(document.activeElement?.tagName) && !$('log-dialog').open) {
    event.preventDefault();
    ({ map: $('contract-search'), changes: $('change-search'), checks: $('check-search') }[state.view] || $('contract-search')).focus();
  }
});
window.addEventListener('focus', checkStale);
async function checkStale() {
  if (!state.snapshot || document.hidden || document.body.classList.contains('busy')) return;
  try {
    const result = await api('stamp');
    state.stale = state.snapshot.fingerprint !== result.fingerprint;
    if (state.impact) {
      const impactStamp = state.selection.mode === 'staged' ? await api('stamp', { mode: 'staged' }) : result;
      state.stale ||= state.impact.fingerprint !== impactStamp.fingerprint;
    }
    $('stale-banner').hidden = !state.stale;
  } catch {}
}
setInterval(checkStale, 15000);
await switchView();
await refresh();
await switchView();
