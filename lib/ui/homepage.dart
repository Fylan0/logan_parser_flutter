import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:logan_parser_flutter/utils/loganParser.dart';
import 'package:oktoast/oktoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _content = '请选择文件';

  Future<void> _incrementCounter() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    setState(() {
      _content = '解析中';
    });
    if (result != null) {
      File file = File(result.files.single.path!);

      String parserLog = await readFile(
          file, result.files.single.name, result.files.single.path!);
      setState(() {
        _content = parserLog;
      });
      showToast('file 选择成功,解析成功');
    } else {
      // User canceled the picker
      showToast('file 失败');
      setState(() {
        _content = 'canceled the picker';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white), // 设置文本颜色为白色
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Text(
            //   '',
            //   style: Theme.of(context).textTheme.headlineMedium,
            // ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10), // 离顶部10像素
                child: Container(
                  decoration: BoxDecoration(
                    // 淡灰色背景
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8), // 可选，为容器添加圆角
                  ),
                  padding: const EdgeInsets.all(10),
                  // 内边距10像素
                  height: double.infinity,
                  // 示例高度，根据实际情况调整
                  width: double.infinity,
                  // 宽度充满屏幕
                  child: SingleChildScrollView(
                    // 支持上下滑动
                    scrollDirection: Axis.vertical,
                    child: SelectableText(
                      _content,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
