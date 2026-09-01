import 'package:flutter/material.dart';
import '../services/stores.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/shared/error_banner.dart';
import 'chat_screen.dart';
import 'consent_screen.dart';
import 'login_screen.dart';

/// Pantalla de registro con el diseño soybluia (SPEC §11): nombre, correo,
/// contraseña con confirmación, botones sociales y consentimiento en la
/// primera sesión. El registro es opcional: la app arranca en el chat.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _touched = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? get _passwordError {
    if (!_touched) return null;
    if (_password.text.isEmpty) return 'Ingresa una contraseña';
    if (_password.text.length < 6) return 'Mínimo 6 caracteres';
    if (_confirm.text.isNotEmpty && _confirm.text != _password.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  void _submit() {
    setState(() => _touched = true);
    final nameOk = _name.text.trim().isNotEmpty;
    final emailOk = _email.text.trim().isNotEmpty;
    final pwdOk = _password.text.isNotEmpty &&
        _password.text.length >= 6 &&
        _password.text == _confirm.text;
    if (!(nameOk && emailOk && pwdOk)) return;
    UserStore.instance
        .setProfile(name: _name.text.trim(), email: _email.text.trim());
    UserStore.instance.setLoggedIn(true);
    // Primera sesión: consentimiento obligatorio antes de continuar.
    if (!UserStore.instance.consentGiven) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ConsentScreen()),
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
  }

  void _socialNotReady() {
    setState(() => _error =
        'No pudimos conectarnos. Revisa tu red e inténtalo de nuevo.');
  }

  InputDecoration _decoration(AppPalette c, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          kBodyMd.copyWith(color: c.onSurfaceVariant.withValues(alpha: 0.6)),
      filled: true,
      fillColor: c.surfaceContainer,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: c.outlineVariant.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: c.outlineVariant.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: c.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: c.error, width: 1.2),
      ),
    );
  }

  InputDecoration _passwordDecoration(AppPalette c, bool obscure, VoidCallback toggle) {
    return _decoration(c, '••••••••').copyWith(
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
          color: c.onSurfaceVariant,
        ),
        onPressed: toggle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight - 40),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(Icons.arrow_back,
                                size: 20, color: c.onSurfaceVariant),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: c.primaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.person_add_alt_1,
                                  size: 28, color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            Text('soybluia',
                                textAlign: TextAlign.center,
                                style: kHeadlineLg.copyWith(
                                    color: c.onSurface,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Crea tu cuenta y empieza a trabajar',
                                textAlign: TextAlign.center,
                                style: kBodyMd.copyWith(
                                    color: c.onSurfaceVariant)),
                          ],
                        ),
                        const SizedBox(height: 28),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: c.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: c.outlineVariant.withValues(alpha: 0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Regístrate',
                                    style: kHeadlineMd.copyWith(
                                        color: c.onSurface,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Text(
                                    'Solo te tomará un minuto. Sin tarjeta de crédito.',
                                    style: kBodyMd.copyWith(
                                        color: c.onSurfaceVariant)),
                                const SizedBox(height: 20),
                                Text('Nombre completo',
                                    style: kLabelMd.copyWith(
                                        color: c.onSurfaceVariant)),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _name,
                                  textInputAction: TextInputAction.next,
                                  style: kBodyMd.copyWith(color: c.onSurface),
                                  decoration: _decoration(c, 'Ignacio Loyola'),
                                ),
                                const SizedBox(height: 14),
                                Text('Correo electrónico',
                                    style: kLabelMd.copyWith(
                                        color: c.onSurfaceVariant)),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _email,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  style: kBodyMd.copyWith(color: c.onSurface),
                                  decoration: _decoration(c, 'nombre@ejemplo.com'),
                                ),
                                const SizedBox(height: 14),
                                Text('Contraseña',
                                    style: kLabelMd.copyWith(
                                        color: c.onSurfaceVariant)),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _password,
                                  obscureText: _obscure,
                                  textInputAction: TextInputAction.next,
                                  style: kBodyMd.copyWith(color: c.onSurface),
                                  decoration: _passwordDecoration(
                                      c, _obscure,
                                      () => setState(() => _obscure = !_obscure)),
                                ),
                                const SizedBox(height: 14),
                                Text('Confirmar contraseña',
                                    style: kLabelMd.copyWith(
                                        color: c.onSurfaceVariant)),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _confirm,
                                  obscureText: _obscureConfirm,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _submit(),
                                  style: kBodyMd.copyWith(color: c.onSurface),
                                  decoration: _passwordDecoration(
                                      c, _obscureConfirm,
                                      () => setState(
                                          () => _obscureConfirm = !_obscureConfirm)),
                                ),
                                if (_passwordError != null) ...[
                                  const SizedBox(height: 10),
                                  Text(_passwordError!,
                                      style: kLabelMd.copyWith(
                                          fontSize: 12, color: c.error)),
                                ],
                                const SizedBox(height: 18),
                                _RegisterButton(onTap: _submit),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Container(
                                            height: 1,
                                            color: c.outlineVariant
                                                .withValues(alpha: 0.2))),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Text('o continúa con',
                                          style: kLabelMd.copyWith(
                                              fontSize: 11,
                                              color: c.onSurfaceVariant)),
                                    ),
                                    Expanded(
                                        child: Container(
                                            height: 1,
                                            color: c.outlineVariant
                                                .withValues(alpha: 0.2))),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _SocialButton(
                                  icon: const Text('G',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4285F4))),
                                  label: 'Continuar con Google',
                                  onTap: _socialNotReady,
                                ),
                                const SizedBox(height: 10),
                                _SocialButton(
                                  icon: const Icon(Icons.phone_android,
                                      size: 18, color: BrandColors.cobalt),
                                  label: 'Continuar con teléfono',
                                  cobaltBorder: true,
                                  onTap: _socialNotReady,
                                ),
                                if (_error != null) ...[
                                  const SizedBox(height: 16),
                                  ErrorBanner(
                                    message: _error!,
                                    onAction: () =>
                                        setState(() => _error = null),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('¿Ya tienes cuenta?',
                                style: kBodyMd.copyWith(
                                    color: c.onSurfaceVariant)),
                            TextButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                              ),
                              child: Text('Inicia sesión',
                                  style: kBodyMd.copyWith(
                                      color: c.primary,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RegisterButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RegisterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: c.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Crear cuenta',
                  style: kBodyMd.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;
  final bool cobaltBorder;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.cobaltBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        hoverColor: c.surfaceContainerHigh,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: c.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: cobaltBorder
                    ? BrandColors.cobalt.withValues(alpha: 0.25)
                    : c.outlineVariant.withValues(alpha: 0.2)),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 10),
              Text(label,
                  style: kBodyMd.copyWith(fontSize: 14, color: c.onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}