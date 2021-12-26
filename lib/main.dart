import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pdf_scanner_algo/app.dart';
import 'package:path_provider/path_provider.dart' as path;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final directory = await path.getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  await Hive.openBox('pdfs');
   try {
    Hive.box('pdfs').getAt(0);
  } catch (e) {
    Hive.box('pdfs').add([]);
  }
  runApp(const App());
}
