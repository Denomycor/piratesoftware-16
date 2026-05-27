#!/usr/bin/env node
/**
 * GDScript LSP Diagnostic Checker
 *
 * Connects to a running Godot editor's built-in LSP server (default port 6005),
 * opens every .gd file in the project, and reports parser errors / warnings.
 *
 * Requirements:
 *   - Godot editor must be running with the project open, OR
 *   - Start headlessly: godot --path <project> --editor --headless
 *
 * Usage:
 *   node gdscript-check.mjs [projectPath] [--port 6005] [--timeout 15]
 */

import net from 'net';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const args = process.argv.slice(2);
const PROJECT_PATH = path.resolve(args.find(a => !a.startsWith('--')) || process.cwd());
const portIdx = args.indexOf('--port');
const LSP_PORT = parseInt(portIdx !== -1 ? args[portIdx + 1] : (process.env.GODOT_LSP_PORT || '6005'));
const timeoutIdx = args.indexOf('--timeout');
const TIMEOUT_MS = parseInt(timeoutIdx !== -1 ? args[timeoutIdx + 1] : '15') * 1000;

// ── helpers ──────────────────────────────────────────────────────────────────

function pathToUri(filePath) {
  // Godot expects: file:///C:/path/to/file  (three slashes, forward slashes)
  const normalised = filePath.replace(/\\/g, '/');
  return normalised.startsWith('/') ? `file://${normalised}` : `file:///${normalised}`;
}

function uriToRelPath(uri) {
  const decoded = decodeURIComponent(uri.replace(/^file:\/\/\//, ''));
  const abs = decoded.replace(/\//g, path.sep);
  return path.relative(PROJECT_PATH, abs);
}

function encode(obj) {
  const json = JSON.stringify(obj);
  return `Content-Length: ${Buffer.byteLength(json, 'utf8')}\r\n\r\n${json}`;
}

function* parseFrames(buf) {
  while (true) {
    const sep = buf.indexOf('\r\n\r\n');
    if (sep === -1) break;
    const m = buf.slice(0, sep).match(/Content-Length:\s*(\d+)/i);
    if (!m) { buf = buf.slice(sep + 4); continue; }
    const len = parseInt(m[1]);
    const start = sep + 4;
    if (buf.length < start + len) break;
    try { yield JSON.parse(buf.slice(start, start + len)); } catch { /* skip */ }
    buf = buf.slice(start + len);
  }
  return buf; // leftover
}

function findGdFiles(dir, results = []) {
  let entries;
  try { entries = fs.readdirSync(dir, { withFileTypes: true }); }
  catch { return results; }
  for (const e of entries) {
    if (e.name.startsWith('.')) continue;
    const full = path.join(dir, e.name);
    if (e.isDirectory()) findGdFiles(full, results);
    else if (e.isFile() && e.name.endsWith('.gd')) results.push(full);
  }
  return results;
}

// ── LSP session ───────────────────────────────────────────────────────────────

async function runCheck() {
  const files = findGdFiles(PROJECT_PATH);
  const pending = new Set(files.map(pathToUri));
  const allDiagnostics = {};   // uri → diagnostics[]
  let msgId = 1;
  let buf = '';

  return new Promise((resolve, reject) => {
    const sock = new net.Socket();
    let settled = false;

    const done = () => {
      if (settled) return;
      settled = true;
      clearTimeout(timer);
      sock.destroy();
      resolve(allDiagnostics);
    };

    const timer = setTimeout(() => {
      // Godot only sends publishDiagnostics for files that have issues —
      // timeout is the normal exit path when the project is mostly clean.
      process.stderr.write(`[done] Scanned ${files.length} files (timeout after ${TIMEOUT_MS / 1000}s)\n`);
      done();
    }, TIMEOUT_MS);

    const send = obj => sock.write(encode(obj));

    sock.connect(LSP_PORT, '127.0.0.1', () => {
      process.stderr.write(`Connected to Godot LSP on port ${LSP_PORT}\n`);
      process.stderr.write(`Checking ${files.length} .gd files...\n`);

      send({
        jsonrpc: '2.0', id: msgId++, method: 'initialize',
        params: {
          processId: process.pid,
          clientInfo: { name: 'claude-gdscript-checker', version: '1.0' },
          rootUri: pathToUri(PROJECT_PATH),
          rootPath: PROJECT_PATH,
          capabilities: {
            textDocument: { publishDiagnostics: { relatedInformation: false } }
          }
        }
      });
    });

    sock.on('data', chunk => {
      buf += chunk.toString('utf8');
      const gen = parseFrames(buf);
      let next;
      while (!(next = gen.next()).done) {
        const msg = next.value;
        if (typeof msg !== 'object') continue;

        // initialize response → send initialized + open all files
        if (msg.id === 1 && msg.result) {
          send({ jsonrpc: '2.0', method: 'initialized', params: {} });
          for (const file of files) {
            let text;
            try { text = fs.readFileSync(file, 'utf8'); } catch { continue; }
            send({
              jsonrpc: '2.0', method: 'textDocument/didOpen',
              params: {
                textDocument: {
                  uri: pathToUri(file), languageId: 'gdscript',
                  version: 1, text
                }
              }
            });
          }
        }

        // publishDiagnostics → record and tick off
        if (msg.method === 'textDocument/publishDiagnostics') {
          const { uri, diagnostics } = msg.params;
          pending.delete(uri);
          if (diagnostics && diagnostics.length > 0) allDiagnostics[uri] = diagnostics;
          if (pending.size === 0) done();
        }
      }
      // gen.return() gives leftover buf — update it
      buf = gen.return().value ?? buf;
    });

    sock.on('error', err => { if (!settled) reject(err); });
    sock.on('close', () => done());
  });
}

// ── main ──────────────────────────────────────────────────────────────────────

const SEVERITY = { 1: 'ERROR', 2: 'WARNING', 3: 'INFO', 4: 'HINT' };

try {
  const diagnostics = await runCheck();

  let errorCount = 0, warnCount = 0;
  const entries = Object.entries(diagnostics);

  if (entries.length === 0) {
    console.log('✅ No diagnostics — all GDScript files parsed clean.');
  } else {
    for (const [uri, diags] of entries.sort()) {
      const rel = uriToRelPath(uri);
      for (const d of diags) {
        const sev = SEVERITY[d.severity] ?? 'INFO';
        const line = (d.range?.start?.line ?? 0) + 1;
        const col  = (d.range?.start?.character ?? 0) + 1;
        console.log(`${sev}\t${rel}:${line}:${col}\t${d.message}`);
        if (d.severity === 1) errorCount++;
        else if (d.severity === 2) warnCount++;
      }
    }
    console.log(`\n${errorCount} error(s), ${warnCount} warning(s)`);
  }

  process.exit(errorCount > 0 ? 1 : 0);
} catch (err) {
  console.error(`❌ Could not connect to Godot LSP on port ${LSP_PORT}: ${err.message}`);
  console.error('');
  console.error('Options:');
  console.error('  1. Open the project in the Godot editor (it starts LSP automatically)');
  console.error('  2. Start Godot headlessly:');
  console.error(`     godot --path "${PROJECT_PATH}" --editor --headless`);
  console.error('     then re-run this script.');
  process.exit(2);
}
