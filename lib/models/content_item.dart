import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single editable content block (news article, event, info section, etc.)
class ContentItem {
  final String? id;
  final String section; // 'news', 'events', 'about', 'services', 'help', 'location', 'settings'
  final String title;
  final String body;
  final DateTime? eventDate;     // only for events
  final DateTime? eventEndDate;  // optional end date for events
  final bool isActive;
  final int sortOrder;
  final DateTime updatedAt;

  ContentItem({
    this.id,
    required this.section,
    required this.title,
    required this.body,
    this.eventDate,
    this.eventEndDate,
    this.isActive = true,
    this.sortOrder = 0,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'section': section,
      'title': title,
      'body': body,
      'eventDate': eventDate != null ? Timestamp.fromDate(eventDate!) : null,
      'eventEndDate': eventEndDate != null ? Timestamp.fromDate(eventEndDate!) : null,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ContentItem.fromMap(Map<String, dynamic> map, String id) {
    return ContentItem(
      id: id,
      section: map['section'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      eventDate: (map['eventDate'] as Timestamp?)?.toDate(),
      eventEndDate: (map['eventEndDate'] as Timestamp?)?.toDate(),
      isActive: map['isActive'] ?? true,
      sortOrder: map['sortOrder'] ?? 0,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  ContentItem copyWith({
    String? id,
    String? section,
    String? title,
    String? body,
    DateTime? eventDate,
    DateTime? eventEndDate,
    bool? isActive,
    int? sortOrder,
    DateTime? updatedAt,
  }) {
    return ContentItem(
      id: id ?? this.id,
      section: section ?? this.section,
      title: title ?? this.title,
      body: body ?? this.body,
      eventDate: eventDate ?? this.eventDate,
      eventEndDate: eventEndDate ?? this.eventEndDate,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// A single-document info page (about, help, location, settings, services)
/// stored as one Firestore document per section with multiple sub-sections
class ContentPage {
  final String? id;
  final String section;
  final String subtitle;
  final List<ContentSection> sections;
  final DateTime updatedAt;

  ContentPage({
    this.id,
    required this.section,
    required this.subtitle,
    required this.sections,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'section': section,
      'subtitle': subtitle,
      'sections': sections.map((s) => s.toMap()).toList(),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ContentPage.fromMap(Map<String, dynamic> map, String id) {
    final rawSections = map['sections'] as List<dynamic>? ?? [];
    return ContentPage(
      id: id,
      section: map['section'] ?? '',
      subtitle: map['subtitle'] ?? '',
      sections: rawSections
          .map((s) => ContentSection.fromMap(s as Map<String, dynamic>))
          .toList(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class ContentSection {
  final String title;
  final String body;

  ContentSection({required this.title, required this.body});

  Map<String, dynamic> toMap() => {'title': title, 'body': body};

  factory ContentSection.fromMap(Map<String, dynamic> map) {
    return ContentSection(
      title: map['title'] ?? '',
      body: map['body'] ?? '',
    );
  }
}
