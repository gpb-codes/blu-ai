const fs = require('fs');
const path = require('path');
const { spawn, execSync } = require('child_process');

const ROOT = process.argv.includes('--fs')
  ? path.resolve(process.argv[process.argv.indexOf('--fs') + 1])
  : __dirname;

const ALLOWED_COMMANDS = {
  'blu-graf.py': { cmd: 'py', args: ['-3.11'] },
  'blu-tts.py': { cmd: 'py', args: ['-3.11'] },
  'blu-transcribe.py': { cmd: 'py', args: ['-3.11'] },
  'blu-server.py': { cmd: 'py', args: ['-3.11'] },
  'blu-notify.js': { cmd: 'node', args: [] },
  'blu-send.js': { cmd: 'node', args: [] },
};

let requestId = 0;
const pending = {};

function writeMessage(msg) {
  const str = JSON.stringify(msg);
  process.stdout.write(str.length + '\n' + str);
}

process.stdin.on('data', (chunk) => {
  const lines = chunk.toString().split('\n');
  for (const line of lines) {
    if (!line.trim()) continue;
    try {
      const msg = JSON.parse(line);
      handleMessage(msg);
    } catch (e) {
      // partial JSON, wait for more data
    }
  }
});

function handleMessage(msg) {
  switch (msg.method) {
    case 'initialize':
      writeMessage({
        id: msg.id,
        result: {
          protocolVersion: '2024-11-05',
          capabilities: {
            tools: {},
            resources: {}
          },
          serverInfo: { name: 'blu-mcp', version: '1.0.0' }
        }
      });
      break;

    case 'tools/list':
      writeMessage({
        id: msg.id,
        result: {
          tools: [
            {
              name: 'read_file',
              description: 'Lee el contenido de cualquier archivo del proyecto',
              inputSchema: {
                type: 'object',
                properties: {
                  path: { type: 'string', description: 'Ruta relativa al proyecto' }
                },
                required: ['path']
              }
            },
            {
              name: 'list_files',
              description: 'Lista archivos y directorios del proyecto',
              inputSchema: {
                type: 'object',
                properties: {
                  dir: { type: 'string', description: 'Directorio relativo (opcional)' },
                  pattern: { type: 'string', description: 'Glob pattern opcional (ej: *.js, **/*.py)' }
                }
              }
            },
            {
              name: 'search_code',
              description: 'Busca texto en los archivos del proyecto',
              inputSchema: {
                type: 'object',
                properties: {
                  pattern: { type: 'string', description: 'Texto o regex a buscar' },
                  include: { type: 'string', description: 'Filtro de archivos (ej: *.js)' }
                },
                required: ['pattern']
              }
            },
            {
              name: 'run_script',
              description: 'Ejecuta un script del proyecto (blu-graf.py, blu-tts.py, blu-transcribe.py, etc.)',
              inputSchema: {
                type: 'object',
                properties: {
                  script: {
                    type: 'string',
                    description: 'Nombre del script (blu-graf.py, blu-tts.py, blu-transcribe.py, blu-notify.js, blu-send.js)'
                  },
                  args: {
                    type: 'array',
                    items: { type: 'string' },
                    description: 'Argumentos para el script'
                  }
                },
                required: ['script']
              }
            },
            {
              name: 'project_info',
              description: 'Obtiene informacion del proyecto: archivos, tamaños, ultima modificacion',
              inputSchema: {
                type: 'object',
                properties: {}
              }
            },
            {
              name: 'whatsapp_status',
              description: 'Verifica el estado del servidor HTTP de WhatsApp (:5052)',
              inputSchema: {
                type: 'object',
                properties: {}
              }
            },
            {
              name: 'whatsapp_send',
              description: 'Envia un mensaje proactivo por WhatsApp via POST /send',
              inputSchema: {
                type: 'object',
                properties: {
                  message: { type: 'string', description: 'Texto del mensaje a enviar' },
                  number: { type: 'string', description: 'Numero de telefono (opcional, default: Ignacio)' }
                },
                required: ['message']
              }
            }
          ]
        }
      });
      break;

    case 'tools/call': {
      const tool = msg.params.name;
      const args = msg.params.arguments || {};
      handleToolCall(msg.id, tool, args);
      break;
    }

    case 'resources/list':
      writeMessage({
        id: msg.id,
        result: {
          resources: [
            {
              uri: 'file://' + ROOT.replace(/\\/g, '/') + '/package.json',
              name: 'package.json',
              description: 'Dependencias del proyecto Node.js',
              mimeType: 'application/json'
            },
            {
              uri: 'project://files',
              name: 'Lista de archivos del proyecto',
              description: 'Inventario completo de archivos del proyecto',
              mimeType: 'application/json'
            }
          ]
        }
      });
      break;

    case 'resources/read':
      if (msg.params.uri === 'project://files') {
        const files = walkDir(ROOT);
        writeMessage({ id: msg.id, result: { contents: [{ uri: msg.params.uri, mimeType: 'application/json', text: JSON.stringify(files, null, 2) }] } });
      } else if (msg.params.uri.startsWith('file://')) {
        const filePath = msg.params.uri.replace('file:///', '');
        try {
          const content = fs.readFileSync(filePath, 'utf-8');
          writeMessage({ id: msg.id, result: { contents: [{ uri: msg.params.uri, mimeType: 'text/plain', text: content }] } });
        } catch (e) {
          writeMessage({ id: msg.id, error: { code: -32000, message: 'No se pudo leer el archivo: ' + e.message } });
        }
      }
      break;

    default:
      if (msg.id) {
        writeMessage({ id: msg.id, error: { code: -32601, message: 'Metodo no soportado: ' + msg.method } });
      }
  }
}

async function handleToolCall(id, tool, args) {
  try {
    let result;
    switch (tool) {
      case 'read_file': {
        const filePath = path.resolve(ROOT, args.path);
        if (!filePath.startsWith(ROOT)) throw new Error('Acceso denegado: fuera del proyecto');
        const content = fs.readFileSync(filePath, 'utf-8');
        result = { content: [{ type: 'text', text: content }] };
        break;
      }
      case 'list_files': {
        const dir = args.dir ? path.resolve(ROOT, args.dir) : ROOT;
        if (!dir.startsWith(ROOT)) throw new Error('Acceso denegado');
        const entries = fs.readdirSync(dir, { withFileTypes: true });
        let files = entries.map(e => ({
          name: e.name,
          type: e.isDirectory() ? 'dir' : 'file',
          size: e.isFile() ? fs.statSync(path.join(dir, e.name)).size : null
        }));
        if (args.pattern) {
          const glob = requireGlob();
          if (glob) files = glob.sync(args.pattern, { cwd: ROOT, nodir: true }).map(f => ({ name: f, type: 'file' }));
        }
        result = { content: [{ type: 'text', text: JSON.stringify(files, null, 2) }] };
        break;
      }
      case 'search_code': {
        const { execSync } = require('child_process');
        const results = [];
        const walk = (dir) => {
          const entries = fs.readdirSync(dir, { withFileTypes: true });
          for (const e of entries) {
            const full = path.join(dir, e.name);
            if (e.isDirectory() && !e.name.startsWith('.') && e.name !== 'node_modules') walk(full);
            else if (e.isFile()) {
              if (args.include && !e.name.endsWith(args.include.replace('*', ''))) continue;
              try {
                const content = fs.readFileSync(full, 'utf-8');
                const lines = content.split('\n');
                for (let i = 0; i < lines.length; i++) {
                  if (lines[i].toLowerCase().includes(args.pattern.toLowerCase())) {
                    results.push({ file: path.relative(ROOT, full), line: i + 1, text: lines[i].trim() });
                  }
                }
              } catch (e) { /* skip binary */ }
            }
          }
        };
        walk(ROOT);
        result = { content: [{ type: 'text', text: JSON.stringify(results.slice(0, 100), null, 2) }] };
        break;
      }
      case 'run_script': {
        const scriptName = args.script;
        if (!ALLOWED_COMMANDS[scriptName]) throw new Error('Script no permitido: ' + scriptName);
        const config = ALLOWED_COMMANDS[scriptName];
        const scriptPath = path.resolve(ROOT, scriptName);
        if (!fs.existsSync(scriptPath)) throw new Error('Script no encontrado: ' + scriptName);
        const allArgs = [...config.args, scriptPath, ...(args.args || [])];
        const output = execSync(`"${config.cmd}" ${allArgs.map(a => '"' + a + '"').join(' ')}`, {
          cwd: ROOT,
          timeout: 30000,
          encoding: 'utf-8',
          maxBuffer: 1024 * 1024
        });
        result = { content: [{ type: 'text', text: output || '(ejecutado sin salida)' }] };
        break;
      }
      case 'project_info': {
        const files = walkDir(ROOT);
        const totalSize = files.reduce((acc, f) => acc + (f.size || 0), 0);
        const stats = {
          totalFiles: files.length,
          totalSize: totalSize,
          root: ROOT,
          categories: {
            js: files.filter(f => f.name.endsWith('.js')).length,
            py: files.filter(f => f.name.endsWith('.py')).length,
            ps1: files.filter(f => f.name.endsWith('.ps1')).length,
            bat: files.filter(f => f.name.endsWith('.bat')).length,
            json: files.filter(f => f.name.endsWith('.json')).length,
            md: files.filter(f => f.name.endsWith('.md')).length,
            vbs: files.filter(f => f.name.endsWith('.vbs')).length,
          }
        };
        result = { content: [{ type: 'text', text: JSON.stringify(stats, null, 2) }] };
        break;
      }
      case 'whatsapp_status': {
        const http = require('http');
        try {
          const res = await new Promise((resolve, reject) => {
            const req = http.get('http://localhost:5052/health', (res) => resolve(res));
            req.on('error', reject);
            req.setTimeout(3000, () => { req.destroy(); reject(new Error('timeout')); });
          });
          let body = '';
          res.on('data', c => body += c);
          await new Promise(r => res.on('end', r));
          result = { content: [{ type: 'text', text: 'WhatsApp server activo: ' + body }] };
        } catch (e) {
          result = { content: [{ type: 'text', text: 'WhatsApp server no responde: ' + e.message }] };
        }
        break;
      }
      case 'whatsapp_send': {
        const http = require('http');
        const data = JSON.stringify({ message: args.message, number: args.number || '' });
        try {
          const res = await new Promise((resolve, reject) => {
            const req = http.request('http://localhost:5052/send', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json', 'Content-Length': data.length }
            }, resolve);
            req.on('error', reject);
            req.setTimeout(5000, () => { req.destroy(); reject(new Error('timeout')); });
            req.write(data);
            req.end();
          });
          let body = '';
          res.on('data', c => body += c);
          await new Promise(r => res.on('end', r));
          result = { content: [{ type: 'text', text: 'Enviado: ' + body }] };
        } catch (e) {
          result = { content: [{ type: 'text', text: 'Error al enviar: ' + e.message }] };
        }
        break;
      }
      default:
        throw new Error('Tool not found: ' + tool);
    }
    writeMessage({ id, result });
  } catch (e) {
    writeMessage({ id, error: { code: -32000, message: e.message } });
  }
}

function walkDir(dir) {
  const results = [];
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const e of entries) {
    const full = path.join(dir, e.name);
    if (e.name.startsWith('.') || e.name === 'node_modules' || e.name === '__pycache__') continue;
    if (e.isDirectory()) {
      results.push(...walkDir(full));
    } else {
      results.push({
        name: path.relative(ROOT, full),
        size: fs.statSync(full).size,
        ext: path.extname(e.name)
      });
    }
  }
  return results;
}

function requireGlob() {
  try { return require('glob'); } catch (e) { return null; }
}

// Start: send initialized notification
setTimeout(() => {
  writeMessage({ method: 'notifications/initialized' });
  writeMessage({ method: 'notifications/message', params: { level: 'info', message: 'BLU MCP server ready. Tools: read_file, list_files, search_code, run_script, project_info, whatsapp_status, whatsapp_send' } });
}, 100);
