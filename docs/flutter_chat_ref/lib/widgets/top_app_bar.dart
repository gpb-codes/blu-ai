import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Barra superior: en móvil muestra menú/atrás, logo y acciones; en
/// escritorio (wide) muestra botón de colapso del sidebar, título centrado y
/// acciones (compartir, configuración, ayuda) al estilo ChatGPT.
class TopAppBar extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onSettingsTap;
  final bool showBack;

  /// Modo escritorio: título de la conversación centrado.
  final String? title;

  /// Icono de colapso del sidebar (escritorio) a la izquierda.
  final VoidCallback? onCollapseTap;

  final VoidCallback? onShareTap;

  const TopAppBar({
    super.key,
    this.onMenuTap,
    this.onSettingsTap,
    this.showBack = false,
    this.title,
    this.onCollapseTap,
    this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    final isWide = title != null || onCollapseTap != null;
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: c.background,
        border: Border(
            bottom:
                BorderSide(color: c.outlineVariant.withValues(alpha: 0.2))),
      ),
      child: isWide ? _buildWide(context) : _buildMobile(context),
    );
  }

  Widget _buildMobile(BuildContext context) {
    final c = ThemeScope.of(context);
    return Row(
      children: [
        IconButton(
          icon: Icon(showBack ? Icons.arrow_back : Icons.menu,
              color: c.onSurface),
          onPressed:
              showBack ? () => Navigator.of(context).maybePop() : onMenuTap,
          tooltip: showBack ? 'Volver' : 'Abrir menú',
        ),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: c.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Text('soybluia',
            style: kHeadlineMd.copyWith(
                color: c.onSurface, fontWeight: FontWeight.bold)),
        const Spacer(),
        if (onSettingsTap != null)
          IconButton(
            icon: Icon(Icons.settings_outlined,
                size: 20, color: c.onSurfaceVariant),
            onPressed: onSettingsTap,
            tooltip: 'Configuración',
          ),
        IconButton(
          icon: Icon(Icons.help_outline,
              size: 20, color: c.onSurfaceVariant),
          onPressed: () => showHelpSheet(context),
          tooltip: 'Ayuda',
        ),
      ],
    );
  }

  Widget _buildWide(BuildContext context) {
    final c = ThemeScope.of(context);
    return Row(
      children: [
        if (onCollapseTap != null)
          IconButton(
            icon: Icon(Icons.menu_open,
                size: 20, color: c.onSurfaceVariant),
            onPressed: onCollapseTap,
            tooltip: 'Alternar barra lateral',
          )
        else
          const SizedBox(width: 48),
        Expanded(
          child: Text(
            title ?? '',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: kBodyMd.copyWith(
                fontSize: 14, color: c.onSurface, fontWeight: FontWeight.w600),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onShareTap != null)
              IconButton(
                icon: Icon(Icons.share_outlined,
                    size: 18, color: c.onSurfaceVariant),
                onPressed: onShareTap,
                tooltip: 'Compartir conversación',
              ),
            if (onSettingsTap != null)
              IconButton(
                icon: Icon(Icons.settings_outlined,
                    size: 18, color: c.onSurfaceVariant),
                onPressed: onSettingsTap,
                tooltip: 'Configuración',
              ),
            IconButton(
              icon: Icon(Icons.help_outline,
                  size: 18, color: c.onSurfaceVariant),
              onPressed: () => showHelpSheet(context),
              tooltip: 'Ayuda',
            ),
          ],
        ),
      ],
    );
  }
}

/// Hoja inferior "Centro de ayuda" (SPEC): atajos, planes y contacto.
void showHelpSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: ThemeScope.of(context).surfaceContainerLow,
    showDragHandle: true,
    builder: (_) => const _HelpSheet(),
  );
}

class _HelpSheet extends StatefulWidget {
  const _HelpSheet();

  @override
  State<_HelpSheet> createState() => _HelpSheetState();
}

class _HelpSheetState extends State<_HelpSheet> {
  static const _entries = <(IconData, String, String)>[
    (
      Icons.keyboard_outlined,
      'Atajos de teclado',
      'Enter envía el mensaje\nShift + Enter añade una línea nueva\nEl campo del chat se enfoca con "/"'
    ),
    (
      Icons.workspace_premium_outlined,
      'Planes y créditos',
      'El plan determina el límite mensual de créditos. Cada agente consume créditos por tarea; consulta tu saldo en el perfil.'
    ),
    (
      Icons.shield_outlined,
      'Privacidad y datos',
      'Las sesiones, la memoria y las mini-aplicaciones se guardan localmente en esta demo.'
    ),
    (
      Icons.mail_outline,
      'Contacto',
      'Escríbenos a contacto@soybluia.com y te responderemos en menos de 24 horas.'
    ),
  ];

  int? _selected;

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Centro de ayuda',
                style: kHeadlineMd.copyWith(
                    color: c.onSurface, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            for (var i = 0; i < _entries.length; i++) ...[
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () =>
                    setState(() => _selected = _selected == i ? null : i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Icon(_entries[i].$1, size: 20, color: BrandColors.cobalt),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(_entries[i].$2,
                            style: kBodyMd.copyWith(
                                color: c.onSurface,
                                fontWeight: FontWeight.w500)),
                      ),
                      Icon(
                        _selected == i
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: BrandColors.gris,
                      ),
                    ],
                  ),
                ),
              ),
              if (_selected == i)
                Padding(
                  padding: const EdgeInsets.only(left: 32, bottom: 8),
                  child: Text(_entries[i].$3,
                      style: kBodyMd.copyWith(
                          fontSize: 13, color: BrandColors.gris)),
                ),
            ],
          ],
        ),
      ),
    );
  }
}