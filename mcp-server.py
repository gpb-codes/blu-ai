import sys
import json
import os
import subprocess
import glob as glob_mod

ROOT = os.path.dirname(os.path.abspath(__file__))

SCRIPTS = {
    'blu-graf.py': {'cmd': sys.executable, 'cwd': ROOT},
    'blu-tts.py': {'cmd': sys.executable, 'cwd': ROOT},
    'blu-transcribe.py': {'cmd': sys.executable, 'cwd': ROOT},
    'blu-server.py': {'cmd': sys.executable, 'cwd': ROOT},
}

TOOLS = [
    {
        'name': 'run_python',
        'description': 'Ejecuta un script Python del proyecto',
        'inputSchema': {
            'type': 'object',
            'properties': {
                'script': {
                    'type': 'string',
                    'description': 'Script a ejecutar: blu-graf.py, blu-tts.py, blu-transcribe.py, blu-server.py'
                },
                'args': {
                    'type': 'array',
                    'items': {'type': 'string'},
                    'description': 'Argumentos para el script'
                }
            },
            'required': ['script']
        }
    },
    {
        'name': 'analyze_project',
        'description': 'Analiza archivos del proyecto por extension y tamano',
        'inputSchema': {'type': 'object', 'properties': {}}
    },
]


def write_message(msg):
    sys.stdout.write(json.dumps(msg) + '\n')
    sys.stdout.flush()


def read_stdin():
    for line in sys.stdin:
        line = line.strip()
        if line:
            yield json.loads(line)


def handle_tool_call(tool_name, args):
    if tool_name == 'run_python':
        script = args.get('script')
        script_args = args.get('args', [])
        if script not in SCRIPTS:
            return {'error': f'Script no permitido: {script}'}
        cfg = SCRIPTS[script]
        script_path = os.path.join(ROOT, script)
        if not os.path.exists(script_path):
            return {'error': f'Script no encontrado: {script}'}
        cmd = [cfg['cmd'], script_path] + script_args
        try:
            result = subprocess.run(cmd, capture_output=True, text=True,
                                    timeout=60, cwd=cfg['cwd'])
            output = result.stdout
            if result.stderr:
                output += '\nSTDERR:\n' + result.stderr
            return {'content': [{'type': 'text', 'text': output or '(sin salida)'}]}
        except subprocess.TimeoutExpired:
            return {'error': 'Timeout: el script tardo mas de 60s'}
        except Exception as e:
            return {'error': str(e)}

    elif tool_name == 'analyze_project':
        info = []
        for f in glob_mod.glob(os.path.join(ROOT, '**', '*'), recursive=True):
            if os.path.isfile(f):
                rel = os.path.relpath(f, ROOT)
                if rel.startswith('.') or rel.startswith('node_modules') or rel.startswith('__pycache__'):
                    continue
                info.append({
                    'file': rel,
                    'size': os.path.getsize(f),
                    'ext': os.path.splitext(f)[1]
                })
        return {'content': [{'type': 'text', 'text': json.dumps(info, indent=2)}]}

    return {'error': f'Tool not found: {tool_name}'}


def main():
    for msg in read_stdin():
        method = msg.get('method')
        msg_id = msg.get('id')

        if method == 'initialize':
            write_message({
                'id': msg_id,
                'result': {
                    'protocolVersion': '2024-11-05',
                    'capabilities': {'tools': {}},
                    'serverInfo': {'name': 'blu-python-mcp', 'version': '1.0.0'}
                }
            })
            write_message({'method': 'notifications/initialized'})

        elif method == 'tools/list':
            write_message({'id': msg_id, 'result': {'tools': TOOLS}})

        elif method == 'tools/call':
            tool = msg.get('params', {}).get('name')
            args = msg.get('params', {}).get('arguments', {})
            result = handle_tool_call(tool, args)
            if 'error' in result:
                write_message({'id': msg_id, 'error': {'code': -32000, 'message': result['error']}})
            else:
                write_message({'id': msg_id, 'result': result})


if __name__ == '__main__':
    main()
