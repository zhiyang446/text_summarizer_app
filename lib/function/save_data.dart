import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:text_summarizer_app/function/select_file.dart';
import 'package:text_summarizer_app/function/firebase_service.dart';
import 'package:text_summarizer_app/function/upload_file.dart';

class SaveData {
  static Future<void> saveUserData({
    required BuildContext context,
    required TextEditingController summaryController,
    required int selectedlanguageIndex,
    required int selectedModeIndex,
    required int selectedToneIndex,
    required FileUploadResult? fileUploadResult, // Add this parameter
  }) async {
    String summary = summaryController.text;
    List<String> language = [
      'English',
      'Chinese',
      'Korean',
      'German',
      'French',
      'Japanese'
    ];
    List<String> mode = [
      'Expository',
      'Third Person',
      'Present Tense',
      'Bullet Point',
      'Methodologies',
      'Implications'
    ];
    List<String> tone = [
      'Objective',
      'Formal',
      'Concise',
      'Descriptive',
      'Critical',
      'Informal'
    ];
    String selectedlanguage = selectedlanguageIndex >= 0
        ? language[selectedlanguageIndex]
        : '';
    String selectedMode = selectedModeIndex >= 0 ? mode[selectedModeIndex] : '';
    String selectedTone = selectedToneIndex >= 0 ? tone[selectedToneIndex] : '';

    try {
      String? fileURL = fileUploadResult?.fileURL;
      String? fileName = fileUploadResult?.fileName;

      FirebaseService firebaseService = FirebaseService();

      if (fileURL != null && fileURL.isNotEmpty) {
        // Save file data
        Map<String, dynamic> userData = {
          'fileUrl': fileURL,
          'fileName': fileName,
          'language': selectedlanguage,
          'mode': selectedMode,
          'tone': selectedTone,
          'timestamp': FieldValue.serverTimestamp(),
        };
        await firebaseService.saveUserData(userData);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('File data stored successfully.'),
        ));
      } else if (summary.isNotEmpty) {
        // Save text data
        Map<String, dynamic> userData = {
          'summary': summary,
          'language': selectedlanguage,
          'mode': selectedMode,
          'tone': selectedTone,
          'timestamp': FieldValue.serverTimestamp(),
        };
        await firebaseService.saveUserData(userData);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Text data stored successfully.'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter text or select a file to submit.'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error uploading file: $e'),
      ));
    }
  }
}