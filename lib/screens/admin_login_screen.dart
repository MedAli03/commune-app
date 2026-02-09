import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../services/auth_service.dart';
import 'admin_shell.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _pinController = TextEditingController();
  final _authService = AuthService();
  String? _errorMessage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.adminLoginTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.adminLoginPrompt,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: localizations.adminPinLabel,
                errorText: _errorMessage,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _isSubmitting ? null : _handleLogin,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(localizations.adminLoginAction),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    final success =
        await _authService.loginWithPin(_pinController.text.trim());
    if (!mounted) {
      return;
    }
    if (!success) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = AppLocalizations.of(context).adminLoginError;
      });
      return;
    }
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AdminShell()),
    );
  }
}
