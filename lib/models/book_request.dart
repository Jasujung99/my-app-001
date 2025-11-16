import 'dart:convert';
import 'package:myapp/models/user.dart';

BookRequest bookRequestFromJson(String str) => BookRequest.fromJson(json.decode(str));

String bookRequestToJson(BookRequest data) => json.encode(data.toJson());

class BookRequest {
    final String id;
    final String bookId;
    final User author;
    final String type;
    final Content content;
    final List<Comment> thread;
    final int points;

    BookRequest({
        required this.id,
        required this.bookId,
        required this.author,
        required this.type,
        required this.content,
        required this.thread,
        required this.points,
    });

    factory BookRequest.fromJson(Map<String, dynamic> json) => BookRequest(
        id: json["id"],
        bookId: json["bookId"],
        author: User.fromJson(json["author"]),
        type: json["type"],
        content: Content.fromJson(json["content"]),
        thread: List<Comment>.from(json["thread"].map((x) => Comment.fromJson(x))),
        points: json["points"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "bookId": bookId,
        "author": author.toJson(),
        "type": type,
        "content": content.toJson(),
        "thread": List<dynamic>.from(thread.map((x) => x.toJson())),
        "points": points,
    };
}

class Content {
    final String summary;
    final List<Quote> quotes;
    final String thoughts;
    final List<String> questions;

    Content({
        required this.summary,
        required this.quotes,
        required this.thoughts,
        required this.questions,
    });

    factory Content.fromJson(Map<String, dynamic> json) => Content(
        summary: json["summary"],
        quotes: List<Quote>.from(json["quotes"].map((x) => Quote.fromJson(x))),
        thoughts: json["thoughts"],
        questions: List<String>.from(json["questions"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "summary": summary,
        "quotes": List<dynamic>.from(quotes.map((x) => x.toJson())),
        "thoughts": thoughts,
        "questions": List<dynamic>.from(questions.map((x) => x)),
    };
}

class Quote {
    final String text;
    final String page;

    Quote({
        required this.text,
        required this.page,
    });

    factory Quote.fromJson(Map<String, dynamic> json) => Quote(
        text: json["text"],
        page: json["page"],
    );

    Map<String, dynamic> toJson() => {
        "text": text,
        "page": page,
    };
}

class Comment {
    final String userId;
    final String text;
    final DateTime timestamp;

    Comment({
        required this.userId,
        required this.text,
        required this.timestamp,
    });

    factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        userId: json["userId"],
        text: json["text"],
        timestamp: DateTime.parse(json["timestamp"]),
    );

    Map<String, dynamic> toJson() => {
        "userId": userId,
        "text": text,
        "timestamp": timestamp.toIso8601String(),
    };
}
