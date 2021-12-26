import 'dart:io';
import 'dart:async';
import 'package:easy_folder_picker/FolderPicker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_scanner_algo/router.dart';
import 'package:pdf_scanner_algo/src/provider/image_list.dart';
import 'package:pdf_scanner_algo/src/utils/image_converter.dart'
    as image_converter;
import 'package:permission_handler/permission_handler.dart';

class PdfConversionPage extends StatefulWidget {
  final ImageList list;

  const PdfConversionPage({Key? key, required this.list}) : super(key: key);

  @override
  _PdfConverionPageState createState() => _PdfConverionPageState();
}

class _PdfConverionPageState extends State<PdfConversionPage> {
  String? name;
  final myController = TextEditingController();
  Directory? externalDirectory;
  Directory? pickedDirectory;

  @override
  void dispose() {
    super.dispose();
    myController.dispose();
  }

  final pw.Document pdf = pw.Document();
  void writeOnPdf() {
    for (var i = 0; i < widget.list.imagelist.length; i++) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.copyWith(
            marginTop: 0,
            marginBottom: 0,
            marginLeft: 0,
            marginRight: 0,
          ),
          build: (pw.Context context) {
            return pw.Expanded(
              child: pw.Image(
                pw.MemoryImage(
                    File(widget.list.imagepath[i]).readAsBytesSync()),
                fit: pw.BoxFit.contain,
              ),
            );
          },
        ),
      );
    }
  }

  Future<void> savePdf() async {
    // Get external storage directory
    final Directory? directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationSupportDirectory();
    //Get directory path
    final String? path = directory?.path;
    if (path == null) return;
    //Create an empty file to write PDF data
    final String filePath = '$path/$name.pdf';
    final File file = File(filePath);
    //Write PDF data
    //await file.writeAsBytes(bytes, flush: true);
    file.writeAsBytesSync(await pdf.save());
    //document.pdfPath = path;
    //Open the PDF document in mobile
    OpenFile.open(filePath);

    final List<dynamic> files = Hive.box('pdfs').getAt(0) as List<dynamic>;
    final now = DateTime.now();
    final String formatter = DateFormat('yMd').format(now);
    final String previewImage = image_converter
        .base64StringFromImage(widget.list.imagelist[0].readAsBytesSync());
    files.add([filePath, formatter, previewImage]);
    Hive.box('pdfs').putAt(0, files);
    print("PDFS : ${Hive.box('pdfs').getAt(0)}");

    // Clearing the image list once the PDF is created and saved
    for (int i = 0; i < widget.list.imagelist.length; i++) {
      print('i = $i');
      widget.list.imagelist.removeAt(i);
      widget.list.imagepath.removeAt(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Name Your PDF',
          style: TextStyle(
            fontSize: 22,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              await getPermissions();
              await getStorage();
              print("External : $externalDirectory");

              Directory? folderDir = await FolderPicker.pick(
                  allowFolderCreation: true,
                  context: context,
                  rootDirectory: externalDirectory!,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))));
              if (folderDir != null) {
                setState(() => pickedDirectory = folderDir);
              }
            },
            child: const Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Icon(Icons.folder_open),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: myController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Pdf Name',
                labelStyle: TextStyle(color: Colors.grey[500]),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide(width: 2, color: Colors.grey[500]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide(width: 2, color: Colors.grey[500]!),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FocusScope.of(context).unfocus();
          _pushSaved();
        },
        child: const Icon(Icons.arrow_forward, size: 40),
      ),
    );
  }

  Future<void> getPermissions() async {
    PermissionStatus permissions = await Permission.storage.status;
    var request = true;
    switch (permissions) {
      case PermissionStatus.granted:
        request = false;
        break;
      default:
    }
    if (request) {
      await Permission.storage.request();
    }
  }

  Future<void> getStorage() async {
    final directory = await getExternalStorageDirectory();
    setState(() => externalDirectory = directory);
  }

  Future<void> _pushSaved() async {
    name = Text(myController.text).data;

    //document.name = name;
    writeOnPdf();
    await savePdf();
    //Documents.add(document);
    Directory documentDirectory = await getApplicationDocumentsDirectory();

    if (pickedDirectory != null) documentDirectory = pickedDirectory!;

    final String documentPath = documentDirectory.path;
    //document.documentPath = documentPath;
    final String fullPath = '$documentPath/$name.pdf';
    print(fullPath);

    openPdfPreviewPage(context, fullPath, name ?? "Page Preview");
  }
}
