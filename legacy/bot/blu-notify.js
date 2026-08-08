// blu-notify.js — manda un mensaje proactivo por WhatsApp via Blu
// Uso: node blu-notify.js "Ignacio, son las 5pm, recuerda X"
//
// Le pide a blu-whatsapp.js (que debe estar corriendo) que envie el mensaje.

const http = require("http");

const texto = process.argv.slice(2).join(" ").trim();
if (!texto) {
  console.error('Uso: node blu-notify.js "mensaje a enviar"');
  process.exit(1);
}

const data = JSON.stringify({ text: texto });

const req = http.request(
  {
    host: "127.0.0.1",
    port: 5052,
    path: "/send",
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Content-Length": Buffer.byteLength(data),
    },
  },
  (res) => {
    let body = "";
    res.on("data", (c) => (body += c));
    res.on("end", () => {
      let ok = false;
      try { ok = JSON.parse(body || "{}").ok === true; } catch (_) {}
      if (ok) {
        console.log("Enviado.");
        process.exit(0);
      } else {
        console.error(`No se pudo enviar: ${body}`);
        process.exit(1);
      }
    });
  }
);

req.on("error", (e) => {
  console.error(`Error: ${e.message}. Esta corriendo blu-whatsapp.js?`);
  process.exit(1);
});

req.write(data);
req.end();
