import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../models/report.dart';
import '../repositories/reports_repository.dart';
import 'report_details_screen.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final _reportsRepository = ReportsRepository();
  final Set<String> _selectedIds = {};
  List<Report> _reports = [];
  bool _isLoading = true;
  String? _errorMessage;

  bool get _isSelectionMode => _selectedIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

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
                  onPressed: _selectAll,
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
      body: RefreshIndicator(
        onRefresh: _loadReports,
        child: _buildBody(localizations),
      ),
    );
  }

  Widget _buildBody(AppLocalizations localizations) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _loadReports,
                child: Text(localizations.refresh),
              ),
            ],
          ),
        ),
      );
    }

    if (_reports.isEmpty) {
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
      itemCount: _reports.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final report = _reports[index];
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
          onTap: () async {
            if (_isSelectionMode) {
              _toggleSelection(report.id, false);
              return;
            }
            final deleted = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (context) => ReportDetailsScreen(
                  report: report,
                  canDelete: true,
                  onDeleted: _loadReports,
                ),
              ),
            );
            if (deleted == true && mounted) {
              await _loadReports();
            }
          },
        );
      },
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

  void _selectAll() {
    setState(() {
      _selectedIds
        ..clear()
        ..addAll(_reports.map((report) => report.id));
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

    await _deleteReports(_selectedIds.toList());
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

    await _deleteReports(_reports.map((report) => report.id).toList());
  }

  Future<void> _deleteReports(List<String> ids) async {
    if (ids.isEmpty) {
      return;
    }
    final localizations = AppLocalizations.of(context);
    try {
      for (final id in ids) {
        await _reportsRepository.deleteReportOnServer(id);
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.deleteSuccess)),
      );
      _clearSelection();
      await _loadReports();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${localizations.deleteFailed} $error')),
      );
    }
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final reports = await _reportsRepository.fetchReportsFromServer();
      if (!mounted) {
        return;
      }
      setState(() {
        _reports = reports..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = AppLocalizations.of(context).adminReportsLoadFailed;
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }
}
