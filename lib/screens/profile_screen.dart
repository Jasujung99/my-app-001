// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/book_request.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<BookRequest>> _userBRsFuture;

  @override
  void initState() {
    super.initState();
    _userBRsFuture = _firestoreService.getBookRequestsByUser(widget.userId);
  }

  // BR 상세 페이지로 이동하는 로직 (HomeScreen과 동일)
  Future<void> _navigateToDetail(BookRequest br) async {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;
    if (user == null) return;

    final success = await _firestoreService.spendPointsToReadBR(user.uid, br);

    if (mounted) {
      if (success) {
        context.go('/br/${br.id}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('포인트가 부족하여 열람할 수 없습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('프로필')),
      body: FutureBuilder<List<BookRequest>>(
        future: _userBRsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('정보를 불러오는 데 실패했습니다.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('작성한 Book Request가 없습니다.'));
          }

          final userBRs = snapshot.data!;
          final authorName = userBRs.first.authorName;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // ... 사용자 정보 섹션 ...
              Row(
                children: [
                  const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(authorName, style: theme.textTheme.headlineSmall),
                      Text('작성한 Book Request: ${userBRs.length}개', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ],
              ),
              const Divider(height: 48),

              Text('작성한 Book Request 목록', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userBRs.length,
                itemBuilder: (context, index) {
                  final br = userBRs[index];
                  return ContentCard(
                    title: br.title,
                    subtitle: '열람 비용: ${br.cost} P',
                    onTap: () => _navigateToDetail(br), // 수정된 네비게이션 로직 호출
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
