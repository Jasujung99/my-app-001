// lib/services/auth_service.dart

import 'package/flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 임포트

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore 인스턴스

  User? _user;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get currentUser => _user;
  bool get isLoggedIn => _user != null;

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;

      if (_user != null) {
        // -- 사용자 문서 생성 로직 추가 --
        final userDocRef = _firestore.collection('users').doc(_user!.uid);
        await userDocRef.set({
          'uid': _user!.uid,
          'email': _user!.email,
          'displayName': _user!.displayName ?? _user!.email?.split('@').first,
          'points': 100, // 신규 가입 시 100 포인트 지급
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      notifyListeners();
      return _user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // 사용자가 창을 닫음

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      _user = userCredential.user;

      if (_user != null) {
        // -- 사용자 문서 생성 로직 추가 --
        final userDocRef = _firestore.collection('users').doc(_user!.uid);
        final docSnapshot = await userDocRef.get();

        if (!docSnapshot.exists) {
          // 문서가 없으면 새로 생성 (신규 유저)
          await userDocRef.set({
            'uid': _user!.uid,
            'email': _user!.email,
            'displayName': _user!.displayName ?? _user!.email?.split('@').first,
            'points': 100, // 신규 가입 시 100 포인트 지급
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      notifyListeners();
      return _user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
