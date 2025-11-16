import 'dart:convert';

Book bookFromJson(String str) => Book.fromJson(json.decode(str));

String bookToJson(Book data) => json.encode(data.toJson());

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
