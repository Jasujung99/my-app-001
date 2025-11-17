// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/book_request.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/widgets/content_card.dart';

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
  void _navigateToDetail(BookRequest br) {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    context.go('/br/${br.id}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                final authService = context.read<AuthService>();
                await authService.signOut();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('로그아웃되었습니다.')),
                );
                context.go('/login');
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'logout',
                child: Text('로그아웃'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: FutureBuilder<List<BookRequest>>(
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
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            children: [
              // Type Hierarchy micro-label
              Text(
                'PROFILE',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 12),
              // ... 사용자 정보 섹션 ...
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.midnight,
                        child: const Icon(Icons.person, size: 32, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(authorName, style: theme.textTheme.titleLarge?.copyWith(height: 1.2)),
                          const SizedBox(height: 4),
                          Text('작성한 Book Request: ${userBRs.length}개', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.accent)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'MY BOOK REQUESTS',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 8),
              Text('작성한 목록', style: theme.textTheme.titleMedium?.copyWith(height: 1.2)),
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
        ),
      ),
    );
  }
}
