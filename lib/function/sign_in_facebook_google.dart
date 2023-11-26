import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<void> _storeUserDataInFirestore(User? user, String email, String username, String imageUrl) async {
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': email,
          'username': username,
          'imageUrl': imageUrl,
        });
        print('User data stored in Firestore.');
      } catch (e) {
        print('Error storing user data in Firestore: $e');
      }
    }
  }

  Future<void> _uploadProfileImage(User? user, Uint8List imageBytes) async {
    if (user != null) {
      try {
        final Reference storageRef = FirebaseStorage.instance.ref().child('profile_images/${user.uid}.jpg');
        await storageRef.putData(imageBytes);

        // Get the download URL of the uploaded image
        final String imageUrl = await storageRef.getDownloadURL();

        // Store the image URL along with other user data in Firestore
        await _storeUserDataInFirestore(user, user.email ?? '', user.displayName ?? '', imageUrl);
      } catch (e) {
        print('Error uploading profile image to Cloud Storage: $e');
      }
    }
  }

  Future<UserCredential?> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);
      UserCredential? userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Retrieve user data using FacebookAuth
      final userData = await FacebookAuth.instance.getUserData();

      // Store user data in Firestore and upload profile image after successful authentication
      await _storeUserDataInFirestore(
        userCredential.user,
        userCredential.user?.email ?? '',
        userCredential.user?.displayName ?? '',
        userData['picture']['data']['url'] ?? '', // Assuming the profile picture URL is available in the user data
      );

      await _uploadProfileImage(
        userCredential.user,
        await _downloadImage(userData['picture']['data']['url']),
      );

      return userCredential;
    }
    return null;
  }


  Future<UserCredential?> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

      if (googleSignInAccount == null) {
        print('Google Sign-In canceled by the user');
        return null;
      }

      GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      UserCredential? userCredential = await _auth.signInWithCredential(credential);

      // Store user data in Firestore and upload profile image after successful authentication
      await _storeUserDataInFirestore(userCredential.user, userCredential.user?.email ?? '', userCredential.user?.displayName ?? '', userCredential.user?.photoURL ?? '');
      await _uploadProfileImage(userCredential.user, await _downloadImage(userCredential.user?.photoURL));

      return userCredential;
    } catch (e) {
      print('Error during Google Sign-In: $e');
      return null;
    }
  }

  // Download image bytes from a URL
  Future<Uint8List> _downloadImage(String? imageUrl) async {
    if (imageUrl != null) {
      try {
        final HttpClientRequest request = await HttpClient().getUrl(Uri.parse(imageUrl));
        final HttpClientResponse response = await request.close();
        return Uint8List.fromList(await consolidateHttpClientResponseBytes(response));
      } catch (e) {
        print('Error downloading image: $e');
      }
    }
    return Uint8List(0);
  }

  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    } catch (e) {
      print('Error during email and password login: $e');
      return null;
    }
  }
}
