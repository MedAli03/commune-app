import 'package:flutter/material.dart';

import 'admin_reports_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const AdminReportsScreen(),
    );
  }
}
