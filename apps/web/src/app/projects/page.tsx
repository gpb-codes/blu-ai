// Listado de proyectos con creación rápida desde la cabecera.

"use client";

import { useCallback, useEffect, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { Button } from "@/components/Button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/Card";
import { MainLayout } from "@/components/MainLayout";
import { projectsApi } from "@/lib/api";
import { cn, formatDate } from "@/lib/utils";
import type { ProjectSummary } from "@/types";

export default function ProjectsPage() {
  const router = useRouter();
  const [projects, setProjects] = useState<ProjectSummary[] | null>(null);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    try {
      setProjects(await projectsApi.list());
    } catch {
      setError("No se pudieron cargar los proyectos.");
      setProjects([]);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  return (
    <MainLayout>
      <div className="mx-auto max-w-5xl space-y-6">
        <header className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-slate-900 dark:text-slate-100">Proyectos</h1>
            <p className="mt-1 text-slate-500 dark:text-slate-400">Organiza tus notas, chats y agentes por proyecto.</p>
          </div>
          <Button asChild>
            <Link href="/projects/new">Nuevo proyecto</Link>
          </Button>
        </header>

        {error && (
          <p className="rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700 dark:bg-red-950/50 dark:text-red-300">{error}</p>
        )}

        {projects === null ? (
          <Card>
            <CardContent className="py-8 text-center text-sm text-slate-500 dark:text-slate-400">Cargando…</CardContent>
          </Card>
        ) : projects.length === 0 ? (
          <Card>
            <CardContent className="py-12 text-center">
              <p className="text-slate-600 dark:text-slate-300">No hay proyectos todavía.</p>
              <p className="mt-1 text-sm text-slate-500 dark:text-slate-400">Crea uno para empezar a trabajar.</p>
              <Button className="mt-5" onClick={() => router.push("/projects/new")}>
                Crear el primero
              </Button>
            </CardContent>
          </Card>
        ) : (
          <div className="grid gap-4 md:grid-cols-2">
            {projects.map((project) => (
              <Link key={project.id} href={`/projects/${project.id}`}>
                <Card className="transition-colors hover:border-indigo-400 dark:hover:border-indigo-600">
                  <CardHeader>
                    <div className="flex items-start justify-between gap-2">
                      <CardTitle>{project.name}</CardTitle>
                      <span
                        className={cn(
                          "shrink-0 rounded-full px-2 py-0.5 text-xs font-medium",
                          project.role === "OWNER"
                            ? "bg-indigo-100 text-indigo-700 dark:bg-indigo-950/60 dark:text-indigo-300"
                            : "bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-300",
                        )}
                      >
                        {project.role}
                      </span>
                    </div>
                    <CardDescription>
                      {project.memberCount} miembro{project.memberCount === 1 ? "" : "s"} · creado el {formatDate(project.createdAt)}
                    </CardDescription>
                  </CardHeader>
                </Card>
              </Link>
            ))}
          </div>
        )}
      </div>
    </MainLayout>
  );
}