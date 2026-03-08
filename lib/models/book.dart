class Book {
  final String title;
  final String author;
  final String isbn;
  final String category;
  final String course;
  final int searchCount;
  final String status; // e.g., "PHYSICAL COPY AVAILABLE", "E-RESOURCE AVAILABLE", etc.

  Book({
    required this.title,
    required this.author,
    required this.isbn,
    required this.category,
    required this.course,
    required this.searchCount,
    required this.status,
  });
}
