import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Locale? _locale;

  void _setLocale(Locale locale) {
    if (locale == _locale) {
      return;
    }
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) {
          return const Locale('en');
        }
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return const Locale('en');
      },
      home: HomeScreen(
        locale: _locale ?? WidgetsBinding.instance.platformDispatcher.locale,
        onLocaleChanged: _setLocale,
      ),
    );
  }
}
