import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class UserBubble extends StatelessWidget {
  final String text;
  const UserBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        LayoutBuilder(
          builder: (context, constraints) => ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.7),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColorsDark.primaryContainer,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
                ],
              ),
              child: Text(text,
                  style:
                      const TextStyle(color: Colors.white, fontSize: 16, height: 1.6)),
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('SENT',
              style: TextStyle(
                  fontSize: 10, color: AppColorsDark.onSurfaceVariant, letterSpacing: 1)),
        ),
      ],
    );
  }
}
