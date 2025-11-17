// lib/screens/meeting_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/theme/app_theme.dart';

// 임시 데이터. 실제로는 라우터 파라미터로 받은 ID로 Firestore에서 조회해야 함.
const meetingDetailData = {
  "id": "1",
  "title": "카뮈 『이방인』",
  "date": "2025년 1월 20일 (월)",
  "time": "오후 8시",
  "status": "진행중",
  "participants": 8,
  "maxParticipants": 12,
  "hasCard": true,
  "questions": [
    "뫼르소는 왜 무감각한가?",
    "부조리의 의미는?",
    "어머니의 죽음에 대한 무관심의 의미"
  ],
};


class MeetingDetailScreen extends StatelessWidget {
  final String meetingId;

  const MeetingDetailScreen({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
        title: Text('모임 상세', style: textTheme.titleMedium),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 모임 정보 카드
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meetingDetailData['title'] as String, style: textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    '${meetingDetailData['date']} ${meetingDetailData['time']}',
                    style: textTheme.bodySmall?.copyWith(color: AppColors.ink.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Chip(
                        label: Text(meetingDetailData['status'] as String, style: textTheme.bodySmall?.copyWith(color: AppColors.ink)),
                        backgroundColor: AppColors.grain,
                        side: BorderSide.none,
                      ),
                      const SizedBox(width: 8),
                      Text('참여 ${meetingDetailData['participants']}명', style: textTheme.bodySmall),
                    ],
                  ),
                   if (meetingDetailData['hasCard'] as bool) ...[
                      const SizedBox(height: 12),
                      Row(children: [
                        CircleAvatar(radius: 8, backgroundColor: AppColors.midnight),
                        const SizedBox(width: 8),
                        Text('진행 카드 준비됨', style: textTheme.bodySmall?.copyWith(color: AppColors.ink))
                      ],)
                   ]
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 참여자
          Text('참여자', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              (meetingDetailData['participants'] as int).clamp(0, 4), 
              (index) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(radius: 16, backgroundColor: AppColors.accent.withOpacity(0.3)),
              )
            ),
          ),
          const SizedBox(height: 24),
          
          // 생각거리
          Text('생각거리', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (meetingDetailData['questions'] as List<String>).map((q) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text('• $q', style: textTheme.bodyMedium),
                  )
                ).toList(),
              ),
            ),
          ),
        ],
      ),
       bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {},
          child: const Text('모임 참여하기'),
        ),
      ),
    );
  }
}
