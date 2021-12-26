import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:pdf_scanner_algo/router.dart';
import 'package:pdf_scanner_algo/src/provider/image_list.dart';

class PictureView extends StatefulWidget {
  final File file;
  final ImageList list;
  const PictureView({Key? key, required this.file, required this.list})
      : super(key: key);

  @override
  _PictureViewState createState() => _PictureViewState();
}

class _PictureViewState extends State<PictureView> {
  File? cropped;
  List<File> files = [];
  int index = 0;

  @override
  void initState() {
    super.initState();
    files.add(widget.file);
  }

  Future<void> cropimage(File file) async {
    if (await file.exists()) {
      cropped = await ImageCropper.cropImage(
        sourcePath: file.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        compressQuality: 80,
        androidUiSettings: const AndroidUiSettings(
          statusBarColor: Colors.blue,
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          backgroundColor: Colors.black,
        ),
      );
      setState(() {
        if (cropped != null) {
          index++;
          files.add(cropped!);
        } else {}
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Image.file(
                  files[index],
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 65,
                color: Colors.blue[600],
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Opacity(
                        opacity: index == 0 ? 0.5 : 1,
                        child: TextButton(
                          onPressed: () {
                            if (index == 0) {
                              print("no undo possible");
                            } else {
                              setState(() {
                                index--;
                                files.removeLast();
                                print(widget.list.imagelist.length);
                              });
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const <Widget>[
                              Icon(
                                Icons.undo,
                                color: Colors.white,
                              ),
                              Text(
                                "Undo",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (files.isNotEmpty) {
                            cropimage(files[index]);
                          } else {
                            cropimage(widget.file);
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const <Widget>[
                            Icon(
                              Icons.crop_rotate,
                              color: Colors.white,
                            ),
                            Text(
                              "Crop",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (files.isNotEmpty) {
                            widget.list.imagelist.add(files[index]);
                            widget.list.imagepath.add(files[index].path);
                          } else {
                            widget.list.imagelist.add(widget.file);
                            widget.list.imagepath.add(widget.file.path);
                          }
                          openEditedPictureLists(context, widget.list);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const <Widget>[
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                            Text(
                              "Next",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
