import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:smart_queue_app/screens/auth/login_screen.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // REGISTER
  Future<UserModel?> register(String email, String password, String role) async {
    try {
      UserCredential result =
          await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      // Save role in Firestore
      await _firestore.collection('users').doc(user!.uid).set({
        'email': email,
        'role': role,
      });

      return UserModel(uid: user.uid, email: email, role: role);
    } catch (e) {
      print("Registration Error: $e");
      return null;
    }
  }

  // LOGIN
  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential result =
          await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      // Fetch role from Firestore
      DocumentSnapshot doc = await _firestore.collection('users').doc(user!.uid).get();
      String role = doc['role'];

      return UserModel(uid: user.uid, email: email, role: role);
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }
}
