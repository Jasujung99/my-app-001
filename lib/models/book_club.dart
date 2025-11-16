// To parse this JSON data, do
//
//     final bookClub = bookClubFromJson(jsonString);

import 'dart:convert';


BookClub bookClubFromJson(String str) => BookClub.fromJson(json.decode(str));

String bookClubToJson(BookClub data) => json.encode(data.toJson());

class BookClub {
    final String id;
    final String name;
    final Location location;
    final Book currentBook;
    final List<Member> members;
    final String chatRoomId;
    final List<dynamic> meetings;

    BookClub({
        required this.id,
        required this.name,
        required this.location,
        required this.currentBook,
        required this.members,
        required this.chatRoomId,
        required this.meetings,
    });

    factory BookClub.fromJson(Map<String, dynamic> json) => BookClub(
        id: json["id"],
        name: json["name"],
        location: Location.fromJson(json["location"]),
        currentBook: Book.fromJson(json["currentBook"]),
        members: List<Member>.from(json["members"].map((x) => Member.fromJson(x))),
        chatRoomId: json["chatRoomId"],
        meetings: List<dynamic>.from(json["meetings"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "location": location.toJson(),
        "currentBook": currentBook.toJson(),
        "members": List<dynamic>.from(members.map((x) => x.toJson())),
        "chatRoomId": chatRoomId,
        "meetings": List<dynamic>.from(meetings.map((x) => x)),
    };
}

class Book {
    final String title;
    final String author;

    Book({
        required this.title,
        required this.author,
    });

    factory Book.fromJson(Map<String, dynamic> json) => Book(
        title: json["title"],
        author: json["author"],
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "author": author,
    };
}

class Location {
    final String dong;
    final double lat;
    final double lng;

    Location({
        required this.dong,
        required this.lat,
        required this.lng,
    });

    factory Location.fromJson(Map<String, dynamic> json) => Location(
        dong: json["dong"],
        lat: json["lat"]?.toDouble(),
        lng: json["lng"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "dong": dong,
        "lat": lat,
        "lng": lng,
    };
}

class Member {
    final String userId;
    final String name;

    Member({
        required this.userId,
        required this.name,
    });

    factory Member.fromJson(Map<String, dynamic> json) => Member(
        userId: json["userId"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "userId": userId,
        "name": name,
    };
}
