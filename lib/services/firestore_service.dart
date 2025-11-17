// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/book_request.dart';
import 'package:myapp/models/reply.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _brCollection;
  late final CollectionReference<Map<String, dynamic>> _userCollection;
  late final CollectionReference<Map<String, dynamic>> _meetingCollection; // meetings 컬렉션 추가

  FirestoreService() {
    _brCollection = _db.collection('book_requests');
    _userCollection = _db.collection('users');
    _meetingCollection = _db.collection('meetings'); // 컬렉션 초기화
  }

  Future<void> addBookRequest(BookRequest br) async {
    await _brCollection.add(br.toJson());
  }

  Stream<List<BookRequest>> getBookRequests() {
    return _brCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => BookRequest.fromFirestore(doc)).toList();
    });
  }

  Future<BookRequest?> getBookRequestById(String id) async {
    final doc = await _brCollection.doc(id).get();
    if (doc.exists) {
      return BookRequest.fromFirestore(doc);
    }
    return null;
  }

  Future<void> addReplyToBR(String brId, {required String content, required String authorId, required String authorName}) async {
    await _brCollection.doc(brId).collection('replies').add({
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Reply>> getRepliesStream(String brId) {
    return _brCollection.doc(brId).collection('replies').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Reply.fromFirestore(doc)).toList();
    });
  }
  
  Future<List<BookRequest>> getBookRequestsByUser(String userId) async {
    final snapshot = await _brCollection.where('authorId', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => BookRequest.fromFirestore(doc)).toList();
  }

  Future<void> spendPointsToReadBR(String userId, String brId) async {
    // Implement logic to spend points
  }

  // --- 모임(Meeting) 관련 메소드 ---

  // 새로운 모임 생성
  Future<void> createMeeting({
    required String title,
    required String description,
    required String location,
    required String hostId,
    required String hostName,
    required int maxMembers,
    required DateTime meetingTime,
  }) async {
    try {
      await _meetingCollection.add({
        'title': title,
        'description': description,
        'location': location,
        'hostId': hostId,
        'hostName': hostName,
        'memberIds': [hostId], // 주최자는 자동으로 참여자에 포함
        'maxMembers': maxMembers,
        'meetingTime': Timestamp.fromDate(meetingTime),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating meeting: $e');
      rethrow;
    }
  }
}
