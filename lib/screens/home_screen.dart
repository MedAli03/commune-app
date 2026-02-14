import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/home_action_card.dart';
import 'admin_gate_screen.dart';
import 'create_report_screen.dart';
import 'privacy_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.locale,
    required this.onLocaleChanged,
  });

  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final isArabic = widget.locale.languageCode == 'ar';
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppPalette.backgroundDark,
              Color(0xFF0C1A2E),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      widget.onLocaleChanged(
                        isArabic ? const Locale('en') : const Locale('ar'),
                      );
                    },
                    child: Text(
                      isArabic ? 'EN' : 'AR',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppPalette.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _HomeHeader(),
                        const SizedBox(height: AppSpacing.lg),
                        HomeActionCard(
                          icon: Icons.report_problem_rounded,
                          title: 'Signaler un problème',
                          subtitle: 'Photo, description, localisation',
                          variant: HomeActionCardVariant.primary,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CreateReportScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        HomeActionCard(
                          icon: Icons.admin_panel_settings_rounded,
                          title: 'Connexion Admin',
                          subtitle: 'Accès tableau de bord',
                          variant: HomeActionCardVariant.secondary,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AdminGateScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const _TipCard(),
                        const SizedBox(height: AppSpacing.xs),
                        _PrivacyRow(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const PrivacyScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text(
                    'SERVICE MUNICIPAL • VERSION 2.4.0',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.metaMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppPalette.surfaceAlt,
            borderRadius: AppRadii.lg,
            border: Border.all(color: AppPalette.outlineSoft),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.location_city_rounded,
                color: AppPalette.accentGreen,
                size: 36,
              ),
              Positioned.fill(
                child: Image.asset(
                  'assets/images/logomsaken.jpg',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Municipalité de Ville-en-Montagne',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppPalette.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Signaler un problème dans votre quartier',
          textAlign: TextAlign.center,
          style: AppTextStyles.subtitleGreen,
        ),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x152ACD3D),
        borderRadius: AppRadii.lg,
        border: Border.all(
          color: AppPalette.accentGreen.withValues(alpha: 0.35),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.tips_and_updates_outlined,
            color: AppPalette.accentGreen,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: AppPalette.textPrimary,
                  fontSize: 14,
                  height: 1.45,
                ),
                children: [
                  TextSpan(
                    text: 'Conseil : ',
                    style: TextStyle(
                      color: AppPalette.accentGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text:
                        'Ajoutez une photo pour accélérer le traitement de votre demande.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyRow extends StatelessWidget {
  const _PrivacyRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.md,
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(
              Icons.shield_outlined,
              color: AppPalette.accentGreen,
            ),
            SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                'Politique de confidentialité',
                style: TextStyle(
                  color: AppPalette.accentGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              size: 18,
              color: AppPalette.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
