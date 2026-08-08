import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Top bar móvil del chat: menú, logo y "soybluia" a la izquierda;
/// settings y ayuda a la derecha. Solo se muestra en pantallas angostas.
class TopAppBar extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onSettingsTap;

  const TopAppBar({super.key, this.onMenuTap, this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColorsDark.background,
        border: Border(
            bottom:
                BorderSide(color: AppColorsDark.outlineVariant.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppColorsDark.onSurface),
            onPressed: onMenuTap,
            tooltip: 'Abrir menú',
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColorsDark.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.auto_awesome,
                size: 16, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text('soybluia',
              style: kHeadlineMd.copyWith(
                  color: AppColorsDark.onSurface, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                size: 20, color: AppColorsDark.onSurfaceVariant),
            onPressed: onSettingsTap,
            tooltip: 'Configuración',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline,
                size: 20, color: AppColorsDark.onSurfaceVariant),
            onPressed: () {},
            tooltip: 'Ayuda',
          ),
        ],
      ),
    );
  }
}
