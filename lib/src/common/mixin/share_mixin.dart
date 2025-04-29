// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:fazt_order/src/common/utils/date_utils.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

mixin ShareMixin {
  Future<void> processAndSaveImage(
    Uint8List? image,
  ) async {
    if (image != null) {
      // Decode the Uint8List into an Image
      img.Image imgImage = img.decodeImage(image)!;

      // Get the document directory to save the processed image
      Directory directory = await getApplicationDocumentsDirectory();
      String filePath =
          '${directory.path}/Boat-Receipt-${DateTime.now().formatToReadableDateTime()}.png';

      // Save the processed image to a file
      File file = File(filePath);
      file.writeAsBytesSync(img.encodePng(imgImage));

      // Share the processed image using share_plus
      XFile xFile = XFile(file.path); // Convert the file path to XFile
      Share.shareXFiles([xFile]);
    }
  }
}
