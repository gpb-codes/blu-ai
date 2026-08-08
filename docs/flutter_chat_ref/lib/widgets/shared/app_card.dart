import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Tarjeta oscura reutilizable (fondo surfaceContainerLow, borde sutil,
/// radio 12) usada por las secciones de Settings y Perfil.
class AppCard extends StatelessWidget {
  final Widget child;
  final BoxBorder? border;

  const AppCard({super.key, required this.child, this.border});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsDark.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: border ??
            Border.all(color: AppColorsDark.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: child,
    );
  }
}

/// Encabezado de página: título grande y subtítulo descriptivo.
class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: kHeadlineLg.copyWith(color: AppColorsDark.onSurface)),
        const SizedBox(height: 8),
        Text(subtitle,
            style: kBodyMd.copyWith(color: AppColorsDark.onSurfaceVariant)),
      ],
    );
  }
}

/// Encabezado de sección: icono en color primario, título y descripción.
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColorsDark.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title,
                  overflow: TextOverflow.ellipsis,
                  style: kHeadlineMd.copyWith(color: AppColorsDark.onSurface)),
            ),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(description!,
              style: kBodyMd.copyWith(color: AppColorsDark.onSurfaceVariant)),
        ],
      ],
    );
  }
}