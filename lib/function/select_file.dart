import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';

class SelectFile {
  static bool isFileSelected = false;
  static String fileURL = '';

  static Future<void> pickFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.isNotEmpty) {
      String? filePath = result.files.single.path;
      if (filePath != null) {
        fileURL = filePath;
        isFileSelected = true;
      }
    } else {
      // The user canceled the file selection, so clear the selection
      fileURL = '';
      isFileSelected = false;
    }
  }

  static void deselectFile() {
    fileURL = '';
    isFileSelected = false;
  }
}

