import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class FileUpload {
  static Future<void> uploadFile() async {
    try {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: false,
        );

        if (result != null) {
          File file = File(result.files.single.path!);

          try {
            // Initialize Firebase Storage
            final Reference storageRef =
            FirebaseStorage.instance.ref().child('uploads/${file.uri.pathSegments.last}');

            // Upload the file to Firebase Storage
            await storageRef.putFile(file);

            print('File uploaded to Firebase Storage');
          } catch (e) {
            print('Error during file upload: $e');
          }
        } else {
          // User canceled the file picker.
        }
      } else {
        // Permission denied.
        print('Permission denied to access external storagesss');
      }
    } catch (e) {
      print('Error during file upload: $e');
    }
  }
}
