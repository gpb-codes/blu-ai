// blu-send.js — manda un WhatsApp a cualquier número vía Blu
// Uso: node blu-send.js 5551014481 "mensaje aquí"
// El número puede ser con o sin código de país (agrega 52 automático si falta)

const http = require("http");

let numero = (process.argv[2] || "").replace(/\D/g, "");
const texto = process.argv.slice(3).join(" ").trim();

if (!numero || !texto) {
  console.error('Uso: node blu-send.js <numero> "mensaje"');
  process.exit(1);
}

// Agregar código de país México (52) si el número tiene 10 dígitos
if (numero.length === 10) numero = "52" + numero;

const data = JSON.stringify({ numero, text: texto });

const req = http.request(
  {
    host: "127.0.0.1", port: 5052, path: "/send-to", method: "POST",
    headers: { "Content-Type": "application/json", "Content-Length": Buffer.byteLength(data) },
  },
  (res) => {
    let body = "";
    res.on("data", (c) => (body += c));
    res.on("end", () => {
      let ok = false;
      try { ok = JSON.parse(body || "{}").ok === true; } catch (_) {}
      if (ok) { console.log(`Enviado a ${numero}.`); process.exit(0); }
      else { console.error(`Error: ${body}`); process.exit(1); }
    });
  }
);
req.on("error", (e) => { console.error(`Error: ${e.message}`); process.exit(1); });
req.write(data);
req.end();
