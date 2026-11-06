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
  const manifest = JSON.stringify({ languages: { ru: { published: true }, en: { published: true }, 'zh-CN': { published: false } } })
  put('docs/manifest.json', manifest)
  put('site/content/docs/manifest.json', manifest)
  put('docs/zh-CN/auto-routing/README.md', '# Unpublished\n')
  const files = {}
  for (const language of ['en', 'ru']) {
    for (const file of ['README.md', 'auto-routing/README.md']) {
      const text = `# ${language} ${file}\n`
      put(`docs/${language}/${file}`, text)
      put(`site/content/docs/${language}/${file}`, text)
      files[`${language}/${file}`] = createHash('sha256').update(text).digest('hex')
    }
  }
  put('site/content/docs/catalogue.json', JSON.stringify({ source: { repository: 'https://github.com/Hoxiee/ReClash', commit: 'a'.repeat(40) }, files }))
  return { root, put }
}

test('checks the website exports and source documentation without rewriting them', t => {
  const { root } = fixture(t)
  assert.deepEqual(synchronizeSite(root), { exports: 3, documents: 4 })
})

test('the sibling checkout works without the shortcut or submodule configuration', t => {
  const { root } = fixture(t)
  rmSync(join(root, 'site'))
  assert.deepEqual(synchronizeSite(root), { exports: 3, documents: 4 })
})

test('a missing sibling checkout reports the required location', t => {
  const { root } = fixture(t)
  rmSync(join(root, 'site/package.json'))
  assert.throws(() => synchronizeSite(root), /Clone Hoxiee\/reclash-site beside ReClash/)
})

test('stale exports fail a check and only explicit synchronization copies them', t => {
  const { root, put } = fixture(t)
  put('provider-config.schema.json', '{"version":2}\n')
  assert.throws(() => synchronizeSite(root), /provider-config.schema.json differs/)
  assert.equal(readFileSync(join(root, 'site/public/schemas/provider-config.schema.json'), 'utf8'), '{"version":1}\n')
  synchronizeSite(root, { write: true })
  assert.equal(readFileSync(join(root, 'site/public/schemas/provider-config.schema.json'), 'utf8'), '{"version":2}\n')
})

test('a changed application document cannot pass with an old website snapshot', t => {
  const { root, put } = fixture(t)
  put('docs/en/auto-routing/README.md', '# Changed handbook\n')
  assert.throws(() => synchronizeSite(root), /docs\/en\/auto-routing\/README.md is stale/)
})

test('a hand-edited website snapshot cannot pass its source checksum', t => {
  const { root, put } = fixture(t)
  put('site/content/docs/ru/README.md', '# Different handbook\n')
  assert.throws(() => synchronizeSite(root), /docs\/ru\/README.md is stale/)
})

test('new application pages require updating the website inventory', t => {
  const { root, put } = fixture(t)
  put('docs/en/providers/new-page.md', '# New page\n')
  assert.throws(() => synchronizeSite(root), /Documentation inventory changed/)
})

test('a changed manifest or newly published language requires a new snapshot', t => {
  const { root, put } = fixture(t)
  put('docs/manifest.json', JSON.stringify({ languages: { ru: { published: true }, en: { published: true }, 'zh-CN': { published: true } } }))
  assert.throws(() => synchronizeSite(root), /Documentation inventory changed/)
  put('docs/manifest.json', JSON.stringify({ languages: { en: { published: true }, ru: { published: true }, 'zh-CN': { published: false } } }))
  assert.throws(() => synchronizeSite(root), /docs\/manifest.json is stale/)
})

test('the website repository is an explicit integration boundary', t => {
  const { root, put } = fixture(t)
  put('site/package.json', '{"name":"other-site"}')
  assert.throws(() => synchronizeSite(root, { write: true }), /sibling website must be the reclash-site repository/)
})
