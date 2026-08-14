// Ajustes: perfil, API keys BYOK y créditos del plan.

"use client";

import { useCallback, useEffect, useState } from "react";
import { Button } from "@/components/Button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/Card";
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
          <h1 className="text-2xl font-bold text-slate-900 dark:text-slate-100">Ajustes</h1>
          <p className="mt-1 text-slate-500 dark:text-slate-400">Tu perfil, tus llaves y tu plan.</p>
        </header>

        {error && (
          <p className="rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700 dark:bg-red-950/50 dark:text-red-300">{error}</p>
        )}

        <Card>
          <CardHeader>
            <CardTitle>Perfil</CardTitle>
            <CardDescription>Información visible para tus colaboradores.</CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={saveProfile} className="space-y-4">
              <div className="space-y-1">
                <label htmlFor="displayName" className="text-sm font-medium text-slate-700 dark:text-slate-300">
                  Nombre
                </label>
                <Input
                  id="displayName"
                  value={displayName}
                  onChange={(e) => setDisplayName(e.target.value)}
                  minLength={2}
                  maxLength={60}
                  required
                />
              </div>
              <div className="space-y-1">
                <label htmlFor="timezone" className="text-sm font-medium text-slate-700 dark:text-slate-300">
                  Zona horaria
                </label>
                <Input
                  id="timezone"
                  value={timezone}
                  onChange={(e) => setTimezone(e.target.value)}
                  placeholder="America/Mexico_City"
                  pattern="^[A-Za-z0-9_+\-]+$"
                />
              </div>
              <div className="flex items-center gap-3">
                <Button type="submit">Guardar</Button>
                {saved && <span className="text-sm text-emerald-600 dark:text-emerald-400">Guardado ✓</span>}
              </div>
            </form>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>API keys (BYOK)</CardTitle>
            <CardDescription>
              Conecta tu propia llave de proveedor para pagar tu consumo directo. Se almacena cifrada.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <form onSubmit={addKey} className="flex flex-wrap items-end gap-2">
              <div className="min-w-0 flex-1 space-y-1">
                <label htmlFor="provider" className="text-sm font-medium text-slate-700 dark:text-slate-300">
                  Proveedor
                </label>
                <select
                  id="provider"
                  value={provider}
                  onChange={(e) => setProvider(e.target.value as ProviderId)}
                  className="h-10 w-full rounded-lg border border-slate-300 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-950 dark:text-slate-100"
                >
                  {PROVIDERS.map((p) => (
                    <option key={p.id} value={p.id}>
                      {p.label}
                    </option>
                  ))}
                </select>
              </div>
              <div className="min-w-0 flex-[2] space-y-1">
                <label htmlFor="keyValue" className="text-sm font-medium text-slate-700 dark:text-slate-300">
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
                />
              </div>
              <Button type="submit">Guardar</Button>
            </form>

            {keys === null ? (
              <p className="text-sm text-slate-500 dark:text-slate-400">Cargando llaves…</p>
            ) : keys.length === 0 ? (
              <p className="text-sm text-slate-500 dark:text-slate-400">Sin llaves configuradas.</p>
            ) : (
              <ul className="space-y-2">
                {keys.map((key) => (
                  <li key={key.id} className="flex items-center justify-between rounded-lg bg-slate-50 px-3 py-2 dark:bg-slate-800/50">
                    <div>
                      <p className="text-sm font-medium text-slate-900 dark:text-slate-100">
                        {PROVIDERS.find((p) => p.id === key.provider)?.label ?? key.provider}
                      </p>
                      <p className="font-mono text-xs text-slate-500 dark:text-slate-400">{key.maskedKey}</p>
                    </div>
                    <Button variant="ghost" size="sm" onClick={() => void removeKey(key.provider)}>
                      Eliminar
                    </Button>
                  </li>
                ))}
              </ul>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Créditos</CardTitle>
            <CardDescription>Tu saldo y límites según el plan.</CardDescription>
          </CardHeader>
          <CardContent>
            {credits === null ? (
              <p className="text-sm text-slate-500 dark:text-slate-400">Cargando…</p>
            ) : (
              <div className="space-y-3 text-sm">
                <div className="flex justify-between">
                  <span className="text-slate-600 dark:text-slate-300">Plan</span>
                  <span className="font-medium text-slate-900 dark:text-slate-100">{credits.plan}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-600 dark:text-slate-300">Saldo</span>
                  <span className="font-medium text-slate-900 dark:text-slate-100">{formatCredits(credits.credits)} créditos</span>
                </div>
                {credits.frozen ? (
                  <p className="text-slate-500 dark:text-slate-400">
                    Con el plan BYOK tu consumo se descuenta directo del proveedor.
                  </p>
                ) : (
                  <>
                    <div className="flex justify-between">
                      <span className="text-slate-600 dark:text-slate-300">Grant diario</span>
                      <span className="font-medium text-slate-900 dark:text-slate-100">{credits.grantsPerDay}</span>
                    </div>
                    {credits.resetsAt && (
                      <p className="text-xs text-slate-500 dark:text-slate-400">
                        Se renueva el {new Date(credits.resetsAt).toLocaleDateString("es-MX")}.
                      </p>
                    )}
                  </>
                )}
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </MainLayout>
  );
}