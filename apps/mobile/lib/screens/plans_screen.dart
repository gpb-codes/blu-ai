import 'package:flutter/material.dart';
import '../services/stores.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/shared/app_card.dart';
import '../widgets/shared/sidebar_shell.dart';
import 'agenda_screen.dart';
import 'chat_screen.dart';
import 'memory_screen.dart';
import 'mini_apps_screen.dart';
import 'profile_screen.dart';
import 'projects_screen.dart';

/// Pantalla de planes y cobros (SPEC §10): Gratis, BYOK $10 y Créditos $30,
/// con la actual marcada y acción cobalto. Incluye la barra de saldo cuando
/// el plan es Créditos.
class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  static const _plans = [
    (plan: UserPlan.gratis, name: 'Gratis', price: 0, benefits: [
      'Chat con modelos Blu Light',
      'Memoria limitada',
      'Historial reciente',
    ]),
    (plan: UserPlan.byok, name: 'BYOK', price: 10, benefits: [
      'Trae tus propias claves de API',
      'Todos los modelos',
      'Memoria completa + grafo',
    ]),
    (plan: UserPlan.creditos, name: 'Créditos', price: 30, benefits: [
      'Créditos por consumo',
      'Tope suave por modelo',
      'Soporte prioritario',
    ]),
  ];

  void _switch(BuildContext context, AppSidebarItem item) {
    switch (item) {
      case AppSidebarItem.newChat:
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const ChatScreen()),
            (r) => false);
      case AppSidebarItem.projects:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const ProjectsScreen()));
      case AppSidebarItem.memory:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const MemoryScreen()));
      case AppSidebarItem.agenda:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const AgendaScreen()));
      case AppSidebarItem.miniApps:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const MiniAppsScreen()));
      case AppSidebarItem.profile:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
      case AppSidebarItem.settings:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SidebarShell(
      selected: AppSidebarItem.settings,
      onSelect: (item) => _switch(context, item),
      onOpenSession: (s) => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => ChatScreen(sessionId: s.id))),
      child: ListenableBuilder(
        listenable: UserStore.instance,
        builder: (context, _) {
          final user = UserStore.instance;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const PageHeader(
                      title: 'Planes',
                      subtitle:
                          'Elige el plan que se adapte a tu forma de trabajar.',
                    ),
                    const SizedBox(height: 24),
                    if (user.plan == UserPlan.creditos) ...[
                      BalanceBar(user: user),
                      const SizedBox(height: 24),
                    ],
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cards = _plans
                            .map((p) => _PlanCard(
                                  plan: p.plan,
                                  name: p.name,
                                  price: p.price,
                                  benefits: p.benefits,
                                  current: user.plan == p.plan,
                                  onChoose: () {
                                    if (user.plan != p.plan) {
                                      user.setPlan(p.plan);
                                      _snack(context,
                                          'Plan ${p.name} activado');
                                    }
                                  },
                                ))
                            .toList();
                        if (constraints.maxWidth >= 720) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var i = 0; i < cards.length; i++) ...[
                                Expanded(child: cards[i]),
                                if (i < cards.length - 1)
                                  const SizedBox(width: 16),
                              ],
                            ],
                          );
                        }
                        return Column(
                          children: [
                            for (var i = 0; i < cards.length; i++) ...[
                              cards[i],
                              if (i < cards.length - 1)
                                const SizedBox(height: 16),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        backgroundColor: ThemeScope.of(context).surfaceContainerHigh,
        content: Text(text,
            style: kBodyMd.copyWith(color: ThemeScope.of(context).onSurface)),
      ));
  }
}

class _PlanCard extends StatelessWidget {
  final UserPlan plan;
  final String name;
  final int price;
  final List<String> benefits;
  final bool current;
  final VoidCallback onChoose;

  const _PlanCard({
    required this.plan,
    required this.name,
    required this.price,
    required this.benefits,
    required this.current,
    required this.onChoose,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return AppCard(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: current
              ? Border.all(color: BrandColors.cobalt, width: 1.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(name,
                    style: kHeadlineMd.copyWith(
                        color: c.onSurface, fontWeight: FontWeight.w600)),
                if (current) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: BrandColors.cobalt,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('Actual',
                        style: kLabelMd.copyWith(
                            fontSize: 10, color: Colors.white)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(price == 0
                ? 'Sin costo'
                : 'US\$$price / mes',
                style: kHeadlineLg.copyWith(
                    color: BrandColors.cobalt,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            for (final b in benefits)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check,
                        size: 16, color: BrandColors.cobalt),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(b,
                          style: kBodyMd.copyWith(
                              fontSize: 13, color: c.onSurfaceVariant)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: current ? null : onChoose,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: current
                          ? c.surfaceContainerHigh
                          : BrandColors.cobalt,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                        current ? 'Plan actual' : 'Elegir $name',
                        style: kLabelMd.copyWith(
                            color: current ? c.onSurfaceVariant : Colors.white)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Barra de saldo para el plan Créditos: saldo disponible, tope suave por
/// modelo y estado de congelación (SPEC §10).
class BalanceBar extends StatelessWidget {
  final UserStore user;

  const BalanceBar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    final ratio = (user.creditBalance / user.creditSoftCap).clamp(0.0, 1.0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: user.creditFrozen
            ? c.error.withValues(alpha: 0.12)
            : c.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: user.creditFrozen
                ? c.error.withValues(alpha: 0.4)
                : c.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  size: 18, color: BrandColors.cobalt),
              const SizedBox(width: 8),
              Text('Saldo disponible',
                  style: kBodyMd.copyWith(
                      color: c.onSurface, fontWeight: FontWeight.w500)),
              const Spacer(),
              Text('US\$${user.creditBalance.toStringAsFixed(2)}',
                  style: kHeadlineMd.copyWith(
                      color: BrandColors.cobalt,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              color: BrandColors.cobalt,
              backgroundColor: c.surfaceContainerHigh,
            ),
          ),
          const SizedBox(height: 8),
          Text(
              'Tope suave por modelo: US\$${user.creditSoftCap.toStringAsFixed(0)} '
              '${user.creditFrozen ? '· Estado: congelado' : '· Estado: activo'}',
              style: kLabelMd.copyWith(fontSize: 11, color: BrandColors.gris)),
        ],
      ),
    );
  }
}