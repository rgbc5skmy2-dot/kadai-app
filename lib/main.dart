import 'package:flutter/material.dart';
import 'screens/task_list_screen.dart';

void main() {
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

    // スマホサイズ（600px以下）はそのまま全画面
    if (width <= 600) {
      return const TaskListScreen();
    }

    // PC・タブレットはスマホサイズに制限して中央に表示
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