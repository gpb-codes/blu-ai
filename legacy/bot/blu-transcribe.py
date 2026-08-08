"""
blu-transcribe.py  —  transcribe un audio con faster-whisper (modelo medium)
Uso: py -3.11 blu-transcribe.py <ruta_archivo>
Imprime solo el texto transcrito en stdout. Errores van a stderr (antes se
tragaban en silencio y nunca se sabia por que fallaba una transcripcion real).
"""
import sys, os

if len(sys.argv) < 2:
    print("", end="")
    sys.exit(0)

audio_path = sys.argv[1]
if not os.path.exists(audio_path):
    print(f"archivo no existe: {audio_path}", file=sys.stderr)
    sys.exit(1)

try:
    from faster_whisper import WhisperModel
    # 25-jul: subido de "small" a "medium" (pedido explicito: mejor calidad, como
    # ChatGPT/Claude voz). Probado en vivo: en audio limpio ambos transcriben igual,
    # la diferencia real se nota en audio ruidoso/acentos fuertes tipico de notas de
    # voz reales de WhatsApp. Tarda ~23s en esta CPU vs ~6s de "small" — aceptable,
    # el chat personal tiene 5 min de margen igual.
    model = WhisperModel("medium", device="cpu", compute_type="int8")
    segments, _ = model.transcribe(audio_path, language="es")
    text = " ".join(s.text.strip() for s in segments).strip()
    print(text, end="")
except Exception as e:
    print(f"{type(e).__name__}: {e}", file=sys.stderr)
    sys.exit(1)
