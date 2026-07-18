class Book {
  final String? id;
  final String title;
  final String author;
  final String isbn;
  final String category;
  final String course;
  final int searchCount;
  final String status;
  final String school;
  final String department;
  // Optional branch — links the book to a specific academic branch
  final String? branch;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.category,
    required this.course,
    this.searchCount = 0,
    required this.status,
    required this.school,
    required this.department,
    this.branch,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'isbn': isbn,
      'category': category,
      'course': course,
      'searchCount': searchCount,
      'status': status,
      'school': school,
      'department': department,
      if (branch != null && branch!.isNotEmpty) 'branch': branch,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map, String id) {
    return Book(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      isbn: map['isbn'] ?? '',
      category: map['category'] ?? '',
      course: map['course'] ?? '',
      searchCount: map['searchCount'] ?? 0,
      status: map['status'] ?? '',
      school: map['school'] ?? 'school-of-education',
      department: map['department'] ?? '',
      branch: map['branch'] as String?,
    );
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? isbn,
    String? category,
    String? course,
    int? searchCount,
    String? status,
    String? school,
    String? department,
    String? branch,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      category: category ?? this.category,
      course: course ?? this.course,
      searchCount: searchCount ?? this.searchCount,
      status: status ?? this.status,
      school: school ?? this.school,
      department: department ?? this.department,
      branch: branch ?? this.branch,
    );
  }
}
