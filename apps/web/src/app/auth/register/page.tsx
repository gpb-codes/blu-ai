// Página de registro con el diseño soybluia (fondo y tarjetas dark).

"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { Button } from "@/components/Button";
import { Input } from "@/components/Input";
import { useAuth } from "@/lib/auth-context";
import { ApiError } from "@/types";

export default function RegisterPage() {
  const { register } = useAuth();
  const router = useRouter();
  const [displayName, setDisplayName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      await register(email, password, displayName);
      router.replace("/dashboard");
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "No se pudo crear la cuenta. Intenta de nuevo.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex flex-1 items-center justify-center bg-blu-bg p-6">
      <div className="w-full max-w-md">
        <div className="mb-8 flex items-center justify-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-blu-primary-solid">
            <svg viewBox="0 0 24 24" className="h-5 w-5 text-white" fill="currentColor" aria-hidden>
              <path d="M13 2 4.5 13.5h5L11 22l8.5-11.5h-5L13 2z" />
            </svg>
          </div>
          <span className="text-2xl font-bold text-blu-on">soybluia</span>
        </div>

        <div className="rounded-xl border border-blu-outline/20 bg-blu-surface-low p-6">
          <h1 className="font-geist text-2xl font-semibold text-blu-on">Crear cuenta</h1>
          <p className="mt-1 text-sm text-blu-on-variant">Únete a BLU y empieza a construir tu segundo cerebro.</p>

          <form onSubmit={onSubmit} className="mt-6 space-y-4">
            {error && (
              <p className="rounded-lg bg-blu-error/10 px-3 py-2 text-sm text-blu-error">{error}</p>
            )}
            <div className="space-y-1">
              <label htmlFor="displayName" className="text-sm text-blu-on-variant">
                Nombre
              </label>
              <Input
                id="displayName"
                required
                minLength={2}
                value={displayName}
                onChange={(e) => setDisplayName(e.target.value)}
                placeholder="Ana García"
                className="border-blu-outline/40 bg-blu-surface focus:border-blu-primary-solid dark:bg-blu-surface"
              />
            </div>
            <div className="space-y-1">
              <label htmlFor="email" className="text-sm text-blu-on-variant">
                Correo
              </label>
              <Input
                id="email"
                type="email"
                required
                autoComplete="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="tu@correo.com"
                className="border-blu-outline/40 bg-blu-surface focus:border-blu-primary-solid dark:bg-blu-surface"
              />
            </div>
            <div className="space-y-1">
              <label htmlFor="password" className="text-sm text-blu-on-variant">
                Contraseña
              </label>
              <Input
                id="password"
                type="password"
                required
                minLength={8}
                autoComplete="new-password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Mínimo 8 caracteres"
                className="border-blu-outline/40 bg-blu-surface focus:border-blu-primary-solid dark:bg-blu-surface"
              />
            </div>
            <Button type="submit" className="w-full" disabled={loading}>
              {loading ? "Creando…" : "Crear cuenta"}
            </Button>
          </form>
          <p className="mt-4 text-center text-sm text-blu-on-variant">
            ¿Ya tienes cuenta?{" "}
            <Link href="/auth/login" className="font-medium text-blu-primary hover:underline">
              Inicia sesión
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}