import 'package:flutter/material.dart';

enum ReportStatusFilter {
  all,
  newReport,
  inProgress,
  resolved,
}

class StatusFilterChips extends StatelessWidget {
  const StatusFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ReportStatusFilter selected;
  final ValueChanged<ReportStatusFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final labels = <ReportStatusFilter, String>{
      ReportStatusFilter.all: 'All',
      ReportStatusFilter.newReport: 'New',
      ReportStatusFilter.inProgress: 'In Progress',
      ReportStatusFilter.resolved: 'Resolved',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ReportStatusFilter.values.map((filter) {
          final isSelected = selected == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(labels[filter] ?? filter.name),
              onSelected: (_) => onSelected(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}
