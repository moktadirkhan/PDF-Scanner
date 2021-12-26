import 'dart:async';
import 'dart:io';
import 'package:easy_folder_picker/FolderPicker.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf_scanner_algo/router.dart';
import 'package:pdf_scanner_algo/src/provider/image_list.dart';
import 'package:pdf_scanner_algo/src/utils/image_converter.dart'
    as image_converter;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool tablet = false;
  final picker = ImagePicker();
  ImageList images = ImageList();
  String? _imagePath;
  Future<void> getImage(ImageSource imageSource) async {
    final XFile? imageFile = await picker.pickImage(source: imageSource);

    if (imageFile == null) return;
    final File tmpFile = File(imageFile.path);

    if (imageSource == ImageSource.camera) {
      GallerySaver.saveImage(tmpFile.path)
          .then((value) => print("Image Saved"));
    }

    openPictureView(context, tmpFile, images);
  }

  Future<void> getImage2() async {
    String? imagePath;

    try {
      imagePath = (await EdgeDetection.detectEdge);
      print("$imagePath");
    } on PlatformException catch (e) {
      imagePath = e.toString();
    }
    final File tmpFile = File(imagePath!);
    if (!mounted) return;
    setState(() {
      _imagePath = imagePath;
    });
    openPictureView(context, tmpFile, images);
  }

  // Future<void> getImages(ImageSource imageSource) async {
  //   List<XFile>? imageFileList = [];

  //   imageFileList = await picker.pickMultiImage();
  //   if (imageFileList == null) return;
  //   List<File> tmpFiles;
  //   if (imageFileList.isNotEmpty) {
  //     imageFileList.addAll(imageFileList);
  //     for (var i = 0; i < imageFileList.length; i++) {
  //       tmpFiles =await imageFileList(File(imageFileList[i].path));
  //     }
  //   }

  //   if (imageSource == ImageSource.camera) {
  //     GallerySaver.saveImage(tmpFile.path)
  //         .then((value) => print("Images Saved"));
  //   }

  //   openPictureView(context, tmpFile, images);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("PDF Scanner"),
        ),
      ),
      body: Container(
        child: ValueListenableBuilder(
          valueListenable: Hive.box('pdfs').listenable(),
          builder: (context, Box<dynamic> pdfsBox, widget) {
            if (pdfsBox.getAt(0).length == 0) {
              return const Center(
                child: Text("No PDFs Scanned Yet !! "),
              );
            }
            return ListView.builder(
              itemCount: pdfsBox.getAt(0).length as int,
              itemBuilder: (context, index) {
                final Image previewImage = image_converter
                    .base64StringToImage(pdfsBox.getAt(0)[index][2] as String);
                return GestureDetector(
                  onTap: () async {
                    OpenFile.open(pdfsBox.getAt(0)[index][0] as String);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? MediaQuery.of(context).size.height / 2.5
                          : MediaQuery.of(context).size.height / 5,
                      child: Card(
                        elevation: 5,
                        color: Colors.white,
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 4,
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: previewImage),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        (pdfsBox.getAt(0)[index][0] as String)
                                            .split('/')
                                            .last,
                                        style: TextStyle(
                                            fontSize: tablet ? 30 : 20)),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                    child: Text('${pdfsBox.getAt(0)[index][1]}',
                                        style: TextStyle(
                                            fontSize: tablet ? 20 : 13)),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.grey,
                                          size: tablet ? 40.0 : 20.0,
                                        ),
                                        onPressed: () async {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext ctx) {
                                                return AlertDialog(
                                                  backgroundColor:
                                                      Colors.blueGrey[800],
                                                  title: const Text(
                                                    "Delete the File?",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  content:
                                                      SingleChildScrollView(
                                                    child: ListBody(
                                                      children: <Widget>[
                                                        GestureDetector(
                                                            onTap: () {
                                                              final File
                                                                  sourceFile =
                                                                  File(pdfsBox.getAt(
                                                                              0)[
                                                                          index][0]
                                                                      as String);
                                                              print(sourceFile
                                                                  .path);
                                                              sourceFile
                                                                  .delete();
                                                              // final List<dynamic>starredFiles =Hive.box('starred').getAt(0) as List<dynamic>;
                                                              setState(
                                                                () {
                                                                  pdfsBox
                                                                      .getAt(0)
                                                                      .removeAt(
                                                                          index);
                                                                  final List<
                                                                          dynamic>
                                                                      editedList =
                                                                      pdfsBox.getAt(
                                                                              0)
                                                                          as List<
                                                                              dynamic>;
                                                                  pdfsBox.putAt(
                                                                      0,
                                                                      editedList);
                                                                },
                                                              );
                                                              Navigator.of(ctx)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                              "Yes",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            )),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.of(ctx)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                            "No",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          getImage2();
        },
        label: const Text(
          "Scan",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        icon:const Icon(Icons.camera),
      
        // label: Row(
        //   mainAxisSize: MainAxisSize.min,
        //   children: <Widget>[
        //     IconButton(
        //       iconSize: 30,
        //       icon: const Icon(
        //         Icons.camera_alt,
        //       ),
        //       onPressed: () async {
        //         // getImage(ImageSource.camera);
        //         getImage2();
        //       },
        //     ),
        //     IconButton(
        //       iconSize: 30,
        //       icon: const Icon(
        //         Icons.image,
        //       ),
        //       onPressed: () {
        //         getImage(ImageSource.gallery);
        //       },
        //     )
        //   ],
        // ),
      ),
    );
  }
}
