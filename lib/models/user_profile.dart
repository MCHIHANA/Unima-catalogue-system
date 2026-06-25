class UserProfile {
  final String email;
  final String fullName;
  final String department;
  final bool isSuperUser;

  UserProfile({
    required this.email,
    required this.fullName,
    required this.department,
    this.isSuperUser = false,
  });
}

// User registry - maps emails to their profile information
final userRegistry = {
  'tbodzambewe@unima.ac.mw': UserProfile(
    email: 'tbodzambewe@unima.ac.mw',
    fullName: 'T. Bodzambewe',
    department: 'Library Services',
    isSuperUser: false,
  ),
  'anjolomole@unima.ac.mw': UserProfile(
    email: 'anjolomole@unima.ac.mw',
    fullName: 'Anjolo Mole',
    department: 'Library Services',
    isSuperUser: false,
  ),
  'fmwalemba@unima.ac.mw': UserProfile(
    email: 'fmwalemba@unima.ac.mw',
    fullName: 'F. Mwalemba',
    department: 'Library Services',
    isSuperUser: true,
  ),
  'admin@unima.ac.mw': UserProfile(
    email: 'admin@unima.ac.mw',
    fullName: 'Administrator',
    department: 'Library Services',
    isSuperUser: false,
  ),
};

// Function to get user profile by email
UserProfile? getUserProfile(String email) {
  return userRegistry[email.toLowerCase()];
}

// Function to get user name, fallback to email if not found
String getUserDisplayName(String email) {
  final profile = getUserProfile(email);
  return profile?.fullName ?? email.split('@')[0];
}

// Function to get user department
String getUserDepartment(String email) {
  final profile = getUserProfile(email);
  return profile?.department ?? 'Library Services';
}

// Function to check if user is a super user
bool isSuperUser(String email) {
  final profile = getUserProfile(email);
  return profile?.isSuperUser ?? false;
}
