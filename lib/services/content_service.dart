import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_item.dart';

class ContentService {
  static const String _col = 'library_content';
  static const String _pagesCol = 'library_pages';

  final CollectionReference _db =
      FirebaseFirestore.instance.collection(_col);
  final CollectionReference _pagesDb =
      FirebaseFirestore.instance.collection(_pagesCol);

  // ── News & Events (list-based) ──────────────────────────────────────────

  Stream<List<ContentItem>> getSection(String section) {
    return _db
        .where('section', isEqualTo: section)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ContentItem.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  /// All items for a section (including inactive) — for admin view
  Stream<List<ContentItem>> getSectionAdmin(String section) {
    return _db
        .where('section', isEqualTo: section)
        .orderBy('sortOrder')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ContentItem.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  Future<void> addItem(ContentItem item) async {
    await _db.add(item.toMap());
  }

  Future<void> updateItem(ContentItem item) async {
    if (item.id == null) throw Exception('Item has no id');
    await _db.doc(item.id).update(item.copyWith(updatedAt: DateTime.now()).toMap());
  }

  Future<void> deleteItem(String id) async {
    await _db.doc(id).delete();
  }

  // ── Single-page sections (about, services, help, location, settings) ────

  Stream<ContentPage?> getPage(String section) {
    return _pagesDb
        .where('section', isEqualTo: section)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      final d = snap.docs.first;
      return ContentPage.fromMap(d.data() as Map<String, dynamic>, d.id);
    });
  }

  Future<void> savePage(ContentPage page) async {
    final snap = await _pagesDb
        .where('section', isEqualTo: page.section)
        .limit(1)
        .get();

    final data = page.toMap();
    if (snap.docs.isEmpty) {
      await _pagesDb.add(data);
    } else {
      await _pagesDb.doc(snap.docs.first.id).set(data);
    }
  }
}
