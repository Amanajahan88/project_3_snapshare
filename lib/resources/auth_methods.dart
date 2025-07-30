// AuthMethods.dart
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_flutter/resources/storage_methods.dart';
import 'package:instagram_flutter/models/user.dart' as model;

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches the current logged-in user's details from Firestore.
  Future<model.User> getUserDetails() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw FirebaseAuthException(
        code: 'NO_CURRENT_USER',
        message: 'No user is currently signed in.',
      );
    }
    final snap = await _firestore.collection('users').doc(currentUser.uid).get();
    return model.User.fromSnap(snap);
  }

  /// Signs up a new user, uploads profile picture, and saves user data to Firestore.
  Future<String> signUpUser({
    required String username,
    required String email,
    required String password,
    required String bio,
    Uint8List? file,
  }) async {
    try {
      // Ensure all fields are provided
      if (username.isEmpty || email.isEmpty || password.isEmpty || bio.isEmpty || file==null) {
        return 'Please enter all the fields';
      }

      // Create user in Firebase Auth
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Upload profile picture
      final photoUrl = await StorageMethods().uploadImageToStorage(
        'profilePics',
        file!,
        false,
      );

      // Build user model
      final user = model.User(
        username: username,
        uid: cred.user!.uid,
        email: email,
        bio: bio,
        photoUrl: photoUrl, // "https://i.ibb.co.com/7xKtg74t/image.png",
        followers: [],
        following: [],
      );

      // Save to Firestore
      await _firestore.collection('users').doc(cred.user!.uid).set(user.toJason());
      return 'success';
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'An error occurred';
    } catch (err) {
      return err.toString();
    }
  }

  /// Logs in an existing user with email and password.
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Ensure both email and password fields are provided
      if (email.isEmpty || password.isEmpty) {
        return 'Please enter all the fields';
      }

      // Sign in
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'success';
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'An error occurred';
    } catch (err) {
      return err.toString();
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
