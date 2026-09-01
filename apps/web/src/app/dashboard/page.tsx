// Panel principal: resumen con datos reales de la API (proyectos, sesiones y créditos).

"use client";

import { useCallback, useEffect, useState } from "react";
import Link from "next/link";
import { Button } from "@/components/Button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/Card";
import { MainLayout } from "@/components/MainLayout";
import { chatApi, projectsApi, userApi } from "@/lib/api";
import { useAuth } from "@/lib/auth-context";
import { cn, formatCredits, formatDate } from "@/lib/utils";
import type { ChatSession, CreditBalance, ProjectSummary } from "@/types";

export default function DashboardPage() {
  const { user } = useAuth();
  const [projects, setProjects] = useState<ProjectSummary[] | null>(null);
  const [sessions, setSessions] = useState<ChatSession[] | null>(null);
  const [credits, setCredits] = useState<CreditBalance | null>(null);

  const load = useCallback(async () => {
    try {
      const [p, s, c] = await Promise.all([projectsApi.list(), chatApi.sessions(), userApi.credits()]);
      setProjects(p);
      setSessions(s);
      setCredits(c);
    } catch {
      setProjects([]);
      setSessions([]);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  return (
    <MainLayout>
      <div className="mx-auto max-w-5xl space-y-8">
        <header>
          <h1 className="text-2xl font-bold text-slate-900 dark:text-slate-100">
            Hola, {user?.displayName.split(" ")[0]} 👋
          </h1>
          <p className="mt-1 text-slate-500 dark:text-slate-400">Este es el resumen de tu espacio de trabajo.</p>
        </header>

        <div className="grid gap-4 md:grid-cols-3">
          <Card>
            <CardHeader>
              <CardTitle className="text-sm font-medium text-slate-500 dark:text-slate-400">Proyectos</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-3xl font-bold text-slate-900 dark:text-slate-100">{projects?.length ?? "…"}</p>
            </CardContent>
          </Card>
          <Card>
            <CardHeader>
              <CardTitle className="text-sm font-medium text-slate-500 dark:text-slate-400">Sesiones de chat</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-3xl font-bold text-slate-900 dark:text-slate-100">{sessions?.length ?? "…"}</p>
            </CardContent>
          </Card>
          <Card>
            <CardHeader>
              <CardTitle className="text-sm font-medium text-slate-500 dark:text-slate-400">Créditos ({credits?.plan ?? "…"})</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-3xl font-bold text-slate-900 dark:text-slate-100">{credits ? formatCredits(credits.credits) : "…"}</p>
              {credits?.resetsAt && (
                <p className="mt-1 text-xs text-slate-500 dark:text-slate-400">
                  Se renuevan el {formatDate(credits.resetsAt)}
                </p>
              )}
            </CardContent>
          </Card>
        </div>

        <section className="space-y-4">
          <div className="flex items-center justify-between">
            <h2 className="text-lg font-semibold text-slate-900 dark:text-slate-100">Tus proyectos</h2>
            <Button asChild size="sm">
              <Link href="/projects/new">Nuevo proyecto</Link>
            </Button>
          </div>
          {projects === null ? (
            <Card>
              <CardContent className="py-6 text-center text-sm text-slate-500 dark:text-slate-400">Cargando proyectos…</CardContent>
            </Card>
          ) : projects.length === 0 ? (
            <Card>
              <CardContent className="py-10 text-center">
                <p className="text-slate-600 dark:text-slate-300">Aún no tienes proyectos.</p>
                <p className="mt-1 text-sm text-slate-500 dark:text-slate-400">Crea el primero para empezar a organizar tu trabajo.</p>
                <Button asChild className="mt-4">
                  <Link href="/projects/new">Crear proyecto</Link>
                </Button>
              </CardContent>
            </Card>
          ) : (
            <div className="grid gap-4 md:grid-cols-2">
              {projects.map((project) => (
                <Link key={project.id} href={`/projects/${project.id}`}>
                  <Card className="transition-colors hover:border-indigo-400 dark:hover:border-indigo-600">
                    <CardHeader className="mb-0">
                      <CardTitle>{project.name}</CardTitle>
                      <CardDescription>
                        {project.memberCount} miembro{project.memberCount === 1 ? "" : "s"} · {formatDate(project.createdAt)}
                      </CardDescription>
                    </CardHeader>
                    <CardContent className="mt-3">
                      <span
                        className={cn(
                          "rounded-full px-2 py-0.5 text-xs font-medium",
                          project.role === "OWNER"
                            ? "bg-indigo-100 text-indigo-700 dark:bg-indigo-950/60 dark:text-indigo-300"
                            : "bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-300",
                        )}
                      >
                        {project.role}
                      </span>
                    </CardContent>
                  </Card>
                </Link>
              ))}
            </div>
          )}
        </section>
      </div>
    </MainLayout>
  );
}