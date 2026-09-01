import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

const kBluModels = ['Blu Light', 'Blu Flash', 'Blu Ultra'];

/// Modo Auto: selección inteligente del modelo según la tarea (tier "auto").
const kAutoModel = 'Auto';

class OtherModel {
  final String name;
  final IconData icon;
  final Color color;

  const OtherModel(
      {required this.name, required this.icon, required this.color});
}

const kOtherModels = [
  OtherModel(name: 'Claude', icon: Icons.flare, color: Color(0xFFFB923C)),
  OtherModel(
      name: 'ChatGPT', icon: Icons.donut_large, color: Color(0xFF34D399)),
  OtherModel(
      name: 'Gemini', icon: Icons.auto_awesome, color: Color(0xFF60A5FA)),
];

/// Agente de IA (AGENT_METADATA web).
class AiAgent {
  final String name;
  final IconData icon;
  final String description;

  const AiAgent({
    required this.name,
    required this.icon,
    required this.description,
  });
}

const kNoAgent = 'Sin agente';

const kAgents = [
  AiAgent(
      name: 'Plan',
      icon: Icons.assignment_outlined,
      description: 'Divide el trabajo y define el plan.'),
  AiAgent(
      name: 'Build',
      icon: Icons.code,
      description: 'Escribe y corrige código.'),
  AiAgent(
      name: 'Cowork',
      icon: Icons.groups_outlined,
      description: 'Trabaja contigo en tareas conjuntas.'),
  AiAgent(
      name: 'Research',
      icon: Icons.search,
      description: 'Investiga y resume fuentes.'),
  AiAgent(
      name: 'QA',
      icon: Icons.bug_report,
      description: 'Prueba y detecta fallos.'),
  AiAgent(
      name: 'Automation',
      icon: Icons.bolt,
      description: 'Automatiza tareas repetitivas.'),
  AiAgent(
      name: 'Knowledge',
      icon: Icons.auto_stories,
      description: 'Recupera y organiza la memoria.'),
  AiAgent(
      name: 'Design',
      icon: Icons.design_services_outlined,
      description: 'Crea interfaces, imágenes y propuestas visuales.'),
  AiAgent(
      name: 'Data',
      icon: Icons.storage_outlined,
      description: 'Analiza datos, tablas y genera informes.'),
  AiAgent(
      name: 'Writing',
      icon: Icons.edit_note,
      description: 'Redacta y edita textos en tu tono.'),
  AiAgent(
      name: 'Review',
      icon: Icons.fact_check_outlined,
      description: 'Revisa borradores con criterio editorial.'),
  AiAgent(
      name: 'Publish',
      icon: Icons.rocket_launch_outlined,
      description: 'Publica y distribuye contenido.'),
  AiAgent(
      name: 'Support',
      icon: Icons.support_agent,
      description: 'Responde dudas y da soporte a usuarios.'),
  AiAgent(
      name: 'Legal',
      icon: Icons.gavel,
      description: 'Revisa términos, políticas y contratos.'),
  AiAgent(
      name: 'Sales',
      icon: Icons.trending_up,
      description: 'Prepara propuestas y seguimiento comercial.'),
];

/// Pill del selector (modelo o agente). Fondo cobalto + texto blanco mientras
/// el modo Auto esté activo; tonos neutros con otro modelo (SPEC §2).
class ModelPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool active;

  const ModelPill({
    super.key,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        hoverColor: active ? BrandColors.cobalt : c.surfaceBright,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active ? BrandColors.cobalt : c.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
            border: active
                ? Border.all(color: BrandColors.cobalt)
                : Border.all(color: c.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: kBodyMd.copyWith(
                      fontSize: 13,
                      color: active ? Colors.white : c.onSurface)),
              const SizedBox(width: 2),
              Icon(Icons.expand_more,
                  size: 16, color: active ? Colors.white : c.onSurface),
            ],
          ),
        ),
      ),
    );
  }
}

/// Panel del dropdown: AGENTES + OTROS MODELOS + SOYBLUIA (con Auto).
class ModelDropdown extends StatelessWidget {
  final String selected;
  final String agent;
  final ValueChanged<String> onSelected;
  final ValueChanged<String> onAgentChanged;

  const ModelDropdown({
    super.key,
    required this.selected,
    required this.agent,
    required this.onSelected,
    required this.onAgentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 288,
      decoration: BoxDecoration(
        color: ThemeScope.of(context).elevatedOverlay,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: ThemeScope.of(context).outlineVariant.withValues(alpha: 0.5)),
        boxShadow: AppShadows.l,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _DropdownLabel('AGENTES'),
                _DropdownButton(
                  onTap: () => onAgentChanged(kNoAgent),
                  selected: agent == kNoAgent,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        child: Icon(Icons.person_outline,
                            size: 16,
                            color: agent == kNoAgent ? Colors.white : ThemeScope.of(context).onSurfaceVariant),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(kNoAgent,
                            style: kBodyMd.copyWith(
                                fontSize: 14,
                                color: agent == kNoAgent ? Colors.white : ThemeScope.of(context).onSurface)),
                      ),
                    ],
                  ),
                ),
                for (final a in kAgents)
                  _DropdownButton(
                    onTap: () => onAgentChanged(a.name),
                    selected: agent == a.name,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          child: Icon(a.icon,
                              size: 16,
                              color: agent == a.name ? Colors.white : ThemeScope.of(context).onSurfaceVariant),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: kBodyMd.copyWith(
                                      fontSize: 14,
                                      color: agent == a.name ? Colors.white : ThemeScope.of(context).onSurface)),
                              Text(a.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: kLabelMd.copyWith(
                                      fontSize: 11,
                                      color: agent == a.name ? Colors.white.withValues(alpha: 0.85) : ThemeScope.of(context).onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Container(
              height: 1,
              color:
                  ThemeScope.of(context).outlineVariant.withValues(alpha: 0.2)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _DropdownLabel('OTROS MODELOS'),
                for (final m in kOtherModels)
                  _DropdownButton(
                    onTap: () => onSelected(m.name),
                    selected: selected == m.name,
                    child: Row(
                      children: [
                        Icon(m.icon, size: 16, color: selected == m.name ? Colors.white : m.color),
                        const SizedBox(width: 12),
                        Text(m.name,
                            style: kBodyMd.copyWith(
                                fontSize: 14,
                                color: selected == m.name ? Colors.white : ThemeScope.of(context).onSurface)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Container(
              height: 1,
              color:
                  ThemeScope.of(context).outlineVariant.withValues(alpha: 0.2)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _DropdownLabel('SOYBLUIA'),
                _DropdownButton(
                  onTap: () => onSelected(kAutoModel),
                  selected: selected == kAutoModel,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Auto',
                                style: kBodyMd.copyWith(
                                    fontSize: 14,
                                    color: selected == kAutoModel ? Colors.white : ThemeScope.of(context).onSurface)),
                            Text('Selección inteligente',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: kLabelMd.copyWith(
                                    fontSize: 11,
                                    color: selected == kAutoModel ? Colors.white.withValues(alpha: 0.85) : ThemeScope.of(context).onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                for (final name in kBluModels)
                  _DropdownButton(
                    onTap: () => onSelected(name),
                    selected: selected == name,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(name,
                              style: kBodyMd.copyWith(
                                  fontSize: 14,
                                  color: selected == name ? Colors.white : ThemeScope.of(context).onSurface)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownLabel extends StatelessWidget {
  final String text;

  const _DropdownLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(text,
          style: kLabelMd.copyWith(
              fontSize: 10,
              height: 1.2,
              letterSpacing: 0.6,
              color: ThemeScope.of(context).onSurfaceVariant)),
    );
  }
}

/// Fila del dropdown; cuando está seleccionada usa borde cobalto y check
/// cobalto (SPEC §2: "marca de verificación cobalto").
class _DropdownButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool selected;
  final Widget child;

  const _DropdownButton({
    required this.onTap,
    this.selected = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    // Screenshot: seleccionado = fondo #0A34F5 azul vivo con texto blanco y check blanco
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: selected ? BrandColors.cobalt.withValues(alpha: 0.9) : c.surfaceContainerHigh,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? BrandColors.cobalt : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? BrandColors.cobalt : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: selected ? Colors.white : null),
                    child: IconTheme.merge(
                      data: IconThemeData(color: selected ? Colors.white : null),
                      child: child,
                    ),
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check, size: 18, color: Colors.white),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón circular de enviar que aparece al escribir; durante el streaming se
/// convierte en un cuadrado de detener (patrón ChatGPT).
class ChatSendButton extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback? onStop;

  /// Verdadero mientras la respuesta se transmite por flujo.
  final bool isStreaming;

  /// Verdadero cuando hay texto en el campo; si no, el botón queda oculto.
  final bool active;

  /// Color de fondo del círculo; por defecto, el cobalto de marca.
  final Color? background;

  const ChatSendButton({
    super.key,
    required this.onTap,
    this.onStop,
    this.isStreaming = false,
    this.active = false,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    if (!active && !isStreaming) {
      return const SizedBox(width: 36, height: 36);
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isStreaming ? onStop : onTap,
        customBorder: isStreaming ? null : const CircleBorder(),
        borderRadius: BorderRadius.circular(isStreaming ? 6 : 18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: isStreaming ? 28 : 36,
          height: isStreaming ? 28 : 36,
          decoration: BoxDecoration(
            color:
                isStreaming ? c.onSurface : (background ?? BrandColors.cobalt),
            borderRadius: BorderRadius.circular(isStreaming ? 6 : 18),
            boxShadow: isStreaming || background != null
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x330A34F5),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Icon(
            isStreaming ? Icons.stop_rounded : Icons.arrow_upward,
            size: isStreaming ? 20 : 18,
            color: isStreaming ? c.surface : Colors.white,
          ),
        ),
      ),
    );
  }
}
