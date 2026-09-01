import 'package:flutter/material.dart';
import '../services/stores.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/shared/error_banner.dart';
import 'chat_screen.dart';
import 'consent_screen.dart';
import 'register_screen.dart';

/// Pantalla de inicio de sesión con el diseño soybluia (SPEC §11): correo,
/// Google y teléfono (SMS), banner de error de red y consentimiento obligatorio
/// en la primera sesión.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscure = true;
  bool _networkError = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _enter() {
    if (_email.text.trim().isEmpty) {
      setState(() => _networkError = true);
      return;
    }
    setState(() => _networkError = false);
    if (_email.text.trim().isNotEmpty) {
      UserStore.instance.setProfile(name: UserStore.instance.name, email: _email.text.trim());
    }
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

  void _notReady() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: ThemeScope.of(context).surfaceContainerHigh,
          content: Text('Esta opción estará disponible pronto.',
              style: kBodyMd.copyWith(color: ThemeScope.of(context).onSurface)),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight - 64),
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
                              child: const Icon(Icons.auto_awesome,
                                  size: 28, color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            Text('soybluia',
                                textAlign: TextAlign.center,
                                style: kHeadlineLg.copyWith(
                                    color: c.onSurface,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Tu asistente de IA para trabajar hoy',
                                textAlign: TextAlign.center,
                                style: kBodyMd.copyWith(
                                    color: c.onSurfaceVariant)),
                          ],
                        ),
                        const SizedBox(height: 40),
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
                                Text('Inicia sesión',
                                    style: kHeadlineMd.copyWith(
                                        color: c.onSurface,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Text(
                                    'Bienvenido de nuevo. ¿En qué trabajamos hoy?',
                                    style: kBodyMd.copyWith(
                                        color: c.onSurfaceVariant)),
                                const SizedBox(height: 24),
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
                                const SizedBox(height: 16),
                                Text('Contraseña',
                                    style: kLabelMd.copyWith(
                                        color: c.onSurfaceVariant)),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _password,
                                  obscureText: _obscure,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _enter(),
                                  style: kBodyMd.copyWith(color: c.onSurface),
                                  decoration: _decoration(c, '••••••••').copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 20,
                                        color: c.onSurfaceVariant,
                                      ),
                                      onPressed: () =>
                                          setState(() => _obscure = !_obscure),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: _notReady,
                                    child: Text('¿Olvidaste tu contraseña?',
                                        style: kLabelMd.copyWith(
                                            color: c.primary)),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _LoginButton(onTap: _enter),
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
                                _GoogleButton(onTap: _enter),
                                const SizedBox(height: 10),
                                _PhoneButton(onTap: _enter),
                                if (_networkError) ...[
                                  const SizedBox(height: 16),
                                  ErrorBanner(
                                    message:
                                        'No pudimos conectarnos. Revisa tu red e inténtalo de nuevo.',
                                    onAction: () => setState(
                                        () => _networkError = false),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('¿No tienes cuenta?',
                                style: kBodyMd.copyWith(
                                    color: c.onSurfaceVariant)),
                            TextButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const RegisterScreen()),
                              ),
                              child: Text('Regístrate',
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
        borderSide:
            BorderSide(color: c.outlineVariant.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            BorderSide(color: c.outlineVariant.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: c.primary, width: 1.5),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LoginButton({required this.onTap});

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
              Text('Iniciar sesión',
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

class _PhoneButton extends StatelessWidget {
  final VoidCallback onTap;

  const _PhoneButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        hoverColor: BrandColors.cobalt.withValues(alpha: 0.06),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: c.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: BrandColors.cobalt.withValues(alpha: 0.25)),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.phone_android,
                  size: 18, color: BrandColors.cobalt),
              const SizedBox(width: 10),
              Text('Continuar con teléfono',
                  style: kBodyMd.copyWith(
                      fontSize: 14, color: c.onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final VoidCallback onTap;

  const _GoogleButton({required this.onTap});

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
                color: c.outlineVariant.withValues(alpha: 0.2)),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('G',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4285F4))),
              const SizedBox(width: 10),
              Text('Continuar con Google',
                  style: kBodyMd.copyWith(
                      fontSize: 14, color: c.onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}