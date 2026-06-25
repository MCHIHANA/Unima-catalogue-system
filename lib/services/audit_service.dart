import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/access_log.dart';
import '../models/activity_log.dart';

class AuditService {
  final CollectionReference _accessLogsDb = 
      FirebaseFirestore.instance.collection('audit_logs/access_logs/logs');
  final CollectionReference _activityLogsDb = 
      FirebaseFirestore.instance.collection('audit_logs/activity_logs/logs');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Log user access (login)
  Future<void> logUserAccess({
    required String userId,
    required String userEmail,
    String ipAddress = 'Unknown',
    String userAgent = 'Flutter App',
  }) async {
    try {
      final accessLog = AccessLog(
        userId: userId,
        userEmail: userEmail,
        loginTime: DateTime.now(),
        ipAddress: ipAddress,
        userAgent: userAgent,
        isSuccessful: true,
      );

      await _accessLogsDb.add(accessLog.toMap());
    } catch (e) {
      print('Error logging user access: $e');
    }
  }

  // Log failed login attempt
  Future<void> logFailedLogin({
    required String userEmail,
    required String failureReason,
    String ipAddress = 'Unknown',
    String userAgent = 'Flutter App',
  }) async {
    try {
      final accessLog = AccessLog(
        userId: 'unknown',
        userEmail: userEmail,
        loginTime: DateTime.now(),
        ipAddress: ipAddress,
        userAgent: userAgent,
        isSuccessful: false,
        failureReason: failureReason,
      );

      await _accessLogsDb.add(accessLog.toMap());
    } catch (e) {
      print('Error logging failed login: $e');
    }
  }

  // Log user logout
  Future<void> logUserLogout({
    required String userId,
    required String userEmail,
  }) async {
    try {
      // Log the logout activity
      await logActivity(
        userId: userId,
        userEmail: userEmail,
        activityType: ActivityType.userLoggedOut,
        description: '$userEmail logged out of the system',
      );
    } catch (e) {
      print('Error logging user logout: $e');
    }
  }

  // Log general activity
  Future<void> logActivity({
    required String userId,
    required String userEmail,
    required ActivityType activityType,
    required String description,
    Map<String, dynamic>? changedFields,
    String? relatedDocumentId,
    String? relatedDocumentType,
    bool success = true,
  }) async {
    try {
      final activityLog = ActivityLog(
        userId: userId,
        userEmail: userEmail,
        activityType: activityType,
        description: description,
        timestamp: DateTime.now(),
        changedFields: changedFields,
        relatedDocumentId: relatedDocumentId,
        relatedDocumentType: relatedDocumentType,
        success: success,
      );

      await _activityLogsDb.add(activityLog.toMap());
    } catch (e) {
      print('Error logging activity: $e');
    }
  }

  // Get access logs for a specific user
  Stream<List<AccessLog>> getUserAccessLogs(String userId) {
    return _accessLogsDb
        .where('userId', isEqualTo: userId)
        .orderBy('loginTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AccessLog.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get all access logs (for admin)
  Stream<List<AccessLog>> getAllAccessLogs() {
    return _accessLogsDb
        .orderBy('loginTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AccessLog.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get access logs for date range
  Future<List<AccessLog>> getAccessLogsDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _accessLogsDb
          .where('loginTime', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('loginTime', isLessThanOrEqualTo: endDate.toIso8601String())
          .orderBy('loginTime', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return AccessLog.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching access logs: $e');
      return [];
    }
  }

  // Get activity logs for a specific user
  Stream<List<ActivityLog>> getUserActivityLogs(String userId) {
    return _activityLogsDb
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ActivityLog.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get all activity logs (for admin)
  Stream<List<ActivityLog>> getAllActivityLogs() {
    return _activityLogsDb
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ActivityLog.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get activity logs by type
  Stream<List<ActivityLog>> getActivityLogsByType(String activityType) {
    return _activityLogsDb
        .where('activityType', isEqualTo: activityType)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ActivityLog.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get activity logs for date range
  Future<List<ActivityLog>> getActivityLogsDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _activityLogsDb
          .where('timestamp', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('timestamp', isLessThanOrEqualTo: endDate.toIso8601String())
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return ActivityLog.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching activity logs: $e');
      return [];
    }
  }

  // Get statistics for admin dashboard
  Future<Map<String, dynamic>> getAuditStatistics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final accessLogsSnapshot = await _accessLogsDb
          .where('loginTime', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('loginTime', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      final activityLogsSnapshot = await _activityLogsDb
          .where('timestamp', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('timestamp', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      final totalAccessLogs = accessLogsSnapshot.docs.length;
      final totalActivityLogs = activityLogsSnapshot.docs.length;

      // Count successful and failed logins
      int successfulLogins = 0;
      int failedLogins = 0;

      for (var doc in accessLogsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['isSuccessful'] == true) {
          successfulLogins++;
        } else {
          failedLogins++;
        }
      }

      // Count activity types
      final activityTypeCounts = <String, int>{};
      for (var doc in activityLogsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final type = data['activityType'] as String? ?? 'other';
        activityTypeCounts[type] = (activityTypeCounts[type] ?? 0) + 1;
      }

      // Get unique users
      final uniqueUsers = <String>{};
      for (var doc in accessLogsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        uniqueUsers.add(data['userEmail'] ?? 'unknown');
      }

      return {
        'totalAccessLogs': totalAccessLogs,
        'totalActivityLogs': totalActivityLogs,
        'successfulLogins': successfulLogins,
        'failedLogins': failedLogins,
        'uniqueUsers': uniqueUsers.length,
        'activityTypeCounts': activityTypeCounts,
      };
    } catch (e) {
      print('Error fetching audit statistics: $e');
      return {};
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
