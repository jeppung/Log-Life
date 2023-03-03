import 'package:life_log/pages/home_page.dart';
import 'package:life_log/pages/intro_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('log');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final box = Hive.box('log');

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: box.containsKey('user_name') ? const HomePage() : const IntroPage(),
    );
  }
}
