# Audit & Access Tracking System - Documentation

## Overview
This document describes the comprehensive audit and tracking system implemented in the UNIMA Library Catalogue system. The system tracks all user access and activities performed in the system, providing administrators with complete visibility into who accessed the system and what changes were made.

## Features

### 1. User Access Tracking
- **Login Tracking**: Records every user login attempt (successful and failed)
- **Session Management**: Tracks login time and logout time
- **IP Address Logging**: Records the IP address from which the user logged in
- **User Agent**: Captures device/browser information
- **Session Duration**: Calculates total session duration in minutes
- **Failed Login Attempts**: Logs failed authentication attempts with failure reasons

### 2. Activity/Action Tracking
Tracks all system activities including:
- **Book Management**:
  - Books added to the system
  - Books updated with new information
  - Books deleted from the system
  - Books searched by users
- **User Actions**:
  - User login events
  - User logout events
  - User registration (when implemented)
- **System Actions**:
  - Reports generated
  - Settings changed (when implemented)

### 3. Data Captured for Each Activity
- User ID and Email
- Activity Type
- Timestamp (with full date and time)
- Description of the activity
- Changed fields (for updates) - before and after values
- Related document ID and type (e.g., book ID)
- Success status

## Components

### Models

#### 1. AccessLog (`lib/models/access_log.dart`)
Represents a user access/login event.

**Fields:**
- `id`: Unique identifier
- `userId`: Firebase user ID
- `userEmail`: User email address
- `loginTime`: When the user logged in
- `logoutTime`: When the user logged out (optional)
- `ipAddress`: IP address of the login
- `userAgent`: Device/browser information
- `isSuccessful`: Whether the login was successful
- `failureReason`: Reason for failed login attempts

**Methods:**
- `toMap()`: Converts to Firestore format
- `fromMap()`: Creates object from Firestore data
- `getSessionDurationMinutes()`: Calculates session length

#### 2. ActivityLog (`lib/models/activity_log.dart`)
Represents a user action or system activity.

**Fields:**
- `id`: Unique identifier
- `userId`: Firebase user ID
- `userEmail`: User email address
- `activityType`: Type of activity (enum)
- `description`: Human-readable description
- `timestamp`: When the activity occurred
- `changedFields`: Map of what was changed
- `relatedDocumentId`: ID of related document (e.g., book ID)
- `relatedDocumentType`: Type of related document
- `success`: Whether the operation succeeded

**Activity Types:**
```dart
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
```

### Services

#### AuditService (`lib/services/audit_service.dart`)
Central service for all audit logging operations.

**Key Methods:**

1. **logUserAccess()**
   ```dart
   Future<void> logUserAccess({
     required String userId,
     required String userEmail,
     String ipAddress = 'Unknown',
     String userAgent = 'Flutter App',
   })
   ```
   Logs successful user login.

2. **logFailedLogin()**
   ```dart
   Future<void> logFailedLogin({
     required String userEmail,
     required String failureReason,
     String ipAddress = 'Unknown',
     String userAgent = 'Flutter App',
   })
   ```
   Logs failed login attempts.

3. **logUserLogout()**
   ```dart
   Future<void> logUserLogout({
     required String userId,
     required String userEmail,
   })
   ```
   Logs user logout events.

4. **logActivity()**
   ```dart
   Future<void> logActivity({
     required String userId,
     required String userEmail,
     required ActivityType activityType,
     required String description,
     Map<String, dynamic>? changedFields,
     String? relatedDocumentId,
     String? relatedDocumentType,
     bool success = true,
   })
   ```
   Logs general system activities.

5. **Retrieval Methods:**
   - `getUserAccessLogs(String userId)` - Get all logins for a user
   - `getAllAccessLogs()` - Get all system logins
   - `getAccessLogsDateRange()` - Filter by date range
   - `getUserActivityLogs(String userId)` - Get activities by user
   - `getAllActivityLogs()` - Get all activities
   - `getActivityLogsByType()` - Filter by activity type
   - `getActivityLogsDateRange()` - Filter activities by date
   - `getAuditStatistics()` - Get summary statistics

### Screens

#### AuditLogsScreen (`lib/screens/audit_logs_screen.dart`)
Comprehensive UI for viewing audit logs with three tabs:

1. **Access Logs Tab**
   - Shows all user login/logout events
   - Displays login time, duration, IP address
   - Shows success/failure status with reason
   - Filterable by date range
   - Cards display session details

2. **Activity Logs Tab**
   - Shows all system activities
   - Color-coded by activity type
   - Displays what was changed
   - Shows related documents (e.g., which book was modified)
   - Filterable by date range
   - Search and filter capabilities

3. **Statistics Tab**
   - Total access logs count
   - Total activity logs count
   - Successful vs failed logins
   - Unique user count
   - Activity type breakdown
   - Visual metrics and summary cards

## Integration Points

### 1. Login Screen (`lib/screens/login_screen.dart`)
- ✅ Logs successful logins via `AuditService.logUserAccess()`
- ✅ Logs failed login attempts via `AuditService.logFailedLogin()`
- ✅ Records login activity via `AuditService.logActivity()`

### 2. Dashboard Screen (`lib/screens/dashboard_screen.dart`)
- ✅ Logs user logout via `AuditService.logUserLogout()`
- ✅ Integrated into logout confirmation dialog

### 3. Book Service (`lib/services/book_service.dart`)
- ✅ Logs book creation: `ActivityType.bookAdded`
- ✅ Logs book updates: `ActivityType.bookUpdated`
- ✅ Logs book deletion: `ActivityType.bookDeleted`
- ✅ Logs book searches: `ActivityType.bookSearched`
- ✅ Captures changed fields for updates

### 4. Navigation (`lib/widgets/main_layout.dart`)
- ✅ Added "Audit Logs" link to desktop navigation
- ✅ Added "Audit Logs" link to mobile drawer
- ✅ Links to the new AuditLogsScreen

## Firestore Structure

The audit logs are stored in Firebase Firestore with the following structure:

```
audit_logs/
  access_logs/
    logs/
      [docId]: {
        userId: string,
        userEmail: string,
        loginTime: timestamp,
        logoutTime: timestamp (nullable),
        ipAddress: string,
        userAgent: string,
        isSuccessful: boolean,
        failureReason: string (nullable)
      }
  activity_logs/
    logs/
      [docId]: {
        userId: string,
        userEmail: string,
        activityType: string,
        description: string,
        timestamp: timestamp,
        changedFields: map (nullable),
        relatedDocumentId: string (nullable),
        relatedDocumentType: string (nullable),
        success: boolean
      }
```

## Usage Examples

### Example 1: Logging a Book Addition
```dart
// Automatically logged in BookService.addBook()
final book = Book(
  title: 'Flutter Guide',
  author: 'John Doe',
  // ... other fields
);

await bookService.addBook(book);
// Activity log automatically created:
// - Type: bookAdded
// - Description: "Added new book: Flutter Guide by John Doe"
// - Timestamp: current time
```

### Example 2: Tracking User Access
```dart
// Automatically logged in LoginScreen._handleLogin()
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);
// Two logs automatically created:
// 1. AccessLog with login time
// 2. ActivityLog for user login event
```

### Example 3: Viewing Audit Logs
```dart
// Navigate to audit logs screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const AuditLogsScreen()),
);
// Shows all access and activity logs with filters
```

## Security Considerations

1. **Immutable Records**: Audit logs should never be modified or deleted
2. **User Permissions**: Consider restricting audit log access to administrators only
3. **Data Retention**: Implement a retention policy for old logs
4. **Encryption**: Ensure Firestore security rules protect sensitive data
5. **IP Address Privacy**: Consider anonymizing IP addresses in certain contexts

## Recommended Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow only authenticated admins to read audit logs
    match /audit_logs/{document=**} {
      allow read: if request.auth != null && 
                     request.auth.token.admin == true;
      allow create: if request.auth != null; // App can log
      allow update, delete: if false; // Never allow modification
    }
  }
}
```

## Future Enhancements

1. **Email Alerts**: Send alerts for suspicious activities
2. **IP Whitelisting**: Flag logins from unexpected locations
3. **Automated Reports**: Generate daily/weekly audit reports
4. **Data Export**: Export audit logs as CSV/Excel
5. **Advanced Filtering**: Filter by user, date range, activity type
6. **Audit Trail Visualization**: Timeline view of activities
7. **Compliance Reports**: Generate compliance documentation
8. **Failed Login Threshold**: Lock account after N failed attempts
9. **Activity Notifications**: Real-time notifications for admin
10. **Detailed Change Logs**: Store full before/after snapshots

## Troubleshooting

### Logs Not Appearing
- Check Firebase authentication is working
- Verify Firestore collection paths are correct
- Ensure user has proper permissions

### Missing Activity Logs
- Verify book operations are using BookService methods
- Check network connectivity during operations
- Review Firestore error logs

### Performance Issues
- Implement pagination for large log datasets
- Add indexes to frequently queried fields
- Consider archiving old logs

## API Reference

See individual model and service files for complete API documentation:
- `lib/models/access_log.dart`
- `lib/models/activity_log.dart`
- `lib/services/audit_service.dart`
- `lib/screens/audit_logs_screen.dart`
