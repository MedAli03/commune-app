import 'package:flutter/material.dart';

import '../api/app_exception.dart';
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
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final List<Report> _reports = [];

  ReportStatusFilter _statusFilter = ReportStatusFilter.all;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  String? _errorMessage;

  static const int _perPage = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
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
    if (_loadingMore || !_hasMore || _loading) {
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
      final status = _inferStatus(report);
      final statusMatches =
          _statusFilter == ReportStatusFilter.all || _statusFilter == status;
      if (!statusMatches) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }
      return report.title.toLowerCase().contains(query) ||
          report.description.toLowerCase().contains(query);
    }).toList();
  }

  ReportStatusFilter _inferStatus(Report report) {
    final normalizedTitle = report.title.toLowerCase();
    final normalizedDescription = report.description.toLowerCase();
    if (normalizedTitle.contains('resolved') ||
        normalizedTitle.contains('fixed') ||
        normalizedDescription.contains('resolved') ||
        normalizedDescription.contains('fixed')) {
      return ReportStatusFilter.resolved;
    }
    if (report.photoPath != null && report.photoPath!.isNotEmpty) {
      return ReportStatusFilter.inProgress;
    }
    return ReportStatusFilter.newReport;
  }

  String _statusLabel(ReportStatusFilter status) {
    switch (status) {
      case ReportStatusFilter.all:
        return 'All';
      case ReportStatusFilter.newReport:
        return 'New';
      case ReportStatusFilter.inProgress:
        return 'In Progress';
      case ReportStatusFilter.resolved:
        return 'Resolved';
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final filteredReports = _filteredReports;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.myReports),
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
                    StatusFilterChips(
                      selected: _statusFilter,
                      onSelected: (value) {
                        setState(() {
                          _statusFilter = value;
                        });
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
                      final status = _inferStatus(report);
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == filteredReports.length - 1
                              ? 0
                              : AppSpacing.md,
                        ),
                        child: ReportCard(
                          report: report,
                          statusLabel: _statusLabel(status),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ReportDetailsScreen(report: report),
                              ),
                            );
                          },
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
