import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../models/report.dart';
import '../repositories/reports_repository.dart';
import '../utils/platform_image.dart';

class ReportDetailsScreen extends StatelessWidget {
  const ReportDetailsScreen({
    super.key,
    required this.report,
    this.canDelete = false,
  });

  final Report report;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.detailsTitle),
        actions: [
          if (canDelete)
            IconButton(
              tooltip: localizations.deleteAction,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoRow(label: localizations.titleLabel, value: report.title),
          _InfoRow(
            label: localizations.descriptionLabel,
            value: report.description,
          ),
          _InfoRow(
            label: localizations.createdAt,
            value: report.createdAt.toLocal().toString(),
          ),
          _InfoRow(
            label: localizations.locationLabel,
            value: report.latitude != null && report.longitude != null
                ? localizations.locationCaptured(
                    lat: report.latitude!.toStringAsFixed(6),
                    lng: report.longitude!.toStringAsFixed(6),
                  )
                : localizations.noLocation,
          ),
          const SizedBox(height: 16),
          Text(
            localizations.photoLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (report.photoPath != null &&
              platformFileExists(report.photoPath!))
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: buildPlatformImage(
                report.photoPath!,
                height: 200,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Center(
                child: Text(localizations.photoMissing),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.deleteAction),
        content: Text(localizations.confirmDeleteSelectedTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(localizations.deleteAction),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }

    await ReportsRepository().deleteReport(report.id);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
