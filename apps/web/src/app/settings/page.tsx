// Ajustes con el diseño de referencia: encabezado de página, tarjetas AppCard
// (fondo surfaceContainerLow, radio 12) y secciones con icono.

"use client";

import { useCallback, useEffect, useState } from "react";
import { Button } from "@/components/Button";
import { Input } from "@/components/Input";
import { MainLayout } from "@/components/MainLayout";
import { userApi } from "@/lib/api";
import { useAuth } from "@/lib/auth-context";
import { formatCredits } from "@/lib/utils";
import type { ApiKeyMasked, CreditBalance, ProviderId } from "@/types";

const PROVIDERS: Array<{ id: ProviderId; label: string }> = [
  { id: "anthropic", label: "Anthropic" },
  { id: "openai", label: "OpenAI" },
  { id: "gemini", label: "Google Gemini" },
  { id: "openrouter", label: "OpenRouter" },
];

function SectionIcon({ children }: { children: React.ReactNode }) {
  return <span className="text-blu-primary">{children}</span>;
}

export default function SettingsPage() {
  const { user, updateUser } = useAuth();
  const [displayName, setDisplayName] = useState(user?.displayName ?? "");
  const [timezone, setTimezone] = useState(user?.timezone ?? "UTC");
  const [saved, setSaved] = useState(false);
  const [keys, setKeys] = useState<ApiKeyMasked[] | null>(null);
  const [credits, setCredits] = useState<CreditBalance | null>(null);
  const [provider, setProvider] = useState<ProviderId>("anthropic");
  const [keyValue, setKeyValue] = useState("");
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    try {
      const [k, c] = await Promise.all([userApi.apiKeys(), userApi.credits()]);
      setKeys(k);
      setCredits(c);
    } catch {
      setKeys([]);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  const saveProfile = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setSaved(false);
    try {
      const updated = await userApi.updateProfile({ displayName, timezone });
      updateUser(updated);
      setSaved(true);
    } catch (err) {
      setError(err instanceof Error ? err.message : "No se pudo guardar el perfil.");
    }
  };

  const addKey = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    try {
      await userApi.addApiKey(provider, keyValue);
      setKeyValue("");
      await load();
    } catch (err) {
      setError(err instanceof Error ? err.message : "No se pudo guardar la API key.");
    }
  };

  const removeKey = async (p: ProviderId) => {
    setError(null);
    try {
      await userApi.removeApiKey(p);
      await load();
    } catch (err) {
      setError(err instanceof Error ? err.message : "No se pudo eliminar la API key.");
    }
  };

  return (
    <MainLayout>
      <div className="mx-auto max-w-2xl space-y-6">
        <header>
          <h1 className="font-geist text-3xl font-semibold text-blu-on">Ajustes</h1>
          <p className="mt-2 text-sm text-blu-on-variant">Tu perfil, tus llaves y tu plan.</p>
        </header>

        {error && (
          <p className="rounded-lg bg-blu-error/10 px-3 py-2 text-sm text-blu-error">{error}</p>
        )}

        <section className="rounded-xl border border-blu-outline/20 bg-blu-surface-low p-4">
          <header className="mb-4">
            <h2 className="flex items-center gap-2 text-xl font-medium text-blu-on">
              <SectionIcon>👤</SectionIcon> Perfil
            </h2>
            <p className="mt-1 text-sm text-blu-on-variant">Información visible para tus colaboradores.</p>
          </header>
          <form onSubmit={saveProfile} className="space-y-4">
            <div className="space-y-1">
              <label htmlFor="displayName" className="text-sm text-blu-on-variant">
                Nombre
              </label>
              <Input
                id="displayName"
                value={displayName}
                onChange={(e) => setDisplayName(e.target.value)}
                minLength={2}
                maxLength={60}
                required
                className="border-blu-outline/40 bg-blu-surface focus:border-blu-primary-solid dark:bg-blu-surface"
              />
            </div>
            <div className="space-y-1">
              <label htmlFor="timezone" className="text-sm text-blu-on-variant">
                Zona horaria
              </label>
              <Input
                id="timezone"
                value={timezone}
                onChange={(e) => setTimezone(e.target.value)}
                placeholder="America/Mexico_City"
                pattern="^[A-Za-z0-9_+\-]+$"
                className="border-blu-outline/40 bg-blu-surface focus:border-blu-primary-solid dark:bg-blu-surface"
              />
            </div>
            <div className="flex items-center gap-3">
              <Button type="submit">Guardar</Button>
              {saved && <span className="text-sm text-emerald-400">Guardado ✓</span>}
            </div>
          </form>
        </section>

        <section className="rounded-xl border border-blu-outline/20 bg-blu-surface-low p-4">
          <header className="mb-4">
            <h2 className="flex items-center gap-2 text-xl font-medium text-blu-on">
              <SectionIcon>🔑</SectionIcon> API keys (BYOK)
            </h2>
            <p className="mt-1 text-sm text-blu-on-variant">
              Conecta tu propia llave de proveedor para pagar tu consumo directo. Se almacena cifrada.
            </p>
          </header>
          <div className="space-y-4">
            <form onSubmit={addKey} className="flex flex-wrap items-end gap-2">
              <div className="min-w-0 flex-1 space-y-1">
                <label htmlFor="provider" className="text-sm text-blu-on-variant">
                  Proveedor
                </label>
                <select
                  id="provider"
                  value={provider}
                  onChange={(e) => setProvider(e.target.value as ProviderId)}
                  className="h-10 w-full rounded-lg border border-blu-outline/40 bg-blu-surface px-3 text-sm text-blu-on focus:outline-none focus:ring-1 focus:ring-blu-primary/40"
                >
                  {PROVIDERS.map((p) => (
                    <option key={p.id} value={p.id}>
                      {p.label}
                    </option>
                  ))}
                </select>
              </div>
              <div className="min-w-0 flex-[2] space-y-1">
                <label htmlFor="keyValue" className="text-sm text-blu-on-variant">
                  Llave
                </label>
                <Input
                  id="keyValue"
                  type="password"
                  value={keyValue}
                  onChange={(e) => setKeyValue(e.target.value)}
                  placeholder="sk-…"
                  required
                  minLength={8}
                  className="border-blu-outline/40 bg-blu-surface focus:border-blu-primary-solid dark:bg-blu-surface"
                />
              </div>
              <Button type="submit">Guardar</Button>
            </form>

            {keys === null ? (
              <p className="text-sm text-blu-on-variant">Cargando llaves…</p>
            ) : keys.length === 0 ? (
              <p className="text-sm text-blu-on-variant">Sin llaves configuradas.</p>
            ) : (
              <ul className="space-y-2">
                {keys.map((key) => (
                  <li
                    key={key.id}
                    className="flex items-center justify-between rounded-lg bg-blu-surface px-3 py-2"
                  >
                    <div>
                      <p className="text-sm font-medium text-blu-on">
                        {PROVIDERS.find((p) => p.id === key.provider)?.label ?? key.provider}
                      </p>
                      <p className="font-mono text-xs text-blu-on-variant">{key.maskedKey}</p>
                    </div>
                    <Button variant="ghost" size="sm" onClick={() => void removeKey(key.provider)}>
                      Eliminar
                    </Button>
                  </li>
                ))}
              </ul>
            )}
          </div>
        </section>

        <section className="rounded-xl border border-blu-outline/20 bg-blu-surface-low p-4">
          <header className="mb-4">
            <h2 className="flex items-center gap-2 text-xl font-medium text-blu-on">
              <SectionIcon>⚡</SectionIcon> Créditos
            </h2>
            <p className="mt-1 text-sm text-blu-on-variant">Tu saldo y límites según el plan.</p>
          </header>
          {credits === null ? (
            <p className="text-sm text-blu-on-variant">Cargando…</p>
          ) : (
            <div className="space-y-3 text-sm">
              <div className="flex justify-between">
                <span className="text-blu-on-variant">Plan</span>
                <span className="font-medium text-blu-on">{credits.plan}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-blu-on-variant">Saldo</span>
                <span className="font-medium text-blu-on">{formatCredits(credits.credits)} créditos</span>
              </div>
              {credits.frozen ? (
                <p className="text-blu-on-variant">
                  Con el plan BYOK tu consumo se descuenta directo del proveedor.
                </p>
              ) : (
                <>
                  <div className="flex justify-between">
                    <span className="text-blu-on-variant">Grant diario</span>
                    <span className="font-medium text-blu-on">{credits.grantsPerDay}</span>
                  </div>
                  {credits.resetsAt && (
                    <p className="text-xs text-blu-on-variant">
                      Se renueva el {new Date(credits.resetsAt).toLocaleDateString("es-MX")}.
                    </p>
                  )}
                </>
              )}
            </div>
          )}
        </section>
      </div>
    </MainLayout>
  );
}