import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Politique de confidentialité'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vos données sont utilisées uniquement pour traiter les signalements municipaux.',
              style: TextStyle(
                color: AppPalette.textPrimary,
                height: 1.4,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Les informations partagées sont conservées selon la réglementation locale.',
              style: TextStyle(
                color: AppPalette.textMuted,
                height: 1.4,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Pour toute question, contactez le service municipal.',
              style: TextStyle(
                color: AppPalette.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
