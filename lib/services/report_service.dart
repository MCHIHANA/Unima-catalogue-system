import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/search_request.dart';

class ReportService {
  final CollectionReference _searchDb = FirebaseFirestore.instance.collection('search_requests');
  final CollectionReference _recommendationDb = FirebaseFirestore.instance.collection('recommendations');

  Stream<List<SearchRequest>> getSearchRequests() {
    return _searchDb.orderBy('count', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return SearchRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> logSearchQuery(String query, bool found) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final docId = Uri.encodeComponent(trimmed.toLowerCase());
    await _searchDb.doc(docId).set({
      'query': trimmed,
      'found': found,
      'count': FieldValue.increment(1),
      'lastSearched': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Stream<String?> getLatestRecommendation() {
    return _recommendationDb
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      return data['text'] as String?;
    });
  }

  Future<void> saveRecommendation(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    await _recommendationDb.add({
      'text': trimmed,
      'createdAt': Timestamp.now(),
    });
  }
}
