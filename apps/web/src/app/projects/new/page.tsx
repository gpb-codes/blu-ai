// Creación de un proyecto nuevo.

"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/Button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/Card";
import { Input } from "@/components/Input";
import { MainLayout } from "@/components/MainLayout";
import { projectsApi } from "@/lib/api";
import { ApiError } from "@/types";

export default function NewProjectPage() {
  const router = useRouter();
  const [name, setName] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      const project = await projectsApi.create(name);
      router.push(`/projects/${project.id}`);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "No se pudo crear el proyecto.");
      setLoading(false);
    }
  };

  return (
    <MainLayout>
      <div className="mx-auto max-w-xl space-y-6">
        <header>
          <h1 className="text-2xl font-bold text-slate-900 dark:text-slate-100">Nuevo proyecto</h1>
          <p className="mt-1 text-slate-500 dark:text-slate-400">Un espacio para agrupar notas, chats y agentes.</p>
        </header>

        <Card>
          <CardHeader>
            <CardTitle>Detalles</CardTitle>
            <CardDescription>El nombre define también la URL pública del proyecto.</CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={onSubmit} className="space-y-4">
              {error && (
                <p className="rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700 dark:bg-red-950/50 dark:text-red-300">
                  {error}
                </p>
              )}
              <div className="space-y-1">
                <label htmlFor="name" className="text-sm font-medium text-slate-700 dark:text-slate-300">
                  Nombre
                </label>
                <Input
                  id="name"
                  required
                  minLength={2}
                  maxLength={60}
                  autoFocus
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="Ej. Lanzamiento 2027"
                />
              </div>
              <div className="flex gap-3">
                <Button type="submit" disabled={loading}>
                  {loading ? "Creando…" : "Crear proyecto"}
                </Button>
                <Button variant="ghost" onClick={() => router.back()}>
                  Cancelar
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      </div>
    </MainLayout>
  );
}