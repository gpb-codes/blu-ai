import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Botón de micrófono (SPEC §8): pide permiso la primera vez y abre el
/// diálogo de grabación con anillo de pulso rojo y opciones Cancelar / Enviar;
/// la transcripción vuelve al campo.
class VoiceButton extends StatelessWidget {
  final ValueChanged<String> onTranscribed;
  final IconData icon;

  /// Decisión de permiso simulada para la sesión (null = aún sin preguntar).
  static bool? _permissionGranted;

  const VoiceButton({
    super.key,
    required this.onTranscribed,
    this.icon = Icons.mic_none,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return IconButton(
      icon: Icon(icon, size: 20, color: c.onSurfaceVariant),
      tooltip: 'Grabar voz',
      onPressed: () async {
        final granted = _permissionGranted ??= (await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (_) => const _PermissionDialog(),
            )) ??
            false;
        if (!granted) {
          if (!context.mounted) return;
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) => const _PermissionDeniedDialog(),
          );
          return;
        }
        if (!context.mounted) return;
        final text = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (_) => _VoiceRecordingDialog(),
        );
        if (text != null) onTranscribed(text);
      },
    );
  }
}

class _PermissionDialog extends StatelessWidget {
  const _PermissionDialog();

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Dialog(
      backgroundColor: c.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: BrandColors.cobalt.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.mic, size: 26, color: BrandColors.cobalt),
            ),
            const SizedBox(height: 16),
            Text('soybluia quiere usar el micrófono',
                textAlign: TextAlign.center,
                style: kHeadlineMd.copyWith(
                    color: c.onSurface, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Se usará solo para transcribir tu voz en mensajes.',
                textAlign: TextAlign.center,
                style: kBodyMd.copyWith(color: c.onSurfaceVariant)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _DialogAction(
                    label: 'No permitir',
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogAction(
                    label: 'Permitir',
                    primary: true,
                    onTap: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionDeniedDialog extends StatelessWidget {
  const _PermissionDeniedDialog();

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Dialog(
      backgroundColor: c.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mic_off_outlined,
                size: 40, color: Color(0xFFFF5A4E)),
            const SizedBox(height: 16),
            Text('Micrófono bloqueado',
                textAlign: TextAlign.center,
                style: kHeadlineMd.copyWith(
                    color: c.onSurface, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(
                'Sin permiso no podemos grabar tu voz. Actívalo en la configuración de tu navegador (sitio "soybluia" → micrófono) y vuelve a intentarlo.',
                textAlign: TextAlign.center,
                style: kBodyMd.copyWith(color: c.onSurfaceVariant)),
            const SizedBox(height: 24),
            _DialogAction(
              label: 'Entendido',
              primary: true,
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceRecordingDialog extends StatefulWidget {
  @override
  State<_VoiceRecordingDialog> createState() => _VoiceRecordingDialogState();
}

class _VoiceRecordingDialogState extends State<_VoiceRecordingDialog>
    with SingleTickerProviderStateMixin {
  static const _transcriptions = [
    'Prepara un resumen ejecutivo del plan Q3 con los próximos pasos.',
    'Crea una checklist de lanzamiento para la campaña de IA.',
    'Escribe un borrador de correo para el cliente de la propuesta.',
    'Redacta las preguntas frecuentes para la nueva landing.',
  ];

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);
  final Random _random = Random();
  Timer? _timer;
  bool _listening = true;

  String get _transcription =>
      _transcriptions[_random.nextInt(_transcriptions.length)];

  @override
  void initState() {
    super.initState();
    // Simula la captura de voz; habilita "Enviar" al terminar.
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _listening = false);
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Dialog(
      backgroundColor: c.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 96,
              height: 96,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Anillo de pulso rojo (SPEC §8).
                  ScaleTransition(
                    scale: Tween(begin: 0.9, end: 1.2).animate(_pulse),
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFFF5A4E), width: 2),
                      ),
                    ),
                  ),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0x33FF5A4E),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.mic,
                        size: 32, color: Color(0xFFFF5A4E)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(_listening ? 'Escuchando…' : 'Transcripción lista',
                style: kHeadlineMd.copyWith(
                    color: c.onSurface, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(
                _listening
                    ? 'Habla ahora; se convertirá a texto.'
                    : '¿Qué hacemos con la transcripción?',
                textAlign: TextAlign.center,
                style: kBodyMd.copyWith(color: c.onSurfaceVariant)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _DialogAction(
                    label: 'Cancelar',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogAction(
                    label: _listening ? 'Enviar' : 'Enviar transcripción',
                    primary: true,
                    enabled: !_listening,
                    onTap: () => Navigator.of(context).pop(_transcription),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool primary;
  final bool enabled;

  const _DialogAction({
    required this.label,
    required this.onTap,
    this.primary = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: primary
                ? BrandColors.cobalt
                : c.surfaceContainerHigh.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: primary
                    ? BrandColors.cobalt
                    : c.outlineVariant.withValues(alpha: 0.4)),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: kLabelMd.copyWith(
                  color: primary ? Colors.white : c.onSurface)),
        ),
      ),
    );
  }
}
