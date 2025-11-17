// lib/models/meeting.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Meeting {
  final String id;
  final String title;
  final String description;
  final String location;
  final String hostId;
  final String hostName;
  final List<String> memberIds; // 참여자들의 uid 리스트
  final int maxMembers;
  final Timestamp meetingTime;
  final Timestamp createdAt;

  Meeting({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.hostId,
    required this.hostName,
    required this.memberIds,
    required this.maxMembers,
    required this.meetingTime,
    required this.createdAt,
  });

  factory Meeting.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Meeting(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      hostId: data['hostId'] ?? '',
      hostName: data['hostName'] ?? '',
      // Firestore의 Array는 List<dynamic>으로 넘어오므로 List<String>으로 변환
      memberIds: List<String>.from(data['memberIds'] ?? []),
      maxMembers: data['maxMembers'] ?? 0,
      meetingTime: data['meetingTime'] as Timestamp,
      createdAt: data['createdAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'hostId': hostId,
      'hostName': hostName,
      'memberIds': memberIds,
      'maxMembers': maxMembers,
      'meetingTime': meetingTime,
      'createdAt': createdAt,
    };
  }
}
