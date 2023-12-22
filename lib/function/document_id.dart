import 'dart:js';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../historyresult_screen.dart';

class DocumentIds {
  final String summarizerId;
  final String historyId;

  DocumentIds(this.summarizerId, this.historyId);
}

Future<Map<String, dynamic>> getHistoryData(String historyId) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not authenticated.');
    }

    String userId = user.uid;

    // Get a reference to the specific history document
    DocumentReference<Map<String, dynamic>> historyRef =
    FirebaseFirestore.instance.collection('users').doc(userId).collection('summarizer').doc().collection('history').doc(historyId);

    // Extract the summarizerID and historyID from the Firestore path
    DocumentIds documentIds = extractDocumentIds(historyRef);

    // Get and display data using summarizerID and historyID
    Map<String, dynamic> historyData = await fetchAndDisplayData(documentIds);


    Navigator.push(
      context as BuildContext,
      MaterialPageRoute(
        builder: (context) => HistoryResultPage(historyId: documentIds),
      ),
    );
    return historyData;
  } catch (e, stackTrace) {
    print('Error fetching history data: $e\n$stackTrace');
    rethrow;
  }
}

DocumentIds extractDocumentIds(DocumentReference documentRef) {
  String summarizerId = documentRef.parent!.parent!.id;
  String historyId = documentRef.id;
  return DocumentIds(summarizerId, historyId);
}

Future<Map<String, dynamic>> fetchAndDisplayData(DocumentIds documentIds) async {
  try {
    // Get a reference to the specific history document using summarizerID and historyID
    DocumentSnapshot<Map<String, dynamic>> historySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(documentIds.summarizerId)
        .collection('history')
        .doc(documentIds.historyId)
        .get();

    // Check if the document exists
    if (!historySnapshot.exists) {
      throw Exception('History document does not exist.');
    }

    // Return the data from the document
    return historySnapshot.data()!;
  } catch (e, stackTrace) {
    print('Error fetching and displaying data: $e\n$stackTrace');
    rethrow;
  }
}
