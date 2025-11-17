// lib/models/meeting.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum MeetingLocationType { online, offline }

MeetingLocationType _meetingLocationTypeFromString(String? value) {
  if (value == null) return MeetingLocationType.offline;
  return MeetingLocationType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => MeetingLocationType.offline,
  );
}

class Meeting {
  final String id;
  final String title;
  final String description;
  final String locationNote;
  final MeetingLocationType locationType;
  final String hostId;
  final String hostName;
  final String? assignedOrganizerId;
  final String? assignedOrganizerName;
  final List<String> memberIds; // 참여자들의 uid 리스트
  final int maxMembers;
  final Timestamp meetingTime;
  final Timestamp createdAt;
  final bool hasFacilitatorCard;
  final String? placeId;
  final String? placeName;
  final String? placeAddress;
  final double? latitude;
  final double? longitude;

  Meeting({
    required this.id,
    required this.title,
    required this.description,
    required this.locationNote,
    required this.locationType,
    required this.hostId,
    required this.hostName,
    required this.assignedOrganizerId,
    required this.assignedOrganizerName,
    required this.memberIds,
    required this.maxMembers,
    required this.meetingTime,
    required this.createdAt,
    required this.hasFacilitatorCard,
    this.placeId,
    this.placeName,
    this.placeAddress,
    this.latitude,
    this.longitude,
  });

  factory Meeting.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Meeting(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      locationNote: data['location'] ?? '',
      locationType: _meetingLocationTypeFromString(data['locationType'] as String?),
      hostId: data['hostId'] ?? '',
      hostName: data['hostName'] ?? '',
      assignedOrganizerId: data['assignedOrganizerId'] as String?,
      assignedOrganizerName: data['assignedOrganizerName'] as String?,
      // Firestore의 Array는 List<dynamic>으로 넘어오므로 List<String>으로 변환
      memberIds: List<String>.from(data['memberIds'] ?? []),
      maxMembers: data['maxMembers'] ?? 0,
      meetingTime: data['meetingTime'] as Timestamp,
      createdAt: data['createdAt'] as Timestamp,
      hasFacilitatorCard: data['hasFacilitatorCard'] ?? false,
      placeId: data['placeId'] as String?,
      placeName: data['placeName'] as String?,
      placeAddress: data['placeAddress'] as String?,
      latitude: (data['lat'] is num) ? (data['lat'] as num).toDouble() : null,
      longitude: (data['lng'] is num) ? (data['lng'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'location': locationNote,
      'locationType': locationType.name,
      'hostId': hostId,
      'hostName': hostName,
      'assignedOrganizerId': assignedOrganizerId,
      'assignedOrganizerName': assignedOrganizerName,
      'memberIds': memberIds,
      'maxMembers': maxMembers,
      'meetingTime': meetingTime,
      'createdAt': createdAt,
      'hasFacilitatorCard': hasFacilitatorCard,
      'placeId': placeId,
      'placeName': placeName,
      'placeAddress': placeAddress,
      'lat': latitude,
      'lng': longitude,
    };
  }
}
