#!/usr/bin/env node
'use strict';

// Read-only: no package installs, shell initialization, network, or config writes.
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const home = os.homedir();
const windows = process.platform === 'win32';
const counts = { PASS: 0, WARN: 0, FAIL: 0 };
function report(level, message) {
  counts[level]++;
  console.log(`[${level}] ${message}`);
}
function run(command, args) {
  const result = spawnSync(command, args, { encoding: 'utf8', timeout: 10000, windowsHide: true });
  return result.status === 0 ? result.stdout.trim() : null;
}
function candidates(name) {
  const extensions = windows ? (process.env.PATHEXT || '.EXE;.CMD;.BAT').split(';') : [''];
  const found = [];
  for (const directory of (process.env.PATH || '').split(path.delimiter).filter(Boolean)) {
    for (const extension of extensions) {
      const file = path.resolve(directory.replace(/^"|"$/g, ''), name + extension.toLowerCase());
      try {
        if (!fs.statSync(file).isFile()) continue;
        fs.accessSync(file, windows ? fs.constants.F_OK : fs.constants.X_OK);
        if (!found.some(item => windows ? item.toLowerCase() === file.toLowerCase() : item === file)) found.push(file);
      } catch { /* Not an available command. */ }
    }
  }
  return found;
}
function json(file) {
  try { return JSON.parse(fs.readFileSync(file, 'utf8')); }
  catch (error) { report('FAIL', `${file}: ${error.code || error.message}`); return null; }
}
function real(file) {
  try { return fs.realpathSync(file); } catch { return file; }
}
console.log(`Dotfiles doctor — ${process.platform}/${process.arch}\nRead-only checks; credentials and session contents are not inspected.\n`);
const commands = {};
for (const name of ['chezmoi', 'git', 'fnm', 'node', 'npm', 'pi']) {
  commands[name] = candidates(name);
  report(commands[name].length ? 'PASS' : 'FAIL', `${name}: ${commands[name][0] || 'not on PATH; apply provisioning and open a new terminal'}`);
  // npm/pi have several shim extensions; only flag different installation directories.
  const directories = [...new Set(commands[name].map(file => {
    const directory = path.dirname(real(file));
    return windows ? directory.toLowerCase() : directory;
  }))];
  if (directories.length > 1) report('WARN', `${name} has multiple PATH command locations (possibly the same installation): ${directories.join(', ')}`);
}
report(process.versions.node.split('.')[0] === '26' ? 'PASS' : 'FAIL', `Doctor runtime: Node ${process.versions.node} (${process.execPath}); expected major 26`);
if (commands.fnm.length) {
  const versions = run(commands.fnm[0], ['list']);
  if (versions === null) report('FAIL', 'Unable to query fnm list (failed or timed out)');
  else {
    const defaultVersion = versions.replace(/\x1b\[[0-9;]*m/g, '').split(/\r?\n/).find(line => /\bdefault\b/.test(line));
    report(defaultVersion && /\bv26\./.test(defaultVersion) ? 'PASS' : 'FAIL', `fnm default: ${defaultVersion?.trim() || 'not configured'}; expected Node 26`);
  }
  const current = run(commands.fnm[0], ['current']);
  report(current && /^v?26\./.test(current) ? 'PASS' : 'FAIL', `fnm current: ${current || 'unavailable'}; expected Node 26`);
  if (current && current.replace(/^v/, '') !== process.versions.node) report('WARN', 'Active Node differs from fnm current; check PATH and reopen your terminal');
}
const prefix = path.join(home, '.local', 'share', 'pi');
const piManifest = path.join(prefix, 'lib', 'node_modules', '@earendil-works', 'pi-coding-agent', 'package.json');
const windowsPiManifest = path.join(prefix, 'node_modules', '@earendil-works', 'pi-coding-agent', 'package.json');
const pi = json(windows ? windowsPiManifest : piManifest);
if (pi) report(pi.version === '1.0.4' ? 'PASS' : 'WARN', `Stable-prefix Pi: ${pi.version}; bootstrap pins 1.0.4`);
if (commands.pi.length) {
  const expected = real(prefix);
  const active = real(commands.pi[0]);
  const relative = path.relative(expected, active);
  const managed = !relative.startsWith('..') && !path.isAbsolute(relative);
  report(managed ? 'PASS' : 'WARN', `Active Pi ${managed ? 'uses' : 'may not use'} the managed stable prefix: ${active}`);
}
const agent = process.env.PI_CODING_AGENT_DIR || path.join(home, '.pi', 'agent');
if (process.env.PI_CODING_AGENT_DIR) report('WARN', `PI_CODING_AGENT_DIR overrides the managed agent directory: ${agent}`);
const settings = json(path.join(agent, 'settings.json'));
if (settings) {
  report('PASS', 'Pi settings are valid JSON');
  if (!Array.isArray(settings.packages)) report('FAIL', 'Pi settings.packages is not an array');
  else for (const source of settings.packages) {
    const match = typeof source === 'string' && source.match(/^npm:(@[^/]+\/[^@]+|[^@]+)@([^@]+)$/);
    if (!match) { report('WARN', 'An unpinned or non-npm package declaration needs manual review'); continue; }
    const [, name, version] = match;
    const installed = json(path.join(agent, 'npm', 'node_modules', ...name.split('/'), 'package.json'));
    if (installed) {
      report(installed.version === version ? 'PASS' : 'FAIL', `${name}: installed ${installed.version}, configured ${version}`);
      if (installed.peerDependencies?.['@earendil-works/pi-coding-agent']) {
        console.log(`       Declared Pi peer range: ${installed.peerDependencies['@earendil-works/pi-coding-agent']} (not evaluated)`);
      }
    }
  }
}
console.log('\nScope: package presence/version checks, not interactive plugin or authentication tests.');
console.log('For deeper checks: chezmoi doctor; chezmoi verify; then test plugins inside Pi.');
console.log(`\n${counts.PASS} passed, ${counts.WARN} warnings, ${counts.FAIL} failures.`);
process.exitCode = counts.FAIL ? 1 : 0;
