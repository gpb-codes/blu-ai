// HTTP compartido por los adapters: POST JSON con timeout y errores legibles
// para que TierRouter haga fallback entre proveedores.

export const HTTP_TIMEOUT_MS = 90000;

export class ProviderHttpError extends Error {
  constructor(
    message: string,
    public readonly status: number,
    public readonly providerLabel: string,
  ) {
    super(message);
    this.name = "ProviderHttpError";
  }
}

export interface PostJsonOptions {
  url: string;
  body: unknown;
  headers: Record<string, string>;
  signal?: AbortSignal;
  timeoutMs?: number;
}

/** POST JSON → parsed body. Lanza ProviderHttpError con mensaje útil si el proveedor responde error. */
export async function postJson<T>(opts: PostJsonOptions): Promise<T> {
  const { url, body, headers, signal, timeoutMs = HTTP_TIMEOUT_MS } = opts;

  const signal2 = signal ? AbortSignal.any([signal, AbortSignal.timeout(timeoutMs)]) : AbortSignal.timeout(timeoutMs);

  let res: Response;
  try {
    res = await fetch(url, {
      method: "POST",
      headers: { "content-type": "application/json", ...headers },
      body: JSON.stringify(body),
      signal: signal2,
    });
  } catch (e) {
    throw new ProviderHttpError(
      e instanceof Error ? `Sin conexión con el proveedor: ${e.message}` : "Error de red",
      0,
      headers["x-provider"] ?? "proveedor",
    );
  }

  const raw = await res.text();
  let parsed: unknown = null;
  try {
    parsed = raw ? JSON.parse(raw) : null;
  } catch {
    parsed = null;
  }

  if (!res.ok) {
    throw new ProviderHttpError(describeHttpError(res.status, parsed), res.status, headers["x-provider"] ?? "proveedor");
  }
  return parsed as T;
}

function describeHttpError(status: number, body: unknown): string {
  if (status === 401 || status === 403) return `API key rechazada (HTTP ${status})`;
  if (status === 429) return `Rate limit del proveedor (HTTP 429)`;
  const msg = extractErrorMessage(body);
  return `Error del proveedor (HTTP ${status}): ${msg}`;
}

function extractErrorMessage(body: unknown): string {
  if (!body) return "sin detalle";
  if (typeof body === "string") return body.slice(0, 300);
  const b = body as { error?: { error?: { message?: string }; message?: string; status?: string | number; code?: string | number }; message?: string };
  const err = b.error;
  const candidates: unknown[] = [
    err?.error?.message,
    err?.message,
    err?.status ?? err?.code,
    b.message,
  ];
  const found = candidates.find((c) => typeof c === "string" && (c as string).length > 0) as string | undefined;
  return found?.slice(0, 300) ?? `HTTP ${err?.status ?? ""}`.trim();
}