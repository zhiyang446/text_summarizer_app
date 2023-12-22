  import 'dart:io';
  import 'package:firebase_storage/firebase_storage.dart';

  class FileUploadResult {
    final String fileURL;
    final String fileName;

    FileUploadResult(this.fileURL,this.fileName);
  }

  class FileUpload {
    static Future<FileUploadResult?> uploadFileToBoth(File file) async {
      try {
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('pdfs/${file.uri.pathSegments.last}');

        UploadTask uploadTask = storageRef.putFile(file);

        await uploadTask.whenComplete(() {});

        String fileURL = await storageRef.getDownloadURL();

        return FileUploadResult(fileURL,file.uri.pathSegments.last);
      } catch (e) {
        print('Error during file upload: $e');
        throw e;
      }
    }
  }
