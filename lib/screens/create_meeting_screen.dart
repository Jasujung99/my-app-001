// lib/screens/create_meeting_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
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
  final _placeSearchController = TextEditingController();
  final _firestoreService = FirestoreService();

  String? _selectedPlaceId;
  String? _selectedPlaceName;
  String? _selectedPlaceAddress;
  double? _selectedLat;
  double? _selectedLng;

  double _maxMembers = 8;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  MeetingLocationType _locationType = MeetingLocationType.offline;
  bool _hasFacilitatorCard = true;
  bool _isLoading = false;

  static const String _placesApiKey = String.fromEnvironment('PLACES_API_KEY');

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationNoteController.dispose();
    _placeSearchController.dispose();
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
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submitMeeting() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모임 날짜와 시간을 선택해주세요.')),
      );
      return;
    }

    if (_locationType == MeetingLocationType.offline && _selectedPlaceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오프라인 모임은 장소를 검색해 선택해주세요.')),
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

      await _firestoreService.createMeeting(
        title: _titleController.text,
        description: _descriptionController.text,
        location: _locationNoteController.text,
        locationType: _locationType,
        placeId: _selectedPlaceId,
        placeName: _selectedPlaceName,
        placeAddress: _selectedPlaceAddress,
        latitude: _selectedLat,
        longitude: _selectedLng,
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
          const SnackBar(content: Text('새 모임이 생성되었어요.')),
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildPlaceAutocomplete() {
    if (_placesApiKey.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('장소 검색', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('PLACES_API_KEY가 설정되지 않았어요. --dart-define=PLACES_API_KEY=... 로 설정해주세요.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GooglePlaceAutoCompleteTextField(
          textEditingController: _placeSearchController,
          googleAPIKey: _placesApiKey,
          inputDecoration: const InputDecoration(
            labelText: '장소 검색',
            border: OutlineInputBorder(),
            hintText: '예) 서울시 강남구 카페',
          ),
          debounceTime: 400,
          countries: const ['kr'],
          isLatLngRequired: true,
          getPlaceDetailWithLatLng: (Prediction prediction) {
            _selectedPlaceId = prediction.placeId;
            _selectedPlaceName = prediction.description;
            _selectedPlaceAddress = prediction.structuredFormatting?.secondaryText ?? prediction.description;
            if (prediction.lat != null && prediction.lng != null) {
              _selectedLat = double.tryParse(prediction.lat!);
              _selectedLng = double.tryParse(prediction.lng!);
            }
            setState(() {});
          },
          itemClick: (Prediction prediction) {
            _placeSearchController.text = prediction.description ?? '';
          },
          itmClick: (Prediction prediction) {}, // legacy prop (no-op)
        ),
        const SizedBox(height: 12),
        if (_selectedPlaceName != null || _selectedPlaceAddress != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedPlaceName != null)
                Text(_selectedPlaceName!, style: Theme.of(context).textTheme.titleSmall),
              if (_selectedPlaceAddress != null)
                Text(_selectedPlaceAddress!, style: Theme.of(context).textTheme.bodySmall),
              if (_selectedLat != null && _selectedLng != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '위도 ${_selectedLat!.toStringAsFixed(5)}, 경도 ${_selectedLng!.toStringAsFixed(5)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = _selectedDate == null
        ? '날짜 선택'
        : '${_selectedDate!.year}.${_selectedDate!.month.toString().padLeft(2, '0')}.${_selectedDate!.day.toString().padLeft(2, '0')}';
    final timeLabel = _selectedTime == null ? '시간 선택' : _selectedTime!.format(context);

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
              SegmentedButton<MeetingLocationType>(
                segments: const [
                  ButtonSegment(value: MeetingLocationType.offline, label: Text('오프라인'), icon: Icon(Icons.storefront)),
                  ButtonSegment(value: MeetingLocationType.online, label: Text('온라인'), icon: Icon(Icons.videocam)),
                ],
                selected: {_locationType},
                onSelectionChanged: (selection) {
                  setState(() => _locationType = selection.first);
                },
              ),
              const SizedBox(height: 16),
              if (_locationType == MeetingLocationType.offline) ...[
                _buildPlaceAutocomplete(),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _locationNoteController,
                decoration: InputDecoration(
                  labelText: _locationType == MeetingLocationType.online ? '링크/접속 가이드' : '추가 안내 (층수, 비번 등)',
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
              SwitchListTile(
                value: _hasFacilitatorCard,
                onChanged: (value) => setState(() => _hasFacilitatorCard = value),
                title: const Text('진행 카드/북카드 준비됨'),
                subtitle: const Text('토론 가이드를 준비한 관리자 카드 여부'),
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
