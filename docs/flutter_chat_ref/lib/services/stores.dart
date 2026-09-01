import '../models/chat_message.dart';
import 'package:flutter/material.dart';

/// Plan del usuario (SPEC §10).
enum UserPlan { gratis, byok, creditos }

extension UserPlanLabel on UserPlan {
  String get label => switch (this) {
        UserPlan.gratis => 'Gratis',
        UserPlan.byok => 'BYOK',
        UserPlan.creditos => 'Créditos',
      };
}

/// Origen de una nota de la memoria (SPEC §4).
enum NoteOrigin { chat, manual, agente }

extension NoteOriginLabel on NoteOrigin {
  String get label => switch (this) {
        NoteOrigin.chat => 'Chat',
        NoteOrigin.manual => 'Manual',
        NoteOrigin.agente => 'Agente',
      };
}

/// Rol en un proyecto colaborativo (SPEC §3).
enum ProjectRole { propietario, admin, editor, visualizador }

extension ProjectRoleMeta on ProjectRole {
  String get label => switch (this) {
        ProjectRole.propietario => 'PROPIETARIO',
        ProjectRole.admin => 'ADMIN',
        ProjectRole.editor => 'EDITOR',
        ProjectRole.visualizador => 'VISUALIZADOR',
      };

  IconData get icon => switch (this) {
        ProjectRole.propietario => Icons.key_outlined,
        ProjectRole.admin => Icons.shield_outlined,
        ProjectRole.editor => Icons.edit_outlined,
        ProjectRole.visualizador => Icons.visibility_outlined,
      };
}

class ProjectMember {
  final String email;
  final ProjectRole role;
  const ProjectMember(this.email, this.role);
}

class Project {
  final String id;
  final String name;
  final String slug;
  final ProjectRole role;
  final DateTime createdAt;
  final List<ProjectMember> members;
  const Project({
    required this.id,
    required this.name,
    required this.slug,
    required this.role,
    required this.createdAt,
    required this.members,
  });
}

class MemoryNote {
  final String id;
  final String title;
  final String body;
  final List<String> tags;
  final NoteOrigin origin;
  final DateTime date;

  /// Títulos de las notas referenciadas con [[título]].
  final List<String> links;
  const MemoryNote({
    required this.id,
    required this.title,
    required this.body,
    required this.tags,
    required this.origin,
    required this.date,
    this.links = const [],
  });
}

class ApiKeyEntry {
  final String id;
  final String provider;
  final String prefix;
  final String suffix;
  const ApiKeyEntry({
    required this.id,
    required this.provider,
    required this.prefix,
    required this.suffix,
  });

  /// Formato oculto tipo sk-proj-...abcd.
  String get masked => '$prefix-...$suffix';
}

class ChatSession {
  final String id;
  final String title;
  final DateTime date;

  /// Historial completo de la conversación (SPEC §6).
  final List<ChatMessage> messages;
  IconData get icon => Icons.chat_bubble_outline;
  ChatSession({
    required this.id,
    required this.title,
    required this.date,
    this.messages = const [],
  });

  ChatSession withMessage(ChatMessage msg) => ChatSession(
      id: id, title: title, date: date, messages: [...messages, msg]);
}

class Reminder {
  final String id;
  final String text;
  final DateTime at;
  final String timezone;
  Reminder({
    required this.id,
    required this.text,
    required this.at,
    required this.timezone,
  });
}

class MiniApp {
  final String id;
  final String title;
  final IconData icon;
  final bool edited;
  const MiniApp({
    required this.id,
    required this.title,
    required this.icon,
    this.edited = false,
  });
}

/// Cuenta del usuario: plan real, saldo (créditos) y consentimiento (SPEC §10-11).
class UserStore extends ChangeNotifier {
  UserStore._();
  static final UserStore instance = UserStore._();

  UserPlan plan = UserPlan.byok;
  bool consentGiven = false;

  /// El inicio de sesión es opcional (SPEC §11): la app arranca en la página
  /// principal y el usuario entra desde su perfil cuando quiera.
  bool loggedIn = false;

  /// Datos de cuenta (mock de GET /me): el registro los actualiza.
  String name = 'Ignacio Loyola';
  String email = 'ignacio@example.com';
  double creditBalance = 18.40;
  double creditSoftCap = 25.0;
  bool creditFrozen = false;

  void setPlan(UserPlan p) {
    plan = p;
    notifyListeners();
  }

  void setLoggedIn(bool v) {
    loggedIn = v;
    notifyListeners();
  }

  void setProfile({required String name, required String email}) {
    this.name = name.trim().isEmpty ? this.name : name.trim();
    this.email = email.trim().isEmpty ? this.email : email.trim();
    notifyListeners();
  }

  void setConsentGiven(bool v) {
    consentGiven = v;
    notifyListeners();
  }
}

/// Sesiones e historial (GET /chat/sessions, SPEC §6).
class SessionStore extends ChangeNotifier {
  SessionStore._();
  static final SessionStore instance = SessionStore._();

  static final List<({String title, String id, List<ChatMessage>? messages})>
      _seed = [
    (
      title: 'Ideas para campaña de IA',
      id: 's1',
      messages: [
        ChatMessage(
            sender: Sender.user, text: '¿Qué ideas hay para la campaña de IA?'),
        ChatMessage(
            sender: Sender.ai,
            text: 'Podemos partir por tres ejes: demostraciones de producto, '
                'casos de uso por industria y contenido técnico de la API.'),
      ],
    ),
    (
      title: 'Mejores prompts para diseño',
      id: 's2',
      messages: [
        ChatMessage(
            sender: Sender.user,
            text: '¿Cuáles son los mejores prompts para diseño de identidad?'),
        ChatMessage(
            sender: Sender.ai,
            text: 'Para identidad: pide "estilo visual, paleta y tipografía '
                'para la marca X", menciona el público y entrega ejemplos de uso.'),
      ]
    ),
    (
      title: 'Resumen de documento PDF',
      id: 's3',
      messages: [
        ChatMessage(
            sender: Sender.user,
            text: 'Resume el PDF de la propuesta comercial que te envié.'),
        ChatMessage(
            sender: Sender.ai,
            text: 'La propuesta cubre alcance, cronograma en 3 fases y un '
                'presupuesto en dos tramos; incluye condiciones de pago.'),
      ]
    ),
    (
      title: 'Código para página web',
      id: 's4',
      messages: [
        ChatMessage(
            sender: Sender.user,
            text: 'Genera el HTML y CSS de una landing para mi producto.'),
        ChatMessage(
            sender: Sender.ai,
            text: 'Aquí tienes la base: sección hero, beneficios y formulario '
                'de contacto; los estilos usan variables CSS fáciles de ajustar.'),
      ]
    ),
    (
      title: 'Estrategia de contenido',
      id: 's5',
      messages: [
        ChatMessage(
            sender: Sender.user,
            text: 'Propón una estrategia de contenido para el Q3.'),
        ChatMessage(
            sender: Sender.ai,
            text:
                'Recomiendo 3 bloques: tutoriales semanales, estudios de caso '
                'y boletines; cada uno con su propio canal y métrica de éxito.'),
      ]
    ),
  ];

  final List<ChatSession> sessions = [
    for (var i = 0; i < _seed.length; i++)
      ChatSession(
        id: _seed[i].id,
        title: _seed[i].title,
        date: DateTime.now().subtract(Duration(hours: i * 5 + 2)),
        messages: _seed[i].messages ?? const [],
      ),
  ];

  /// Sesión activa del chat actual (null = nueva conversación).
  String? activeSessionId;

  /// Crea la sesión con el primer mensaje y la deja activa (SPEC §6).
  String beginSession(String title) {
    final id = 's${sessions.length + 2}';
    sessions.insert(0, ChatSession(id: id, title: title, date: DateTime.now()));
    activeSessionId = id;
    notifyListeners();
    return id;
  }

  ChatSession? byId(String? id) =>
      id == null ? null : sessions.where((s) => s.id == id).firstOrNull;

  /// Anexa un mensaje a la sesión activa (historial completo).
  void appendActive(ChatMessage msg) {
    final id = activeSessionId;
    final i = sessions.indexWhere((s) => s.id == id);
    if (i < 0) return;
    sessions[i] = sessions[i].withMessage(msg);
    notifyListeners();
  }

  void resetActive() {
    activeSessionId = null;
  }
}

/// Proyectos colaborativos (SPEC §3).
class ProjectsStore extends ChangeNotifier {
  ProjectsStore._();
  static final ProjectsStore instance = ProjectsStore._();

  final List<Project> projects = [
    Project(
      id: 'p1',
      name: 'Lanzamiento soybluia',
      slug: 'lanzamiento-soybluia',
      role: ProjectRole.propietario,
      createdAt: DateTime.now().subtract(const Duration(days: 42)),
      members: const [
        ProjectMember('ignacio@example.com', ProjectRole.propietario),
        ProjectMember('valery@example.com', ProjectRole.editor),
      ],
    ),
    Project(
      id: 'p2',
      name: 'App móvil Beta',
      slug: 'app-movil-beta',
      role: ProjectRole.editor,
      createdAt: DateTime.now().subtract(const Duration(days: 17)),
      members: const [
        ProjectMember('ignacio@example.com', ProjectRole.editor),
        ProjectMember('daniel@example.com', ProjectRole.admin),
      ],
    ),
  ];

  Project? byId(String? id) =>
      id == null ? null : projects.where((p) => p.id == id).firstOrNull;

  void create(String name) {
    final slug = name
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    projects.insert(
      0,
      Project(
        id: 'p${projects.length + 1}',
        name: name,
        slug: slug,
        role: ProjectRole.propietario,
        createdAt: DateTime.now(),
        members: const [
          ProjectMember('ignacio@example.com', ProjectRole.propietario)
        ],
      ),
    );
    notifyListeners();
  }

  void rename(String id, String name) {
    final i = projects.indexWhere((p) => p.id == id);
    if (i < 0) return;
    projects[i] = Project(
      id: projects[i].id,
      name: name,
      slug: projects[i].slug,
      role: projects[i].role,
      createdAt: projects[i].createdAt,
      members: projects[i].members,
    );
    notifyListeners();
  }

  void invite(String id, String email, ProjectRole role) {
    final i = projects.indexWhere((p) => p.id == id);
    if (i < 0 || projects[i].members.any((m) => m.email == email)) return;
    final p = projects[i];
    projects[i] = Project(
      id: p.id,
      name: p.name,
      slug: p.slug,
      role: p.role,
      createdAt: p.createdAt,
      members: [...p.members, ProjectMember(email, role)],
    );
    notifyListeners();
  }

  void removeMember(String id, String email) {
    final i = projects.indexWhere((p) => p.id == id);
    if (i < 0) return;
    final p = projects[i];
    projects[i] = Project(
      id: p.id,
      name: p.name,
      slug: p.slug,
      role: p.role,
      createdAt: p.createdAt,
      members: p.members.where((m) => m.email != email).toList(),
    );
    notifyListeners();
  }

  void remove(String id) {
    projects.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}

/// Memoria / Vault: notas con etiquetas, enlaces y referencias (SPEC §4).
class NotesStore extends ChangeNotifier {
  NotesStore._();
  static final NotesStore instance = NotesStore._();

  final List<MemoryNote> notes = [
    MemoryNote(
      id: 'n1',
      title: 'Objetivos Q3',
      body: '**Objetivos del trimestre:**\n\n1. Lanzar la app móvil.\n2. '
          'Alcanzar 10k usuarios.\n3. Publicar la extensión de Chrome.',
      tags: ['plan', 'q3'],
      origin: NoteOrigin.chat,
      date: DateTime.now().subtract(const Duration(days: 3)),
      links: ['Estrategia de contenido'],
    ),
    MemoryNote(
      id: 'n2',
      title: 'Estrategia de contenido',
      body: '**Plan editorial:**\n\n- 2 publicaciones por semana.\n- Guías '
          'técnicas y casos de uso.\n- Newsletter quincenal.',
      tags: ['marketing'],
      origin: NoteOrigin.manual,
      date: DateTime.now().subtract(const Duration(days: 8)),
      links: ['Objetivos Q3'],
    ),
    MemoryNote(
      id: 'n3',
      title: 'Architecture notes',
      body: '**Decisiones del motor de chat:**\n\n- Streaming por SSE.\n- '
          'Mapeo de tier auto en el servidor.\n- Cifrado AES-256-GCM para claves.',
      tags: ['dev', 'tech'],
      origin: NoteOrigin.agente,
      date: DateTime.now().subtract(const Duration(days: 15)),
      links: [],
    ),
    MemoryNote(
      id: 'n4',
      title: 'Tono de la marca',
      body: '**Voz de la marca soybluia:**\n\nClara, directa y cercana. '
          'Usar "tú" y frases cortas.',
      tags: ['marca'],
      origin: NoteOrigin.manual,
      date: DateTime.now().subtract(const Duration(days: 21)),
      links: ['Estrategia de contenido'],
    ),
  ];

  MemoryNote? byTitle(String title) =>
      notes.where((n) => n.title == title).firstOrNull;

  /// Notas que apuntan a [title] (referencias inversas).
  List<MemoryNote> backlinks(String title) =>
      notes.where((n) => n.links.contains(title)).toList();

  void create({
    required String title,
    required String body,
    required List<String> tags,
    NoteOrigin origin = NoteOrigin.manual,
  }) {
    notes.insert(
      0,
      MemoryNote(
        id: 'n${notes.length + 1}',
        title: title,
        body: body,
        tags: tags,
        origin: origin,
        date: DateTime.now(),
        links: _extractLinks(body),
      ),
    );
    notifyListeners();
  }

  void update(MemoryNote note) {
    final i = notes.indexWhere((n) => n.id == note.id);
    if (i < 0) return;
    notes[i] = MemoryNote(
      id: note.id,
      title: note.title,
      body: note.body,
      tags: note.tags,
      origin: note.origin,
      date: DateTime.now(),
      links: _extractLinks(note.body),
    );
    notifyListeners();
  }

  void remove(String id) {
    notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  static List<String> _extractLinks(String body) {
    final out = <String>[];
    for (final m in RegExp(r'\[\[([^\]]+)\]\]').allMatches(body)) {
      final t = m.group(1)!.trim();
      if (!out.contains(t)) out.add(t);
    }
    return out;
  }
}

/// Claves de proveedor del usuario (GET /user/api-keys, SPEC §10).
class ApiKeysStore extends ChangeNotifier {
  ApiKeysStore._();
  static final ApiKeysStore instance = ApiKeysStore._();

  final List<ApiKeyEntry> keys = [
    const ApiKeyEntry(
        id: 'k1', provider: 'OpenAI', prefix: 'sk-proj', suffix: '8a2b'),
    const ApiKeyEntry(
        id: 'k2', provider: 'Anthropic', prefix: 'sk-ant', suffix: 'f93d'),
  ];

  void add(String provider, String prefix, String suffixValue) {
    keys.add(ApiKeyEntry(
        id: 'k${keys.length + 1}',
        provider: provider,
        prefix: prefix,
        suffix: suffixValue));
    notifyListeners();
  }

  void remove(String id) {
    keys.removeWhere((k) => k.id == id);
    notifyListeners();
  }
}

/// Agenda y recordatorios (SPEC §9).
class RemindersStore extends ChangeNotifier {
  RemindersStore._();
  static final RemindersStore instance = RemindersStore._();

  static final _seed = [
    Reminder(
      id: 'r1',
      text: 'Revisar el borrador del post',
      at: DateTime(2026, 8, 13, 18, 30),
      timezone: 'America/Argentina/Buenos_Aires',
    ),
    Reminder(
      id: 'r2',
      text: 'Llamada con el equipo de diseño',
      at: DateTime(2026, 8, 14, 10, 0),
      timezone: 'America/Argentina/Buenos_Aires',
    ),
  ];

  final List<Reminder> reminders = [..._seed];

  int get pendingCount => reminders.length;

  void add(String text, DateTime at, String timezone) {
    reminders.insert(
        0,
        Reminder(
            id: 'r${reminders.length + 3}',
            text: text,
            at: at,
            timezone: timezone));
    notifyListeners();
  }

  void update(String id, String text, DateTime at, String timezone) {
    final i = reminders.indexWhere((r) => r.id == id);
    if (i < 0) return;
    reminders[i] = Reminder(id: id, text: text, at: at, timezone: timezone);
    notifyListeners();
  }

  void remove(String id) {
    reminders.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}

/// Mini-aplicaciones guardadas (SPEC §7).
class MiniAppsStore extends ChangeNotifier {
  MiniAppsStore._();
  static final MiniAppsStore instance = MiniAppsStore._();

  final List<MiniApp> apps = [
    const MiniApp(
        id: 'a1', title: 'Calendario editorial', icon: Icons.calendar_month),
    const MiniApp(
        id: 'a2', title: 'Lista de verificación Q3', icon: Icons.checklist),
  ];

  void add(String title, IconData icon) {
    apps.add(MiniApp(id: 'a${apps.length + 1}', title: title, icon: icon));
    notifyListeners();
  }

  MiniApp? byId(String id) {
    for (final a in apps) {
      if (a.id == id) return a;
    }
    return null;
  }

  void rename(String id, String title) {
    final i = apps.indexWhere((a) => a.id == id);
    if (i < 0) return;
    apps[i] =
        MiniApp(id: apps[i].id, title: title, icon: apps[i].icon, edited: true);
    notifyListeners();
  }
}
