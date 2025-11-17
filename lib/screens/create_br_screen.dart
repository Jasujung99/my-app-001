// lib/screens/create_br_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/book_request.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/widgets/status_pill.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateBRScreen extends StatefulWidget {
  const CreateBRScreen({super.key});

  @override
  State<CreateBRScreen> createState() => _CreateBRScreenState();
}

class _CreateBRScreenState extends State<CreateBRScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;
  double _cost = 10; // 기본 열람 비용

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitBookRequest() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 모두 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final newBR = BookRequest(
        id: '', // Firestore에서 자동 생성
        title: _titleController.text,
        content: _contentController.text,
        authorId: user.uid,
        authorName: user.email ?? 'Unknown',
        createdAt: Timestamp.now(),
        cost: _cost.toInt(),
      );
      await _firestoreService.addBookRequest(newBR);
      context.pop(); // 성공 시 이전 화면으로
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Book Request 등록에 실패했습니다: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Book Request 작성')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '제목', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: '내용', border: OutlineInputBorder()),
              maxLines: 10,
            ),
            const SizedBox(height: 24),

            // --- Cost 설정 슬라이더 추가 ---
            Text('열람 비용 설정 (Points)', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _cost,
                    min: 0,
                    max: 50,
                    divisions: 5,
                    label: _cost.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        _cost = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Text('${_cost.toInt()} P', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 32),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitBookRequest,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: theme.textTheme.titleMedium,
                    ),
                    child: const Text('등록하기'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
