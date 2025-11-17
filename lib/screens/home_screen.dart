// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/services/auth_service.dart';

// 씨드 데이터 (임시)
const seedMeetings = [
  {
    "id": "1",
    "title": "카뮈 『이방인』",
    "date": "2025년 1월 20일 (월)",
    "time": "오후 8시",
    "status": "진행중",
    "participants": 8,
    "maxParticipants": 12,
  },
  {
    "id": "2",
    "title": "사피엔스 1-3부",
    "date": "2025년 1월 25일 (토)",
    "time": "오후 3시",
    "status": "모집중",
    "participants": 5,
    "maxParticipants": 10,
  },
  {
    "id": "3",
    "title": "1984 전체 토론",
    "date": "2025년 2월 1일 (토)",
    "time": "오후 7시",
    "status": "예정",
    "participants": 3,
    "maxParticipants": 8,
  }
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.paper,
              AppColors.stardust,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // 상단 앱바
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.white.withOpacity(0.9),
              leading: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(Icons.menu_book, color: AppColors.ink, size: 22),
              ),
              title: Text('삼시세독', style: textTheme.titleMedium),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.grain,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.person, size: 18, color: AppColors.ink),
                      onPressed: () {
                        final auth = context.read<AuthService>();
                        final user = auth.currentUser;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('로그인이 필요합니다.')),
                          );
                          context.go('/login');
                          return;
                        }
                        context.go('/profile/${user.uid}');
                      },
                    ),
                  ),
                ),
              ],
            ),

            // 영웅 섹션
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  children: [
                    // 별 아이콘
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.midnight.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 15,
                            left: 15,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.stardust,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 25,
                            right: 20,
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.stardust,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 30,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.stardust,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('사람이 중심인', style: textTheme.titleSmall),
                    Text('독서 커뮤니티', style: textTheme.titleSmall),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => context.go('/create-br'),
                          child: const Text('지금 시작'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text('둘러보기'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            // 모임 목록 헤더
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              sliver: SliverToBoxAdapter(
                child: Text('진행중인 모임', style: textTheme.titleMedium),
              ),
            ),

            // 모임 카드 목록
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final meeting = seedMeetings[index];
                    final statusColor = meeting['status'] == '진행중'
                        ? AppColors.grain
                        : meeting['status'] == '모집중'
                            ? const Color(0xFFD1FAE5)
                            : AppColors.stardust;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => context.go('/meetings/${meeting["id"]}'),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      meeting['title'] as String,
                                      style: textTheme.titleMedium,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      meeting['status'] as String,
                                      style: textTheme.labelMedium,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${meeting['date']} ${meeting['time']}',
                                style: textTheme.bodySmall,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.people_outline, size: 14, color: AppColors.accent),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${meeting['participants']}/${meeting['maxParticipants']}명',
                                    style: textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: seedMeetings.length,
                ),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_outlined), label: 'Review'),
          BottomNavigationBarItem(icon: Icon(Icons.military_tech_outlined), label: 'Honor'),
        ],
        currentIndex: 0,
        onTap: (index) {
          // TODO: 탭 이동 로직 구현
        },
      ),
    );
  }
}
