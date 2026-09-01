import 'package:flutter/material.dart';
import '../services/stores.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'chat_screen.dart';

/// Pantalla de consentimiento de la primera sesión (SPEC §11): términos de
/// uso, aviso de tratamiento de datos y aceptación de la memoria, obligatoria
/// para continuar.
class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _terms = false;
  bool _data = false;
  bool _memory = false;

  bool get _accepted => _terms && _data && _memory;

  void _continue() {
    if (!_accepted) return;
    UserStore.instance.setConsentGiven(true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: BrandColors.cobalt,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.verified_user_outlined,
                        size: 28, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text('Un último paso',
                      textAlign: TextAlign.center,
                      style: kHeadlineLg.copyWith(
                          color: c.onSurface, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                      'Para usar soybluia necesitamos tu consentimiento.',
                      textAlign: TextAlign.center,
                      style: kBodyMd.copyWith(color: c.onSurfaceVariant)),
                  const SizedBox(height: 28),
                  _ConsentTile(
                    icon: Icons.description_outlined,
                    title: 'Términos de uso',
                    subtitle:
                        'He leído y acepto los términos de uso de soybluia.',
                    value: _terms,
                    onChanged: (v) => setState(() => _terms = v),
                  ),
                  const SizedBox(height: 12),
                  _ConsentTile(
                    icon: Icons.lock_outline,
                    title: 'Tratamiento de datos',
                    subtitle:
                        'Entiendo cómo se tratan mis datos y mi información.',
                    value: _data,
                    onChanged: (v) => setState(() => _data = v),
                  ),
                  const SizedBox(height: 12),
                  _ConsentTile(
                    icon: Icons.memory_outlined,
                    title: 'Aceptación de la memoria',
                    subtitle:
                        'Autorizo a la memoria a guardar y recuperar notas de mis conversaciones.',
                    value: _memory,
                    onChanged: (v) => setState(() => _memory = v),
                  ),
                  const SizedBox(height: 28),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _accepted ? _continue : null,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _accepted
                              ? BrandColors.cobalt
                              : BrandColors.gris.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                            _accepted
                                ? 'Aceptar y continuar'
                                : 'Acepta todo para continuar',
                            style: kBodyMd.copyWith(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConsentTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ConsentTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: value
                ? BrandColors.cobalt.withValues(alpha: 0.5)
                : c.outlineVariant.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: BrandColors.cobalt),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: kBodyMd.copyWith(
                        color: c.onSurface, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: kBodyMd.copyWith(
                        fontSize: 13, color: c.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: BrandColors.cobalt,
            side: BorderSide(color: c.outlineVariant),
          ),
        ],
      ),
    );
  }
}