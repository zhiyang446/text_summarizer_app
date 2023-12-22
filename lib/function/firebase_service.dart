import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? userId = user.uid;
        if (userId != null) {
          await FirebaseFirestore.instance.collection('users').doc(userId).collection('summarizer').add(userData);
        }
      }
    } catch (e) {
      print('Error storing data: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getHistoricalData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? userId = user.uid;
        if (userId != null) {
          // Get a reference to the 'summarizer' collection
          CollectionReference summarizerCollection = FirebaseFirestore.instance.collection('users').doc(userId).collection('summarizer');

          // Get all documents from the 'summarizer' collection
          QuerySnapshot<Object?> querySnapshot = await summarizerCollection.get();

          // Explicitly cast the querySnapshot to the correct type
          QuerySnapshot<Map<String, dynamic>> typedQuerySnapshot = querySnapshot as QuerySnapshot<Map<String, dynamic>>;

          // Extract historical data from the documents
          List<Map<String, dynamic>> historicalData = typedQuerySnapshot.docs
              .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.data()!)
              .toList();

          return historicalData;
        }
      }
      return [];
    } catch (e) {
      print('Error fetching historical data: $e');
      throw e;
    }
  }
}
