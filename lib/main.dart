import 'package:flutter/material.dart';
import 'package:logan_parser_flutter/ui/homepage.dart';
import 'package:oktoast/oktoast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 2-A: Wrap MaterialApp with OKToast.
  Widget buildWrapperApp() {
    return OKToast(
      // 2-A: wrap your app with OKToast
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(title: 'logan 解析工具（点击右下角+号选择解析文件）'),
      ),
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return buildWrapperApp();
  }
}
