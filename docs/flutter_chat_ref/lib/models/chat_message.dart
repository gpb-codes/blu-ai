enum Sender { user, ai }

class SuggestionCard {
  final String title;
  final String subtitle;
  const SuggestionCard(this.title, this.subtitle);
}

class ChatMessage {
  final Sender sender;
  final String text;
  final List<SuggestionCard>? cards;

  ChatMessage({required this.sender, required this.text, this.cards});
}
