import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Items de navegación del sidebar compartido.
enum AppSidebarItem { newChat, settings, profile }

/// Sidebar unificado con el diseño principal: logo soybluia, "Nuevo chat",
/// sección Recientes, tarjeta de usuario y Configuración.
/// `selected` resalta la sección actual (null = sin resaltado, p. ej. chat).
class AppSidebar extends StatelessWidget {
  final AppSidebarItem? selected;
  final ValueChanged<AppSidebarItem> onSelect;

  const AppSidebar({super.key, this.selected, required this.onSelect});

  static const _recentItems = [
    (Icons.chat_bubble, 'Ideas para campaña de IA'),
    (Icons.lightbulb, 'Mejores prompts para diseño'),
    (Icons.description, 'Resumen de documento PDF'),
    (Icons.code, 'Código para página web'),
    (Icons.track_changes, 'Estrategia de contenido'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColorsDark.surfaceContainerLow,
        border: Border(
            right:
                BorderSide(color: AppColorsDark.outlineVariant.withValues(alpha: 0.2))),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const _BrandHeader(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: _NewChatButton(
                  onTap: () => onSelect(AppSidebarItem.newChat),
                ),
              ),
              const SizedBox(height: 24),
              const _SectionLabel('Recientes'),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (final item in _recentItems)
                      _RecentItem(
                        icon: item.$1,
                        label: item.$2,
                        onTap: () => onSelect(AppSidebarItem.newChat),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _UserCard(
                selected: selected == AppSidebarItem.profile,
                onTap: () => onSelect(AppSidebarItem.profile),
              ),
              const SizedBox(height: 8),
              _SettingsButton(
                selected: selected == AppSidebarItem.settings,
                onTap: () => onSelect(AppSidebarItem.settings),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColorsDark.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Text('soybluia',
            style: kHeadlineMd.copyWith(
                color: AppColorsDark.onSurface, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _NewChatButton extends StatelessWidget {
  final VoidCallback onTap;

  const _NewChatButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColorsDark.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppColorsDark.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.add, size: 18, color: AppColorsDark.onSurface),
              const SizedBox(width: 8),
              Text('Nuevo chat',
                  style: kLabelMd.copyWith(color: AppColorsDark.onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(text.toUpperCase(),
          style: kLabelMd.copyWith(
              fontSize: 10,
              height: 1.2,
              letterSpacing: 0.8,
              color: AppColorsDark.onSurfaceVariant.withValues(alpha: 0.7))),
    );
  }
}

class _RecentItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _RecentItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppColorsDark.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon,
                  size: 16,
                  color: AppColorsDark.onSurfaceVariant.withValues(alpha: 0.7)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: kBodyMd.copyWith(
                        color: AppColorsDark.onSurfaceVariant)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _UserCard({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColorsDark.surfaceContainerHigh : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppColorsDark.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColorsDark.inversePrimary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('IL',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ignacio Loyola',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: kBodyMd.copyWith(
                            fontSize: 13, color: AppColorsDark.onSurface)),
                    const SizedBox(height: 2),
                    Text('Plan BYOK',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: kLabelMd.copyWith(
                            fontSize: 11,
                            color: AppColorsDark.onSurfaceVariant)),
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

class _SettingsButton extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _SettingsButton({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColorsDark.surfaceContainerHigh : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppColorsDark.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              const Icon(Icons.settings,
                  size: 20, color: AppColorsDark.onSurfaceVariant),
              const SizedBox(width: 12),
              Text('Configuración',
                  style: kBodyMd.copyWith(
                      fontSize: 13, color: AppColorsDark.onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}
