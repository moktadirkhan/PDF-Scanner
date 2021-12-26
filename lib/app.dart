import 'package:flutter/material.dart';
import 'package:pdf_scanner_algo/router.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'PDF Scanner',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: buildRouter,
    );
  }
}
