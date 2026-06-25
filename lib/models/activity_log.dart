enum ActivityType {
  bookAdded,
  bookUpdated,
  bookDeleted,
  bookSearched,
  userLoggedIn,
  userLoggedOut,
  userRegistered,
  reportGenerated,
  settingsChanged,
  other,
}

class ActivityLog {
  final String? id;
  final String userId;
  final String userEmail;
  final ActivityType activityType;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? changedFields;
  final String? relatedDocumentId;
  final String? relatedDocumentType;
  final bool success;

  ActivityLog({
    this.id,
    required this.userId,
    required this.userEmail,
    required this.activityType,
    required this.description,
    required this.timestamp,
    this.changedFields,
    this.relatedDocumentId,
    this.relatedDocumentType,
    this.success = true,
  });

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'activityType': activityType.toString(),
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'changedFields': changedFields,
      'relatedDocumentId': relatedDocumentId,
      'relatedDocumentType': relatedDocumentType,
      'success': success,
    };
  }

  // Create from Firestore map
  factory ActivityLog.fromMap(Map<String, dynamic> map, String id) {
    return ActivityLog(
      id: id,
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      activityType: _parseActivityType(map['activityType'] ?? ''),
      description: map['description'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      changedFields: map['changedFields'] as Map<String, dynamic>?,
      relatedDocumentId: map['relatedDocumentId'],
      relatedDocumentType: map['relatedDocumentType'],
      success: map['success'] ?? true,
    );
  }

  // Helper to parse activity type from string
  static ActivityType _parseActivityType(String value) {
    return ActivityType.values.firstWhere(
      (type) => type.toString() == value,
      orElse: () => ActivityType.other,
    );
  }

  // Copy with method for updates
  ActivityLog copyWith({
    String? id,
    String? userId,
    String? userEmail,
    ActivityType? activityType,
    String? description,
    DateTime? timestamp,
    Map<String, dynamic>? changedFields,
    String? relatedDocumentId,
    String? relatedDocumentType,
    bool? success,
  }) {
    return ActivityLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      activityType: activityType ?? this.activityType,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      changedFields: changedFields ?? this.changedFields,
      relatedDocumentId: relatedDocumentId ?? this.relatedDocumentId,
      relatedDocumentType: relatedDocumentType ?? this.relatedDocumentType,
      success: success ?? this.success,
    );
  }

  // Get activity type display name
  String getActivityTypeDisplayName() {
    switch (activityType) {
      case ActivityType.bookAdded:
        return 'Book Added';
      case ActivityType.bookUpdated:
        return 'Book Updated';
      case ActivityType.bookDeleted:
        return 'Book Deleted';
      case ActivityType.bookSearched:
        return 'Book Searched';
      case ActivityType.userLoggedIn:
        return 'User Logged In';
      case ActivityType.userLoggedOut:
        return 'User Logged Out';
      case ActivityType.userRegistered:
        return 'User Registered';
      case ActivityType.reportGenerated:
        return 'Report Generated';
      case ActivityType.settingsChanged:
        return 'Settings Changed';
      case ActivityType.other:
        return 'Other Activity';
    }
  }
}
