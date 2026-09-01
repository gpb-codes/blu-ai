"use client";

import { useCallback, useEffect, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { Button } from "@/components/Button";
import { Input } from "@/components/Input";
import { AppShell } from "@/components/shell/AppShell";
import { userApi } from "@/lib/api";
import { useAuth } from "@/lib/auth-context";
import { formatCredits } from "@/lib/utils";
import type { ApiKeyMasked, CreditBalance, ProviderId } from "@/types";

type Tab = "general" | "mcp" | "interfaz" | "modelos" | "chats" | "personalizacion" | "cuenta" | "about";

const TABS: Array<{ id: Tab; label: string; icon: string }> = [
  { id: "general", label: "General", icon: "⬡" },
  { id: "mcp", label: "MCP", icon: "✦" },
  { id: "interfaz", label: "Interfaz", icon: "▭" },
  { id: "modelos", label: "Modelos", icon: "⬢" },
  { id: "chats", label: "Chats", icon: "💬" },
  { id: "personalizacion", label: "Personalización", icon: "⊞" },
  { id: "cuenta", label: "Cuenta", icon: "👤" },
  { id: "about", label: "Sobre nosotros", icon: "ⓘ" },
];

const PROVIDERS: Array<{ id: ProviderId; label: string }> = [
  { id: "anthropic", label: "Anthropic" },
  { id: "openai", label: "OpenAI" },
  { id: "gemini", label: "Google Gemini" },
  { id: "openrouter", label: "OpenRouter" },
];

function useTheme() {
  const [theme, setTheme] = useState<"sistema" | "claro" | "oscuro">("oscuro");
  useEffect(() => {
    const saved = localStorage.getItem("blu.theme") as typeof theme | null;
    if (saved) setTheme(saved);
  }, []);
  const apply = (t: typeof theme) => {
    setTheme(t);
    localStorage.setItem("blu.theme", t);
    const root = document.documentElement;
    root.classList.remove("dark", "light");
    if (t === "oscuro") root.classList.add("dark");
    else if (t === "claro") root.classList.add("light");
    else {
      if (window.matchMedia("(prefers-color-scheme: dark)").matches) root.classList.add("dark");
    }
  };
  return { theme, apply };
}

export default function SettingsPage() {
  const router = useRouter();
  const [tab, setTab] = useState<Tab>("general");
  const { theme, apply } = useTheme();
  const [lang, setLang] = useState("Spanish (Español)");

  return (
    <AppShell>
      <div className="flex h-screen flex-col bg-blu-bg">
        {/* Header */}
        <div className="flex h-12 shrink-0 items-center gap-3 border-b border-blu-outline/20 px-4">
          <button
            type="button"
            onClick={() => router.back()}
            aria-label="Volver"
            className="flex items-center gap-2 text-sm font-medium text-blu-on hover:text-blu-primary-solid"
          >
            <span aria-hidden>←</span> Configuración
          </button>
        </div>

        <div className="flex min-h-0 flex-1">
          {/* Left nav */}
          <nav className="w-[220px] shrink-0 border-r border-blu-outline/20 bg-blu-bg p-2">
            {TABS.map((t) => (
              <button
                key={t.id}
                type="button"
                onClick={() => setTab(t.id)}
                className={`flex w-full items-center gap-3 rounded-lg px-3 py-2 text-left text-sm transition-colors ${
                  tab === t.id ? "bg-blu-surface-high text-blu-on" : "text-blu-on-variant hover:bg-blu-surface-high hover:text-blu-on"
                }`}
              >
                <span className="w-4 text-center text-xs">{t.icon}</span>
                {t.label}
              </button>
            ))}
          </nav>

          {/* Right content */}
          <div className="flex-1 overflow-y-auto bg-[#2d2d2d] md:bg-blu-surface">
            <div className="mx-auto max-w-[560px] px-6 py-8">
              {tab === "general" && (
                <GeneralTab theme={theme} apply={apply} lang={lang} setLang={setLang} />
              )}
              {tab === "cuenta" && <CuentaTab />}
              {tab !== "general" && tab !== "cuenta" && (
                <div className="py-12 text-center">
                  <p className="text-sm text-blu-on-variant">Sección {TABS.find((t) => t.id === tab)?.label} — Próximamente</p>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </AppShell>
  );
}

function GeneralTab({
  theme,
  apply,
  lang,
  setLang,
}: {
  theme: "sistema" | "claro" | "oscuro";
  apply: (t: "sistema" | "claro" | "oscuro") => void;
  lang: string;
  setLang: (v: string) => void;
}) {
  return (
    <div>
      <h1 className="text-base font-semibold text-white">General</h1>

      <div className="mt-6 divide-y divide-white/10 rounded">
        {/* Tema */}
        <div className="flex items-center justify-between py-4">
          <span className="text-sm text-blu-on">Tema</span>
          <div className="flex rounded-full bg-black/40 p-1">
            {(["Sistema", "Claro", "Oscuro"] as const).map((opt) => {
              const key = opt.toLowerCase() as typeof theme;
              const active = theme === key;
              return (
                <button
                  key={opt}
                  type="button"
                  onClick={() => apply(key)}
                  className={`rounded-full px-3 py-1 text-xs font-medium transition-colors ${
                    active ? "bg-blu-surface-high text-white shadow" : "text-blu-on-variant hover:text-white"
                  }`}
                >
                  {opt}
                </button>
              );
            })}
          </div>
        </div>

        {/* Lenguaje */}
        <div className="flex items-center justify-between py-4">
          <span className="text-sm text-blu-on">Lenguaje</span>
          <div className="relative">
            <select
              value={lang}
              onChange={(e) => setLang(e.target.value)}
              className="appearance-none rounded bg-transparent pr-6 text-sm text-blu-on focus:outline-none"
            >
              <option>Spanish (Español)</option>
              <option>English</option>
            </select>
            <span className="pointer-events-none absolute right-0 top-1/2 -translate-y-1/2 text-blu-on-variant">⌄</span>
          </div>
        </div>

        {/* Voz */}
        <button
          type="button"
          onClick={() => alert("Voz: Dylan")}
          className="flex w-full items-center justify-between py-4 text-left hover:opacity-80"
        >
          <span className="text-sm text-blu-on">Voz</span>
          <span className="flex items-center gap-1 text-sm text-blu-on">
            Dylan <span className="text-blu-on-variant">›</span>
          </span>
        </button>
      </div>
    </div>
  );
}

function CuentaTab() {
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
      setError(err instanceof Error ? err.message : "No se pudo guardar.");
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
      setError(err instanceof Error ? err.message : "No se pudo guardar.");
    }
  };
  const removeKey = async (p: ProviderId) => {
    try {
      await userApi.removeApiKey(p);
      await load();
    } catch (err) {
      setError(err instanceof Error ? err.message : "No se pudo eliminar.");
    }
  };

  return (
    <div className="space-y-6">
      <h2 className="text-base font-semibold text-white">Cuenta</h2>
      {error && <p className="rounded bg-red-500/10 px-3 py-2 text-sm text-red-400">{error}</p>}
      <form onSubmit={saveProfile} className="space-y-4 rounded-xl border border-white/10 bg-blu-surface-low p-4">
        <h3 className="font-medium text-blu-on">Perfil</h3>
        <Input value={displayName} onChange={(e) => setDisplayName(e.target.value)} placeholder="Nombre" />
        <Input value={timezone} onChange={(e) => setTimezone(e.target.value)} placeholder="America/Mexico_City" />
        <div className="flex items-center gap-2">
          <Button type="submit">Guardar</Button>
          {saved && <span className="text-sm text-emerald-400">Guardado ✓</span>}
        </div>
      </form>

      <div className="rounded-xl border border-white/10 bg-blu-surface-low p-4">
        <h3 className="font-medium text-blu-on">API keys (BYOK)</h3>
        <form onSubmit={addKey} className="mt-3 flex gap-2">
          <select value={provider} onChange={(e) => setProvider(e.target.value as ProviderId)} className="rounded-lg border border-white/10 bg-blu-surface px-3 text-sm text-blu-on">
            {PROVIDERS.map((p) => (
              <option key={p.id} value={p.id}>
                {p.label}
              </option>
            ))}
          </select>
          <Input value={keyValue} onChange={(e) => setKeyValue(e.target.value)} placeholder="sk-…" className="flex-1" />
          <Button type="submit">Guardar</Button>
        </form>
        <div className="mt-3 space-y-2">
          {keys?.map((k) => (
            <div key={k.id} className="flex items-center justify-between rounded bg-blu-surface px-3 py-2">
              <span className="text-sm text-blu-on">
                {k.provider} · <span className="font-mono text-xs text-blu-on-variant">{k.maskedKey}</span>
              </span>
              <Button variant="ghost" size="sm" onClick={() => void removeKey(k.provider)}>
                Eliminar
              </Button>
            </div>
          ))}
        </div>
      </div>

      <div className="rounded-xl border border-white/10 bg-blu-surface-low p-4">
        <h3 className="font-medium text-blu-on">Créditos</h3>
        {credits ? (
          <p className="mt-2 text-sm text-blu-on-variant">
            Plan {credits.plan} · {formatCredits(credits.credits)} créditos
          </p>
        ) : (
          <p className="text-sm text-blu-on-variant">Cargando…</p>
        )}
      </div>
    </div>
  );
}
