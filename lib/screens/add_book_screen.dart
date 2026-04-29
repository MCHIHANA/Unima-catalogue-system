import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../utils/schools_and_departments.dart';

class AddBookScreen extends StatefulWidget {
  /// If [book] is provided, the screen operates in Edit mode.
  final Book? book;

  const AddBookScreen({super.key, this.book});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _authorCtrl;
  late final TextEditingController _isbnCtrl;
  late final TextEditingController _courseCtrl;
  late final TextEditingController _searchCountCtrl;

  String _selectedCategory = 'LAW';
  String _selectedStatus = 'PHYSICAL COPY AVAILABLE';
  String _selectedSchool = 'school-of-natural-and-applied-sciences';
  String _selectedDepartment = 'Department of Computer Science';

  bool _isLoading = false;

  bool get _isEditing => widget.book != null;

  final List<String> _categories = [
    'LAW', 'ECONOMICS', 'MEDICINE', 'COMPSCI',
    'HISTORY', 'BIOLOGY', 'ENGLISH', 'MATHEMATICS',
  ];

  final List<String> _statuses = [
    'PHYSICAL COPY AVAILABLE',
    'E-RESOURCE AVAILABLE',
    'SHORT TERM LOAN ONLY',
    'NEW ARRIVAL',
    'RESERVED',
    'UNAVAILABLE',
  ];

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _titleCtrl       = TextEditingController(text: b?.title ?? '');
    _authorCtrl      = TextEditingController(text: b?.author ?? '');
    _isbnCtrl        = TextEditingController(text: b?.isbn ?? '');
    _courseCtrl      = TextEditingController(text: b?.course ?? '');
    _searchCountCtrl = TextEditingController(text: b != null ? '${b.searchCount}' : '0');
    if (b != null) {
      _selectedCategory = b.category;
      _selectedStatus   = b.status;
      // Ensure school is valid, fallback to first available
      _selectedSchool = SchoolsAndDepartments.getSchools().contains(b.school) 
          ? b.school 
          : SchoolsAndDepartments.getSchools().first;
      // Ensure department is valid for the selected school, fallback to first department
      final validDepartments = SchoolsAndDepartments.getDepartments(_selectedSchool);
      _selectedDepartment = validDepartments.contains(b.department) 
          ? b.department 
          : validDepartments.first;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _isbnCtrl.dispose();
    _courseCtrl.dispose();
    _searchCountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final newBook = Book(
          id: widget.book?.id,
          title:       _titleCtrl.text.trim(),
          author:      _authorCtrl.text.trim(),
          isbn:        _isbnCtrl.text.trim(),
          category:    _selectedCategory,
          course:      _courseCtrl.text.trim(),
          searchCount: int.tryParse(_searchCountCtrl.text.trim()) ?? widget.book?.searchCount ?? 0,
          status:      _selectedStatus,
          school:      _selectedSchool,
          department:  _selectedDepartment,
        );

        final service = BookService();
        if (_isEditing) {
          await service.updateBook(newBook);
        } else {
          await service.addBook(newBook);
        }

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving book: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      // ── Premium App Bar ──────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppTheme.primaryNavy,
          tooltip: 'Back to Manage Books',
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isEditing
                    ? AppTheme.accentGold.withOpacity(0.1)
                    : AppTheme.primaryNavy.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _isEditing ? Icons.edit_rounded : Icons.add_rounded,
                color: _isEditing ? AppTheme.accentGold : AppTheme.primaryNavy,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Edit Book Entry' : 'Add New Book',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'University of Malawi Institutional Repository',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF1F3F9), height: 1),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _submit,
              icon: _isLoading 
                  ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Icon(_isEditing ? Icons.save_rounded : Icons.add_circle_outline_rounded, size: 18),
              label: Text(_isEditing ? 'Save Changes' : 'Add Book'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isEditing ? AppTheme.accentGold : AppTheme.primaryNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
                textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
          ),
        ],
      ),

      // ── Body ─────────────────────────────────────────────────────────────
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 900 : double.infinity),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 60 : 20,
              vertical: 32,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Section 1: Book Information ─────────────────────────
                  _sectionHeader('Book Information', Icons.book_rounded),
                  const SizedBox(height: 28),

                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _field('Book Title *', _titleCtrl, 'e.g. Introduction to Law and Legal Systems', required: true)),
                        const SizedBox(width: 20),
                        Expanded(child: _field('Author *', _authorCtrl, 'e.g. Chigawa, M.', required: true)),
                      ],
                    )
                  else ...[
                    _field('Book Title *', _titleCtrl, 'e.g. Introduction to Law and Legal Systems', required: true),
                    const SizedBox(height: 20),
                    _field('Author *', _authorCtrl, 'e.g. Chigawa, M.', required: true),
                  ],

                  const SizedBox(height: 20),

                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _field('ISBN', _isbnCtrl, 'e.g. 978-99908-0-1')),
                        const SizedBox(width: 20),
                        Expanded(child: _field('Course Code *', _courseCtrl, 'e.g. LAW 110', required: true)),
                        const SizedBox(width: 20),
                        Expanded(child: _field('Search Count', _searchCountCtrl, '0', isNumber: true)),
                      ],
                    )
                  else ...[
                    _field('ISBN', _isbnCtrl, 'e.g. 978-99908-0-1'),
                    const SizedBox(height: 20),
                    _field('Course Code *', _courseCtrl, 'e.g. LAW 110', required: true),
                    const SizedBox(height: 20),
                    _field('Search Count', _searchCountCtrl, '0', isNumber: true),
                  ],

                  const SizedBox(height: 36),

                  // ── Section 2: School & Department ──────────────────────
                  _sectionHeader('School & Department', Icons.domain_rounded),
                  const SizedBox(height: 28),

                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _dropdown('School *', SchoolsAndDepartments.getSchools(), _selectedSchool, (v) {
                          setState(() {
                            _selectedSchool = v!;
                            _selectedDepartment = SchoolsAndDepartments.getDepartments(v).first;
                          });
                        }, formatLabel: true)),
                        const SizedBox(width: 20),
                        Expanded(child: _dropdown('Department *', SchoolsAndDepartments.getDepartments(_selectedSchool), _selectedDepartment, (v) => setState(() => _selectedDepartment = v!))),
                      ],
                    )
                  else ...[
                    _dropdown('School *', SchoolsAndDepartments.getSchools(), _selectedSchool, (v) {
                      setState(() {
                        _selectedSchool = v!;
                        _selectedDepartment = SchoolsAndDepartments.getDepartments(v).first;
                      });
                    }, formatLabel: true),
                    const SizedBox(height: 20),
                    _dropdown('Department *', SchoolsAndDepartments.getDepartments(_selectedSchool), _selectedDepartment, (v) => setState(() => _selectedDepartment = v!)),
                  ],

                  const SizedBox(height: 36),

                  // ── Section 3: Classification ───────────────────────────
                  _sectionHeader('Classification & Status', Icons.label_rounded),
                  const SizedBox(height: 28),

                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _dropdown('Category *', _categories, _selectedCategory, (v) => setState(() => _selectedCategory = v!))),
                        const SizedBox(width: 20),
                        Expanded(child: _dropdown('Availability Status *', _statuses, _selectedStatus, (v) => setState(() => _selectedStatus = v!))),
                      ],
                    )
                  else ...[
                    _dropdown('Category *', _categories, _selectedCategory, (v) => setState(() => _selectedCategory = v!)),
                    const SizedBox(height: 20),
                    _dropdown('Availability Status *', _statuses, _selectedStatus, (v) => setState(() => _selectedStatus = v!)),
                  ],

                  const SizedBox(height: 48),

                  // ── Action row ─────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textDark,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                          side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _submit,
                        icon: _isLoading 
                            ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Icon(_isEditing ? Icons.save_rounded : Icons.add_circle_outline_rounded, size: 20),
                        label: Text(_isEditing ? 'Save Changes' : 'Add Book'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isEditing ? AppTheme.accentGold : AppTheme.primaryNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                          textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryNavy),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
        const SizedBox(width: 14),
        Expanded(child: Container(height: 1, color: const Color(0xFFF1F3F9))),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    String hint, {
    bool required = false,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textGrey, letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppTheme.textGrey.withOpacity(0.5), fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 2)),
          ),
          validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'This field is required' : null : null,
        ),
      ],
    );
  }

  Widget _dropdown(String label, List<String> items, String value, ValueChanged<String?> onChanged, {bool formatLabel = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textGrey, letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          isExpanded: true,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 2)),
          ),
          items: items.map((e) {
            final displayText = formatLabel ? SchoolsAndDepartments.formatSchoolName(e) : e;
            return DropdownMenuItem(value: e, child: Text(displayText, overflow: TextOverflow.ellipsis, maxLines: 1));
          }).toList(),
          validator: (v) => v == null ? 'Please select an option' : null,
        ),
      ],
    );
  }
}
