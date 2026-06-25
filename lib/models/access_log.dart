class AccessLog {
  final String? id;
  final String userId;
  final String userEmail;
  final DateTime loginTime;
  final DateTime? logoutTime;
  final String ipAddress;
  final String userAgent;
  final bool isSuccessful;
  final String? failureReason;

  AccessLog({
    this.id,
    required this.userId,
    required this.userEmail,
    required this.loginTime,
    this.logoutTime,
    required this.ipAddress,
    required this.userAgent,
    this.isSuccessful = true,
    this.failureReason,
  });

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'loginTime': loginTime.toIso8601String(),
      'logoutTime': logoutTime?.toIso8601String(),
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'isSuccessful': isSuccessful,
      'failureReason': failureReason,
    };
  }

  // Create from Firestore map
  factory AccessLog.fromMap(Map<String, dynamic> map, String id) {
    return AccessLog(
      id: id,
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      loginTime: DateTime.parse(map['loginTime'] ?? DateTime.now().toIso8601String()),
      logoutTime: map['logoutTime'] != null ? DateTime.parse(map['logoutTime']) : null,
      ipAddress: map['ipAddress'] ?? 'Unknown',
      userAgent: map['userAgent'] ?? 'Unknown',
      isSuccessful: map['isSuccessful'] ?? true,
      failureReason: map['failureReason'],
    );
  }

  // Copy with method for updates
  AccessLog copyWith({
    String? id,
    String? userId,
    String? userEmail,
    DateTime? loginTime,
    DateTime? logoutTime,
    String? ipAddress,
    String? userAgent,
    bool? isSuccessful,
    String? failureReason,
  }) {
    return AccessLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      loginTime: loginTime ?? this.loginTime,
      logoutTime: logoutTime ?? this.logoutTime,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      isSuccessful: isSuccessful ?? this.isSuccessful,
      failureReason: failureReason ?? this.failureReason,
    );
  }

  // Get session duration in minutes
  int? getSessionDurationMinutes() {
    if (logoutTime == null) return null;
    return logoutTime!.difference(loginTime).inMinutes;
  }
}
