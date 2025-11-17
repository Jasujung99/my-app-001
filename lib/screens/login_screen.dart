// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _validateRegisterFields = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _validateForm({required bool forRegister}) {
    _validateRegisterFields = forRegister;
    final isValid = _formKey.currentState?.validate() ?? false;
    if (forRegister) {
      _validateRegisterFields = false;
    }
    return isValid;
  }

  Future<void> _login() async {
    if (!_validateForm(forRegister: false)) return;

    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final result = await authService.signInWithEmailAndPassword(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (!result.isSuccess) {
      _showSnackBar(result.errorMessage ?? '로그인에 실패했습니다. 다시 시도해주세요.');
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _register() async {
    if (!_validateForm(forRegister: true)) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('비밀번호가 일치하지 않습니다.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final result = await authService.createUserWithEmailAndPassword(
      _emailController.text,
      _passwordController.text,
    );
    
    if (!mounted) return;

    if (!result.isSuccess) {
      _showSnackBar(
        result.errorMessage ?? '회원가입에 실패했습니다. 입력한 정보를 확인해주세요.',
      );
    } else {
      _showSnackBar('회원가입이 완료되었습니다! 자동으로 로그인됩니다.');
    }

    setState(() => _isLoading = false);
  }

  void _googleSignIn() {
    // TODO: Google 로그인 로직 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google 로그인은 현재 준비 중입니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'BookTalk City',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.oswald(fontSize: 48, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  '내 취향의 책으로, 우리 동네 사람들과.',
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  key: const ValueKey('login_email_field'),
                  decoration: const InputDecoration(labelText: '이메일', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || !value.contains('@')) ? '유효한 이메일을 입력해주세요.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  key: const ValueKey('login_password_field'),
                  decoration: const InputDecoration(labelText: '비밀번호', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) => (value == null || value.length < 6) ? '6자 이상의 비밀번호를 입력해주세요.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  key: const ValueKey('register_confirm_field'),
                  decoration: const InputDecoration(labelText: '비밀번호 확인', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) {
                    if (!_validateRegisterFields) return null;
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 한번 더 입력해주세요.';
                    }
                    if (value != _passwordController.text) {
                      return '비밀번호가 일치하지 않습니다.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text('로그인'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _register,
                    child: const Text('새로운 계정 만들기'),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('OR'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _googleSignIn,
                    icon: const Icon(Icons.g_mobiledata, size: 30),
                    label: const Text('Google로 로그인'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
