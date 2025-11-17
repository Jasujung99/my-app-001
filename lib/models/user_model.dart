// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final int points;
  final bool isAdmin;
  final List<String> roles;
  final String? assignedOrganizerId;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.points,
    required this.isAdmin,
    required this.roles,
    this.assignedOrganizerId,
  });

  // Firestore 문서로부터 UserModel 객체를 생성하는 factory 생성자
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      points: data['points'] ?? 0,
      isAdmin: data['isAdmin'] ?? false,
      roles: List<String>.from(data['roles'] ?? const []),
      assignedOrganizerId: data['assignedOrganizerId'] as String?,
    );
  }

  // UserModel 객체를 Firestore 문서(Map)로 변환하는 메소드
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'points': points,
      'isAdmin': isAdmin,
      'roles': roles,
      'assignedOrganizerId': assignedOrganizerId,
    };
  }
}
