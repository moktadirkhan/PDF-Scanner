import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PDFPreviewPage extends StatefulWidget {
  final String path;
  final String name;
  const PDFPreviewPage({Key? key, required this.path, required this.name})
      : super(key: key);

  @override
  _PDFPreviewPageState createState() => _PDFPreviewPageState();
}

class _PDFPreviewPageState extends State<PDFPreviewPage> {
  @override
  @override
  void initState() {
    super.initState();
    homePageTimer();
  }

  void homePageTimer() {
    Timer(const Duration(), () {
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pdf preview"),
      ),
      body: PdfPreview(
        canDebug: false,
        canChangeOrientation: false,
        canChangePageFormat: false,
        allowPrinting: false,
        allowSharing: false,
        pageFormats: const <String, PdfPageFormat>{
          'A4': PdfPageFormat.a4,
          'Letter': PdfPageFormat.letter,
          'A3': PdfPageFormat.a3,
          'A5': PdfPageFormat.a5,
          'Standard': PdfPageFormat.standard,
        },
        build: (PdfPageFormat format) {
          return File(widget.path).readAsBytes();
        },
      ),
    );
  }
}
