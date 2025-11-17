// lib/screens/meeting_detail_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/meeting.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:provider/provider.dart';

class MeetingDetailScreen extends StatefulWidget {
  const MeetingDetailScreen({super.key, required this.meetingId});

  final String meetingId;

  @override
  State<MeetingDetailScreen> createState() => _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends State<MeetingDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isActionLoading = false;

  String _formatMeetingDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final formatter = DateFormat('yyyy년 M월 d일(E) a h:mm', 'ko');
    return formatter.format(date);
  }

  String _friendlyCountdown(Timestamp timestamp) {
    final diff = timestamp.toDate().difference(DateTime.now());
    if (diff.isNegative) return '진행/종료됨';
    if (diff.inDays >= 1) return '${diff.inDays}일 남음';
    if (diff.inHours >= 1) {
      final minutes = diff.inMinutes % 60;
      return minutes > 0 ? '${diff.inHours}시간 ${minutes}분 남음' : '${diff.inHours}시간 남음';
    }
    return '${diff.inMinutes}분 남음';
  }

  String _meetingStatusLabel(Meeting meeting) {
    final now = DateTime.now();
    final meetingDate = meeting.meetingTime.toDate();
    if (now.isAfter(meetingDate)) return '종료';
    if (meetingDate.difference(now).inHours <= 2) return '임박';
    return '예정';
  }

  Color _meetingStatusColor(Meeting meeting) {
    switch (_meetingStatusLabel(meeting)) {
      case '종료':
        return Colors.grey.shade400;
      case '임박':
        return AppColors.accent;
      default:
        return AppColors.grain;
    }
  }

  String _locationTypeLabel(MeetingLocationType type) {
    switch (type) {
      case MeetingLocationType.online:
        return '온라인 진행';
      case MeetingLocationType.offline:
        return '오프라인 모임';
    }
  }

  double _participantRatio(int participants, int maxMembers) {
    if (maxMembers <= 0) return 0;
    return (participants / maxMembers).clamp(0, 1);
  }

  Widget _buildPill({
    required IconData icon,
    required String label,
    required TextTheme textTheme,
    Color background = Colors.white,
    Color iconColor = AppColors.midnight,
    Color textColor = AppColors.midnight,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(label, style: textTheme.bodySmall?.copyWith(color: textColor)),
        ],
      ),
    );
  }

  Widget _buildMapPreview(Meeting meeting, TextTheme textTheme) {
    final lat = meeting.latitude;
    final lng = meeting.longitude;
    final hasCoordinates = lat != null && lng != null;

    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: hasCoordinates
          ? const LinearGradient(
              colors: [AppColors.midnight, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
      color: hasCoordinates ? null : AppColors.paper,
      border: hasCoordinates ? null : Border.all(color: AppColors.grain),
    );

    return Container(
      height: 160,
      decoration: decoration,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: hasCoordinates ? () {} : null,
        child: Center(
          child: hasCoordinates
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map, color: Colors.white, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      '위도 ${lat.toStringAsFixed(5)}, 경도 ${lng.toStringAsFixed(5)}',
                      style: textTheme.bodyMedium?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '지도 미리보기 (베타)',
                      style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Google Places 자동 지도 미리보기가 준비되는 동안 위치 텍스트를 참고해주세요.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(
    Meeting meeting,
    int participants,
    TextTheme textTheme,
  ) {
    final statusLabel = _meetingStatusLabel(meeting);
    final statusColor = _meetingStatusColor(meeting);
    final remainingSeats = (meeting.maxMembers - participants).clamp(0, meeting.maxMembers);
    final isFull = remainingSeats == 0;
    final isNearFull = !isFull && _participantRatio(participants, meeting.maxMembers) >= 0.7;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.midnight, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.midnight.withOpacity(0.2),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu_book, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meeting.title,
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.schedule, color: Colors.white70, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          _formatMeetingDate(meeting.meetingTime),
                          style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusLabel == '종료' ? Icons.event_busy : Icons.timelapse,
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusLabel,
                      style: textTheme.bodySmall?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPill(
                icon: meeting.locationType == MeetingLocationType.online ? Icons.videocam : Icons.store,
                label: _locationTypeLabel(meeting.locationType),
                textTheme: textTheme,
                background: Colors.white.withOpacity(0.16),
                iconColor: Colors.white,
                textColor: Colors.white,
              ),
              _buildPill(
                icon: Icons.people_alt,
                label: '참여 $participants / ${meeting.maxMembers}명',
                textTheme: textTheme,
                background: Colors.white.withOpacity(0.16),
                iconColor: Colors.white,
                textColor: Colors.white,
              ),
              if (meeting.hasFacilitatorCard)
                _buildPill(
                  icon: Icons.library_books,
                  label: '진행 카드 준비',
                  textTheme: textTheme,
                  background: Colors.white.withOpacity(0.16),
                  iconColor: Colors.white,
                  textColor: Colors.white,
                ),
              if (isFull)
                _buildPill(
                  icon: Icons.check_circle,
                  label: '모집 마감',
                  textTheme: textTheme,
                  background: Colors.white.withOpacity(0.16),
                  iconColor: Colors.white,
                  textColor: Colors.white,
                )
              else if (isNearFull)
                _buildPill(
                  icon: Icons.flash_on,
                  label: '마감 임박',
                  textTheme: textTheme,
                  background: Colors.white.withOpacity(0.16),
                  iconColor: Colors.white,
                  textColor: Colors.white,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.place, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  meeting.placeName ?? _locationTypeLabel(meeting.locationType),
                  style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParticipationCard(
    Meeting meeting,
    int participants,
    TextTheme textTheme,
  ) {
    final ratio = _participantRatio(participants, meeting.maxMembers);
    final remainingSeats = (meeting.maxMembers - participants).clamp(0, meeting.maxMembers);
    final isFull = remainingSeats == 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('참여 현황', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$participants / ${meeting.maxMembers}명',
                    style: textTheme.headlineSmall?.copyWith(fontSize: 24, color: AppColors.midnight),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.grain.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isFull ? '모집 마감' : '$remainingSeats명 남음',
                    style: textTheme.bodySmall?.copyWith(color: AppColors.midnight),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: AppColors.grain.withOpacity(0.6),
                color: AppColors.midnight,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(isFull ? Icons.check_circle : Icons.bolt, size: 16, color: AppColors.accent),
                const SizedBox(width: 6),
                Text(
                  _friendlyCountdown(meeting.meetingTime),
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostCard(Meeting meeting, TextTheme textTheme) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.midnight,
          child: Text(
            meeting.hostName.isNotEmpty ? meeting.hostName[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(meeting.hostName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('주최자 UID: ${meeting.hostId}', style: textTheme.bodySmall),
            if (meeting.assignedOrganizerName != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text('담당 관리자: ${meeting.assignedOrganizerName}', style: textTheme.bodySmall),
              ),
          ],
        ),
        trailing: meeting.assignedOrganizerId != null
            ? Chip(
                avatar: const Icon(Icons.verified, size: 16),
                label: const Text('관리자 진행'),
                backgroundColor: AppColors.grain,
              )
            : null,
      ),
    );
  }

  Widget _buildLocationCard(Meeting meeting, TextTheme textTheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('주소 & 접근 가이드', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            if (meeting.placeName != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.place, size: 18, color: AppColors.midnight),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(meeting.placeName!, style: textTheme.titleMedium),
                  ),
                ],
              ),
            if (meeting.placeAddress != null) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 26.0),
                child: Text(meeting.placeAddress!, style: textTheme.bodyMedium),
              ),
            ],
            if (meeting.locationNote.isNotEmpty) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        meeting.locationNote,
                        style: textTheme.bodySmall?.copyWith(color: AppColors.ink),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            _buildMapPreview(meeting, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(Meeting meeting, TextTheme textTheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('모임 소개', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(meeting.description, style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Future<void> _handleJoinOrLeave({
    required Meeting meeting,
    required bool isMember,
    required bool isHost,
    required bool isFull,
    required bool isFinished,
  }) async {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    if (isFinished) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미 종료된 모임입니다.')),
      );
      return;
    }

    if (!isMember && isFull) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모집이 마감된 모임입니다.')),
      );
      return;
    }

    if (isMember && isHost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주최자는 참석 취소할 수 없습니다.')),
      );
      return;
    }

    setState(() => _isActionLoading = true);
    try {
      if (isMember) {
        await _firestoreService.leaveMeeting(meeting.id, user.uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('참여를 취소했습니다.')),
          );
        }
      } else {
        await _firestoreService.joinMeeting(meeting.id, user.uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('모임에 참여했습니다.')),
          );
        }
      }
    } catch (e) {
      final message = e.toString();
      String humanized = '요청을 처리하지 못했어요. 잠시 후 다시 시도해주세요.';
      if (message.contains('meeting_full')) {
        humanized = '모집 인원이 가득 찼습니다.';
      } else if (message.contains('meeting_not_found')) {
        humanized = '모임 정보를 찾을 수 없습니다.';
      } else if (message.contains('host_cannot_leave')) {
        humanized = '주최자는 참석 취소할 수 없습니다.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(humanized)));
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Widget _buildBottomActionBar({
    required Meeting meeting,
    required int participants,
    required TextTheme textTheme,
    required bool isMember,
    required bool isHost,
    required bool isLoggedIn,
    required bool isFull,
    required bool isFinished,
    required int remainingSeats,
  }) {
    final buttonLabel = isFinished
        ? '종료됨'
        : isFull && !isMember
            ? '마감됨'
            : isMember
                ? '참여 취소'
                : isLoggedIn
                    ? '참여하기'
                    : '로그인 필요';

    String helperText;
    if (!isLoggedIn) {
      helperText = '참여하려면 로그인해주세요';
    } else if (isFinished) {
      helperText = '모임이 종료되었습니다';
    } else if (isFull && !isMember) {
      helperText = '모집이 마감됐어요';
    } else if (isMember) {
      helperText = '내 자리가 확보되었습니다';
    } else {
      helperText = '$remainingSeats명 참여 가능';
    }

    final bool isDisabled = _isActionLoading || isFinished || (!isMember && isFull) || !isLoggedIn;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    helperText,
                    style: textTheme.bodySmall?.copyWith(color: AppColors.accent),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '현재 $participants / ${meeting.maxMembers}명',
                    style: textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: isDisabled
                    ? null
                    : () => _handleJoinOrLeave(
                          meeting: meeting,
                          isMember: isMember,
                          isHost: isHost,
                          isFull: isFull,
                          isFinished: isFinished,
                        ),
                child: _isActionLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text('모임 상세', style: textTheme.titleMedium),
      ),
      body: StreamBuilder<Meeting?>(
        stream: _firestoreService.watchMeeting(widget.meetingId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.event_busy, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text('모임 정보를 불러오지 못했습니다.', style: textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('관리자에게 문의해주세요.', style: textTheme.bodySmall),
                  ],
                ),
              ),
            );
          }

          final meeting = snapshot.data!;
          final participants = meeting.memberIds.length;
          final authService = context.read<AuthService>();
          final userId = authService.currentUser?.uid;
          final isLoggedIn = userId != null;
          final isMember = userId != null && meeting.memberIds.contains(userId);
          final isHost = userId != null && meeting.hostId == userId;
          final remainingSeats = (meeting.maxMembers - participants).clamp(0, meeting.maxMembers);
          final isFull = remainingSeats == 0;
          final isFinished = _meetingStatusLabel(meeting) == '종료';

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _buildHeroHeader(meeting, participants, textTheme),
                    const SizedBox(height: 16),
                    _buildParticipationCard(meeting, participants, textTheme),
                    const SizedBox(height: 16),
                    _buildLocationCard(meeting, textTheme),
                    const SizedBox(height: 16),
                    _buildHostCard(meeting, textTheme),
                    const SizedBox(height: 16),
                    _buildDescriptionCard(meeting, textTheme),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              _buildBottomActionBar(
                meeting: meeting,
                participants: participants,
                textTheme: textTheme,
                isMember: isMember,
                isHost: isHost,
                isLoggedIn: isLoggedIn,
                isFull: isFull,
                isFinished: isFinished,
                remainingSeats: remainingSeats,
              ),
            ],
          );
        },
      ),
    );
  }
}
