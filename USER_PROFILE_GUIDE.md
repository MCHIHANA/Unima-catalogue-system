# User Profile Display - Implementation Guide

## What Was Implemented

The system now displays each user's actual name on the dashboard when they log in. Instead of showing "Administrator" for everyone, each of the 4 authorized users will see their own name in the top-right corner of the dashboard.

## How It Works

### 1. User Registry
A new file `lib/models/user_profile.dart` contains a registry of authorized users:

```
tbodzambewe@unima.aw → Displays as "T. Bodzambewe"
anjolomole@unima.ac.mw → Displays as "Anjolo Mole"
fmwalemba@unima.ac.mw → Displays as "F. Mwalemba"
admin@unima.ac.mw → Displays as "Administrator"
```

### 2. Display Location
User names appear in two places:

**Desktop View (Top Right)**
- Shows user name and department
- Updates automatically when user logs in

**Mobile View (Navigation Drawer)**
- Shows user name and department in drawer header
- Updates automatically when user logs in

### 3. How to Add/Update Users

To add a new user or modify existing ones, edit `lib/models/user_profile.dart`:

```dart
'newuser@unima.ac.mw': UserProfile(
  email: 'newuser@unima.ac.mw',
  fullName: 'New User Name',
  department: 'Library Services',
),
```

Then save and the changes apply immediately.

## Files Modified

1. **`lib/models/user_profile.dart`** (NEW)
   - UserProfile model class
   - User registry mapping
   - Helper functions for lookups

2. **`lib/widgets/main_layout.dart`** (UPDATED)
   - Desktop top navigation now shows actual user name
   - Mobile drawer now shows actual user name
   - Imports Firebase Auth to get current user email
   - Uses user profile helper functions

## How the System Gets User Names

1. User logs in with their email (e.g., `anjolomole@unima.ac.mw`)
2. Firebase Auth stores this email in `FirebaseAuth.instance.currentUser.email`
3. Main layout widget retrieves this email
4. It looks up the email in the user registry
5. Finds the matching full name and department
6. Displays them on the dashboard

## Example User Display

### When tbodzambewe logs in:
```
Top Right Shows:
┌─────────────────────┐
│  T. Bodzambewe      │
│  Library Services   │
└─────────────────────┘
```

### When anjolomole logs in:
```
Top Right Shows:
┌─────────────────────┐
│  Anjolo Mole        │
│  Library Services   │
└─────────────────────┘
```

## Customization

### To Change a User's Display Name

Edit `lib/models/user_profile.dart`:

Before:
```dart
'anjolomole@unima.ac.mw': UserProfile(
  email: 'anjolomole@unima.ac.mw',
  fullName: 'Anjolo Mole',
  department: 'Library Services',
),
```

After:
```dart
'anjolomole@unima.ac.mw': UserProfile(
  email: 'anjolomole@unima.ac.mw',
  fullName: 'Dr. Anjolo Mole',
  department: 'Head - Library Services',
),
```

### To Add a New User

Add a new entry to the `userRegistry`:

```dart
'newperson@unima.ac.mw': UserProfile(
  email: 'newperson@unima.ac.mw',
  fullName: 'New Person Name',
  department: 'Library Services',
),
```

### To Change Department Name

Simply update the `department` field for that user:

```dart
'user@unima.ac.mw': UserProfile(
  email: 'user@unima.ac.mw',
  fullName: 'User Name',
  department: 'Cataloging Department',  // Changed from 'Library Services'
),
```

## Current Authorized Users

| Email | Display Name | Department |
|-------|--------------|-----------|
| tbodzambewe@unima.aw | T. Bodzambewe | Library Services |
| anjolomole@unima.ac.mw | Anjolo Mole | Library Services |
| fmwalemba@unima.ac.mw | F. Mwalemba | Library Services |
| admin@unima.ac.mw | Administrator | Library Services |

## Fallback Behavior

If a user logs in with an email that's not in the registry, the system will:
1. Extract the username part before the @ symbol
2. Display it as the user name
3. Example: `john.doe@gmail.com` → displays as "john.doe"

This ensures the app never crashes even if an unexpected user logs in.

## Integration with Audit System

The user name displayed is also included in audit logs:
- Access logs show which user logged in
- Activity logs show which user performed actions
- All with their full name from the registry

## Technical Details

### Key Functions

**getUserProfile(String email)**
- Returns the UserProfile object for an email
- Returns null if not found

**getUserDisplayName(String email)**
- Returns the display name for a user
- Falls back to email username if not found

**getUserDepartment(String email)**
- Returns the department for a user
- Falls back to "Library Services" if not found

## Testing

To test the user display:

1. Log in with `admin@unima.ac.mw`
   - Should show "Administrator" in top right

2. Log out and log in with `anjolomole@unima.ac.mw`
   - Should show "Anjolo Mole" in top right

3. Check mobile view by resizing window
   - Drawer header should show the name

## Performance

- Zero performance impact
- Lookup is instant (HashMap)
- Names are static, loaded once
- No Firebase queries needed

## Security Notes

- User emails are obtained from Firebase Auth (secure)
- Display names are just for UI (not sensitive)
- Access is still controlled by Firebase Auth
- Unauthorized users cannot log in

---

**Status**: ✅ Complete and Working
**Last Updated**: 2024
