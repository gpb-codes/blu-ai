"""
blu-tts.py — convierte texto a audio con la voz de Álvaro (edge-tts)
Uso: py -3.11 blu-tts.py "texto aquí" ruta_salida.mp3
"""
import sys, asyncio
import edge_tts

VOICE = "es-ES-AlvaroNeural"

async def main():
    if len(sys.argv) < 3:
        sys.exit(1)
    text = sys.argv[1]
    out  = sys.argv[2]
    communicate = edge_tts.Communicate(text, VOICE)
    await communicate.save(out)

asyncio.run(main())
