import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:text_summarizer_app/function/history_result.dart';
import 'openai_sercive.dart';

class SummaryProcessor {
  Future<String> generateSummaryFromText({
    required String summary,
    required int selectedlanguageIndex,
    required int selectedModeIndex,
    required int selectedToneIndex,
    required List<Map<String, dynamic>> historicalData,
  }) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String? userId = user.uid;

        if (userId != null) {
          // Fetch user data from Firestore
          QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('summarizer')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            Map<String, dynamic> snapshotData = querySnapshot.docs.first.data()!;
            String mode = snapshotData['mode'] is String ? snapshotData['mode']! : '';
            String tone = snapshotData['tone'] is String ? snapshotData['tone']! : '';
            String language = snapshotData['language'] is String ? snapshotData['language']! : '';
            String summarizerID = querySnapshot.docs.first.id;

            // Log user data
            print('Mode: $mode');
            print('Tone: $tone');
            print('User-provided Summary: $summary');
            print('Language: $language');

            // Combine user data with the provided summary
            String combinedData =
                'Summarise the following text aim for a response between 100 and 200 words (Whatever the language.) so that it is easy to read and understand. The summary should be $mode and $tone the main point of the text. Avoid using complex sentence structures or technical jargon. Please begin by editing the following text and change to $language language: $summary';

            // Call OpenAIService to generate the final summary
            String generatedSummary = await OpenAIService.summarizeWithOpenAI(inputText: combinedData);

            // Save generated summary to history
            await HistoryResult.saveSummaryToHistory(summarizerID, generatedSummary);

            return generatedSummary;
          } else {
            throw Exception('Firestore document does not exist.');
          }
        }
      }

      throw Exception('Failed to fetch user data from Firestore');
    } catch (error) {
      print('Error: $error');
      throw Exception('Failed to process user data and generate summary');
    }
  }
}
