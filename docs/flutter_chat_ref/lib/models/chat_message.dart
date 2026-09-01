import 'package:flutter/material.dart';

enum Sender { user, ai }

class SuggestionCard {
  final String title;
  final String subtitle;
  const SuggestionCard(this.title, this.subtitle);
}

class ChatMessage {
  final Sender sender;
  final String text;

  /// Tarjetas de sugerencia (post-respuesta).
  final List<SuggestionCard>? cards;

  /// Notas de la memoria usadas por el agente (campo citedNotes del server).
  final List<String>? citedNotes;

  /// Agente activo que generó la respuesta.
  final String? agentName;
  final IconData? agentIcon;

  /// Título de una mini-aplicación incrustada en la respuesta.
  final String? appTitle;

  /// Verdadero mientras la respuesta se está transmitiendo por flujo.
  final bool isStreaming;

  ChatMessage({
    required this.sender,
    required this.text,
    this.cards,
    this.citedNotes,
    this.agentName,
    this.agentIcon,
    this.appTitle,
    this.isStreaming = false,
  });
}