import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUp(String email, String password, String username) async {
    try {
      if (_isPasswordValid(password)) {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await _storeUserData(userCredential.user, email, username,password);

        return userCredential.user;
      } else {
        throw Exception("Invalid password format. It should have at least 1 uppercase, 1 lowercase, and 1 numeric character.");
      }
    } catch (e) {
      throw Exception("Sign up failed: $e");
    }
  }

  bool _isPasswordValid(String password) {
    final RegExp passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');
    return passwordRegex.hasMatch(password);
  }

  Future<void> _storeUserData(User? user, String email, String username,String password) async {
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': email,
          'username': username,
          'password': password,
          // Add more fields as needed
        });
      } catch (e) {
        print("Error storing user data: $e");
      }
    }
  }
}
