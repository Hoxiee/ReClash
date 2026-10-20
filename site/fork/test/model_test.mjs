import test from 'node:test';
import assert from 'node:assert/strict';
import { filterFeatures, neighbourhood, layoutGraph, changesMatching, checkStatus, patchLines, commandText } from '../assets/model.mjs';

const features = [
  { id: 'core.base', state: 'active', kind: 'integration', risk: 'critical', must: { safety: 'Never replace the source' }, watch: ['core/**'], checks: { native: ['safety'] }, files: ['core/source.go'] },
  { id: 'tools.page', state: 'active', kind: 'feature', risk: 'routine', must: { navigation: 'Keep navigation' }, watch: ['lib/tools.dart'], checks: { tools: ['navigation'] }, deps: ['core.base'] },
  { id: 'tools.child', state: 'active', kind: 'feature', risk: 'routine', must: { nesting: 'Keep nested pages' }, watch: ['lib/child.dart'], checks: {}, deps: ['tools.page'] },
  { id: 'old.page', state: 'retired', kind: 'removal', risk: 'routine', must: { removed: 'Intentionally absent' }, watch: ['old/**'], checks: {} },
];
const relations = [{ from: 'tools.page', to: 'core.base' }, { from: 'tools.child', to: 'tools.page' }];

test('search finds real paths, invariant IDs and text without executing markup', () => {
  assert.equal(filterFeatures(features, { query: 'core/source.go' })[0].id, 'core.base');
  assert.equal(filterFeatures(features, { query: 'safety source' })[0].id, 'core.base');
  assert.deepEqual(filterFeatures(features, { query: '<script>' }), []);
  assert.deepEqual(filterFeatures(features, { risk: 'critical' }).map(item => item.id), ['core.base']);
});

test('one-hop scope includes both dependencies and dependents', () => {
  assert.deepEqual([...neighbourhood(features, relations, 'tools.page')].sort(), ['core.base', 'tools.child', 'tools.page']);
  assert.deepEqual([...neighbourhood(features, relations, 'core.base', 1)].sort(), ['core.base', 'tools.page']);
  assert.deepEqual([...neighbourhood(features, relations, 'core.base', 10)].sort(), ['core.base', 'tools.child', 'tools.page']);
});

test('layout is deterministic and does not invent edges for missing contracts', () => {
  assert.deepEqual(layoutGraph(features, relations), layoutGraph([...features].reverse(), relations));
  const graph = layoutGraph(features.slice(1), relations);
  assert.deepEqual(graph.edges, [relations[1]]);
  for (const item of graph.nodes) assert.ok(Number.isFinite(item.x) && Number.isFinite(item.y));
});

test('impact filters distinguish direct critical and unclassified paths', () => {
  const changes = [
    { path: 'core/source.go', direct: [{ feature: 'core.base', via: 'watch' }] },
    { path: 'lib/tools.dart', direct: [{ feature: 'tools.page', via: 'watch' }] },
    { path: 'unknown.dart', direct: [] },
  ];
  const map = new Map(features.map(item => [item.id, item]));
  assert.deepEqual(changesMatching(changes, { filter: 'critical' }, map).map(item => item.path), ['core/source.go']);
  assert.deepEqual(changesMatching(changes, { filter: 'unclassified' }, map).map(item => item.path), ['unknown.dart']);
  assert.deepEqual(changesMatching(changes, { query: 'tools.page' }, map).map(item => item.path), ['lib/tools.dart']);
});

test('waivers are never rendered as passes', () => {
  assert.equal(checkStatus({ status: 'waived', exit: 0 }), 'waived');
  assert.equal(checkStatus({ exit: 1 }), 'failed');
  assert.equal(checkStatus({ exit: 0 }), 'passed');
  assert.equal(checkStatus(null), 'not-run');
});

test('patch metadata is not mistaken for added or deleted content', () => {
  assert.deepEqual(patchLines('--- a\n+++ b\n@@ -1 +1 @@\n-old\n+new').map(item => item.kind), ['header', 'header', 'hunk', 'delete', 'add']);
});

test('copied commands retain argv boundaries and cwd', () => {
  assert.equal(commandText(['flutter', 'test', 'test/a b.dart'], 'core'), "cd core && flutter test 'test/a b.dart'");
  assert.equal(commandText(['git', 'status']), 'git status');
});
