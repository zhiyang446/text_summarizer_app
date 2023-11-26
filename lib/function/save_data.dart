import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:text_summarizer_app/function/select_file.dart';
import 'package:text_summarizer_app/function/firebase_service.dart';

class SaveData {
  static void saveUserData({
    required BuildContext context,
    required TextEditingController summaryController,
    required int selectedWordIndex,
    required int selectedModeIndex,
    required int selectedToneIndex,
  }) async {
    String summary = summaryController.text;
    List<String> word = ['150', '300', '500', '700', '1000'];
    List<String> mode = ['Rephrase', 'Shorten', 'Expand', 'Email', 'Summarize'];
    List<String> tone = ['Professional', 'Academic', 'Business', 'Friendly'];
    String selectedWord = selectedWordIndex >= 0 ? word[selectedWordIndex] : '';
    String selectedMode = selectedModeIndex >= 0 ? mode[selectedModeIndex] : '';
    String selectedTone = selectedToneIndex >= 0 ? tone[selectedToneIndex] : '';
    String fileURL = SelectFile.fileURL;

    if (fileURL.isNotEmpty && summary.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select either a file or enter text, not both.'),
      ));
      return;
    }

    FirebaseService firebaseService = FirebaseService();

    if (fileURL.isNotEmpty) {
      // Save file data
      Map<String, dynamic> userData = {
        'fileUrl': fileURL,
        'word': selectedWord,
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
        'word': selectedWord,
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
  }
}
