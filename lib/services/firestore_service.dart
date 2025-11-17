// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/book_request.dart';
import 'package:myapp/models/meeting.dart';
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

  Future<bool> isUserAdmin(String userId) async {
    final doc = await _userCollection.doc(userId).get();
    final data = doc.data();
    if (data == null) return false;
    return data['isAdmin'] == true;
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
    MeetingLocationType locationType = MeetingLocationType.offline,
    String? placeId,
    String? placeName,
    String? placeAddress,
    double? latitude,
    double? longitude,
    required String hostId,
    required String hostName,
    String? assignedOrganizerId,
    String? assignedOrganizerName,
    required int maxMembers,
    required DateTime meetingTime,
    bool hasFacilitatorCard = false,
  }) async {
    try {
      await _meetingCollection.add({
        'title': title,
        'description': description,
        'location': location,
        'locationType': locationType.name,
        'hostId': hostId,
        'hostName': hostName,
        'assignedOrganizerId': assignedOrganizerId ?? hostId,
        'assignedOrganizerName': assignedOrganizerName ?? hostName,
        'memberIds': [hostId], // 주최자는 자동으로 참여자에 포함
        'maxMembers': maxMembers,
        'meetingTime': Timestamp.fromDate(meetingTime),
        'createdAt': FieldValue.serverTimestamp(),
        'hasFacilitatorCard': hasFacilitatorCard,
        'placeId': placeId,
        'placeName': placeName,
        'placeAddress': placeAddress,
        'lat': latitude,
        'lng': longitude,
      });
    } catch (e) {
      print('Error creating meeting: $e');
      rethrow;
    }
  }

  Stream<Meeting?> watchMeeting(String meetingId) {
    return _meetingCollection.doc(meetingId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return Meeting.fromFirestore(snapshot);
    });
  }

  Future<Meeting?> fetchMeeting(String meetingId) async {
    final snapshot = await _meetingCollection.doc(meetingId).get();
    if (!snapshot.exists) return null;
    return Meeting.fromFirestore(snapshot);
  }

  Future<void> joinMeeting(String meetingId, String userId) async {
    final docRef = _meetingCollection.doc(meetingId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception('meeting_not_found');
      }

      final data = snapshot.data()!;
      final List<String> memberIds = List<String>.from(data['memberIds'] ?? []);
      final int maxMembers = data['maxMembers'] ?? 0;

      if (memberIds.contains(userId)) return;
      if (maxMembers > 0 && memberIds.length >= maxMembers) {
        throw Exception('meeting_full');
      }

      memberIds.add(userId);
      transaction.update(docRef, {'memberIds': memberIds});
    });
  }

  Future<void> leaveMeeting(String meetingId, String userId) async {
    final docRef = _meetingCollection.doc(meetingId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception('meeting_not_found');
      }

      final data = snapshot.data()!;
      final String? hostId = data['hostId'] as String?;
      if (hostId == userId) {
        throw Exception('host_cannot_leave');
      }

      final List<String> memberIds = List<String>.from(data['memberIds'] ?? []);
      if (!memberIds.contains(userId)) return;

      memberIds.remove(userId);
      transaction.update(docRef, {'memberIds': memberIds});
    });
  }
}
