import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:intl/intl.dart';
import 'package:pointycastle/export.dart';

Future<String> readFile(File file, String fileName, String path) async {
  String result='';
  try {
    // 打开文件为二进制流
    Stream<List<int>> inputStream = file.openRead();
    // 使用BytesBuilder来累积从流中读取的所有字节
    BytesBuilder builder = BytesBuilder();
    // 监听流的每一部分，并将其添加到BytesBuilder中
    await for (List<int> chunk in inputStream) {
      builder.add(chunk);
    }
    // 获取完整的字节列表
    List<int> content = builder.toBytes();

    String newFileName = "Good";

    try {
      int timestamp = int.parse(fileName); // 首先尝试将字符串解析为整数
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
          timestamp); // 将整数视为毫秒时间戳转换为DateTime
      final formatter = DateFormat('yyyy-MM-dd'); // 自定义日期时间格式
      newFileName = formatter.format(dateTime) + "_good";
      // 如果没有抛出异常，说明转换成功，即字符串是一个有效的时间戳
    } on FormatException {
      // 如果parseInt失败，说明字符串不是有效的整数
    } on ArgumentError {
      // 如果fromMillisecondsSinceEpoch失败，说明时间戳超出DateTime可表示范围
    }

    // final filePath = '${file.path}/$newFileName';

    int index = path.lastIndexOf('/'); // 获取最后一个'/'的位置
    // String filePath = index != -1 ? path.substring(0, index) : path;
    String filePath = '/Users/chenfeng/Desktop';

    //申请权限
    // requestFolderAccess(filePath);

    // File newFile = File('$filePath/$newFileName');
    // if (!await newFile.exists()) {
    //   // 如果文件不存在，则创建文件
    //   print('创建文件：$newFile');
    //   await newFile.create();
    // }
    // IOSink sink;
    try {
      // sink = newFile.openWrite(mode: FileMode.writeOnly);

      // loganParser(content, sink);
      result = await loganParserRString(content);
      print('Good Job: $result');
    } catch (e) {
      print('Error loganParser file: $e');
    } finally {
      // if(sink!=null) {
      //   sink.close();
      // }
    }

  } catch (e, stackTrace) {
    // 处理异常
    print('Error  file: $e');
    print('Error stackTrace: $stackTrace');
  } finally {}

  return result;
}

Future<String> loganParserRString(List<int> content) async {
  String result = "";
  try {
    // // 密钥（16字节）
    // final key = Uint8List.fromList("2024000987654321".codeUnits);
    // // IV（16字节）
    // final iv = Uint8List.fromList("2024000987654321".codeUnits);
    // // 初始化密钥和IV
    // final keySpec = KeyParameter(key);
    // final ivSpec = ParametersWithIV(keySpec, iv);
    // // 创建解密器
    // final cipher = CBCBlockCipher(AESFastEngine())
    //   ..init(false, ivSpec); // true=encrypt

    //解压
    final decoder = GZipDecoder();
    print('loganParserRString  content: ${content.toString()}');
    print('loganParserRString  content size: ${content.length}');
    //便利日志文件字节数组
    for (int i = 0; i < content.length; i++) {
      var start = content[i];
      // print('loganParserRString for:$i, start:${start}');
      if (start == 1) {
        // 在Dart中，'\1' 对应于字符1的ASCII值，因此直接比较int值即可
        i++; // 移动到长度的开始位置
        int length = (content[i] & 0xFF) << 24 |
        (content[i + 1] & 0xFF) << 16 |
        (content[i + 2] & 0xFF) << 8 |
        (content[i + 3] & 0xFF);
        i += 3; // 移动到数据的开始位置

        int type;
        if (length > 0) {
          int temp = i + length + 1;
          if (content.length - i - 1 == length) {
            //异常
            type = 0;
          } else if (content.length - i - 1 > length && content[temp] == 0) {
            type = 1;
          } else if (content.length - i - 1 > length && content[temp] == 1) {
            //异常
            type = 2;
          } else {
            i -= 4;
            continue;
          }

          Uint8List dest = Uint8List(length);
          dest.setRange(0, length, content, i + 1);
          print('loganParserRString for:$i, content size: ${content.length}');
          // 解密
          try {
            final decryptedBytes = Uint8List(dest.lengthInBytes);
            print('s---------s---------s---------s---------');
            print(
                'loganParserRString for:$i, 前解密decryptedBytes: ${dest
                    .toString()}');
            print('---------');

            final cipher = getCipher();
            var offset = 0;
            while (offset < dest.lengthInBytes) {
              offset +=
                  cipher.processBlock(dest, offset, decryptedBytes, offset);
            }

            print(
                'loganParserRString for:$i, 解密decryptedBytes: ${decryptedBytes
                    .toString()}');
            print('e---------e---------e---------e---------');
            //解压
            print(
                'loganParserRString for:$i, 解压uncompressByte: ${decryptedBytes
                    .toString()}');
            List<int> uncompressByte =
            decoder.decodeBytes(decryptedBytes, verify: true);


            //utf_8
            result += utf8.decode(uncompressByte);

            //gbk
            // result +=
            //     const GbkCodec(allowMalformed: true).decode(uncompressByte);
          } catch (e, t) {
            print('Error during decodeBytes: $e');
            print('Error decodeBytes t: $t');
          }

          i += length;
          if (type == 1) {
            i++;
          }
        }
      }
    }
  } catch (e, t) {
    print('Error during decompression: $e');
    print('Error t: $t');
  }

  return result;
}

CBCBlockCipher getCipher() {
  // 密钥（16字节）
  final key = Uint8List.fromList("2024000987654321".codeUnits);
  // IV（16字节）
  final iv = Uint8List.fromList("2024000987654321".codeUnits);
  // 初始化密钥和IV
  final keySpec = KeyParameter(key);
  final ivSpec = ParametersWithIV(keySpec, iv);
  // 创建解密器
  final cipher = CBCBlockCipher(AESFastEngine())
    ..init(false, ivSpec); // true=encrypt
  return cipher;
}
