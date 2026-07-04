class SchoolsAndDepartments {
  static const Map<String, List<String>> schoolDepartments = {
    'school-of-natural-and-applied-sciences': [
      'Department of Biology',
      'Department of Chemistry',
      'Department of Physics',
      'Department of Mathematics',
      'Department of Computer Science',
      'Department of Engineering',
      'Department of Environmental Studies',
    ],
    'school-of-humanities-and-social-sciences': [
      'Department of History',
      'Department of Philosophy',
      'Department of Sociology',
      'Department of Political Science',
      'Department of Psychology',
      'Department of Economics',
    ],
    'school-of-education': [
      'Department of Initial Teacher Education',
      'Department of Continuing Education',
      'Department of Educational Studies',
      'Department of Physical Education',
    ],
    'school-of-law-economics-and-governance': [
      'Department of Law',
      'Department of Economics',
      'Department of Public Administration',
      'Department of Development Studies',
      'Department of Governance and Public Policy',
    ],
    'school-of-arts-communication-and-design': [
      'Department of Arts',
      'Department of Communication',
      'Department of Design',
      'Department of Creative Arts',
      'Department of Media Studies',
    ],
  };

  static List<String> getSchools() {
    return schoolDepartments.keys.toList();
  }

  static List<String> getDepartments(String school) {
    return schoolDepartments[school] ?? [];
  }

  static String formatSchoolName(String school) {
    switch (school) {
      case 'school-of-natural-and-applied-sciences':
        return 'School of Natural and Applied Sciences';
      case 'school-of-humanities-and-social-sciences':
        return 'School of Humanities and Social Sciences';
      case 'school-of-education':
        return 'School of Education';
      case 'school-of-law-economics-and-governance':
        return 'School of Law, Economics and Government';
      case 'school-of-arts-communication-and-design':
        return 'School of Arts, Communication and Design';
    }

    return school
        .split('-')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
