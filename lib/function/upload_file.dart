import 'package:file_picker/file_picker.dart';

class FileUpload {
  static Future<void> uploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        // You can access the selected file using file.name, file.bytes, etc.
        // Add your file handling logic here, e.g., upload the file to a server.
      } else {
        // User canceled the file picker.
      }
    } catch (e) {
      // Handle any errors that might occur during the file picking process.
    }
  }
}
