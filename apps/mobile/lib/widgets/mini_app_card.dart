import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../screens/mini_apps_screen.dart';

/// Tarjeta de mini-aplicación incrustada en una respuesta del chat (SPEC §7).
class MiniAppCard extends StatelessWidget {
  final String title;
  final IconData? icon;

  const MiniAppCard({super.key, required this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Material(
      color: c.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MiniAppViewer(
              title: title,
              icon: icon ?? Icons.widgets_outlined,
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: BrandColors.cobalt.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: BrandColors.cobalt.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon ?? Icons.widgets_outlined,
                    size: 20, color: BrandColors.cobalt),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: kBodyMd.copyWith(
                            color: c.onSurface, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text('Mini-aplicación generada',
                        style: kLabelMd.copyWith(
                            fontSize: 11, color: c.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: BrandColors.cobalt,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Abrir',
                    style: kLabelMd.copyWith(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}