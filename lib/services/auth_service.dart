// lib/services/auth_service.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  AuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  late final StreamSubscription<User?> _authSubscription;

  User? _user;

  User? get currentUser => _user;
  bool get isLoggedIn => _user != null;

  Future<AuthResult> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = credential.user;
      return AuthResult(user: credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(errorMessage: _mapFirebaseAuthError(e));
    } catch (_) {
      return const AuthResult(
        errorMessage: '로그인 중 알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
      );
    }
  }

  Future<AuthResult> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;
      if (user == null) {
        return const AuthResult(
          errorMessage: '계정을 생성하지 못했습니다. 다시 시도해주세요.',
        );
      }

      try {
        final userDocRef = _firestore.collection('users').doc(user.uid);
        await userDocRef.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName ?? user.email?.split('@').first,
          'points': 100,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } on FirebaseException catch (e) {
        try {
          await user.delete();
        } catch (_) {
          // 사용자 삭제가 실패해도 다음 가입 시도가 가능하도록 계속 진행합니다.
        }
        return AuthResult(
          errorMessage:
              '계정 생성 후 프로필 저장에 실패했습니다: ${e.message ?? e.code}. 다시 시도해주세요.',
        );
      }

      _user = user;
      notifyListeners();
      return AuthResult(user: user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(errorMessage: _mapFirebaseAuthError(e));
    } catch (_) {
      return const AuthResult(
        errorMessage: '회원가입 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  String _mapFirebaseAuthError(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다. 다른 이메일을 입력해주세요.';
      case 'invalid-email':
        return '유효하지 않은 이메일입니다. 다시 입력해주세요.';
      case 'operation-not-allowed':
        return '현재 이메일/비밀번호 가입이 비활성화되어 있습니다. 관리자에게 문의해주세요.';
      case 'weak-password':
        return '비밀번호가 너무 약합니다. 6자 이상으로 설정해주세요.';
      case 'user-disabled':
        return '해당 계정은 사용 중지되었습니다.';
      case 'user-not-found':
      case 'wrong-password':
        return '이메일 또는 비밀번호가 올바르지 않습니다.';
      case 'network-request-failed':
        return '네트워크 오류가 발생했습니다. 연결을 확인해주세요.';
      case 'too-many-requests':
        return '짧은 시간에 너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.';
      default:
        return '요청을 처리하지 못했습니다 (${exception.code}). 잠시 후 다시 시도해주세요.';
    }
  }
}

class AuthResult {
  const AuthResult({this.user, this.errorMessage});

  final User? user;
  final String? errorMessage;

  bool get isSuccess => user != null;
}
