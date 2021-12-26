import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdf_scanner_algo/src/pages/edited_image_list_page.dart';
import 'package:pdf_scanner_algo/src/pages/home_page.dart';
import 'package:pdf_scanner_algo/src/pages/pdf_conversion_page.dart';
import 'package:pdf_scanner_algo/src/pages/pdf_preview_page.dart';
import 'package:pdf_scanner_algo/src/pages/picture_view_page.dart';
import 'package:pdf_scanner_algo/src/provider/image_list.dart';
import 'package:pdf_scanner_algo/src/utils/fade_in_route.dart';

typedef RouterMethod = PageRoute Function(RouteSettings, Map<String, String>);

/*
* Page builder methods
*/
final Map<String, RouterMethod> _definitions = {
  '/': (settings, _) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        return const HomePage();
      },
    );
  },
  // '/picture_view': (settings, _) {
  //   return MaterialPageRoute(
  //     settings: settings,
  //     builder: (context) {
  //       ImageList? imageList = settings.arguments as ImageList?;

  //       return PictureView(file: ,list: imageList );
  //     },
  //   );
  // },
};

Map<String, String>? _buildParams(String key, String name) {
  final uri = Uri.parse(key);
  final path = uri.pathSegments;
  final params = Map<String, String>.from(uri.queryParameters);

  final instance = Uri.parse(name).pathSegments;
  if (instance.length != path.length) {
    return null;
  }

  for (int i = 0; i < instance.length; ++i) {
    if (path[i] == '*') {
      break;
    } else if (path[i][0] == ':') {
      params[path[i].substring(1)] = instance[i];
    } else if (path[i] != instance[i]) {
      return null;
    }
  }
  return params;
}

Route buildRouter(RouteSettings settings) {
  print('VisitingPage: ${settings.name}');

  for (final entry in _definitions.entries) {
    final params = _buildParams(entry.key, settings.name!);
    if (params != null) {
      print('Visiting: ${entry.key} for ${settings.name}');
      return entry.value(settings, params);
    }
  }

  print('<!> Not recognized: ${settings.name}');
  return FadeInRoute(
    settings: settings,
    maintainState: false,
    builder: (_) {
      return Scaffold(
        body: Center(
          child: Text(
            '"${settings.name}"\nYou should not be here!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.grey[600],
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      );
    },
  );
}

void openPictureView(BuildContext context, File? file, ImageList? images) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PictureView(
        file: file!,
        list: images!,
      ),
    ),
  );
}

void openEditedPictureLists(BuildContext context, ImageList? images) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditedPictureList(
        imageList: images!,
      ),
    ),
  );
}

void opedPdfConversionPage(BuildContext context, ImageList? images) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PdfConversionPage(
        list: images!,
      ),
    ),
  );
}

void openPdfPreviewPage(BuildContext context, String name, String path) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PDFPreviewPage(
        name: name,
        path: path,
      ),
    ),
  );
}
