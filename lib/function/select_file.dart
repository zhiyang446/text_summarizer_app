import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';

class SelectFile {
  static bool isFileSelected = false;
  static String selectedFilePath = '';
  static File? selectedFile;

  static Future<FilePickerResult?> pickFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );

    if (result != null && result.files.isNotEmpty) {
      selectedFile = File(result.files.single.path!);
      selectedFilePath = selectedFile!.path;
      isFileSelected = true;
      return result;
    } else {
      selectedFilePath = '';
      isFileSelected = false;
      return null;
    }
  }

  static void deselectFile() {
    selectedFilePath = '';
    isFileSelected = false;
  }
}
