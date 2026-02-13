import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';
import 'admin_gate_screen.dart';
import 'create_report_screen.dart';

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
    final localizations = AppLocalizations.of(context);
    final isArabic = widget.locale.languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
        actions: [
          TextButton(
            onPressed: () {
              widget.onLocaleChanged(
                isArabic ? const Locale('en') : const Locale('ar'),
              );
            },
            child: Text(isArabic ? 'EN' : 'AR'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.appTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    localizations.noReportsHint,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateReportScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_note_outlined),
                label: Text(localizations.newReport),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminGateScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.dashboard_outlined),
                label: Text(localizations.myReports),
              ),
            ),
            const Spacer(),
            Text(
              'Anonymous reporting enabled',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Admin tools are available in the reports dashboard.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Language: ${isArabic ? 'Arabic' : 'English'}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
