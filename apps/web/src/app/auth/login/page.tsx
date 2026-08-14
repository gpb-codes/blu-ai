// Página de inicio de sesión.

"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { Button } from "@/components/Button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/Card";
import { Input } from "@/components/Input";
import { useAuth } from "@/lib/auth-context";
import { ApiError } from "@/types";

export default function LoginPage() {
  const { login } = useAuth();
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      await login(email, password);
      router.replace("/dashboard");
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "No se pudo iniciar sesión. Intenta de nuevo.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex flex-1 items-center justify-center p-6">
      <Card className="w-full max-w-md">
        <CardHeader>
          <CardTitle>Iniciar sesión</CardTitle>
          <CardDescription>Bienvenido de vuelta a BLU.</CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={onSubmit} className="space-y-4">
            {error && (
              <p className="rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700 dark:bg-red-950/50 dark:text-red-300">
                {error}
              </p>
            )}
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
                autoComplete="current-password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
              />
            </div>
            <Button type="submit" className="w-full" disabled={loading}>
              {loading ? "Entrando…" : "Entrar"}
            </Button>
          </form>
          <p className="mt-4 text-center text-sm text-slate-500 dark:text-slate-400">
            ¿No tienes cuenta?{" "}
            <Link href="/auth/register" className="font-medium text-indigo-600 hover:underline dark:text-indigo-400">
              Regístrate
            </Link>
          </p>
        </CardContent>
      </Card>
    </div>
  );
}