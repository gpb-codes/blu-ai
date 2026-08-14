// Utilidades de estilos compartidas.

export function cn(...classes: Array<string | false | null | undefined>): string {
  return classes.filter(Boolean).join(" ");
}

export function formatDate(iso: string): string {
  return new Date(iso).toLocaleDateString("es-MX", { day: "numeric", month: "short", year: "numeric" });
}

export function formatCredits(n: number): string {
  return new Intl.NumberFormat("es-MX").format(Math.max(n, 0));
}