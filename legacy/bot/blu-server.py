"""
Blu Server — Claude text + edge-tts audio (voz: es-ES-AlvaroNeural)
Corre con: py -3.11 blu-server.py

Endpoints:
  POST /ask              {"q": "pregunta"}  -> {"job_id": "xxxxxxxx"}
  GET  /status?job_id=x  -> {"status": "processing"|"done", "answer": "..."}
  GET  /audio?job_id=x   -> audio/mp3
  GET  /health           -> {"ok": true, ...}
"""
import subprocess, json, threading, uuid, time, sys, os, socket
from http.server import HTTPServer, BaseHTTPRequestHandler
from socketserver import ThreadingMixIn
from urllib.parse import urlparse, parse_qs
import tempfile

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
CLAUDE  = r"C:\Users\MSI\AppData\Roaming\npm\claude.cmd"
PROJ    = r"C:\Users\MSI\.claude\projects\blu-memory"
PORT      = 5051
TTS_VOICE = "es-ES-AlvaroNeural"
AUDIO_DIR = os.path.join(tempfile.gettempdir(), "blu_audio")
os.makedirs(AUDIO_DIR, exist_ok=True)

# job_id -> {"text": str|None, "audio": path|None, "done": bool}
jobs = {}
jobs_lock = threading.Lock()

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
def log(msg):
    print(f"[{time.strftime('%H:%M:%S')}] {msg}", flush=True)

# ---------------------------------------------------------------------------
# TTS con edge-tts (no requiere carga de modelo, genera en ~1-2s)
# ---------------------------------------------------------------------------
def generate_audio(text, job_id):
    import asyncio, edge_tts
    path = os.path.join(AUDIO_DIR, f"{job_id}.mp3")
    async def _run():
        tts = edge_tts.Communicate(text, voice=TTS_VOICE)
        await tts.save(path)
    asyncio.run(_run())
    return path

# ---------------------------------------------------------------------------
# Job worker: Claude -> texto, luego TTS -> audio
# ---------------------------------------------------------------------------
def run_job(job_id, q):
    log(f"  [{job_id}] Claude procesando: {q[:60]!r}")
    prompt = (
        "Eres Blu, el asistente de Ignacio (mexicano). "
        "Responde BREVE (2-3 frases), en espanol mexicano natural, "
        "texto plano sin markdown ni emojis. Llamalo Ignacio. "
        "Pregunta: " + q
    )

    # --- Paso 1: Claude genera texto ---
    try:
        r = subprocess.run(
            [CLAUDE, "-p", prompt],
            capture_output=True, cwd=PROJ, timeout=120, shell=True,
        )
        text = r.stdout.decode("utf-8", errors="replace").strip()
        if not text:
            stderr = r.stderr.decode("utf-8", errors="replace").strip()
            text = f"Sin respuesta. {stderr[:100]}" if stderr else "No pude responder."
    except subprocess.TimeoutExpired:
        text = "Lo siento Ignacio, tardé demasiado en responder."
    except Exception as e:
        text = f"Error: {e}"

    log(f"  [{job_id}] Texto listo: {text[:80]!r}")

    # Actualizar job con texto (el polling ya puede devolver la respuesta)
    with jobs_lock:
        jobs[job_id]["text"] = text

    # --- Paso 2: TTS genera audio ---
    audio_path = None
    try:
        log(f"  [{job_id}] TTS generando audio ({TTS_VOICE})...")
        audio_path = generate_audio(text, job_id)
        log(f"  [{job_id}] Audio guardado: {audio_path}")
    except Exception as e:
        log(f"  [{job_id}] TTS ERROR: {e}")

    # Marcar job como completado
    with jobs_lock:
        jobs[job_id]["audio"] = audio_path
        jobs[job_id]["done"]  = True
    log(f"  [{job_id}] Job completo.")

# ---------------------------------------------------------------------------
# HTTP Handler
# ---------------------------------------------------------------------------
class Handler(BaseHTTPRequestHandler):

    def send_json(self, data, status=200):
        body = json.dumps(data, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Connection", "close")
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self):
        client = self.client_address[0]
        log(f"POST {self.path} desde {client}")
        try:
            length = int(self.headers.get("Content-Length", 0))
            raw = self.rfile.read(length) if length > 0 else b"{}"
            log(f"  Body: {raw[:200]}")
            body = json.loads(raw or b"{}")
            q = str(body.get("q", "")).strip()
            if not q:
                self.send_json({"error": "campo 'q' requerido"}, 400)
                return
            job_id = str(uuid.uuid4())[:8]
            with jobs_lock:
                jobs[job_id] = {"text": None, "audio": None, "done": False}
            threading.Thread(target=run_job, args=(job_id, q), daemon=True).start()
            log(f"  Job creado: {job_id}")
            self.send_json({"job_id": job_id})
        except json.JSONDecodeError as e:
            log(f"  ERROR JSON: {e}")
            self.send_json({"error": f"JSON invalido: {e}"}, 400)
        except Exception as e:
            log(f"  ERROR POST: {e}")
            try:
                self.send_json({"error": str(e)}, 500)
            except Exception:
                pass

    def do_GET(self):
        client = self.client_address[0]
        parsed = urlparse(self.path)
        path   = parsed.path
        params = parse_qs(parsed.query)
        log(f"GET {self.path} desde {client}")

        # --- /health ---
        if path == "/health":
            with jobs_lock:
                total = len(jobs)
                done  = sum(1 for j in jobs.values() if j["done"])
            self.send_json({
                "ok": True,
                "tts_voice": TTS_VOICE,
                "jobs_total": total,
                "jobs_done": done,
            })
            return

        # --- /status?job_id=xxx ---
        if path == "/status":
            job_id = params.get("job_id", [""])[0]
            if not job_id:
                self.send_json({"error": "job_id requerido"}, 400)
                return
            with jobs_lock:
                job = jobs.get(job_id)
            if job is None:
                self.send_json({"status": "not_found"}, 404)
                return
            if not job["done"]:
                # Si ya hay texto pero TTS pendiente, avisarlo
                if job["text"] is not None:
                    self.send_json({"status": "tts_pending", "answer": job["text"]})
                else:
                    self.send_json({"status": "processing"})
            else:
                resp = {"status": "done", "answer": job["text"]}
                if job["audio"]:
                    resp["audio_url"] = f"/audio?job_id={job_id}"
                self.send_json(resp)
            return

        # --- /audio?job_id=xxx ---
        if path == "/audio":
            job_id = params.get("job_id", [""])[0]
            if not job_id:
                self.send_json({"error": "job_id requerido"}, 400)
                return
            with jobs_lock:
                job = jobs.get(job_id)
            if job is None:
                self.send_json({"status": "not_found"}, 404)
                return
            audio_path = job.get("audio")
            if not audio_path or not os.path.exists(audio_path):
                if not job["done"]:
                    self.send_json({"status": "processing"}, 202)
                else:
                    self.send_json({"error": "audio no disponible"}, 404)
                return
            # Servir el WAV
            size = os.path.getsize(audio_path)
            self.send_response(200)
            self.send_header("Content-Type", "audio/mpeg")
            self.send_header("Content-Length", str(size))
            self.send_header("Content-Disposition", f'attachment; filename="{job_id}.mp3"')
            self.send_header("Connection", "close")
            self.end_headers()
            with open(audio_path, "rb") as f:
                self.wfile.write(f.read())
            return

        self.send_json({"error": "ruta no encontrada"}, 404)

    def log_message(self, fmt, *args):
        pass   # ya logueamos manualmente


class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
    daemon_threads = True


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    # Verificar que el puerto esté libre
    test_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    test_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 0)
    try:
        test_sock.bind(("0.0.0.0", PORT))
        test_sock.close()
    except OSError:
        log(f"ERROR: Puerto {PORT} ya está en uso.")
        log("Corre en PowerShell admin: taskkill /IM python.exe /F")
        sys.exit(1)

    server = ThreadedHTTPServer(("0.0.0.0", PORT), Handler)
    log(f"Blu server corriendo en 0.0.0.0:{PORT}")
    log(f"  Voz TTS: {TTS_VOICE}")
    log(f"  POST /ask  |  GET /status?job_id=x  |  GET /audio?job_id=x  |  GET /health")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        log("Servidor detenido.")
        sys.exit(0)
