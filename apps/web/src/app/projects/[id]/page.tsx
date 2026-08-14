// Detalle de proyecto: pestañas de notas (vault), sesiones de chat y miembros.

"use client";

import { use, useCallback, useEffect, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { Button } from "@/components/Button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/Card";
import { Input } from "@/components/Input";
import { MainLayout } from "@/components/MainLayout";
import { chatApi, projectsApi, vaultApi } from "@/lib/api";
import { cn, formatDate } from "@/lib/utils";
import type { ChatSession, MemberRole, NoteSummary, ProjectMember, ProjectSummary } from "@/types";

type Tab = "notas" | "chat" | "miembros";

export default function ProjectDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const router = useRouter();
  const [tab, setTab] = useState<Tab>("notas");
  const [project, setProject] = useState<ProjectSummary | null>(null);
  const [notes, setNotes] = useState<NoteSummary[] | null>(null);
  const [sessions, setSessions] = useState<ChatSession[] | null>(null);
  const [members, setMembers] = useState<ProjectMember[] | null>(null);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setError(null);
    try {
      setProject(await projectsApi.get(id));
      setNotes(await vaultApi.notes(id));
      setSessions(await chatApi.sessions(id));
      setMembers(await projectsApi.members(id));
    } catch {
      setError("No se pudo cargar el proyecto. Puede que no tengas acceso.");
    }
  }, [id]);

  useEffect(() => {
    void load();
  }, [load]);

  if (error) {
    return (
      <MainLayout>
        <Card className="mx-auto max-w-xl">
          <CardContent className="py-10 text-center">
            <p className="text-slate-600 dark:text-slate-300">{error}</p>
            <Button variant="outline" className="mt-4" onClick={() => router.push("/projects")}>
              Volver a proyectos
            </Button>
          </CardContent>
        </Card>
      </MainLayout>
    );
  }

  return (
    <MainLayout>
      <div className="mx-auto max-w-5xl space-y-6">
        <header className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-slate-900 dark:text-slate-100">{project?.name ?? "…"}</h1>
            <p className="mt-1 text-slate-500 dark:text-slate-400">
              {project ? `${project.memberCount} miembro(s) · ${project.role}` : ""}
            </p>
          </div>
          <Button asChild variant="outline" size="sm">
            <Link href="/projects">← Proyectos</Link>
          </Button>
        </header>

        <div className="flex gap-1 rounded-lg bg-slate-100 p-1 dark:bg-slate-800">
          {(["notas", "chat", "miembros"] as Tab[]).map((t) => (
            <button
              key={t}
              type="button"
              onClick={() => setTab(t)}
              className={cn(
                "flex-1 rounded-md px-3 py-1.5 text-sm font-medium capitalize transition-colors",
                tab === t
                  ? "bg-white text-slate-900 shadow-sm dark:bg-slate-900 dark:text-slate-100"
                  : "text-slate-600 hover:text-slate-900 dark:text-slate-300 dark:hover:text-slate-100",
              )}
            >
              {t}
            </button>
          ))}
        </div>

        {tab === "notas" && <NotesTab projectId={id} notes={notes} />}
        {tab === "chat" && <SessionsTab projectId={id} sessions={sessions} />}
        {tab === "miembros" && <MembersTab projectId={id} members={members} myRole={project?.role} onChanged={() => void load()} />}
      </div>
    </MainLayout>
  );
}

function NotesTab({ projectId, notes }: { projectId: string; notes: NoteSummary[] | null }) {
  const [title, setTitle] = useState("");
  const [creating, setCreating] = useState(false);

  const create = async (e: React.FormEvent) => {
    e.preventDefault();
    setCreating(true);
    try {
      await vaultApi.createNote({ projectId, title });
      setTitle("");
    } finally {
      setCreating(false);
    }
  };

  return (
    <section className="space-y-4">
      <form onSubmit={create} className="flex gap-2">
        <Input value={title} onChange={(e) => setTitle(e.target.value)} placeholder="Nueva nota…" required maxLength={200} />
        <Button type="submit" disabled={creating || !title.trim()}>
          Crear
        </Button>
      </form>

      {notes === null ? (
        <Card>
          <CardContent className="py-8 text-center text-sm text-slate-500 dark:text-slate-400">Cargando notas…</CardContent>
        </Card>
      ) : notes.length === 0 ? (
        <Card>
          <CardContent className="py-10 text-center text-slate-500 dark:text-slate-400">
            Todavía no hay notas en este proyecto.
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-3 md:grid-cols-2">
          {notes.map((note) => (
            <Card key={note.id} className="transition-colors hover:border-indigo-400 dark:hover:border-indigo-600">
              <CardHeader className="mb-0">
                <CardTitle className="text-base">{note.title}</CardTitle>
                <CardDescription>
                  Actualizada el {formatDate(note.updatedAt)}
                  {note.backlinkCount > 0 && ` · ${note.backlinkCount} enlace(s)`}
                </CardDescription>
              </CardHeader>
              {note.tags.length > 0 && (
                <CardContent className="mt-3 flex flex-wrap gap-1">
                  {note.tags.map((tag) => (
                    <span
                      key={tag}
                      className="rounded-full bg-slate-100 px-2 py-0.5 text-xs text-slate-600 dark:bg-slate-800 dark:text-slate-300"
                    >
                      #{tag}
                    </span>
                  ))}
                </CardContent>
              )}
            </Card>
          ))}
        </div>
      )}
    </section>
  );
}

function SessionsTab({ projectId, sessions }: { projectId: string; sessions: ChatSession[] | null }) {
  const router = useRouter();

  const start = async () => {
    try {
      const session = await chatApi.createSession({ projectId, title: "Nueva conversación" });
      router.push(`/chat?session=${session.id}`);
    } catch {
      // se ignora: la vista de chat sin sesión también funciona
    }
  };

  return (
    <section className="space-y-4">
      <Button onClick={start}>Nueva conversación</Button>
      {sessions === null ? (
        <Card>
          <CardContent className="py-8 text-center text-sm text-slate-500 dark:text-slate-400">Cargando sesiones…</CardContent>
        </Card>
      ) : sessions.length === 0 ? (
        <Card>
          <CardContent className="py-10 text-center text-slate-500 dark:text-slate-400">
            Aún no hay conversaciones en este proyecto.
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-2">
          {sessions.map((session) => (
            <Link key={session.id} href={`/chat?session=${session.id}`}>
              <Card className="transition-colors hover:border-indigo-400 dark:hover:border-indigo-600">
                <CardHeader className="mb-0">
                  <CardTitle className="text-base">{session.title}</CardTitle>
                  <CardDescription>{formatDate(session.createdAt)}</CardDescription>
                </CardHeader>
              </Card>
            </Link>
          ))}
        </div>
      )}
    </section>
  );
}

const ROLES: MemberRole[] = ["OWNER", "ADMIN", "EDITOR", "VIEWER"];

function MembersTab({
  projectId,
  members,
  myRole,
  onChanged,
}: {
  projectId: string;
  members: ProjectMember[] | null;
  myRole?: MemberRole;
  onChanged: () => void;
}) {
  const [email, setEmail] = useState("");
  const [role, setRole] = useState<MemberRole>("EDITOR");
  const [error, setError] = useState<string | null>(null);
  const canManage = myRole === "OWNER" || myRole === "ADMIN";

  const add = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    try {
      await projectsApi.addMember(projectId, email, role);
      setEmail("");
      onChanged();
    } catch (err) {
      setError(err instanceof Error ? err.message : "No se pudo agregar al miembro.");
    }
  };

  const changeRole = async (userId: string, next: MemberRole) => {
    try {
      await projectsApi.updateMemberRole(projectId, userId, next);
      onChanged();
    } catch {
      setError("No se pudo cambiar el rol.");
    }
  };

  const remove = async (userId: string) => {
    try {
      await projectsApi.removeMember(projectId, userId);
      onChanged();
    } catch (err) {
      setError(err instanceof Error ? err.message : "No se pudo remover al miembro.");
    }
  };

  return (
    <section className="space-y-4">
      {canManage && (
        <form onSubmit={add} className="flex flex-wrap items-end gap-2">
          <div className="min-w-0 flex-1 space-y-1">
            <label htmlFor="memberEmail" className="text-sm font-medium text-slate-700 dark:text-slate-300">
              Correo del usuario
            </label>
            <Input
              id="memberEmail"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="colega@correo.com"
              required
            />
          </div>
          <div className="space-y-1">
            <label htmlFor="memberRole" className="text-sm font-medium text-slate-700 dark:text-slate-300">
              Rol
            </label>
            <select
              id="memberRole"
              value={role}
              onChange={(e) => setRole(e.target.value as MemberRole)}
              className="h-10 rounded-lg border border-slate-300 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-950 dark:text-slate-100"
            >
              {ROLES.map((r) => (
                <option key={r} value={r}>
                  {r}
                </option>
              ))}
            </select>
          </div>
          <Button type="submit">Agregar</Button>
        </form>
      )}

      {error && (
        <p className="rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700 dark:bg-red-950/50 dark:text-red-300">{error}</p>
      )}

      {members === null ? (
        <Card>
          <CardContent className="py-8 text-center text-sm text-slate-500 dark:text-slate-400">Cargando miembros…</CardContent>
        </Card>
      ) : members.length === 0 ? (
        <Card>
          <CardContent className="py-8 text-center text-slate-500 dark:text-slate-400">Sin miembros.</CardContent>
        </Card>
      ) : (
        <div className="space-y-2">
          {members.map((member) => (
            <Card key={member.user.id} className="flex items-center justify-between gap-3">
              <div className="min-w-0">
                <p className="truncate font-medium text-slate-900 dark:text-slate-100">{member.user.displayName}</p>
                <p className="truncate text-sm text-slate-500 dark:text-slate-400">{member.user.email ?? "Sin correo"}</p>
              </div>
              <div className="flex shrink-0 items-center gap-2">
                {canManage ? (
                  <>
                    <select
                      value={member.role}
                      onChange={(e) => void changeRole(member.user.id, e.target.value as MemberRole)}
                      className="h-9 rounded-lg border border-slate-300 bg-white px-2 text-sm dark:border-slate-700 dark:bg-slate-950 dark:text-slate-100"
                    >
                      {ROLES.map((r) => (
                        <option key={r} value={r}>
                          {r}
                        </option>
                      ))}
                    </select>
                    <Button variant="danger" size="sm" onClick={() => void remove(member.user.id)}>
                      Quitar
                    </Button>
                  </>
                ) : (
                  <span className="rounded-full bg-slate-100 px-2 py-0.5 text-xs font-medium text-slate-600 dark:bg-slate-800 dark:text-slate-300">
                    {member.role}
                  </span>
                )}
              </div>
            </Card>
          ))}
        </div>
      )}
    </section>
  );
}