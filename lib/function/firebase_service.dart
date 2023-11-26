import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('user_data').add(userData);
    } catch (e) {
      print('Error storing data: $e');
      throw e;
    }
  }
}
