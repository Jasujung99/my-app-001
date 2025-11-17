// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/theme/app_theme.dart';

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
              backgroundColor: Colors.white.withOpacity(0.9),
              leading: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(Icons.menu_book, color: AppColors.ink),
              ),
              title: Text('삼시세독', style: textTheme.titleMedium),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.grain,
                    child: IconButton(
                      icon: const Icon(Icons.person, size: 16),
                      onPressed: () {
                        // TODO: 프로필 화면으로 이동
                      },
                    ),
                  ),
                ),
              ],
            ),

            // 영웅 섹션
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    Text('사람이 중심인', style: textTheme.titleMedium),
                    Text('독서 커뮤니티', style: textTheme.titleMedium),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('지금 시작'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.ink.withOpacity(0.2)),
                            foregroundColor: AppColors.ink,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                          ),
                          child: const Text('둘러보기'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            // 모임 목록
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text('진행중인 모임', style: textTheme.titleMedium),
                      );
                    }
                    final meeting = seedMeetings[index - 1];
                    final statusColor = meeting['status'] == '진행중'
                        ? AppColors.grain
                        : meeting['status'] == '모집중'
                            ? Colors.green.shade100
                            : AppColors.stardust;

                    return Card(
                      child: InkWell(
                        onTap: () => context.go('/meetings/${meeting["id"]}'),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(meeting['title'] as String, style: textTheme.titleMedium)),
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: Text(meeting['status'] as String, style: textTheme.bodySmall?.copyWith(color: AppColors.ink)),
                                    backgroundColor: statusColor,
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    side: BorderSide.none,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('${meeting['date']} ${meeting['time']}', style: textTheme.bodySmall),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.people_outline, size: 14, color: textTheme.bodySmall?.color),
                                  const SizedBox(width: 4),
                                  Text('${meeting['participants']}/${meeting['maxParticipants']}명', style: textTheme.bodySmall),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: seedMeetings.length + 1,
                ),
              ),
            ),
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
