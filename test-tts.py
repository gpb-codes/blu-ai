import time, sys
print("Cargando ChatterboxTTS...", flush=True)
t0 = time.time()

import torch
from chatterbox.tts import ChatterboxTTS

device = "cpu"
print(f"Usando device: {device}", flush=True)

model = ChatterboxTTS.from_pretrained(device=device)
print(f"Modelo cargado en {time.time()-t0:.1f}s", flush=True)

texto = "Hola Ignacio, soy Blu, tu asistente."
print(f"Generando audio para: {texto!r}", flush=True)
t1 = time.time()

wav = model.generate(texto)
print(f"Audio generado en {time.time()-t1:.1f}s", flush=True)

import torchaudio
out = r"C:\Users\MSI\.claude\scripts\test-blu.wav"
torchaudio.save(out, wav, model.sr)
print(f"Guardado en: {out}", flush=True)
print(f"Tiempo total: {time.time()-t0:.1f}s")
