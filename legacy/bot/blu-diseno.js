// blu-diseno.js — renderiza blu-diseno-input.html a PNG (estilo IgnacioLoyola)
// Uso: node blu-diseno.js  [ruta-html-opcional]
// Lee C:\Users\MSI\.claude\scripts\blu-diseno-input.html, mide el alto real del
// contenido y exporta blu-diseno.png a 2x. Imprime la ruta del PNG por stdout.
const path = require("path");
const fs = require("fs");
const puppeteer = require("puppeteer");

const INPUT = process.argv[2] || path.join(__dirname, "blu-diseno-input.html");
const OUT = path.join(__dirname, "blu-diseno.png");

(async () => {
  if (!fs.existsSync(INPUT)) {
    console.error("ERROR: no existe " + INPUT + " — escribe ahi el HTML primero.");
    process.exit(1);
  }
  // La cache de puppeteer esta incompleta; usamos el Chrome del sistema.
  const CHROME = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe";
  const browser = await puppeteer.launch({
    headless: "new",
    executablePath: fs.existsSync(CHROME) ? CHROME : undefined,
    args: ["--no-sandbox", "--disable-dev-shm-usage", "--force-device-scale-factor=2"],
  });
  try {
    const page = await browser.newPage();
    await page.setViewport({ width: 1600, height: 900, deviceScaleFactor: 2 });
    await page.goto("file:///" + INPUT.replace(/\\/g, "/"), { waitUntil: "networkidle0" });
    // Mide el tamano real del contenido (el body define el ancho de la pieza)
    const size = await page.evaluate(() => {
      const b = document.body;
      const w = Math.ceil(Math.max(b.scrollWidth, b.offsetWidth));
      const h = Math.ceil(Math.max(b.scrollHeight, b.offsetHeight));
      return { w, h };
    });
    await page.setViewport({ width: size.w, height: size.h, deviceScaleFactor: 2 });
    await new Promise((r) => setTimeout(r, 150)); // deja asentar fuentes/layout
    await page.screenshot({ path: OUT, clip: { x: 0, y: 0, width: size.w, height: size.h } });
    console.log(OUT);
  } catch (e) {
    console.error("ERROR renderizando:", e.message);
    process.exit(1);
  } finally {
    await browser.close();
  }
})();
