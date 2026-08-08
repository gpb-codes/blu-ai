// blu-reminder.js — daemon que revisa recordatorios y los manda por WhatsApp
// Se lanza automáticamente desde blu-whatsapp.js al arrancar

const fs   = require("fs");
const path = require("path");
const http = require("http");

// Sin esto, un solo error no atrapado (ej. un JSON corrupto, un typeof raro) tira este
// daemon entero — y como corre separado de blu-whatsapp.js, nadie lo vuelve a levantar
// hasta el proximo reinicio completo del bot. Encontrado en la revision nocturna del 21-jul.
process.on("uncaughtException", (e) => console.error(`*** uncaughtException: ${e && e.stack ? e.stack : e}`));
process.on("unhandledRejection", (r) => console.error(`*** unhandledRejection: ${r && r.stack ? r.stack : r}`));

const REMINDERS_FILE     = path.join(__dirname, "reminders.json");
const AGENDA_PUBLIC_FILE = path.join(__dirname, "blu-agenda-publico.json");
const NOTIFY_PORT    = 5052;

// Cuantos ciclos (de 30s) reintenta un recordatorio que fallo antes de darse por
// vencido y avisarle a Ignacio. 10 ciclos = 5 minutos, de sobra para que el bot se
// recupere de un hipo de conexion sin que el usuario espere una eternidad tampoco.
const MAX_REINTENTOS = 10;

function log(msg) {
  const t = new Date().toLocaleTimeString("es-MX", { hour12: false });
  console.log(`[${t}][reminder] ${msg}`);
}

// Encontrado el 21-jul: esto nunca revisaba si el envio en verdad funciono, solo si
// la peticion HTTP salio — cuando /send devolvia {ok:false} (WhatsApp roto por dentro),
// esto igual logueaba "Enviado" y el recordatorio se borraba de la lista para siempre,
// sin que nadie se enterara que en realidad nunca le llego a la persona. Ahora resuelve
// con el ok real, para poder reintentar o avisar segun corresponda.
function postJSON(path_, body) {
  return new Promise((resolve) => {
    const data = JSON.stringify(body);
    const req = http.request(
      { host: "127.0.0.1", port: NOTIFY_PORT, path: path_, method: "POST",
        headers: { "Content-Type": "application/json", "Content-Length": Buffer.byteLength(data) } },
      (res) => {
        let raw = "";
        res.on("data", (c) => (raw += c));
        res.on("end", () => {
          let ok = false;
          try { ok = !!JSON.parse(raw).ok; } catch (_) {}
          resolve(ok);
        });
      }
    );
    req.on("error", () => resolve(false));
    req.write(data);
    req.end();
  });
}

async function sendNotify(text) {
  const ok = await postJSON("/send", { text });
  log(ok ? `Enviado: ${text.slice(0, 60)}` : `Fallo al enviar: ${text.slice(0, 60)}`);
  return ok;
}

// Recordatorios de gente del /blu publico — van a su propio chat (jid), no a Ignacio.
async function sendNotifyA(jid, text) {
  const ok = await postJSON("/send-to", { numero: jid, text });
  log(ok ? `Enviado a ${jid}: ${text.slice(0, 60)}` : `Fallo al enviar a ${jid}: ${text.slice(0, 60)}`);
  return ok;
}

// Avisa a Ignacio que un recordatorio se dio por vencido tras varios reintentos, para
// que lo sepa y pueda reenviarlo a mano si hace falta — antes esto fallaba en total
// silencio (ver hallazgo del 21-jul: piqueras nunca supo de su recordatorio a Raul).
async function alertarFallo(descripcion) {
  const ok = await postJSON("/send", { text: `No pude entregar un recordatorio despues de ${MAX_REINTENTOS} intentos: ${descripcion}. Revisalo a mano.` });
  log(ok ? `Aviso de fallo enviado a Ignacio: ${descripcion.slice(0, 60)}` : `No pude ni avisarle a Ignacio del fallo: ${descripcion.slice(0, 60)}`);
}

function estaVencido(r, hhmm, today) {
  // Ya se disparo antes y sigue en reintento (paso su HH:MM exacto, pero no se ha
  // logrado entregar) — o es su primera vez y justo coincide el minuto/fecha.
  return (r._reintentando && (r._intentos || 0) < MAX_REINTENTOS) || (r.time === hhmm && r.date === today);
}

// Recordatorios con repetir:"diario" (ej. "avisame todos los dias a las 8") se
// re-agendan solos para el dia siguiente tras entregarse — antes se disparaban una
// sola vez y se borraban, aunque la persona hubiera pedido "todos los dias"
// (encontrado el 21-jul: el diario de las 8pm de Ricardo murio tras su primer disparo).
function reagendarDiario(r, pending, list) {
  const [y, m, d] = r.date.split("-").map(Number);
  const sig = new Date(y, m - 1, d + 1);
  const sigDate = `${sig.getFullYear()}-${String(sig.getMonth() + 1).padStart(2, "0")}-${String(sig.getDate()).padStart(2, "0")}`;
  // Dedup: si ya existe una entrada identica para ese dia (ej. una agregada a mano
  // como respaldo), no duplicar — evita que a la persona le lleguen dos avisos.
  const yaExiste = (e) => e.jid === r.jid && e.time === r.time && e.text === r.text && e.date === sigDate;
  if (pending.some(yaExiste) || list.some(yaExiste)) return;
  pending.push({ jid: r.jid, esGrupo: r.esGrupo, quien: r.quien, date: sigDate, time: r.time, text: r.text, repetir: "diario" });
}

async function checkAgendaPublico() {
  let list = [];
  try { list = JSON.parse(fs.readFileSync(AGENDA_PUBLIC_FILE, "utf-8")); } catch (_) { return; }
  if (!list.length) return;

  const now   = new Date();
  const hhmm  = `${String(now.getHours()).padStart(2,"0")}:${String(now.getMinutes()).padStart(2,"0")}`;
  const today = now.toISOString().slice(0, 10);

  const pending = [];
  for (const r of list) {
    if (!estaVencido(r, hhmm, today)) { pending.push(r); continue; }
    const texto = r.esGrupo ? `${r.quien}, recordatorio: ${r.text}` : `Recordatorio: ${r.text}`;
    log(`Disparando agenda publica para ${r.quien}: ${r.text}`);
    const ok = await sendNotifyA(r.jid, texto);
    if (ok) { if (r.repetir === "diario") reagendarDiario(r, pending, list); continue; } // entregado; si es diario, queda para manana
    r._reintentando = true;
    r._intentos = (r._intentos || 0) + 1;
    if (r._intentos >= MAX_REINTENTOS) {
      await alertarFallo(`agenda de ${r.quien} (${r.jid}) — "${r.text}"`);
      continue; // se rinde, no se vuelve a intentar
    }
    pending.push(r);
  }

  if (pending.length !== list.length || JSON.stringify(pending) !== JSON.stringify(list)) {
    try { fs.writeFileSync(AGENDA_PUBLIC_FILE, JSON.stringify(pending, null, 2), "utf-8"); } catch (_) {}
  }
}

async function check() {
  let list = [];
  try { list = JSON.parse(fs.readFileSync(REMINDERS_FILE, "utf-8")); } catch (_) { return; }
  if (!list.length) return;

  const now   = new Date();
  const hhmm  = `${String(now.getHours()).padStart(2,"0")}:${String(now.getMinutes()).padStart(2,"0")}`;
  const today = now.toISOString().slice(0, 10);

  const pending = [];
  for (const r of list) {
    if (!estaVencido(r, hhmm, today)) { pending.push(r); continue; }
    log(`Disparando recordatorio: ${r.text}`);
    const ok = await sendNotify(r.text);
    if (ok) continue; // entregado, se cae de la lista
    r._reintentando = true;
    r._intentos = (r._intentos || 0) + 1;
    if (r._intentos >= MAX_REINTENTOS) {
      await alertarFallo(`"${r.text}"`);
      continue; // se rinde, no se vuelve a intentar
    }
    pending.push(r);
  }

  if (pending.length !== list.length || JSON.stringify(pending) !== JSON.stringify(list)) {
    try { fs.writeFileSync(REMINDERS_FILE, JSON.stringify(pending, null, 2), "utf-8"); } catch (_) {}
  }
}

async function checkAll() {
  try { await check(); } catch (e) { log(`Error en check(): ${e.message}`); }
  try { await checkAgendaPublico(); } catch (e) { log(`Error en checkAgendaPublico(): ${e.message}`); }
}

log("Daemon iniciado. Revisando cada 30s.");
setInterval(checkAll, 30000);
checkAll();
