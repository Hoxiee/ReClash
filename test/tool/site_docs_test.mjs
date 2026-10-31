import assert from 'node:assert/strict'
import { createHash } from 'node:crypto'
import { mkdtempSync, mkdirSync, readFileSync, rmSync, symlinkSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { dirname, join } from 'node:path'
import test from 'node:test'
import { siteSources, synchronizeSite } from '../../tool/site_docs.mjs'

function fixture(t) {
  const workspace = mkdtempSync(join(tmpdir(), 'reclash-site-docs-'))
  t.after(() => rmSync(workspace, { recursive: true, force: true }))
  const root = join(workspace, 'ReClash')
  mkdirSync(root)
  mkdirSync(join(workspace, 'reclash-site'))
  symlinkSync('../reclash-site', join(root, 'site'), 'dir')
  const put = (path, value) => {
    const file = join(root, path)
    mkdirSync(dirname(file), { recursive: true })
    writeFileSync(file, value)
  }
  put('site/package.json', '{"name":"reclash-site"}')
  for (const [source, target] of siteSources) {
    put(source, '{"version":1}\n')
    put(`site/${target}`, '{"version":1}\n')
  }
  const files = {}
  for (const language of ['en', 'ru', 'zh-CN']) {
    const text = `# ${language} handbook\n`
    put(`docs/${language}/auto-routing/README.md`, text)
    put(`site/content/rcx/${language}/README.md`, text)
    files[`${language}/README.md`] = createHash('sha256').update(text).digest('hex')
  }
  put('site/content/rcx/catalogue.json', JSON.stringify({ source: { repository: 'https://github.com/Hoxiee/ReClash', commit: 'a'.repeat(40) }, files }))
  return { root, put }
}

test('checks the website exports and source documentation without rewriting them', t => {
  const { root } = fixture(t)
  assert.deepEqual(synchronizeSite(root), { exports: 3, documents: 3 })
})

test('the sibling checkout works without the shortcut or submodule configuration', t => {
  const { root } = fixture(t)
  rmSync(join(root, 'site'))
  assert.deepEqual(synchronizeSite(root), { exports: 3, documents: 3 })
})

test('a missing sibling checkout reports the required location', t => {
  const { root } = fixture(t)
  rmSync(join(root, 'site/package.json'))
  assert.throws(() => synchronizeSite(root), /Clone Hoxiee\/reclash-site beside ReClash/)
})

test('stale exports fail a check and only explicit synchronization copies them', t => {
  const { root, put } = fixture(t)
  put('provider-policy.schema.json', '{"version":2}\n')
  assert.throws(() => synchronizeSite(root), /provider-policy.schema.json differs/)
  assert.equal(readFileSync(join(root, 'site/public/schemas/provider-policy.schema.json'), 'utf8'), '{"version":1}\n')
  synchronizeSite(root, { write: true })
  assert.equal(readFileSync(join(root, 'site/public/schemas/provider-policy.schema.json'), 'utf8'), '{"version":2}\n')
})

test('a changed application document cannot pass with an old website snapshot', t => {
  const { root, put } = fixture(t)
  put('docs/en/auto-routing/README.md', '# Changed handbook\n')
  assert.throws(() => synchronizeSite(root), /RCX en\/README.md is stale/)
})

test('a hand-edited website snapshot cannot pass its source checksum', t => {
  const { root, put } = fixture(t)
  put('site/content/rcx/ru/README.md', '# Different handbook\n')
  assert.throws(() => synchronizeSite(root), /RCX ru\/README.md is stale/)
})

test('new application chapters require updating the website inventory', t => {
  const { root, put } = fixture(t)
  put('docs/en/auto-routing/new-chapter.md', '# New chapter\n')
  assert.throws(() => synchronizeSite(root), /RCX document inventory changed/)
})

test('the website repository is an explicit integration boundary', t => {
  const { root, put } = fixture(t)
  put('site/package.json', '{"name":"other-site"}')
  assert.throws(() => synchronizeSite(root, { write: true }), /sibling website must be the reclash-site repository/)
})
