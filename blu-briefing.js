// blu-briefing.js — manda un briefing matutino a las 8am con recordatorios y estado de proyectos
// Se lanza como child process desde blu-whatsapp.js

const { spawn } = require("child_process");
const fs   = require("fs");
const path = require("path");
const http = require("http");

const CLAUDE = "C:\\Users\\MSI\\AppData\\Roaming\\npm\\claude.cmd";
const PROJ   = "C:\\Users\\MSI\\.claude\\projects\\blu-memory";
const REMINDERS_FILE = path.join(__dirname, "reminders.json");
const STATE_FILE      = path.join(__dirname, "blu-briefing-lastsent.txt");
const LEADS_FILE       = path.join(__dirname, "blu-leads.json");
const NOTIFY_PORT     = 5052;
const BRIEFING_TIME    = "08:00";
const LEADS_DOC_THRESHOLD = 5; // si hay mas de estos, se manda como archivo en vez de en el chat

function log(msg) {
  const t = new Date().toLocaleTimeString("es-MX", { hour12: false });
  console.log(`[${t}][briefing] ${msg}`);
}

function sendNotify(text) {
  return new Promise((resolve) => {
    const data = JSON.stringify({ text });
    const req = http.request(
      { host: "127.0.0.1", port: NOTIFY_PORT, path: "/send", method: "POST",
        headers: { "Content-Type": "application/json", "Content-Length": Buffer.byteLength(data) } },
      (res) => { res.on("data", () => {}); res.on("end", () => { log("Briefing enviado."); resolve(true); }); }
    );
    req.on("error", (e) => { log(`Error al enviar: ${e.message}`); resolve(false); });
    req.write(data);
    req.end();
  });
}

function sendFile(filePath, caption) {
  return new Promise((resolve) => {
    const data = JSON.stringify({ path: filePath, caption });
    const req = http.request(
      { host: "127.0.0.1", port: NOTIFY_PORT, path: "/send-file", method: "POST",
        headers: { "Content-Type": "application/json", "Content-Length": Buffer.byteLength(data) } },
      (res) => { res.on("data", () => {}); res.on("end", () => { log("Doc de leads enviado."); resolve(true); }); }
    );
    req.on("error", (e) => { log(`Error al enviar doc: ${e.message}`); resolve(false); });
    req.write(data);
    req.end();
  });
}

// --- Prospectos detectados de la noche --------------------------------------
function loadUnbriefedLeads() {
  try {
    const leads = JSON.parse(fs.readFileSync(LEADS_FILE, "utf-8"));
    return leads.filter((l) => !l.briefed);
  } catch (_) { return []; }
}

function markLeadsBriefed(ids) {
  try {
    const leads = JSON.parse(fs.readFileSync(LEADS_FILE, "utf-8"));
    const idSet = new Set(ids);
    leads.forEach((l) => { if (idSet.has(l.id)) l.briefed = true; });
    fs.writeFileSync(LEADS_FILE, JSON.stringify(leads, null, 2));
  } catch (_) {}
}

function buildLeadsDoc(leads) {
  const fecha = new Date().toISOString().slice(0, 10);
  const docPath = path.join(__dirname, `blu-leads-${fecha}.md`);
  let md = `# Prospectos detectados — ${fecha}\n\n${leads.length} en total.\n\n`;
  leads.forEach((l, i) => {
    md += `## ${i + 1}. ${l.name} — ${l.group}\n`;
    md += `Dijo: "${l.message}"\n\n`;
    md += `Por que: ${l.reason}\n\n`;
    if (l.suggestedMessage) md += `Mensaje sugerido:\n> ${l.suggestedMessage}\n\n`;
    md += `---\n\n`;
  });
  fs.writeFileSync(docPath, md, "utf-8");
  return docPath;
}

async function handleLeadsBriefing() {
  const leads = loadUnbriefedLeads();
  if (!leads.length) return;

  if (leads.length > LEADS_DOC_THRESHOLD) {
    const docPath = buildLeadsDoc(leads);
    await sendFile(docPath, `Anoche detecte ${leads.length} posibles prospectos en los grupos. Te dejo el detalle con mensajes sugeridos para cada uno.`);
  } else {
    let resumen = `Anoche detecte ${leads.length} posible${leads.length > 1 ? "s" : ""} prospecto${leads.length > 1 ? "s" : ""}:\n\n`;
    leads.forEach((l) => {
      resumen += `${l.name} en ${l.group}: ${l.reason}\n`;
    });
    resumen += `\nPregúntame por cualquiera y te paso el mensaje sugerido.`;
    await sendNotify(resumen);
  }
  markLeadsBriefed(leads.map((l) => l.id));
}

function generateBriefing() {
  return new Promise((resolve) => {
    let reminders = [];
    try { reminders = JSON.parse(fs.readFileSync(REMINDERS_FILE, "utf-8")); } catch (_) {}
    const remindersHoy = reminders.filter(r => r.date === new Date().toISOString().slice(0, 10));

    const prompt = `Eres Blu, asistente de Ignacio. Genera un briefing matutino corto (3-6 frases), estilo Jarvis, en espanol mexicano, texto plano sin markdown ni emojis.
Antes de responder, revisa el Google Calendar de hoy (mcp__claude_ai_Google_Calendar__list_events, rango: hoy completo) para saber sus eventos/juntas.
Incluye: saludo breve, eventos de Google Calendar de hoy (con hora), recordatorios de hoy (${remindersHoy.length ? remindersHoy.map(r => `${r.time} - ${r.text}`).join("; ") : "ninguno"}), y si hay algo relevante pendiente en sus proyectos (revisa la memoria si quieres, pero no es obligatorio). Responde SOLO el texto del mensaje, sin JSON ni comillas.`;

    const child = spawn("cmd.exe", [
      "/c", `chcp 65001 >nul && ${CLAUDE} -p --model claude-sonnet-5 --allowedTools Read,Glob,mcp__claude_ai_Google_Calendar__list_events`,
    ], { cwd: PROJ, windowsHide: true, env: { ...process.env, PYTHONUTF8: "1" } });

    let out = "", done = false;
    const timer = setTimeout(() => { if (!done) { done = true; try { child.kill(); } catch (_) {} resolve(null); } }, 60000);
    child.stdout.on("data", (d) => (out += d.toString("utf-8")));
    child.on("close", () => {
      if (done) return;
      done = true;
      clearTimeout(timer);
      resolve(out.trim() || null);
    });
    child.on("error", () => { if (!done) { done = true; clearTimeout(timer); resolve(null); } });
    child.stdin.write(prompt);
    child.stdin.end();
  });
}

async function check() {
  const now = new Date();
  const hhmm = `${String(now.getHours()).padStart(2, "0")}:${String(now.getMinutes()).padStart(2, "0")}`;
  const today = now.toISOString().slice(0, 10);

  if (hhmm !== BRIEFING_TIME) return;

  let lastSent = "";
  try { lastSent = fs.readFileSync(STATE_FILE, "utf-8").trim(); } catch (_) {}
  if (lastSent === today) return;

  log("Generando briefing matutino...");
  const texto = await generateBriefing();
  if (texto) {
    await sendNotify(texto);
    fs.writeFileSync(STATE_FILE, today, "utf-8");
  } else {
    log("No se pudo generar el briefing.");
  }

  try { await handleLeadsBriefing(); } catch (e) { log(`Error en briefing de leads: ${e.message}`); }
}

log("Daemon de briefing iniciado. Disparo diario a las " + BRIEFING_TIME);
setInterval(check, 30000);
check();
