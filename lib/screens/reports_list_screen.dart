import 'package:flutter/material.dart';

import '../api/app_exception.dart';
import '../auth/auth_session_service.dart';
import '../localization/app_localizations.dart';
import '../models/report.dart';
import '../repositories/reports_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/report_card.dart';
import '../widgets/status_filter_chips.dart';
import 'report_details_screen.dart';

class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({
    super.key,
    this.onLogoutRequested,
  });

  final Future<void> Function()? onLogoutRequested;

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  final _reportsRepository = ReportsRepository();
  final _authSessionService = const AuthSessionService();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final List<Report> _reports = [];
  final Set<String> _updatingStatusIds = <String>{};

  ReportStatusFilter _statusFilter = ReportStatusFilter.all;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  bool _isAdmin = false;
  int _page = 1;
  String? _errorMessage;

  static const int _perPage = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _bootstrap();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final isAdmin = await _authSessionService.isAdmin();
    if (!mounted) {
      return;
    }

    setState(() {
      _isAdmin = isAdmin;
    });

    if (!_isAdmin) {
      setState(() {
        _loading = false;
        _hasMore = false;
        _errorMessage = 'Admin login required';
      });
      return;
    }

    await _loadInitial();
  }

  Future<void> _loadInitial() async {
    if (!_isAdmin) {
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _page = 1;
      _hasMore = true;
      _reports.clear();
    });

    try {
      final reports = await _reportsRepository.fetchReportsPage(
        page: _page,
        perPage: _perPage,
        sortBy: 'created_at',
        sortDirection: 'desc',
        status: _isAdmin ? _selectedStatusValue : null,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _reports.addAll(reports);
        _hasMore = reports.length == _perPage;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = _readableError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (!_isAdmin || _loadingMore || !_hasMore || _loading) {
      return;
    }
    setState(() {
      _loadingMore = true;
      _errorMessage = null;
    });

    try {
      final nextPage = _page + 1;
      final reports = await _reportsRepository.fetchReportsPage(
        page: nextPage,
        perPage: _perPage,
        sortBy: 'created_at',
        sortDirection: 'desc',
        status: _isAdmin ? _selectedStatusValue : null,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _page = nextPage;
        _reports.addAll(reports);
        _hasMore = reports.length == _perPage;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = _readableError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingMore = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    await _loadInitial();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 180) {
      _loadMore();
    }
  }

  List<Report> get _filteredReports {
    final query = _searchController.text.trim().toLowerCase();
    return _reports.where((report) {
      if (_isAdmin) {
        final statusMatches = _statusFilter == ReportStatusFilter.all ||
            _statusFilter == _filterFromStatus(report.status);
        if (!statusMatches) {
          return false;
        }
      }

      if (query.isEmpty) {
        return true;
      }
      return report.title.toLowerCase().contains(query) ||
          report.description.toLowerCase().contains(query);
    }).toList();
  }

  String? get _selectedStatusValue {
    switch (_statusFilter) {
      case ReportStatusFilter.all:
        return null;
      case ReportStatusFilter.newReport:
        return 'new';
      case ReportStatusFilter.inProgress:
        return 'inProgress';
      case ReportStatusFilter.resolved:
        return 'resolved';
    }
  }

  ReportStatusFilter _filterFromStatus(String? status) {
    switch (status) {
      case 'resolved':
        return ReportStatusFilter.resolved;
      case 'inProgress':
        return ReportStatusFilter.inProgress;
      case 'new':
      default:
        return ReportStatusFilter.newReport;
    }
  }

  String _statusLabelFromValue(String? status) {
    switch (status) {
      case 'resolved':
        return 'Resolved';
      case 'inProgress':
        return 'In Progress';
      case 'new':
      default:
        return 'New';
    }
  }

  Future<void> _changeStatus(Report report, String nextStatus) async {
    if (_updatingStatusIds.contains(report.id)) {
      return;
    }

    setState(() {
      _updatingStatusIds.add(report.id);
    });

    try {
      final updated = await _reportsRepository.updateReportStatus(
        reportId: report.id,
        status: nextStatus,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        final index = _reports.indexWhere((item) => item.id == updated.id);
        if (index != -1) {
          _reports[index] = updated;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Status updated to ${_statusLabelFromValue(nextStatus)}')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_readableError(error))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingStatusIds.remove(report.id);
        });
      }
    }
  }

  String _readableError(Object error) {
    if (error is AppException) {
      final details = error.details;
      if (details == null || details.isEmpty) {
        return error.message;
      }
      if (details['errors'] is List) {
        final values =
            (details['errors'] as List).map((e) => e.toString()).join(', ');
        return '${error.message}: $values';
      }
      return '${error.message}: $details';
    }
    return error.toString();
  }

  Future<void> _openDetails(Report report) async {
    if (!_isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin login required')),
      );
      return;
    }

    if (!mounted) {
      return;
    }
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReportDetailsScreen(
          report: report,
          isAdmin: _isAdmin,
        ),
      ),
    );
    if (result == true && mounted) {
      _loadInitial();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final filteredReports = _filteredReports;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord admin'),
        actions: [
          if (widget.onLogoutRequested != null)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value != 'logout') {
                  return;
                }
                await widget.onLogoutRequested!();
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ],
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Search reports',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (_isAdmin)
                      StatusFilterChips(
                        selected: _statusFilter,
                        onSelected: (value) {
                          setState(() {
                            _statusFilter = value;
                          });
                          _loadInitial();
                        },
                      ),
                  ],
                ),
              ),
            ),
            if (_loading)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) => Padding(
                      padding: EdgeInsets.only(
                        bottom: index == 3 ? 0 : AppSpacing.md,
                      ),
                      child: const ReportCardSkeleton(),
                    ),
                    childCount: 4,
                  ),
                ),
              )
            else if (filteredReports.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: _errorMessage == null
                      ? Icons.inbox_outlined
                      : Icons.cloud_off_outlined,
                  title: _errorMessage == null
                      ? localizations.noReports
                      : 'Unable to load reports',
                  message: _errorMessage ?? localizations.noReportsHint,
                  actionLabel: _errorMessage == null ? null : 'Retry',
                  onAction: _errorMessage == null ? null : _loadInitial,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final report = filteredReports[index];
                      final status = report.status;
                      final updatingStatus =
                          _updatingStatusIds.contains(report.id);
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == filteredReports.length - 1
                              ? 0
                              : AppSpacing.md,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ReportCard(
                              report: report,
                              statusLabel: _statusLabelFromValue(status),
                              onTap: () => _openDetails(report),
                            ),
                            if (_isAdmin) const SizedBox(height: AppSpacing.xs),
                            if (_isAdmin)
                              Align(
                                alignment: Alignment.centerRight,
                                child: PopupMenuButton<String>(
                                  enabled: !updatingStatus,
                                  onSelected: (value) =>
                                      _changeStatus(report, value),
                                  itemBuilder: (context) => const [
                                    PopupMenuItem<String>(
                                      value: 'new',
                                      child: Text('Mark as New'),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'inProgress',
                                      child: Text('Mark as In Progress'),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'resolved',
                                      child: Text('Mark as Resolved'),
                                    ),
                                  ],
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (updatingStatus)
                                        const SizedBox(
                                          height: 14,
                                          width: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      if (updatingStatus)
                                        const SizedBox(width: AppSpacing.xs),
                                      const Text('Change status'),
                                      const SizedBox(width: AppSpacing.xs),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                    childCount: filteredReports.length,
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _loadingMore
                    ? const Center(child: CircularProgressIndicator())
                    : _hasMore
                        ? OutlinedButton(
                            onPressed: _loadMore,
                            child: const Text('Load more'),
                          )
                        : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
