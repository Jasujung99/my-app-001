import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/models/meeting.dart';

void main() {
  group('Meeting model', () {
    test('serializes admin and location metadata', () async {
      final firestore = FakeFirebaseFirestore();
      final docRef = await firestore.collection('meetings').add({
        'title': '테스트 모임',
        'description': '관리자 테스트',
        'location': '3층 북카페',
        'locationType': MeetingLocationType.offline.name,
        'hostId': 'host-123',
        'hostName': '북토크 매니저',
        'assignedOrganizerId': 'admin-001',
        'assignedOrganizerName': 'Admin Kim',
        'memberIds': ['host-123'],
        'maxMembers': 10,
        'meetingTime': Timestamp.now(),
        'createdAt': Timestamp.now(),
        'hasFacilitatorCard': true,
        'placeName': '홍대 서점',
        'placeAddress': '서울시 마포구',
        'lat': 37.5510,
        'lng': 126.9210,
      });

      final snapshot = await docRef.get();
      final meeting = Meeting.fromFirestore(snapshot);

      expect(meeting.assignedOrganizerId, 'admin-001');
      expect(meeting.hasFacilitatorCard, isTrue);
      expect(meeting.placeName, '홍대 서점');
      expect(meeting.latitude, closeTo(37.5510, 0.0001));

      final json = meeting.toJson();
      expect(json['locationType'], MeetingLocationType.offline.name);
      expect(json['placeName'], '홍대 서점');
    });
  });
}
