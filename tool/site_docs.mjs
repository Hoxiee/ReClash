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

const languages = ['en', 'ru', 'zh-CN']
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
  const manifest = join(site, 'package.json')
  assert.ok(existsSync(manifest), 'Clone Hoxiee/reclash-site beside ReClash at ../reclash-site')
  assert.equal(JSON.parse(readFileSync(manifest, 'utf8')).name, 'reclash-site', 'The sibling website must be the reclash-site repository')
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

  const content = join(site, 'content/rcx')
  const catalogue = JSON.parse(readFileSync(join(content, 'catalogue.json'), 'utf8'))
  assert.equal(catalogue.source.repository, 'https://github.com/Hoxiee/ReClash')
  assert.match(catalogue.source.commit, /^[a-f0-9]{40}$/)
  const files = languages.flatMap(language => markdownFiles(join(root, 'docs', language, 'auto-routing'))
    .map(file => `${language}/${file}`)).sort()
  assert.deepEqual(Object.keys(catalogue.files).sort(), files, 'RCX document inventory changed; synchronize the website handbook')
  for (const file of files) {
    const [language, ...parts] = file.split('/')
    const source = join(root, 'docs', language, 'auto-routing', ...parts)
    const destination = join(content, file)
    if (!existsSync(destination) || hash(readFileSync(source)) !== catalogue.files[file] || hash(readFileSync(destination)) !== catalogue.files[file]) {
      failures.push(`RCX ${file} is stale; after committing its source, run npm --prefix ../reclash-site run docs:sync -- "${root}"`)
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
    console.log(`Verified ${result.exports} website exports and ${result.documents} RCX documents against the application checkout.`)
  } catch (error) {
    console.error(error.message)
    process.exitCode = 1
  }
}
