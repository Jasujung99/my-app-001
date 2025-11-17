// lib/models/book_club.dart

class BookClub {
  final String id;
  final String name;
  final String location;
  final String currentBook;
  final String imageUrl;
  final int memberCount;

  BookClub({
    required this.id,
    required this.name,
    required this.location,
    required this.currentBook,
    required this.imageUrl,
    required this.memberCount,
  });
}
