import subprocess, logging, os
from telegram import Update
from telegram.ext import ApplicationBuilder, MessageHandler, filters, ContextTypes

# Carga .env (TELEGRAM_BOT_TOKEN) sin depender de un paquete nuevo — este archivo
# se sube a git, el .env no (esta en .gitignore).
def _load_env():
    env_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".env")
    try:
        with open(env_path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#") or "=" not in line:
                    continue
                k, v = line.split("=", 1)
                os.environ.setdefault(k.strip(), v.strip().strip('"').strip("'"))
    except FileNotFoundError:
        pass

_load_env()

TOKEN = os.environ["TELEGRAM_BOT_TOKEN"]
CLAUDE = r"C:\Users\MSI\AppData\Roaming\npm\claude.cmd"
PROJ   = r"C:\Users\MSI\.claude\projects\blu-memory"

logging.basicConfig(level=logging.WARNING)

async def responder(update: Update, ctx: ContextTypes.DEFAULT_TYPE):
    q = update.message.text
    await update.message.reply_text("...")
    prompt = "Eres Blu, el asistente de Ignacio (mexicano). Responde BREVE (2-3 frases), en espanol mexicano natural (usa tu), texto plano sin markdown ni emojis. Llamalo Ignacio. Pregunta: " + q
    try:
        r = subprocess.run([CLAUDE, "-p", prompt], capture_output=True, cwd=PROJ, timeout=90, shell=True)
        answer = r.stdout.decode("utf-8", errors="replace").strip() or "Perdon Ignacio, no pude responder."
    except Exception as e:
        answer = "Error: " + str(e)
    await update.message.reply_text(answer)

app = ApplicationBuilder().token(TOKEN).build()
app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, responder))
print("Blu Telegram bot corriendo...")
app.run_polling()