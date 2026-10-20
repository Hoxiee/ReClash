export function featureMatches(feature, query) {
  const words = query.toLocaleLowerCase().trim().split(/\s+/).filter(Boolean);
  const haystack = [feature.id, feature.kind, feature.state, feature.why || '', ...Object.keys(feature.must || {}), ...Object.values(feature.must || {}), ...(feature.watch || []), ...(feature.files || []), ...Object.keys(feature.checks || {})].join('\n').toLocaleLowerCase();
  return words.every(word => haystack.includes(word));
}

export function filterFeatures(features, { query = '', risk = 'all', state = 'all' } = {}) {
  return features.filter(feature => featureMatches(feature, query) && (risk === 'all' || feature.risk === risk) && (state === 'all' || feature.state === state));
}

export function neighbourhood(features, relations, selected, depth = 1) {
  const known = new Set(features.map(feature => feature.id));
  const visible = new Set(known.has(selected) ? [selected] : []);
  let frontier = new Set(visible);
  for (let level = 0; level < depth; level++) {
    const next = new Set();
    for (const relation of relations) {
      if (frontier.has(relation.from) && known.has(relation.to) && !visible.has(relation.to)) next.add(relation.to);
      if (frontier.has(relation.to) && known.has(relation.from) && !visible.has(relation.from)) next.add(relation.from);
    }
    for (const id of next) visible.add(id);
    frontier = next;
  }
  return visible;
}

export function layoutGraph(features, relations) {
  const known = new Set(features.map(feature => feature.id));
  const dependencyMap = new Map(features.map(feature => [feature.id, relations.filter(edge => edge.from === feature.id && known.has(edge.to)).map(edge => edge.to)]));
  const levels = new Map();
  const visiting = new Set();
  function level(id) {
    if (levels.has(id)) return levels.get(id);
    if (visiting.has(id)) return 0;
    visiting.add(id);
    const dependencies = dependencyMap.get(id) || [];
    const value = dependencies.length ? Math.max(...dependencies.map(level)) + 1 : 0;
    visiting.delete(id);
    levels.set(id, value);
    return value;
  }
  for (const feature of features) level(feature.id);
  const columns = new Map();
  for (const feature of features) {
    const column = levels.get(feature.id);
    if (!columns.has(column)) columns.set(column, []);
    columns.get(column).push(feature);
  }
  for (const column of columns.values()) column.sort((a, b) => a.id.localeCompare(b.id));
  const maxRows = Math.max(1, ...[...columns.values()].map(column => column.length));
  const maxLevel = Math.max(0, ...levels.values());
  const height = Math.max(330, maxRows * 72 + 92);
  const width = Math.max(570, (maxLevel + 1) * 236 + 48);
  const nodes = [];
  for (const [column, entries] of [...columns].sort(([a], [b]) => a - b)) {
    const offset = (height - entries.length * 72) / 2;
    entries.forEach((feature, row) => nodes.push({ ...feature, x: 24 + (maxLevel - column) * 236, y: offset + row * 72, width: 210, height: 52, level: column }));
  }
  return { width, height, nodes, edges: relations.filter(edge => known.has(edge.from) && known.has(edge.to)) };
}

export function directFeatureIds(change) {
  return new Set((change.direct || []).map(reason => reason.feature));
}

export function changesMatching(changes, { query = '', filter = 'all', feature = null } = {}, featureMap = new Map()) {
  const words = query.toLocaleLowerCase().trim().split(/\s+/).filter(Boolean);
  return changes.filter(change => {
    const direct = directFeatureIds(change);
    if (!words.every(word => `${change.path}\n${[...direct].join('\n')}`.toLocaleLowerCase().includes(word))) return false;
    if (feature && !direct.has(feature)) return false;
    if (filter === 'unclassified') return direct.size === 0;
    if (filter === 'critical') return [...direct].some(id => featureMap.get(id)?.risk === 'critical');
    if (filter === 'core') return change.path === '.gitmodules' || change.path.startsWith('core/');
    if (filter === 'platform') return /^(android|linux|macos|windows|plugins)\//.test(change.path);
    return true;
  });
}

export function checkStatus(result) {
  if (!result) return 'not-run';
  if (result.status === 'waived') return 'waived';
  if (result.exit === 0) return 'passed';
  if (Number.isInteger(result.exit)) return 'failed';
  return 'not-run';
}

export function patchLines(patch) {
  return String(patch || '').split('\n').map(text => ({ text, kind: text.startsWith('@@') ? 'hunk' : text.startsWith('+++') || text.startsWith('---') ? 'header' : text.startsWith('+') ? 'add' : text.startsWith('-') ? 'delete' : 'context' }));
}

export function shortOid(value) {
  return value ? String(value).slice(0, 8) : '—';
}

export function shellArg(value) {
  const text = String(value);
  return /^[a-zA-Z0-9_./:@=+,-]+$/.test(text) ? text : `'${text.replaceAll("'", "'\\''")}'`;
}

export function commandText(argv, cwd) {
  const command = (argv || []).map(shellArg).join(' ');
  return cwd ? `cd ${shellArg(cwd)} && ${command}` : command;
}

export function superellipsePath(width, height, radius = 9) {
  const r = Math.min(radius, width / 2, height / 2);
  const points = [];
  for (const [cx, cy, start] of [[width - r, r, -Math.PI / 2], [width - r, height - r, 0], [r, height - r, Math.PI / 2], [r, r, Math.PI]]) {
    for (let step = 0; step <= 12; step++) {
      const angle = start + step / 12 * Math.PI / 2;
      const cosine = Math.cos(angle), sine = Math.sin(angle);
      points.push(`${(cx + r * Math.sign(cosine) * Math.sqrt(Math.abs(cosine))).toFixed(2)} ${(cy + r * Math.sign(sine) * Math.sqrt(Math.abs(sine))).toFixed(2)}`);
    }
  }
  return `M${points.join(' L')} Z`;
}
