import assert from 'node:assert/strict'
import { createHash } from 'node:crypto'
import { existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from 'node:fs'
import { dirname, join, resolve } from 'node:path'
import { fileURLToPath, pathToFileURL } from 'node:url'

export const siteSources = [
  ['provider_standard.g.json', 'shared/provider/standard.json'],
  ['provider-policy.schema.json', 'public/schemas/provider-policy.schema.json'],
  ['rcx-profile.schema.json', 'public/schemas/rcx-profile.schema.json'],
]

const hash = bytes => createHash('sha256').update(bytes).digest('hex')

function markdownFiles(directory, prefix = '') {
  return readdirSync(directory, { withFileTypes: true }).flatMap(entry => {
    const name = `${prefix}${entry.name}`
    if (entry.isSymbolicLink()) throw new Error(`Documentation must not contain symlinks: ${name}`)
    if (entry.isDirectory()) return markdownFiles(join(directory, entry.name), `${name}/`)
    return entry.isFile() && name.endsWith('.md') ? [name] : []
  }).sort()
}

export function synchronizeSite(root, { write = false } = {}) {
  const site = resolve(root, '../reclash-site')
  const sitePackage = join(site, 'package.json')
  assert.ok(existsSync(sitePackage), 'Clone Hoxiee/reclash-site beside ReClash at ../reclash-site')
  assert.equal(JSON.parse(readFileSync(sitePackage, 'utf8')).name, 'reclash-site', 'The sibling website must be the reclash-site repository')
  const failures = []
  for (const [source, target] of siteSources) {
    const bytes = readFileSync(join(root, source))
    const destination = join(site, target)
    if (existsSync(destination) && readFileSync(destination).equals(bytes)) continue
    if (write) {
      mkdirSync(dirname(destination), { recursive: true })
      writeFileSync(destination, bytes)
    } else {
      failures.push(`${source} differs from ../reclash-site/${target}; run node tool/site_docs.mjs --sync`)
    }
  }

  const content = join(site, 'content/docs')
  const sync = `after committing the source, run npm --prefix ../reclash-site run docs:sync -- "${root}"`
  const manifest = readFileSync(join(root, 'docs/manifest.json'))
  const snapshotManifest = join(content, 'manifest.json')
  if (!existsSync(snapshotManifest) || !readFileSync(snapshotManifest).equals(manifest)) failures.push(`docs/manifest.json is stale; ${sync}`)
  const languages = Object.entries(JSON.parse(manifest).languages).filter(([, state]) => state.published).map(([language]) => language)
  const catalogue = JSON.parse(readFileSync(join(content, 'catalogue.json'), 'utf8'))
  assert.equal(catalogue.source.repository, 'https://github.com/Hoxiee/ReClash')
  assert.match(catalogue.source.commit, /^[a-f0-9]{40}$/)
  const files = languages.flatMap(language => markdownFiles(join(root, 'docs', language)).map(file => `${language}/${file}`)).sort()
  assert.deepEqual(Object.keys(catalogue.files).sort(), files, 'Documentation inventory changed; synchronize the website documentation')
  for (const file of files) {
    const source = join(root, 'docs', ...file.split('/'))
    const destination = join(content, ...file.split('/'))
    if (!existsSync(destination) || hash(readFileSync(source)) !== catalogue.files[file] || hash(readFileSync(destination)) !== catalogue.files[file]) {
      failures.push(`docs/${file} is stale; ${sync}`)
    }
  }
  assert.equal(failures.length, 0, failures.join('\n'))
  return { exports: siteSources.length, documents: files.length }
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  try {
    const arguments_ = process.argv.slice(2)
    assert.ok(arguments_.length <= 1 && (!arguments_.length || ['--check', '--sync'].includes(arguments_[0])), 'Usage: node tool/site_docs.mjs [--check|--sync]')
    const root = fileURLToPath(new URL('../', import.meta.url))
    const result = synchronizeSite(root, { write: arguments_[0] === '--sync' })
    console.log(`Verified ${result.exports} website exports and ${result.documents} documents against the application checkout.`)
  } catch (error) {
    console.error(error.message)
    process.exitCode = 1
  }
}
