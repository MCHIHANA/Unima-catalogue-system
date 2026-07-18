import 'package:flutter_test/flutter_test.dart';
import 'package:unima_library_catalogue/utils/schools_and_departments.dart';

void main() {
  test('law and economics school exposes detailed branches', () {
    final branches = SchoolsAndDepartments.getSchoolBranches(
      'school-of-law-economics-and-governance',
    );

    expect(branches, contains('Constitutional Law'));
    expect(branches, contains('Microeconomics'));
    expect(branches.length, greaterThan(10));
  });
}
