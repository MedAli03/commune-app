import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import 'create_report_screen.dart';
import 'reports_list_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  void _handleReportSaved() {
    setState(() {
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          CreateReportScreen(onSaved: _handleReportSaved),
          const ReportsListScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.note_add_outlined),
            label: localizations.newReport,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list_alt),
            label: localizations.myReports,
          ),
        ],
      ),
    );
  }
}
