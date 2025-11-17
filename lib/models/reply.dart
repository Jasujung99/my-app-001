// lib/models/reply.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Reply {
  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final Timestamp createdAt;

  Reply({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
  });

  // Firestore 문서로부터 Reply 객체를 생성하는 factory 생성자
  factory Reply.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Reply(
      id: doc.id,
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      createdAt: data['createdAt'] as Timestamp,
    );
  }

  // Reply 객체를 Firestore 문서(Map)로 변환하는 메소드 (주로 쓰기용)
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt,
    };
  }
}
