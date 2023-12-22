import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryResult {
  static Future<void> saveSummaryToHistory(String summarizerID, String generatedSummary) async {
    try {
      // Get a reference to the 'history' subcollection under the current 'summarizerID'
      CollectionReference historyCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('summarizer')
          .doc(summarizerID)
          .collection('history');

      // Save the generated summary to the 'history' collection
      await historyCollection.add({
        'summary': generatedSummary,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error storing data: $e');
      throw e;
    }
  }

  static Future<List<Map<String, dynamic>>> getHistoricalData(String summarizerID) async {
    try {
      // Get a reference to the 'history' subcollection under the current 'summarizerID'
      CollectionReference historyCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('summarizer')
          .doc(summarizerID)
          .collection('history');

      // Get all documents from the 'history' collection
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await historyCollection.get() as QuerySnapshot<Map<String, dynamic>>;

      // Extract historical data from the documents
      List<Map<String, dynamic>> historicalData = querySnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.data()!)
          .toList();

      return historicalData;
    } catch (e) {
      print('Error fetching historical data: $e');
      throw e;
    }
  }
}
