import 'dart:math';

import 'package:flutter/material.dart';
import '../services/stores.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/shared/app_card.dart';
import '../widgets/shared/sidebar_shell.dart';
import 'agenda_screen.dart';
import 'chat_screen.dart';
import 'mini_apps_screen.dart';
import 'profile_screen.dart';
import 'projects_screen.dart';
import 'settings_screen.dart';

/// Colores de nodos por etiqueta (SPEC §4: colores por etiqueta + leyenda).
const kTagColors = {
  'plan': Color(0xFF3D6BFF),
  'marketing': Color(0xFFFB923C),
  'dev': Color(0xFF34D399),
  'tech': Color(0xFF34D399),
  'marca': Color(0xFFC084FC),
  'q3': Color(0xFFF87171),
};

Color tagColor(List<String> tags) {
  for (final t in tags) {
    if (kTagColors.containsKey(t)) return kTagColors[t]!;
  }
  return BrandColors.gris;
}

/// Pantalla Memoria / Vault (SPEC §4): búsqueda híbrida, lista de notas,
/// creación y acceso al grafo de conocimiento.
class MemoryScreen extends StatelessWidget {
  const MemoryScreen({super.key});

  void _switch(BuildContext context, AppSidebarItem item) {
    switch (item) {
      case AppSidebarItem.newChat:
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const ChatScreen()),
            (r) => false);
      case AppSidebarItem.memory:
        break;
      case AppSidebarItem.projects:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const ProjectsScreen()));
      case AppSidebarItem.agenda:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const AgendaScreen()));
      case AppSidebarItem.miniApps:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const MiniAppsScreen()));
      case AppSidebarItem.settings:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
      case AppSidebarItem.profile:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SidebarShell(
      selected: AppSidebarItem.memory,
      onSelect: (item) => _switch(context, item),
      onOpenSession: (s) => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => ChatScreen(sessionId: s.id))),
      child: ListenableBuilder(
        listenable: NotesStore.instance,
        builder: (context, _) => _MemoryBody(),
      ),
    );
  }
}

class _MemoryBody extends StatefulWidget {
  @override
  State<_MemoryBody> createState() => _MemoryBodyState();
}

class _MemoryBodyState extends State<_MemoryBody> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<MemoryNote> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return NotesStore.instance.notes;
    return NotesStore.instance.notes
        .where((n) =>
            n.title.toLowerCase().contains(q) ||
            n.tags.any((t) => t.toLowerCase().contains(q)))
        .toList();
  }

  void _createNote(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _NoteEditDialog(
        onSave: (title, body, tags) {
          NotesStore.instance.create(title: title, body: body, tags: tags);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    final notes = _filtered;
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Expanded(
                        child: PageHeader(
                          title: 'Memoria',
                          subtitle:
                              'Tu segundo cerebro: notas, enlaces y grafo de conocimiento.',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const KnowledgeGraphScreen()),
                          ),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: c.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color:
                                      c.outlineVariant.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.hub_outlined,
                                    size: 16, color: BrandColors.cobalt),
                                const SizedBox(width: 6),
                                Text('Grafo',
                                    style: kLabelMd.copyWith(
                                        fontSize: 13, color: c.onSurface)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _search,
                    onChanged: (v) => setState(() => _query = v),
                    style: kBodyMd.copyWith(color: c.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Buscar por título o etiqueta',
                      hintStyle: TextStyle(
                          color: c.onSurfaceVariant.withValues(alpha: 0.6)),
                      prefixIcon: const Icon(Icons.search,
                          size: 20, color: BrandColors.gris),
                      filled: true,
                      fillColor: c.surfaceContainer,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: c.outlineVariant.withValues(alpha: 0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: c.outlineVariant.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: BrandColors.cobalt, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (notes.isEmpty)
                    _NotesEmpty(
                        query: _query, onCreate: () => _createNote(context))
                  else
                    for (final note in notes) ...[
                      _NoteTile(
                        note: note,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => NoteViewScreen(noteId: note.id)),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 24,
          bottom: 24,
          child: FloatingActionButton(
            onPressed: () => _createNote(context),
            backgroundColor: BrandColors.cobalt,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _NotesEmpty extends StatelessWidget {
  final String query;
  final VoidCallback onCreate;

  const _NotesEmpty({required this.query, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.menu_book_outlined,
              size: 40, color: BrandColors.gris),
          const SizedBox(height: 12),
          Text(
              query.isEmpty
                  ? 'Sin notas todavía'
                  : 'Sin resultados para "$query"',
              style: kBodyMd.copyWith(color: c.onSurfaceVariant)),
          const SizedBox(height: 16),
          InkWell(
            onTap: onCreate,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: BrandColors.cobalt,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Nueva nota',
                  style: kLabelMd.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteTile extends StatelessWidget {
  final MemoryNote note;
  final VoidCallback onTap;

  const _NoteTile({required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: c.surfaceContainerHigh,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.outlineVariant.withValues(alpha: 0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tagColor(note.tags).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.note_alt_outlined,
                    size: 18, color: tagColor(note.tags)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(note.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: kBodyMd.copyWith(
                                  color: c.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15)),
                        ),
                        Text(
                            '${note.origin.label} · '
                            '${note.date.day}/${note.date.month}',
                            style: kLabelMd.copyWith(
                                fontSize: 11, color: BrandColors.gris)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final t in note.tags)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  tagColor(note.tags).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text('#$t',
                                style: kLabelMd.copyWith(
                                    fontSize: 11, color: tagColor(note.tags))),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vista de nota: cuerpo markdown-lite, etiquetas, referencias inversas y
/// acciones Editar / Eliminar / Nueva nota (SPEC §4).
class NoteViewScreen extends StatelessWidget {
  final String noteId;

  const NoteViewScreen({super.key, required this.noteId});

  void _openNote(BuildContext context, String title) {
    final n = NotesStore.instance.byTitle(title);
    if (n == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => NoteViewScreen(noteId: n.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return ListenableBuilder(
      listenable: NotesStore.instance,
      builder: (context, _) {
        final note =
            NotesStore.instance.notes.where((n) => n.id == noteId).firstOrNull;
        if (note == null) {
          return Scaffold(
            backgroundColor: c.background,
            body: const SafeArea(
                child: Center(child: Text('Nota no encontrada'))),
          );
        }
        final backlinks = NotesStore.instance.backlinks(note.title);
        return Scaffold(
          backgroundColor: c.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(note.title,
                                style: kHeadlineLg.copyWith(
                                    color: c.onSurface,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: c.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(note.origin.label,
                                style: kLabelMd.copyWith(
                                    fontSize: 11, color: c.onSurfaceVariant)),
                          ),
                          const SizedBox(width: 8),
                          for (final t in note.tags)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: tagColor(note.tags)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text('#$t',
                                    style: kLabelMd.copyWith(
                                        fontSize: 11,
                                        color: tagColor(note.tags))),
                              ),
                            ),
                          const Spacer(),
                          Text(
                              '${note.date.day}/${note.date.month}/${note.date.year}',
                              style: kLabelMd.copyWith(
                                  fontSize: 11, color: BrandColors.gris)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: c.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: c.outlineVariant.withValues(alpha: 0.25)),
                        ),
                        child: MarkdownText(text: note.body),
                      ),
                      const SizedBox(height: 24),
                      Text('Referenciada por...',
                          style: kLabelMd.copyWith(
                              color: c.onSurfaceVariant, letterSpacing: 0.4)),
                      const SizedBox(height: 8),
                      if (backlinks.isEmpty)
                        Text('Ninguna nota enlaza a esta.',
                            style: kBodyMd.copyWith(color: BrandColors.gris))
                      else
                        for (final b in backlinks)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _openNote(context, b.title),
                                borderRadius: BorderRadius.circular(8),
                                hoverColor: c.surfaceContainerHigh,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: c.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: c.outlineVariant
                                            .withValues(alpha: 0.25)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.subdirectory_arrow_left,
                                          size: 14, color: BrandColors.cobalt),
                                      const SizedBox(width: 8),
                                      Text(b.title,
                                          style: kBodyMd.copyWith(
                                              color: c.onSurface,
                                              fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          _NoteAction(
                              icon: Icons.edit_outlined,
                              label: 'Editar',
                              onTap: () => _edit(context, note)),
                          const SizedBox(width: 8),
                          _NoteAction(
                              icon: Icons.add,
                              label: 'Nueva nota',
                              onTap: () => _create(context),
                              primary: true),
                          const Spacer(),
                          _NoteAction(
                              icon: Icons.delete_outline,
                              label: 'Eliminar',
                              danger: true,
                              onTap: () => _delete(context, note)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _edit(BuildContext context, MemoryNote note) {
    showDialog<void>(
      context: context,
      builder: (_) => _NoteEditDialog(
        initialTitle: note.title,
        initialBody: note.body,
        initialTags: note.tags.join(', '),
        submitLabel: 'Guardar',
        onSave: (title, body, tags) {
          NotesStore.instance.update(MemoryNote(
            id: note.id,
            title: title,
            body: body,
            tags: tags,
            origin: note.origin,
            date: note.date,
            links: note.links,
          ));
        },
      ),
    );
  }

  void _create(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _NoteEditDialog(
        onSave: (title, body, tags) {
          NotesStore.instance.create(title: title, body: body, tags: tags);
        },
      ),
    );
  }

  void _delete(BuildContext context, MemoryNote note) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: ThemeScope.of(context).surfaceContainerLow,
        title: Text('Eliminar nota',
            style:
                kHeadlineMd.copyWith(color: ThemeScope.of(context).onSurface)),
        content: Text('¿Eliminar "${note.title}" de la memoria?',
            style: kBodyMd.copyWith(
                color: ThemeScope.of(context).onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              NotesStore.instance.remove(note.id);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Eliminar',
                style: TextStyle(color: Color(0xFFBA1A1A))),
          ),
        ],
      ),
    );
  }
}

class _NoteAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;
  final bool danger;

  const _NoteAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    final color = danger
        ? const Color(0xFFBA1A1A)
        : primary
            ? BrandColors.cobalt
            : c.onSurfaceVariant;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: c.surfaceContainerHigh,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Text(label, style: kLabelMd.copyWith(fontSize: 12, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Diálogo de crear/editar nota: título, cuerpo y etiquetas separadas por coma.
class _NoteEditDialog extends StatefulWidget {
  final String? initialTitle;
  final String? initialBody;
  final String? initialTags;
  final String submitLabel;
  final void Function(String title, String body, List<String> tags) onSave;

  const _NoteEditDialog({
    this.initialTitle,
    this.initialBody,
    this.initialTags,
    this.submitLabel = 'Crear',
    required this.onSave,
  });

  @override
  State<_NoteEditDialog> createState() => _NoteEditDialogState();
}

class _NoteEditDialogState extends State<_NoteEditDialog> {
  late final TextEditingController _title =
      TextEditingController(text: widget.initialTitle ?? '');
  late final TextEditingController _body =
      TextEditingController(text: widget.initialBody ?? '');
  late final TextEditingController _tags =
      TextEditingController(text: widget.initialTags ?? '');
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _tags.dispose();
    super.dispose();
  }

  InputDecoration _dec(AppPalette c, String label) => InputDecoration(
        labelText: label,
        labelStyle: kLabelMd.copyWith(color: c.onSurfaceVariant),
        filled: true,
        fillColor: c.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: c.outlineVariant),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return AlertDialog(
      backgroundColor: c.surfaceContainerLow,
      title: Text(widget.initialTitle == null ? 'Nueva nota' : 'Editar nota',
          style: kHeadlineMd.copyWith(color: c.onSurface)),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              autofocus: true,
              style: kBodyMd.copyWith(color: c.onSurface),
              decoration: _dec(c, 'Título'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _body,
              minLines: 4,
              maxLines: 8,
              style: kBodyMd.copyWith(color: c.onSurface),
              decoration: _dec(c, 'Cuerpo (markdown, [[enlaces]])'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tags,
              style: kBodyMd.copyWith(color: c.onSurface),
              decoration: _dec(c, 'Etiquetas (separadas por coma)'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.error_outline,
                      size: 14, color: Color(0xFFFF6B5E)),
                  const SizedBox(width: 6),
                  Text(_error!,
                      style: kLabelMd.copyWith(
                          fontSize: 12, color: const Color(0xFFFF6B5E))),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            if (_title.text.trim().isEmpty) {
              setState(() => _error = 'El título es obligatorio.');
              return;
            }
            Navigator.of(context).pop();
            widget.onSave(
              _title.text.trim(),
              _body.text.trim(),
              _tags.text
                  .split(RegExp(r'[,\s]+'))
                  .map((t) => t.trim().toLowerCase())
                  .where((t) => t.isNotEmpty)
                  .toList(),
            );
          },
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }
}

/// Texto markdown-lite: resalta **negritas** y deja los enlaces [[...]].
class MarkdownText extends StatelessWidget {
  final String text;

  const MarkdownText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*|\[\[([^\]]+)\]\]');
    var last = 0;
    for (final m in regex.allMatches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start)));
      }
      if (m.group(1) != null) {
        spans.add(TextSpan(
            text: m.group(1),
            style: const TextStyle(fontWeight: FontWeight.w600)));
      } else {
        spans.add(TextSpan(
            text: '[[${m.group(2)}]]',
            style: const TextStyle(color: BrandColors.cobalt)));
      }
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return Text.rich(
      TextSpan(children: spans),
      style: TextStyle(fontSize: 15, height: 1.7, color: c.onSurface),
    );
  }
}

/// Grafo de conocimiento (SPEC §4): distribución por fuerzas simplificada,
/// nodos arrastrables, vecinos resaltados al pasar el cursor, clic enfoca la
/// nota, zoom/paneo, re-centrar, ocultar sin enlaces y profundidad 1-3.
class KnowledgeGraphScreen extends StatefulWidget {
  const KnowledgeGraphScreen({super.key});

  @override
  State<KnowledgeGraphScreen> createState() => _KnowledgeGraphScreenState();
}

class _GraphNode {
  final String id;
  final String title;
  final Color color;
  Offset pos;
  Offset target;

  _GraphNode({
    required this.id,
    required this.title,
    required this.color,
    required this.pos,
    required this.target,
  });
}

class _KnowledgeGraphScreenState extends State<KnowledgeGraphScreen> {
  late final Map<String, _GraphNode> _nodes = _seed();
  final List<(String, String)> _edges = [];
  String? _focusedId;
  String? _hoveredId;
  bool _hideUnlinked = false;
  double _depth = 2;
  double _zoom = 1.0;

  Offset _pan = Offset.zero;

  /// Punto focal del gesto anterior, para acumular paneo en [onScaleUpdate].
  Offset? _lastFocal;
  Map<String, _GraphNode> _seed() {
    final notes = NotesStore.instance.notes;
    final n = notes.length;
    final nodes = <String, _GraphNode>{};
    for (var i = 0; i < n; i++) {
      final note = notes[i];
      final angle = 2 * pi * i / n;
      final r = 140.0 + (i % 3) * 40;
      final pos = Offset(cos(angle) * r, sin(angle) * r);
      nodes[note.id] = _GraphNode(
        id: note.id,
        title: note.title,
        color: tagColor(note.tags),
        pos: pos,
        target: pos,
      );
    }
    return nodes;
  }

  List<(String, String)> get edges {
    if (_edges.isNotEmpty) return _edges;
    final notes = NotesStore.instance.notes;
    for (final a in notes) {
      for (final link in a.links) {
        final b = NotesStore.instance.byTitle(link);
        if (b != null && a.id != b.id) {
          _edges.add((a.id, b.id));
        }
      }
    }
    return _edges;
  }

  Set<String> _neighbors(String id) {
    final set = <String>{};
    for (final (a, b) in edges) {
      if (a == id) set.add(b);
      if (b == id) set.add(a);
    }
    return set;
  }

  bool _visible(String id) {
    if (_hideUnlinked && _neighbors(id).isEmpty) return false;
    if (_focusedId == null) return true;
    return _hopDistance(id, _focusedId!, 0) <= _depth.floor();
  }

  int _hopDistance(String id, String from, int depth) {
    if (id == from) return 0;
    if (depth > 3) return 999;
    for (final nb in _neighbors(from)) {
      final d = _hopDistance(id, nb, depth + 1);
      if (d < 999) return d;
    }
    return 999;
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final focused = _focusedId == null
                ? null
                : NotesStore.instance.notes
                    .where((n) => n.id == _focusedId)
                    .firstOrNull;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _GraphHeader(
                        onBack: () => Navigator.of(context).maybePop(),
                        onRecenter: () => _recenter(constraints),
                        hideUnlinked: _hideUnlinked,
                        onHideUnlinked: (v) =>
                            setState(() => _hideUnlinked = v),
                        depth: _depth,
                        onDepth: (v) => setState(() => _depth = v),
                      ),
                      Expanded(
                        child: ClipRect(
                          child: GestureDetector(
                            onScaleStart: (d) => _lastFocal = d.localFocalPoint,
                            onScaleUpdate: (d) {
                              setState(() {
                                final prev = _lastFocal ?? d.localFocalPoint;
                                _lastFocal = d.localFocalPoint;
                                final next = _pan + d.localFocalPoint - prev;
                                _pan = Offset(
                                  next.dx.clamp(-2400.0, 2400.0),
                                  next.dy.clamp(-2400.0, 2400.0),
                                );
                                _zoom = (_zoom * d.scale).clamp(0.5, 2.0);
                              });
                            },
                            onScaleEnd: (_) => _lastFocal = null,
                            child: Stack(
                              children: [
                                _GraphCanvas(
                                  nodes: _nodes,
                                  edges: edges,
                                  visibleIds:
                                      _nodes.keys.where(_visible).toSet(),
                                  focusedId: _focusedId,
                                  hoveredId: _hoveredId,
                                  neighbors: _focusedId == null
                                      ? null
                                      : _neighbors(_focusedId!),
                                  zoom: _zoom,
                                  pan: _pan,
                                  onHover: (id) =>
                                      setState(() => _hoveredId = id),
                                  onTap: (id) =>
                                      setState(() => _focusedId = id),
                                  onDrag: (id, delta) => setState(() {
                                    _nodes[id]!.pos += delta;
                                  }),
                                ),
                                Positioned(
                                  left: 12,
                                  bottom: 12,
                                  child: _Legend(
                                      visibleIds:
                                          _nodes.keys.where(_visible).toSet()),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (wide && focused != null)
                  SizedBox(
                    width: 300,
                    child: _FocusPanel(note: focused),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _recenter(BoxConstraints constraints) {
    setState(() {
      _pan = Offset.zero;
      _zoom = 1.0;
      _focusedId = null;
      _hoveredId = null;
    });
  }
}

class _GraphHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onRecenter;
  final bool hideUnlinked;
  final ValueChanged<bool> onHideUnlinked;
  final double depth;
  final ValueChanged<double> onDepth;

  const _GraphHeader({
    required this.onBack,
    required this.onRecenter,
    required this.hideUnlinked,
    required this.onHideUnlinked,
    required this.depth,
    required this.onDepth,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
          ),
          const SizedBox(width: 4),
          Text('Grafo de conocimiento',
              style: kHeadlineMd.copyWith(
                  color: c.onSurface, fontWeight: FontWeight.w600)),
          const Spacer(),
          if (MediaQuery.of(context).size.width >= 560) ...[
            Text('Profundidad',
                style:
                    kLabelMd.copyWith(fontSize: 12, color: c.onSurfaceVariant)),
            SizedBox(
              width: 110,
              child: Slider(
                value: depth,
                min: 1,
                max: 3,
                divisions: 2,
                label: '${depth.round()} salto${depth.round() > 1 ? 's' : ''}',
                onChanged: onDepth,
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                Checkbox(
                  value: hideUnlinked,
                  onChanged: (v) => onHideUnlinked(v ?? false),
                  activeColor: BrandColors.cobalt,
                ),
                Text('Ocultar sin enlaces',
                    style: kLabelMd.copyWith(
                        fontSize: 12, color: c.onSurfaceVariant)),
              ],
            ),
          ],
          IconButton(
            icon: const Icon(Icons.center_focus_strong,
                color: BrandColors.cobalt),
            onPressed: onRecenter,
            tooltip: 'Re-centrar',
          ),
        ],
      ),
    );
  }
}

class _GraphCanvas extends StatelessWidget {
  final Map<String, _GraphNode> nodes;
  final List<(String, String)> edges;
  final Set<String> visibleIds;
  final String? focusedId;
  final String? hoveredId;
  final Set<String>? neighbors;
  final double zoom;
  final Offset pan;
  final ValueChanged<String?> onHover;
  final ValueChanged<String> onTap;
  final void Function(String id, Offset delta) onDrag;

  const _GraphCanvas({
    required this.nodes,
    required this.edges,
    required this.visibleIds,
    required this.focusedId,
    required this.hoveredId,
    required this.neighbors,
    required this.zoom,
    required this.pan,
    required this.onHover,
    required this.onTap,
    required this.onDrag,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final center =
            Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
        final scale = zoom;
        Offset toScreen(Offset p) => (center + p * scale + pan);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _EdgesPainter(
                nodes: nodes,
                edges: edges,
                visibleIds: visibleIds,
                focusedId: focusedId,
                neighbors: neighbors,
                toScreen: toScreen,
                color: c.outlineVariant,
              ),
            ),
            for (final node in nodes.values)
              if (visibleIds.contains(node.id))
                Positioned(
                  left: toScreen(node.pos).dx - 16,
                  top: toScreen(node.pos).dy - 16,
                  child: GestureDetector(
                    onTap: () => onTap(node.id),
                    onPanUpdate: (d) => onDrag(node.id, d.delta / scale),
                    child: MouseRegion(
                      onEnter: (_) => onHover(node.id),
                      onExit: (_) => onHover(null),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: node.color,
                          shape: BoxShape.circle,
                          border: focusedId == node.id
                              ? Border.all(color: Colors.white, width: 2.5)
                              : hoveredId == node.id ||
                                      (neighbors != null &&
                                          neighbors!.contains(node.id))
                                  ? Border.all(color: Colors.white, width: 1.5)
                                  : null,
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black38,
                                blurRadius: 8,
                                offset: Offset(0, 2)),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          node.title.isEmpty
                              ? '?'
                              : node.title[0].toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}

class _EdgesPainter extends CustomPainter {
  final Map<String, _GraphNode> nodes;
  final List<(String, String)> edges;
  final Set<String> visibleIds;
  final String? focusedId;
  final Set<String>? neighbors;
  final Offset Function(Offset) toScreen;
  final Color color;

  _EdgesPainter({
    required this.nodes,
    required this.edges,
    required this.visibleIds,
    required this.focusedId,
    required this.neighbors,
    required this.toScreen,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final activeNeighbors = neighbors ?? <String>{};
    for (final (a, b) in edges) {
      if (!visibleIds.contains(a) || !visibleIds.contains(b)) continue;
      final na = nodes[a]!;
      final nb = nodes[b]!;
      final highlighted =
          (focusedId == na.id && activeNeighbors.contains(nb.id)) ||
              (focusedId == nb.id && activeNeighbors.contains(na.id));
      final paint = Paint()
        ..color =
            highlighted ? BrandColors.azulClaro : color.withValues(alpha: 0.35)
        ..strokeWidth = highlighted ? 2.2 : 1.2;
      canvas.drawLine(toScreen(na.pos), toScreen(nb.pos), paint);
    }
  }

  @override
  bool shouldRepaint(_EdgesPainter old) =>
      old.focusedId != focusedId ||
      old.neighbors != neighbors ||
      old.color != color ||
      old.visibleIds != visibleIds;
}

class _Legend extends StatelessWidget {
  final Set<String> visibleIds;

  const _Legend({required this.visibleIds});

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    final tags = <String, Color>{};
    for (final id in visibleIds) {
      final note =
          NotesStore.instance.notes.where((n) => n.id == id).firstOrNull;
      if (note == null) continue;
      for (final t in note.tags) {
        tags[t] = tagColor(note.tags);
      }
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: c.surfaceContainerLow.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final entry in tags.entries.take(5))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: entry.value, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(entry.key,
                      style: kLabelMd.copyWith(
                          fontSize: 11, color: c.onSurfaceVariant)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FocusPanel extends StatelessWidget {
  final MemoryNote note;

  const _FocusPanel({required this.note});

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceContainerLow,
        border: Border(
            left: BorderSide(color: c.outlineVariant.withValues(alpha: 0.3))),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nota enfocada',
              style: kLabelMd.copyWith(fontSize: 11, color: BrandColors.gris)),
          const SizedBox(height: 8),
          Text(note.title,
              style: kHeadlineMd.copyWith(
                  color: c.onSurface, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final t in note.tags)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: tagColor(note.tags).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('#$t',
                      style: kLabelMd.copyWith(
                          fontSize: 11, color: tagColor(note.tags))),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: MarkdownText(text: note.body),
            ),
          ),
        ],
      ),
    );
  }
}
