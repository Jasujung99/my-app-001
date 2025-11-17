// lib/screens/home_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/meeting.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/widgets/interactive_card.dart';
import 'package:myapp/widgets/main_bottom_nav.dart';
import 'package:myapp/widgets/status_pill.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final FirestoreService _firestoreService = FirestoreService();

  String _formatMeetingDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final formatter = DateFormat('M월 d일(E) a h:mm', 'ko');
    return formatter.format(date);
  }

  String _statusLabel(Meeting meeting) {
    final now = DateTime.now();
    final meetingDate = meeting.meetingTime.toDate();
    if (now.isAfter(meetingDate)) return '종료';
    if (meetingDate.difference(now).inHours <= 2) return '임박';
    return '예정';
  }

  PillType _statusType(Meeting meeting) {
    final label = _statusLabel(meeting);
    if (label == '임박') return PillType.alert;
    if (label == '종료') return PillType.inactive;
    return PillType.primary;
  }

  String _locationLabel(MeetingLocationType type) {
    switch (type) {
      case MeetingLocationType.online:
        return '온라인';
      case MeetingLocationType.offline:
        return '오프라인';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.paper, AppColors.stardust],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
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
                  title: Text('도시독', style: textTheme.titleMedium),
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
                        Text('책 모임 커뮤니티', style: textTheme.titleSmall),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => context.go('/create-br'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                              child: const Text('지식 제작'),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () => context.go('/create-meeting'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.terracotta),
                                foregroundColor: AppColors.terracotta,
                              ),
                              child: const Text('모임 만들기'),
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
                  sliver: StreamBuilder<List<Meeting>>(
                    stream: _firestoreService.watchMeetings(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Text('모임 목록을 불러오지 못했습니다.', style: textTheme.bodyMedium),
                          ),
                        );
                      }

                      final meetings = snapshot.data ?? [];
                      if (meetings.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('아직 모집 중인 모임이 없어요.', style: textTheme.titleSmall),
                                  const SizedBox(height: 8),
                                  Text('첫 모임을 열어보세요.', style: textTheme.bodySmall),
                                  const SizedBox(height: 12),
                                  OutlinedButton(
                                    onPressed: () => context.go('/create-meeting'),
                                    child: const Text('모임 만들기'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final meeting = meetings[index];
                            final participants = meeting.memberIds.length;
                            final statusLabel = _statusLabel(meeting);
                            final statusType = _statusType(meeting);
                            return InteractiveCard(
                              margin: const EdgeInsets.only(bottom: 12),
                              onTap: () => context.go('/meetings/${meeting.id}'),
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
                                            meeting.title,
                                            style: textTheme.titleLarge,
                                          ),
                                        ),
                                        StatusPill(label: statusLabel, type: statusType),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.schedule, size: 16, color: AppColors.accent),
                                        const SizedBox(width: 6),
                                        Text(_formatMeetingDate(meeting.meetingTime), style: textTheme.bodySmall),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        Chip(
                                          avatar: Icon(
                                            meeting.locationType == MeetingLocationType.online
                                                ? Icons.videocam
                                                : Icons.store_mall_directory_outlined,
                                            size: 16,
                                          ),
                                          label: Text(_locationLabel(meeting.locationType)),
                                          backgroundColor: AppColors.grain,
                                        ),
                                        Chip(
                                          avatar: const Icon(Icons.people_alt, size: 16),
                                          label: Text('참여 $participants / ${meeting.maxMembers}명'),
                                          backgroundColor: AppColors.grain,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: meetings.length,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const MainBottomNav(current: MainTab.home),
    );
  }
}
