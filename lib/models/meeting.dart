import 'dart:convert';
import 'package:myapp/models/book_request.dart';

Meeting meetingFromJson(String str) => Meeting.fromJson(json.decode(str));

String meetingToJson(Meeting data) => json.encode(data.toJson());

class Meeting {
    final String id;
    final String type;
    final DateTime date;
    final String? location;
    final String? zoomLink;
    final Agenda agenda;
    final List<Participant> participants;

    Meeting({
        required this.id,
        required this.type,
        required this.date,
        this.location,
        this.zoomLink,
        required this.agenda,
        required this.participants,
    });

    factory Meeting.fromJson(Map<String, dynamic> json) => Meeting(
        id: json["id"],
        type: json["type"],
        date: DateTime.parse(json["date"]),
        location: json["location"],
        zoomLink: json["zoomLink"],
        agenda: Agenda.fromJson(json["agenda"]),
        participants: List<Participant>.from(json["participants"].map((x) => Participant.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "date": date.toIso8601String(),
        "location": location,
        "zoomLink": zoomLink,
        "agenda": agenda.toJson(),
        "participants": List<dynamic>.from(participants.map((x) => x.toJson())),
    };
}

class Agenda {
    final List<BookRequest> bookRequests;
    final List<String> discussionTopics;

    Agenda({
        required this.bookRequests,
        required this.discussionTopics,
    });

    factory Agenda.fromJson(Map<String, dynamic> json) => Agenda(
        bookRequests: List<BookRequest>.from(json["bookRequests"].map((x) => BookRequest.fromJson(x))),
        discussionTopics: List<String>.from(json["discussionTopics"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "bookRequests": List<dynamic>.from(bookRequests.map((x) => x.toJson())),
        "discussionTopics": List<dynamic>.from(discussionTopics.map((x) => x)),
    };
}


class Participant {
    final String userId;
    final String status; // e.g., 'attending', 'absent'

    Participant({
        required this.userId,
        required this.status,
    });

    factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        userId: json["userId"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "userId": userId,
        "status": status,
    };
}
