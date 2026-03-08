import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class BookService {
  final CollectionReference _db = FirebaseFirestore.instance.collection('books');

  // Create
  Future<Book> addBook(Book book) async {
    final docRef = await _db.add(book.toMap());
    return book.copyWith(id: docRef.id);
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
    await _db.doc(book.id).update(book.toMap());
  }

  // Delete
  Future<void> deleteBook(String id) async {
    await _db.doc(id).delete();
  }

  // Increment Search Count
  Future<void> incrementSearchCount(String id) async {
    await _db.doc(id).update({
      'searchCount': FieldValue.increment(1)
    });
  }
}
