import 'package:flutter/material.dart';

import '../api/auth_api.dart';
import '../auth/auth_session_service.dart';
import 'admin_login_screen.dart';
import 'reports_list_screen.dart';

class AdminGateScreen extends StatefulWidget {
  const AdminGateScreen({super.key});

  @override
  State<AdminGateScreen> createState() => _AdminGateScreenState();
}

class _AdminGateScreenState extends State<AdminGateScreen> {
  final _authSessionService = const AuthSessionService();
  final _authApi = AuthApi();

  late Future<bool> _hasValidTokenFuture;

  @override
  void initState() {
    super.initState();
    _hasValidTokenFuture = _hasValidToken();
  }

  Future<bool> _hasValidToken() async {
    final token = await _authSessionService.readToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      await _authApi.me();
      await _authSessionService.saveRole('admin');
      return true;
    } catch (_) {
      await _authSessionService.clearSession();
      return false;
    }
  }

  Future<void> _logout() async {
    try {
      await _authApi.logout();
    } catch (_) {
      // Local token cleanup should still happen even if network call fails.
    } finally {
      await _authSessionService.clearSession();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _hasValidTokenFuture = Future<bool>.value(false);
    });
  }

  void _onLoginSuccess() {
    setState(() {
      _hasValidTokenFuture = Future<bool>.value(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasValidTokenFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final hasToken = snapshot.data ?? false;
        if (!hasToken) {
          return AdminLoginScreen(onLoginSuccess: _onLoginSuccess);
        }

        return ReportsListScreen(onLogoutRequested: _logout);
      },
    );
  }
}
