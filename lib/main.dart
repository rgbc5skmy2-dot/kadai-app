import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/task_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja_JP', null); // 日本語ロケール初期化
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '課題管理アプリ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const ResponsiveWrapper(),
    );
  }
}

class ResponsiveWrapper extends StatelessWidget {
  const ResponsiveWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width <= 600) {
      return const TaskListScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE8EAF6),
      body: Center(
        child: SizedBox(
          width: 390,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: const TaskListScreen(),
          ),
        ),
      ),
    );
  }
}