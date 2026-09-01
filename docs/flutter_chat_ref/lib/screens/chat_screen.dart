import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/chat_message.dart';
import '../services/stores.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/ui_state_controller.dart';
import '../widgets/ai_bubble.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/bottom_input_area.dart';
import '../widgets/landing_input_card.dart';
import '../widgets/model_selector.dart';
import '../widgets/shared/error_banner.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/user_bubble.dart';
import 'agenda_screen.dart';
import 'memory_screen.dart';
import 'mini_apps_screen.dart';
import 'profile_screen.dart';
import 'projects_screen.dart';
import 'settings_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.sessionId});

  /// Id de sesión para abrir su historial completo (SPEC §6); null = nueva.
  final String? sessionId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Random _random = Random();

  // SPEC §2: la aplicación inicia en Auto, no en Blu Light.
  String _selectedModel = kAutoModel;
  String _agent = kNoAgent;
  Project? _project;
  bool _sessionCreated = false;

  final List<ChatMessage> _messages = [];
  bool _isStreaming = false;
  Timer? _streamTimer;
  int _streamIndex = -1;

  @override
  void initState() {
    super.initState();
    if (widget.sessionId != null) {
      final session = SessionStore.instance.byId(widget.sessionId);
      if (session != null) {
        _messages.addAll(session.messages);
        _sessionCreated = true;
        SessionStore.instance.activeSessionId = session.id;
        _scrollToBottom();
      }
    }
  }

  @override
  void dispose() {
    _streamTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  /// Respuesta simulada dividida en palabras para el flujo por fragmentos.
  List<String> _buildResponse(String text) {
    final agentNote = _agent == kNoAgent ? '' : ' con el agente $_agent';
    final projectNote = _project == null ? '' : ' (proyecto ${_project!.name})';
    return ('Entendido. Ya puse a trabajar a soybluia en "$text"'
            '$agentNote$projectNote. Esto es lo que haríamos: '
            'primero relevar el contexto, luego proponer un plan '
            'y finalmente iterar sobre el resultado junto a ti. '
            '¿Quieres que continúe o ajustamos el enfoque?')
        .split(' ');
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || _isStreaming) return;
    HapticFeedback.lightImpact();
    if (!_sessionCreated) {
      _sessionCreated = true;
      // SPEC §6: el primer mensaje crea la sesión con su título.
      final session = SessionStore.instance.byId(widget.sessionId);
      if (session == null) {
        SessionStore.instance.beginSession(text);
      } else {
        SessionStore.instance.activeSessionId = session.id;
      }
    }
    setState(() {
      _messages.add(ChatMessage(sender: Sender.user, text: text));
      SessionStore.instance
          .appendActive(ChatMessage(sender: Sender.user, text: text));
      _controller.clear();
      _isStreaming = true;
      _messages.add(ChatMessage(
        sender: Sender.ai,
        text: '',
        isStreaming: true,
        agentName: _agent == kNoAgent ? null : _agent,
        agentIcon: _agent == kNoAgent
            ? null
            : kAgents.where((a) => a.name == _agent).firstOrNull?.icon,
      ));
    });
    _streamIndex = _messages.length - 1;
    _scrollToBottom();

    final words = _buildResponse(text);
    final full = words.join(' ');
    var wordIndex = 0;
    _streamTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      wordIndex += 2;
      final done = wordIndex >= words.length;
      final chunk = words.sublist(0, done ? words.length : wordIndex).join(' ');
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _messages[_streamIndex] = ChatMessage(
          sender: Sender.ai,
          text: chunk,
          isStreaming: !done,
          agentName: _agent == kNoAgent ? null : _agent,
          agentIcon: _agent == kNoAgent
              ? null
              : kAgents.where((a) => a.name == _agent).firstOrNull?.icon,
        );
      });
      _scrollToBottom();
      if (done) {
        timer.cancel();
        _finishStream(full);
      }
    });
  }

  void _stopStream() {
    _streamTimer?.cancel();
    _streamTimer = null;
    if (!mounted || _streamIndex < 0) return;
    setState(() {
      _messages[_streamIndex] = ChatMessage(
        sender: Sender.ai,
        text: _messages[_streamIndex].text,
        isStreaming: false,
        agentName: _messages[_streamIndex].agentName,
        agentIcon: _messages[_streamIndex].agentIcon,
      );
      _isStreaming = false;
    });
  }

  void _finishStream(String full) {
    setState(() {
      _isStreaming = false;
      final notes = NotesStore.instance.notes;
      final cited = notes.isEmpty
          ? null
          : <String>[
              notes[_random.nextInt(notes.length)].title,
              if (notes.length > 2) notes[_random.nextInt(notes.length)].title,
            ];
      // SPEC §7: una respuesta que "crea una app" incrusta una tarjeta de
      // mini-aplicación y la guarda en el panel lateral.
      final createsApp = full.contains('crea') &&
          (full.contains('app') || full.contains('mini'));
      if (createsApp) {
        MiniAppsStore.instance
            .add('Calendario editorial', Icons.calendar_month);
      }
      final agentName = _agent == kNoAgent ? null : _agent;
      final agentIcon = agentName == null
          ? null
          : kAgents.where((a) => a.name == agentName).firstOrNull?.icon;
      _messages[_streamIndex] = ChatMessage(
        sender: Sender.ai,
        text: full,
        cards: const [
          SuggestionCard('Ejemplo de lógica',
              'Crea un algoritmo de ordenación recursivo.'),
          SuggestionCard('Integración de API',
              'Obtén datos del clima con un cliente REST.'),
        ],
        citedNotes: cited,
        agentName: agentName,
        agentIcon: agentIcon,
        appTitle: createsApp ? 'Calendario editorial' : null,
      );
      SessionStore.instance.appendActive(
        ChatMessage(
          sender: Sender.ai,
          text: full,
          agentName: agentName,
          agentIcon: agentIcon,
          citedNotes: cited,
        ),
      );
    });
    _scrollToBottom();
  }

  void _sendSuggestion(SuggestionCard card) {
    if (_isStreaming) return;
    _controller.text =
        card.subtitle.trim().isEmpty ? card.title : card.subtitle;
    _sendMessage();
  }

  /// Continuación directa tras una respuesta: aceptar o ajustar el enfoque.
  void _sendNextStep(String step) {
    if (_isStreaming) return;
    HapticFeedback.lightImpact();
    _controller.text = step == 'Continuar'
        ? 'Continúa con el plan que propusiste'
        : 'Ajustemos el enfoque';
    _sendMessage();
  }

  void _openNote(String title) {
    final note = NotesStore.instance.byTitle(title);
    if (note == null) return;
    Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => NoteViewScreen(noteId: note.id)));
  }

  void _openSession(ChatSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(sessionId: session.id)),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  /// Título de la conversación para la barra superior de escritorio.
  String get _sessionTitle {
    final id = SessionStore.instance.activeSessionId;
    if (id == null) return 'Nueva conversación';
    return SessionStore.instance.byId(id)?.title ?? 'Nueva conversación';
  }

  void _toggleSidebar() {
    final ui = UiStateController.instance;
    ui.setSidebarCollapsed(!ui.sidebarCollapsed);
  }

  void _shareSession() {
    final id = SessionStore.instance.activeSessionId;
    Clipboard.setData(
        ClipboardData(text: 'https://soybluia.com/chat/${id ?? 'nueva'}'));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        backgroundColor: ThemeScope.of(context).surfaceContainerHigh,
        duration: const Duration(seconds: 1),
        content: Text('Enlace de conversación copiado',
            style: kBodyMd.copyWith(color: ThemeScope.of(context).onSurface)),
      ));
  }

  void _handleSidebarSelect(AppSidebarItem item) {
    switch (item) {
      case AppSidebarItem.settings:
        _openSettings();
      case AppSidebarItem.profile:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
      case AppSidebarItem.projects:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ProjectsScreen()));
      case AppSidebarItem.memory:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const MemoryScreen()));
      case AppSidebarItem.agenda:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AgendaScreen()));
      case AppSidebarItem.miniApps:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const MiniAppsScreen()));
      case AppSidebarItem.newChat:
        setState(() {
          _messages.clear();
          _controller.clear();
          _sessionCreated = false;
          SessionStore.instance.resetActive();
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Layout responsivo: sidebar visible solo en pantallas anchas (>= 768px)
    final isWide = MediaQuery.of(context).size.width >= 768;
    final hasUserMessages = _messages.any((m) => m.sender == Sender.user);
    final noKeys = ApiKeysStore.instance.keys.isEmpty;

    void handleSidebarSelect(AppSidebarItem item) {
      if (!isWide) _scaffoldKey.currentState?.closeDrawer();
      _handleSidebarSelect(item);
    }

    AppSidebar buildSidebar() =>
        AppSidebar(onSelect: handleSidebarSelect, onOpenSession: _openSession);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ThemeScope.of(context).background,
      drawer: isWide ? null : buildSidebar(),
      body: Row(
        children: [
          if (isWide) buildSidebar(),
          Expanded(
            child: Column(
              children: [
                if (isWide)
                  TopAppBar(
                    onCollapseTap: _toggleSidebar,
                    title: _sessionTitle,
                    onShareTap: _shareSession,
                    onSettingsTap: _openSettings,
                  )
                else
                  TopAppBar(
                    onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                    onSettingsTap: _openSettings,
                  ),
                if (noKeys && hasUserMessages)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: ErrorBanner(
                      message:
                          'Sin claves de proveedor: agrega tus claves para usar modelos personalizados.',
                      actionLabel: 'Configurar claves',
                      onAction: _openSettings,
                    ),
                  ),
                Expanded(
                  child: hasUserMessages
                      ? Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 768),
                            child: ListView(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 32),
                              children: [
                                for (var i = 0; i < _messages.length; i++)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child: _messages[i].sender == Sender.user
                                        ? UserBubble(text: _messages[i].text)
                                        : AiBubble(
                                            text: _messages[i].text,
                                            cards: _messages[i].cards,
                                            citedNotes: _messages[i].citedNotes,
                                            agentName: _messages[i].agentName,
                                            agentIcon: _messages[i].agentIcon,
                                            appTitle: _messages[i].appTitle,
                                            isStreaming:
                                                _messages[i].isStreaming,
                                            nextSteps: !_messages[i]
                                                        .isStreaming &&
                                                    i == _messages.length - 1
                                                ? const ['Continuar', 'Ajustar']
                                                : const [],
                                            onNextStep: _sendNextStep,
                                            onOpenNote: _openNote,
                                            onSuggestionTap: _sendSuggestion,
                                          ),
                                  ),
                              ],
                            ),
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 32),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight - 64),
                                child: Center(
                                  child: LandingInputCard(
                                    controller: _controller,
                                    onSend: _sendMessage,
                                    onSuggestionTap: _sendSuggestion,
                                    model: _selectedModel,
                                    onModelChanged: (m) =>
                                        setState(() => _selectedModel = m),
                                    agent: _agent,
                                    onAgentChanged: (a) =>
                                        setState(() => _agent = a),
                                    project: _project,
                                    onProjectChanged: (p) =>
                                        setState(() => _project = p),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                if (hasUserMessages)
                  BottomInputArea(
                    controller: _controller,
                    onSend: _sendMessage,
                    onStop: _stopStream,
                    isStreaming: _isStreaming,
                    model: _selectedModel,
                    onModelChanged: (m) => setState(() => _selectedModel = m),
                    agent: _agent,
                    onAgentChanged: (a) => setState(() => _agent = a),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
