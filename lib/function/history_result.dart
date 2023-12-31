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

  Future<List<Map<String, dynamic>>> getHistoricalData(String summarizerID) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userID = user.uid;

      CollectionReference historyCollection = FirebaseFirestore.instance
          .collection('users/$userID/summarizer/$summarizerID/history');

      try {
        QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await historyCollection.get() as QuerySnapshot<Map<String, dynamic>>;

        List<Map<String, dynamic>> historicalData = querySnapshot.docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => {
          'historyID': doc.id,
          'summary': doc.data()?['summary'],
          // Add other data as needed
        })
            .toList();

        return historicalData;
      } catch (e) {
        print('Error fetching historical data: $e');
        throw e;
      }
    } else {
      print('User is not authenticated.');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSummarizerData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userID = user.uid;

      CollectionReference summarizerCollection =
      FirebaseFirestore.instance.collection('users/$userID/summarizer');

      try {
        QuerySnapshot summarizers = await summarizerCollection.get();
        List<Map<String, dynamic>> summarizerData = summarizers.docs
            .map((QueryDocumentSnapshot summarizer) => {
          'summarizerID': summarizer.id,
          // Include other fields
        })
            .toList();
        return summarizerData;
      } catch (e) {
        print('Error fetching summarizer data: $e');
        throw e;
      }
    } else {
      print('User is not authenticated.');
      return [];
    }
  }
}
