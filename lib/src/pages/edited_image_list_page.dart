import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf_scanner_algo/router.dart';
import 'package:pdf_scanner_algo/src/cards/grid_list_card.dart';
import 'package:pdf_scanner_algo/src/cards/item_list.dart';
import 'package:pdf_scanner_algo/src/provider/image_list.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:flutter/services.dart';

class EditedPictureList extends StatefulWidget {
  final ImageList imageList;

  const EditedPictureList({Key? key, required this.imageList})
      : super(key: key);

  @override
  _EditedPictureListState createState() => _EditedPictureListState();
}

class _EditedPictureListState extends State<EditedPictureList> {
  List<Item>? itemList;
  List<Item>? selectedItemList;
  File? imageFile;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadList();
  }

  void loadList() {
    itemList = [];
    selectedItemList = [];
    for (int i = 0; i < (widget.imageList.length()); i++) {
      itemList?.add(Item(widget.imageList.imagelist.elementAt(i), i));
    }
  }

  // Future<void> openImageSourceOption(BuildContext context) {
  //   return showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           backgroundColor: Colors.blueGrey[800],
  //           title: const Text(
  //             "Add more pages with:",
  //             style: TextStyle(color: Colors.white),
  //           ),
  //           content: SingleChildScrollView(
  //             child: ListBody(
  //               children: <Widget>[
  //                 GestureDetector(
  //                   onTap: () {
  //                     Navigator.of(context).pop();
  //                     openGallery();
  //                   },
  //                   child: const Text(
  //                     "Gallery",
  //                     style: TextStyle(color: Colors.white),
  //                   ),
  //                 ),
  //                 const Padding(
  //                   padding: EdgeInsets.all(10),
  //                 ),
  //                 GestureDetector(
  //                   onTap: () {
  //                     Navigator.of(context).pop();
  //                     openCamera();
  //                   },
  //                   child: const Text(
  //                     "Camera",
  //                     style: TextStyle(color: Colors.white),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       });
  // }

  Future<void> addImages() async {
    String? imagePath;

    try {
      imagePath = (await EdgeDetection.detectEdge);
      print("$imagePath");
    } on PlatformException catch (e) {
      imagePath = e.toString();
    }
    final File tmpFile = File(imagePath!);
    if (!mounted) return;

    openPictureView(context, tmpFile, widget.imageList);
  }

  Future<void> openGallery() async {
    XFile? picture = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (picture != null) imageFile = File(picture.path);
    });
    openPictureView(context, imageFile, widget.imageList);
  }

  Future<void> openCamera() async {
    XFile? picture = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (picture != null) imageFile = File(picture.path);
    });

    if (imageFile != null) {
      GallerySaver.saveImage(imageFile!.path);
      openPictureView(context, imageFile, widget.imageList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (itemList!.isNotEmpty) {
          setState(() {
            widget.imageList.imagelist.removeAt(itemList!.length - 1);
            widget.imageList.imagepath.removeAt(itemList!.length - 1);
            itemList!.removeAt(itemList!.length - 1);
          });
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.blueGrey[100],
        appBar: AppBar(
          title: const Center(
            child: Text("PDF Scanner"),
          ),
        ),
        body: GridView.builder(
            itemCount: itemList!.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 4, mainAxisSpacing: 4),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(15),
                child: Card(
                  elevation: 10,
                  child: GridListCard(
                    item: itemList![index],
                    isSelected: (bool value) {
                      setState(() {
                        if (value) {
                          selectedItemList!.add(itemList![index]);
                        } else {
                          selectedItemList!.remove(itemList![index]);
                        }
                      });
                    },
                    key: Key(
                      itemList![index].rank.toString(),
                    ),
                  ),
                ),
              );
            }),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {},
              child: IconButton(
                iconSize: 40,
                onPressed: () {
                  // openImageSourceOption(context);
                  addImages();
                },
                icon: const Icon(
                  Icons.add,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            FloatingActionButton(
              onPressed: () {},
              child: IconButton(
                iconSize: 40,
                onPressed: () {
                  opedPdfConversionPage(context, widget.imageList);
                },
                icon: const Icon(
                  Icons.picture_as_pdf,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
