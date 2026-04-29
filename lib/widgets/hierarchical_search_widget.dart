import 'package:flutter/material.dart';
import '../models/book.dart';
import '../theme/app_theme.dart';
import '../utils/schools_and_departments.dart';

class HierarchicalSearchWidget extends StatefulWidget {
  final List<Book> allBooks;
  final void Function(List<Book> results, bool isActive) onSearchResults;

  const HierarchicalSearchWidget({
    super.key,
    required this.allBooks,
    required this.onSearchResults,
  });

  @override
  State<HierarchicalSearchWidget> createState() =>
      _HierarchicalSearchWidgetState();
}

class _HierarchicalSearchWidgetState extends State<HierarchicalSearchWidget> {
  String? _selectedSchool;
  String? _selectedDepartment;
  String _bookSearchQuery = '';
  final TextEditingController _bookSearchCtrl = TextEditingController();

  void _notifyResults(List<Book> results, bool isActive) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onSearchResults(results, isActive);
    });
  }

  void _updateResults() {
    List<Book> results = List.from(widget.allBooks);

    // Filter by school
    if (_selectedSchool != null) {
      results = results.where((b) => b.school == _selectedSchool).toList();
    }

    // Filter by department
    if (_selectedDepartment != null) {
      results = results.where((b) => b.department == _selectedDepartment).toList();
    }

    // Filter by book search
    if (_bookSearchQuery.isNotEmpty) {
      final query = _bookSearchQuery.toLowerCase();
      results = results.where((b) =>
        b.title.toLowerCase().contains(query) ||
        b.author.toLowerCase().contains(query) ||
        b.isbn.toLowerCase().contains(query) ||
        b.course.toLowerCase().contains(query),
      ).toList();
    }

    final isActive = _selectedSchool != null || _selectedDepartment != null || _bookSearchQuery.isNotEmpty;
    _notifyResults(results, isActive);
  }

  void _resetFilters() {
    setState(() {
      _selectedSchool = null;
      _selectedDepartment = null;
      _bookSearchQuery = '';
      _bookSearchCtrl.clear();
    });
    _updateResults();
  }

  @override
  Widget build(BuildContext context) {
    final schools = SchoolsAndDepartments.getSchools();
    final departments = _selectedSchool != null
        ? SchoolsAndDepartments.getDepartments(_selectedSchool!)
        : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Advanced Search Filters',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            if (_selectedSchool != null ||
                _selectedDepartment != null ||
                _bookSearchQuery.isNotEmpty)
              TextButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(Icons.clear_all_rounded, size: 16),
                label: const Text('Reset All'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Schools Dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: DropdownButton<String?>(
            isExpanded: true,
            hint: const Text(
              'Select School',
              style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
            ),
            value: _selectedSchool,
            underline: const SizedBox(),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All Schools'),
              ),
              ...schools.map((school) {
                return DropdownMenuItem<String?>(
                  value: school,
                  child: Text(SchoolsAndDepartments.formatSchoolName(school)),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedSchool = value;
                _selectedDepartment = null;
              });
              _updateResults();
            },
          ),
        ),
        const SizedBox(height: 12),

        // Departments Dropdown
        if (_selectedSchool != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: DropdownButton<String?>(
              isExpanded: true,
              hint: const Text(
                'Select Department',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
              ),
              value: _selectedDepartment,
              underline: const SizedBox(),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All Departments'),
                ),
                ...departments.map((dept) {
                  return DropdownMenuItem<String?>(
                    value: dept,
                    child: Text(dept),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => _selectedDepartment = value);
                _updateResults();
              },
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Book Search
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded,
                  color: AppTheme.textGrey, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _bookSearchCtrl,
                  onChanged: (value) {
                    setState(() => _bookSearchQuery = value);
                    _updateResults();
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search by title, author, ISBN...',
                    hintStyle:
                        TextStyle(fontSize: 12, color: AppTheme.textGrey),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    filled: false,
                  ),
                ),
              ),
              if (_bookSearchQuery.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _bookSearchCtrl.clear();
                    setState(() => _bookSearchQuery = '');
                    _updateResults();
                  },
                  child: const Icon(Icons.close_rounded,
                      color: AppTheme.textGrey, size: 16),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Active Filters Display
        if (_selectedSchool != null ||
            _selectedDepartment != null ||
            _bookSearchQuery.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_selectedSchool != null)
                Chip(
                  label: Text(
                    SchoolsAndDepartments.formatSchoolName(_selectedSchool!),
                    style: const TextStyle(fontSize: 11),
                  ),
                  onDeleted: () {
                    setState(() {
                      _selectedSchool = null;
                      _selectedDepartment = null;
                    });
                    _updateResults();
                  },
                  backgroundColor: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                  labelStyle: const TextStyle(color: Color(0xFF4F46E5)),
                ),
              if (_selectedDepartment != null)
                Chip(
                  label: Text(
                    _selectedDepartment!,
                    style: const TextStyle(fontSize: 11),
                  ),
                  onDeleted: () {
                    setState(() => _selectedDepartment = null);
                    _updateResults();
                  },
                  backgroundColor:
                      AppTheme.accentGold.withValues(alpha: 0.1),
                  labelStyle: const TextStyle(color: AppTheme.accentGold),
                ),
              if (_bookSearchQuery.isNotEmpty)
                Chip(
                  label: Text(
                    'Book: "$_bookSearchQuery"',
                    style: const TextStyle(fontSize: 11),
                  ),
                  onDeleted: () {
                    _bookSearchCtrl.clear();
                    setState(() => _bookSearchQuery = '');
                    _updateResults();
                  },
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  labelStyle: const TextStyle(color: Colors.green),
                ),
            ],
          ),
      ],
    );
  }

  @override
  void dispose() {
    _bookSearchCtrl.dispose();
    super.dispose();
  }
}
