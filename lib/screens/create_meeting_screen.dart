// lib/screens/create_meeting_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/meeting.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/theme/app_theme.dart';

class CreateMeetingScreen extends StatefulWidget {
  const CreateMeetingScreen({super.key});

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationNoteController = TextEditingController();
  final _placeNameController = TextEditingController();
  final _placeAddressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _firestoreService = FirestoreService(); // 서비스 인스턴스

  double _maxMembers = 8;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  MeetingLocationType _locationType = MeetingLocationType.offline;
  bool _hasFacilitatorCard = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationNoteController.dispose();
    _placeNameController.dispose();
    _placeAddressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  // 모임 생성 로직 구현
  Future<void> _submitMeeting() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모임 날짜와 시간을 선택해주세요.')),
      );
      return;
    }

    if (_locationType == MeetingLocationType.offline && _placeNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오프라인 모임은 장소 이름을 입력해야 합니다.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      setState(() => _isLoading = false);
      return;
    }

    try {
      final meetingDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final organizerDisplayName = user.displayName ?? user.email!;
      double? _parseCoordinate(String value) {
        if (value.trim().isEmpty) return null;
        return double.tryParse(value.trim());
      }

      await _firestoreService.createMeeting(
        title: _titleController.text,
        description: _descriptionController.text,
        location: _locationNoteController.text,
        locationType: _locationType,
        placeName: _placeNameController.text.trim().isEmpty ? null : _placeNameController.text.trim(),
        placeAddress: _placeAddressController.text.trim().isEmpty ? null : _placeAddressController.text.trim(),
        latitude: _parseCoordinate(_latitudeController.text),
        longitude: _parseCoordinate(_longitudeController.text),
        hostId: user.uid,
        hostName: organizerDisplayName,
        assignedOrganizerId: user.uid,
        assignedOrganizerName: organizerDisplayName,
        maxMembers: _maxMembers.toInt(),
        meetingTime: meetingDateTime,
        hasFacilitatorCard: _hasFacilitatorCard,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('새로운 모임이 생성되었습니다!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('모임 생성에 실패했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = _selectedDate == null
        ? '날짜 선택'
        : '${_selectedDate!.year}.${_selectedDate!.month.toString().padLeft(2, '0')}.${_selectedDate!.day.toString().padLeft(2, '0')}';
    final timeLabel = _selectedTime == null
        ? '시간 선택'
        : _selectedTime!.format(context);

    return Scaffold(
      appBar: AppBar(title: const Text('모임 만들기')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '모임 제목',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty) ? '모임 제목을 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '모임 소개',
                  border: OutlineInputBorder(),
                ),
                minLines: 4,
                maxLines: 6,
                validator: (value) => (value == null || value.isEmpty) ? '소개 내용을 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),
              Text('진행 방식', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.grain.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SegmentedButton<MeetingLocationType>(
                  segments: const [
                    ButtonSegment(
                      value: MeetingLocationType.offline,
                      label: Text('오프라인'),
                      icon: Icon(Icons.storefront),
                    ),
                    ButtonSegment(
                      value: MeetingLocationType.online,
                      label: Text('온라인'),
                      icon: Icon(Icons.videocam),
                    ),
                  ],
                  selected: {_locationType},
                  onSelectionChanged: (selection) {
                    setState(() => _locationType = selection.first);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.midnight;
                      }
                      return Colors.transparent;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.white;
                      }
                      return AppColors.ink;
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_locationType == MeetingLocationType.offline) ...[
                TextFormField(
                  controller: _placeNameController,
                  decoration: const InputDecoration(
                    labelText: '장소 이름 (예: 연희문학살롱)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _placeAddressController,
                  decoration: const InputDecoration(
                    labelText: '주소 또는 상세 위치',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latitudeController,
                        decoration: const InputDecoration(
                          labelText: '위도 (lat)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _longitudeController,
                        decoration: const InputDecoration(
                          labelText: '경도 (lng)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _locationNoteController,
                decoration: InputDecoration(
                  labelText: _locationType == MeetingLocationType.online ? '링크/접속 가이드' : '추가 안내 (층수, 비밀번호 등)',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty) ? '장소 안내를 입력해주세요.' : null,
              ),
              const SizedBox(height: 24),
              Text('일정', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month),
                      label: Text(dateLabel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(timeLabel),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('최대 인원 (${_maxMembers.toInt()}명)', style: theme.textTheme.titleMedium),
              Slider(
                min: 4,
                max: 20,
                divisions: 16,
                value: _maxMembers,
                label: _maxMembers.toInt().toString(),
                onChanged: (value) => setState(() => _maxMembers = value),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.grain.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SwitchListTile(
                  value: _hasFacilitatorCard,
                  onChanged: (value) => setState(() => _hasFacilitatorCard = value),
                  title: Text('진행 카드/큐카드 준비됨', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text('토론 가이드를 준비한 관리자 카드 여부', style: theme.textTheme.bodySmall),
                  activeColor: AppColors.midnight,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitMeeting,
                        child: const Text('모임 생성하기'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
