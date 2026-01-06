import 'package:flutter/material.dart';

import 'data/database.dart';
import 'ui/dashboard_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.open();
  runApp(const GoldenGooseJournalApp());
}

class GoldenGooseJournalApp extends StatelessWidget {
  const GoldenGooseJournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Golden Goose Journal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}
