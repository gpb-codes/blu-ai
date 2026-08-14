// Página de registro de cuenta.

"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { Button } from "@/components/Button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/Card";
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
    <div className="flex flex-1 items-center justify-center p-6">
      <Card className="w-full max-w-md">
        <CardHeader>
          <CardTitle>Crear cuenta</CardTitle>
          <CardDescription>Únete a BLU y empieza a construir tu segundo cerebro.</CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={onSubmit} className="space-y-4">
            {error && (
              <p className="rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700 dark:bg-red-950/50 dark:text-red-300">
                {error}
              </p>
            )}
            <div className="space-y-1">
              <label htmlFor="displayName" className="text-sm font-medium text-slate-700 dark:text-slate-300">
                Nombre
              </label>
              <Input
                id="displayName"
                required
                minLength={2}
                value={displayName}
                onChange={(e) => setDisplayName(e.target.value)}
                placeholder="Ana García"
              />
            </div>
            <div className="space-y-1">
              <label htmlFor="email" className="text-sm font-medium text-slate-700 dark:text-slate-300">
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
              />
            </div>
            <div className="space-y-1">
              <label htmlFor="password" className="text-sm font-medium text-slate-700 dark:text-slate-300">
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
              />
            </div>
            <Button type="submit" className="w-full" disabled={loading}>
              {loading ? "Creando…" : "Crear cuenta"}
            </Button>
          </form>
          <p className="mt-4 text-center text-sm text-slate-500 dark:text-slate-400">
            ¿Ya tienes cuenta?{" "}
            <Link href="/auth/login" className="font-medium text-indigo-600 hover:underline dark:text-indigo-400">
              Inicia sesión
            </Link>
          </p>
        </CardContent>
      </Card>
    </div>
  );
}