import 'package:cloud_firestore/cloud_firestore.dart';

class SearchRequest {
  final String id;
  final String query;
  final int count;
  final bool found;
  final DateTime lastSearched;

  SearchRequest({
    required this.id,
    required this.query,
    required this.count,
    required this.found,
    required this.lastSearched,
  });

  factory SearchRequest.fromMap(Map<String, dynamic> map, String id) {
    return SearchRequest(
      id: id,
      query: map['query'] ?? '',
      count: map['count'] ?? 0,
      found: map['found'] ?? false,
      lastSearched: (map['lastSearched'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
