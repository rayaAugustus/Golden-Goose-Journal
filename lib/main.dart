import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/journal_provider.dart';
import 'providers/challenge_provider.dart';
import 'providers/dream_provider.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'pages/main_navigation.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化本地化
  await initializeDateFormatting('zh_CN', null);
  
  // 初始化数据库
  await DatabaseService.instance.database;
  
  // 初始化通知服务
  await NotificationService.instance.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProvider(create: (_) => ChallengeProvider()),
        ChangeNotifierProvider(create: (_) => DreamProvider()),
      ],
      child: MaterialApp(
        title: '金鹅日记',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const MainNavigation(),
      ),
    );
  }
}
