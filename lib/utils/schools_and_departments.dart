import 'package:flutter/material.dart';

class SchoolProfile {
  final String id;
  final String displayName;
  final String description;
  final IconData icon;
  final List<String> branches;

  const SchoolProfile({
    required this.id,
    required this.displayName,
    required this.description,
    required this.icon,
    required this.branches,
  });
}

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

  static const Map<String, List<String>> schoolBranches = {
    'school-of-natural-and-applied-sciences': [
      'Biotechnology',
      'Microbiology',
      'Environmental Science',
      'Computer Science',
      'Physics',
      'Chemistry',
      'Mathematics',
      'Engineering',
      'Geospatial Science',
    ],
    'school-of-humanities-and-social-sciences': [
      'History',
      'Political Science',
      'Sociology',
      'Psychology',
      'Philosophy',
      'Anthropology',
      'Development Studies',
      'Community Development',
      'Gender Studies',
    ],
    'school-of-education': [
      'Curriculum Studies',
      'Educational Leadership',
      'Guidance and Counselling',
      'Special Needs Education',
      'Early Childhood Education',
      'Assessment and Measurement',
      'Physical Education',
      'Adult and Continuing Education',
    ],
    'school-of-law-economics-and-governance': [
      'Constitutional Law',
      'Criminal Law',
      'Civil Law',
      'Commercial Law',
      'International Law',
      'Environmental Law',
      'Labour and Employment Law',
      'Family Law',
      'Property Law',
      'Human Rights Law',
      'Administrative Law',
      'Tax Law',
      'Intellectual Property Law',
      'Microeconomics',
      'Macroeconomics',
      'Development Economics',
      'International Economics',
      'Public Economics',
      'Financial Economics',
      'Monetary Economics',
      'Labour Economics',
      'Agricultural Economics',
      'Environmental Economics',
      'Behavioral Economics',
      'Industrial Economics',
      'Health Economics',
      'Econometrics',
      'Mathematical Economics',
    ],
    'school-of-arts-communication-and-design': [
      'Fine Arts',
      'Graphic Design',
      'Animation',
      'Film and Media',
      'Journalism',
      'Advertising',
      'Theatre Arts',
      'Music',
      'Fashion Design',
      'Digital Media',
    ],
  };

  static const Map<String, SchoolProfile> schoolProfiles = {
    'school-of-natural-and-applied-sciences': SchoolProfile(
      id: 'school-of-natural-and-applied-sciences',
      displayName: 'School of Natural and Applied Sciences',
      description: 'Science, technology, and applied research for practical innovation.',
      icon: Icons.science_rounded,
      branches: [
        'Biotechnology',
        'Microbiology',
        'Environmental Science',
        'Computer Science',
        'Physics',
        'Chemistry',
        'Mathematics',
        'Engineering',
        'Geospatial Science',
      ],
    ),
    'school-of-humanities-and-social-sciences': SchoolProfile(
      id: 'school-of-humanities-and-social-sciences',
      displayName: 'School of Humanities and Social Sciences',
      description: 'Human culture, society, policy, and critical thinking.',
      icon: Icons.history_edu_rounded,
      branches: [
        'History',
        'Political Science',
        'Sociology',
        'Psychology',
        'Philosophy',
        'Anthropology',
        'Development Studies',
        'Community Development',
        'Gender Studies',
      ],
    ),
    'school-of-education': SchoolProfile(
      id: 'school-of-education',
      displayName: 'School of Education',
      description: 'Teaching, learning, leadership, and educational development.',
      icon: Icons.school_rounded,
      branches: [
        'Curriculum Studies',
        'Educational Leadership',
        'Guidance and Counselling',
        'Special Needs Education',
        'Early Childhood Education',
        'Assessment and Measurement',
        'Physical Education',
        'Adult and Continuing Education',
      ],
    ),
    'school-of-law-economics-and-governance': SchoolProfile(
      id: 'school-of-law-economics-and-governance',
      displayName: 'School of Law, Economics and Governance',
      description: 'Law, policy, economic thought, and public leadership.',
      icon: Icons.gavel_rounded,
      branches: [
        'Constitutional Law',
        'Criminal Law',
        'Civil Law',
        'Commercial Law',
        'International Law',
        'Environmental Law',
        'Labour and Employment Law',
        'Family Law',
        'Property Law',
        'Human Rights Law',
        'Administrative Law',
        'Tax Law',
        'Intellectual Property Law',
        'Microeconomics',
        'Macroeconomics',
        'Development Economics',
        'International Economics',
        'Public Economics',
        'Financial Economics',
        'Monetary Economics',
        'Labour Economics',
        'Agricultural Economics',
        'Environmental Economics',
        'Behavioral Economics',
        'Industrial Economics',
        'Health Economics',
        'Econometrics',
        'Mathematical Economics',
      ],
    ),
    'school-of-arts-communication-and-design': SchoolProfile(
      id: 'school-of-arts-communication-and-design',
      displayName: 'School of Arts, Communication and Design',
      description: 'Creative practice, storytelling, media, and visual communication.',
      icon: Icons.palette_rounded,
      branches: [
        'Fine Arts',
        'Graphic Design',
        'Animation',
        'Film and Media',
        'Journalism',
        'Advertising',
        'Theatre Arts',
        'Music',
        'Fashion Design',
        'Digital Media',
      ],
    ),
  };

  static List<String> getSchools() {
    return schoolProfiles.keys.toList();
  }

  static List<String> getDepartments(String school) {
    return schoolDepartments[school] ?? [];
  }

  static List<String> getSchoolBranches(String school) {
    return schoolBranches[school] ?? [];
  }

  static SchoolProfile? getSchoolProfile(String school) {
    return schoolProfiles[school];
  }

  static String formatSchoolName(String school) {
    return schoolProfiles[school]?.displayName ?? school
        .split('-')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
