import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../localization/app_localizations.dart';
import '../models/report.dart';
import '../repositories/reports_repository.dart';
import '../storage/hive_boxes.dart';
import 'report_details_screen.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final _reportsRepository = ReportsRepository();
  final Set<String> _selectedIds = {};

  bool get _isSelectionMode => _selectedIds.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final box = Hive.box<Report>(reportsBoxName);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSelectionMode
              ? localizations.selectedCountLabel(_selectedIds.length)
              : localizations.adminReportsTitle,
        ),
        actions: _isSelectionMode
            ? [
                IconButton(
                  tooltip: localizations.selectAll,
                  icon: const Icon(Icons.select_all),
                  onPressed: () => _selectAll(box),
                ),
                IconButton(
                  tooltip: localizations.deleteSelected,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _confirmDeleteSelected,
                ),
                IconButton(
                  tooltip: localizations.deleteAll,
                  icon: const Icon(Icons.delete_forever_outlined),
                  onPressed: _confirmDeleteAll,
                ),
                IconButton(
                  tooltip: localizations.cancel,
                  icon: const Icon(Icons.close),
                  onPressed: _clearSelection,
                ),
              ]
            : [
                IconButton(
                  tooltip: localizations.deleteAll,
                  icon: const Icon(Icons.delete_forever_outlined),
                  onPressed: _confirmDeleteAll,
                ),
              ],
      ),
      body: ValueListenableBuilder<Box<Report>>(
        valueListenable: box.listenable(),
        builder: (context, reportsBox, _) {
          final reports = reportsBox.values.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    localizations.noReports,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localizations.noReportsHint,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: reports.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final report = reports[index];
              final isSelected = _selectedIds.contains(report.id);
              final hasPhoto = report.photoPath != null;
              final hasLocation =
                  report.latitude != null && report.longitude != null;
              return ListTile(
                selected: isSelected,
                title: Text(report.title),
                subtitle: Text(
                  '${localizations.createdAt}: ${_formatDate(report.createdAt)}',
                ),
                trailing: _isSelectionMode
                    ? Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            hasPhoto
                                ? localizations.photoStatusPresent
                                : localizations.photoStatusMissing,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hasLocation
                                ? localizations.locationStatusPresent
                                : localizations.locationStatusMissing,
                          ),
                        ],
                      ),
                onLongPress: () => _toggleSelection(report.id, true),
                onTap: () {
                  if (_isSelectionMode) {
                    _toggleSelection(report.id, false);
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ReportDetailsScreen(
                        report: report,
                        canDelete: true,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _toggleSelection(String reportId, bool forceSelect) {
    setState(() {
      if (_selectedIds.contains(reportId)) {
        if (!forceSelect) {
          _selectedIds.remove(reportId);
        }
      } else {
        _selectedIds.add(reportId);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
    });
  }

  void _selectAll(Box<Report> box) {
    setState(() {
      _selectedIds
        ..clear()
        ..addAll(box.values.map((report) => report.id));
    });
  }

  Future<void> _confirmDeleteSelected() async {
    if (_selectedIds.isEmpty) {
      return;
    }
    final localizations = AppLocalizations.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.confirmDeleteSelectedTitle),
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

    await _reportsRepository.deleteReports(_selectedIds.toList());
    _clearSelection();
  }

  Future<void> _confirmDeleteAll() async {
    final localizations = AppLocalizations.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.confirmDeleteAllTitle),
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

    await _reportsRepository.deleteAllReports();
    _clearSelection();
  }

  String _formatDate(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }
}
