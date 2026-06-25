import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/activity_log.dart';
import 'audit_service.dart';

class BookService {
  final CollectionReference _db = FirebaseFirestore.instance.collection('books');
  final AuditService _auditService = AuditService();

  // Create
  Future<Book> addBook(Book book) async {
    final docRef = await _db.add(book.toMap());
    final newBook = book.copyWith(id: docRef.id);

    // Log the activity
    final currentUser = _auditService.getCurrentUser();
    if (currentUser != null) {
      await _auditService.logActivity(
        userId: currentUser.uid,
        userEmail: currentUser.email ?? 'unknown',
        activityType: ActivityType.bookAdded,
        description: 'Added new book: ${book.title} by ${book.author}',
        changedFields: {'title': book.title, 'author': book.author, 'isbn': book.isbn},
        relatedDocumentId: newBook.id,
        relatedDocumentType: 'book',
      );
    }

    return newBook;
  }

  // Read (Stream for real-time updates)
  Stream<List<Book>> getBooks() {
    return _db.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Book.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Read (Future for one-time fetch)
  Future<List<Book>> fetchBooks() async {
    final snapshot = await _db.get();
    return snapshot.docs.map((doc) {
      return Book.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  // Update
  Future<void> updateBook(Book book) async {
    if (book.id == null) throw Exception('Cannot update book without ID');
    
    // Get the old book data for comparison
    final oldDoc = await _db.doc(book.id).get();
    final oldData = oldDoc.data() as Map<String, dynamic>? ?? {};

    await _db.doc(book.id).update(book.toMap());

    // Log the activity
    final currentUser = _auditService.getCurrentUser();
    if (currentUser != null) {
      final changedFields = <String, dynamic>{};
      
      // Compare fields to identify what changed
      final bookMap = book.toMap();
      bookMap.forEach((key, value) {
        if (oldData[key] != value) {
          changedFields[key] = {'old': oldData[key], 'new': value};
        }
      });

      await _auditService.logActivity(
        userId: currentUser.uid,
        userEmail: currentUser.email ?? 'unknown',
        activityType: ActivityType.bookUpdated,
        description: 'Updated book: ${book.title}',
        changedFields: changedFields.isNotEmpty ? changedFields : null,
        relatedDocumentId: book.id,
        relatedDocumentType: 'book',
      );
    }
  }

  // Delete
  Future<void> deleteBook(String id) async {
    // Get book data before deletion for logging
    final doc = await _db.doc(id).get();
    final bookData = doc.data() as Map<String, dynamic>? ?? {};

    await _db.doc(id).delete();

    // Log the activity
    final currentUser = _auditService.getCurrentUser();
    if (currentUser != null) {
      await _auditService.logActivity(
        userId: currentUser.uid,
        userEmail: currentUser.email ?? 'unknown',
        activityType: ActivityType.bookDeleted,
        description: 'Deleted book: ${bookData['title'] ?? 'Unknown'}',
        changedFields: {'deletedBook': bookData},
        relatedDocumentId: id,
        relatedDocumentType: 'book',
      );
    }
  }

  // Increment Search Count
  Future<void> incrementSearchCount(String id) async {
    await _db.doc(id).update({
      'searchCount': FieldValue.increment(1)
    });

    // Log the search activity
    final currentUser = _auditService.getCurrentUser();
    if (currentUser != null) {
      final doc = await _db.doc(id).get();
      final bookData = doc.data() as Map<String, dynamic>? ?? {};

      await _auditService.logActivity(
        userId: currentUser.uid,
        userEmail: currentUser.email ?? 'unknown',
        activityType: ActivityType.bookSearched,
        description: 'Searched for book: ${bookData['title'] ?? 'Unknown'}',
        relatedDocumentId: id,
        relatedDocumentType: 'book',
      );
    }
  }
}
