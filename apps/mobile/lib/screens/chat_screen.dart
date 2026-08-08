import 'dart:async';

import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../theme/app_colors.dart';
import '../widgets/ai_bubble.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/bottom_input_area.dart';
import '../widgets/landing_input_card.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/user_bubble.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedModel = 'Blu Light';
  bool _isTyping = false;

  final List<ChatMessage> _messages = [];

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

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || _isTyping) return;
    setState(() {
      _messages.add(ChatMessage(sender: Sender.user, text: text));
      _isTyping = true;
      _controller.clear();
    });
    _scrollToBottom();
    // Aquí engancharías la llamada real a tu backend / Groq SDK.
    Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          sender: Sender.ai,
          text: '¡Listo! Respuesta simulada para "$text" (modelo '
              '$_selectedModel). Conecta tu backend para obtener una respuesta real.',
          cards: const [
            SuggestionCard('Logic Example', 'Create a recursive sorting algorithm.'),
            SuggestionCard('API Integration', 'Fetch weather data using a REST client.'),
          ],
        ));
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Layout responsivo: sidebar visible solo en pantallas anchas (>= 768px)
    final isWide = MediaQuery.of(context).size.width >= 768;
    final hasUserMessages = _messages.any((m) => m.sender == Sender.user);

    void openSettings() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
    }

    void openProfile() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    }

    void handleSidebarSelect(AppSidebarItem item) {
      switch (item) {
        case AppSidebarItem.settings:
          openSettings();
        case AppSidebarItem.profile:
          openProfile();
        case AppSidebarItem.newChat:
          break;
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColorsDark.background,
      drawer: isWide ? null : AppSidebar(onSelect: handleSidebarSelect),
      body: Row(
        children: [
          if (isWide) AppSidebar(onSelect: handleSidebarSelect),
          Expanded(
            child: Column(
              children: [
                if (!isWide)
                  TopAppBar(
                    onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                    onSettingsTap: openSettings,
                  ),
                Expanded(
                  child: hasUserMessages
                      ? ListView(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 32),
                          children: [
                            ..._messages.map((m) => Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: m.sender == Sender.user
                                      ? UserBubble(text: m.text)
                                      : AiBubble(text: m.text, cards: m.cards),
                                )),
                            if (_isTyping)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 24),
                                child: TypingIndicator(),
                              ),
                          ],
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
                                    model: _selectedModel,
                                    onModelChanged: (m) =>
                                        setState(() => _selectedModel = m),
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
                    model: _selectedModel,
                    onModelChanged: (m) => setState(() => _selectedModel = m),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
