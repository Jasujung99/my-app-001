import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:provider/provider.dart';

void main() {
  Widget buildTestApp(AuthService authService) {
    return ChangeNotifierProvider<AuthService>.value(
      value: authService,
      child: const MaterialApp(home: LoginScreen()),
    );
  }

  testWidgets('회원가입 시 비밀번호가 일치하지 않으면 에러가 표시된다', (tester) async {
    final authService = _StubAuthService();

    await tester.pumpWidget(buildTestApp(authService));

    await tester.enterText(find.byKey(const ValueKey('login_email_field')), 'user@example.com');
    await tester.enterText(find.byKey(const ValueKey('login_password_field')), 'password123');
    await tester.enterText(find.byKey(const ValueKey('register_confirm_field')), 'different');

    await tester.tap(find.text('새로운 계정 만들기'));
    await tester.pump();

    expect(find.text('비밀번호가 일치하지 않습니다.'), findsOneWidget);
  });

  testWidgets('회원가입 실패 메시지가 스낵바로 노출된다', (tester) async {
    final authService = _StubAuthService()
      ..registerHandler = (_, __) => const AuthResult(
            errorMessage: '이미 가입된 이메일입니다.',
          );

    await tester.pumpWidget(buildTestApp(authService));

    await tester.enterText(find.byKey(const ValueKey('login_email_field')), 'user@example.com');
    await tester.enterText(find.byKey(const ValueKey('login_password_field')), 'password123');
    await tester.enterText(find.byKey(const ValueKey('register_confirm_field')), 'password123');

    await tester.tap(find.text('새로운 계정 만들기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('이미 가입된 이메일입니다.'), findsOneWidget);
  });

  testWidgets('회원가입 성공 시 완료 메시지를 보여준다', (tester) async {
    final authService = _StubAuthService()
      ..registerHandler = (_, __) => AuthResult(
            user: MockUser(email: 'user@example.com', uid: 'uid-123'),
          );

    await tester.pumpWidget(buildTestApp(authService));

    await tester.enterText(find.byKey(const ValueKey('login_email_field')), 'user@example.com');
    await tester.enterText(find.byKey(const ValueKey('login_password_field')), 'password123');
    await tester.enterText(find.byKey(const ValueKey('register_confirm_field')), 'password123');

    await tester.tap(find.text('새로운 계정 만들기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('회원가입이 완료되었습니다! 자동으로 로그인됩니다.'), findsOneWidget);
  });
}

class _StubAuthService extends AuthService {
  _StubAuthService()
      : super(
          firebaseAuth: MockFirebaseAuth(),
          firestore: FakeFirebaseFirestore(),
        );

  AuthResult Function(String email, String password)? loginHandler;
  AuthResult Function(String email, String password)? registerHandler;

  @override
  Future<AuthResult> signInWithEmailAndPassword(String email, String password) async {
    if (loginHandler != null) return loginHandler!(email, password);
    return const AuthResult(errorMessage: '로그인 실패 (stub)');
  }

  @override
  Future<AuthResult> createUserWithEmailAndPassword(String email, String password) async {
    if (registerHandler != null) return registerHandler!(email, password);
    return const AuthResult(errorMessage: '회원가입 실패 (stub)');
  }
}
