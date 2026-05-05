class SchoolsAndDepartments {
  static const Map<String, List<String>> schoolDepartments = {
    'school-of-education': [
      'Department of Initial Teacher Education',
      'Department of Continuing Education',
      'Department of Educational Studies',
      'Department of Physical Education',
    ],
    'school-of-arts-communication-and-design': [
      'Department of Arts',
      'Department of Communication',
      'Department of Design',
      'Department of Creative Arts',
      'Department of Media Studies',
    ],
    'school-of-humanities-and-social-sciences': [
      'Department of History',
      'Department of Philosophy',
      'Department of Sociology',
      'Department of Political Science',
      'Department of Psychology',
      'Department of Economics',
    ],
    'school-of-natural-and-applied-sciences': [
      'Department of Biology',
      'Department of Chemistry',
      'Department of Physics',
      'Department of Mathematics',
      'Department of Computer Science',
      'Department of Engineering',
      'Department of Environmental Studies',
    ],
    'school-of-law-economics-and-governance': [
      'Department of Law',
      'Department of Economics',
      'Department of Public Administration',
      'Department of Development Studies',
      'Department of Governance and Public Policy',
    ],
  };

  static List<String> getSchools() {
    return schoolDepartments.keys.toList();
  }

  static List<String> getDepartments(String school) {
    return schoolDepartments[school] ?? [];
  }

  static String formatSchoolName(String school) {
    return school
        .split('-')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
