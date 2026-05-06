import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/dgt_theme.dart';
import 'core/constants/dgt_strings.dart';

/// Main app widget
class DGVApp extends ConsumerWidget {
  const DGVApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: DGTStrings.appName,
      theme: DGTTheme.lightTheme,
      darkTheme: DGTTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(
          child: Text(
            'Operación DGV - Core Infrastructure Ready',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
