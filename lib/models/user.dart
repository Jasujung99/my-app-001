import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
    final String id;
    final String name;
    final String email;
    final int level; // User level for content value
    final int points;

    User({
        required this.id,
        required this.name,
        required this.email,
        this.level = 1,
        this.points = 1000, // Starting points
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        level: json["level"],
        points: json["points"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "level": level,
        "points": points,
    };
}
