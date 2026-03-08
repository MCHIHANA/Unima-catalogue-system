import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/book.dart';
import '../widgets/main_layout.dart';
import 'add_book_screen.dart';

class ManageBooksScreen extends StatefulWidget {
  const ManageBooksScreen({super.key});

  @override
  State<ManageBooksScreen> createState() => _ManageBooksScreenState();
}

class _ManageBooksScreenState extends State<ManageBooksScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  List<Book> _books = [
    Book(title: 'Introduction to Law and Legal Systems', author: 'Chigawa, M.', isbn: '978-99908-0-1', category: 'LAW', course: 'LAW 110', searchCount: 1245, status: 'PHYSICAL COPY AVAILABLE'),
    Book(title: 'Macroeconomics: Theory and Policy', author: 'Kandoje, P.', isbn: '978-99908-0-2', category: 'ECONOMICS', course: 'ECO 210', searchCount: 892, status: 'E-RESOURCE AVAILABLE'),
    Book(title: 'Public Health Nursing Principles', author: 'Manda, A.', isbn: '978-99908-0-3', category: 'MEDICINE', course: 'NUR 305', searchCount: 2120, status: 'SHORT TERM LOAN ONLY'),
    Book(title: 'Advanced Data Structures', author: 'Phiri, J.', isbn: '978-99908-0-4', category: 'COMPSCI', course: 'CSC 221', searchCount: 674, status: 'NEW ARRIVAL'),
    Book(title: 'History of Southern Africa', author: 'Chambo, M. C.', isbn: '978-99908-0-5', category: 'HISTORY', course: 'HST 201', searchCount: 541, status: 'PHYSICAL COPY AVAILABLE'),
  ];

  List<Book> get _filtered {
    if (_query.isEmpty) return List.from(_books);
    final q = _query.toLowerCase();
    return _books.where((b) =>
      b.title.toLowerCase().contains(q) ||
      b.author.toLowerCase().contains(q) ||
      b.isbn.toLowerCase().contains(q) ||
      b.course.toLowerCase().contains(q) ||
      b.category.toLowerCase().contains(q),
    ).toList();
  }

  Future<void> _navigateToAdd() async {
    final result = await Navigator.push<Book>(
      context,
      MaterialPageRoute(builder: (_) => const AddBookScreen()),
    );
    if (result != null && mounted) {
      setState(() => _books.add(result));
      _showSnack('Added: ${result.title}', success: true);
    }
  }

  Future<void> _navigateToEdit(int realIndex) async {
    final result = await Navigator.push<Book>(
      context,
      MaterialPageRoute(builder: (_) => AddBookScreen(book: _books[realIndex])),
    );
    if (result != null && mounted) {
      setState(() => _books[realIndex] = result);
      _showSnack('Updated: ${result.title}', success: true);
    }
  }

  void _confirmDelete(int realIndex) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 26),
          SizedBox(width: 10),
          Text('Delete Book', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('This will permanently remove:', style: TextStyle(fontSize: 13, color: AppTheme.textGrey)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
            child: Text(_books[realIndex].title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          ),
          const SizedBox(height: 8),
          const Text('This action cannot be undone.', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final name = _books[realIndex].title;
              setState(() => _books.removeAt(realIndex));
              Navigator.pop(context);
              _showSnack('Deleted: $name', success: false);
            },
            icon: const Icon(Icons.delete_forever_rounded, size: 18),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(success ? Icons.check_circle_rounded : Icons.delete_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600))),
      ]),
      backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w > 1100;
    final hPad = isDesktop ? 60.0 : 20.0;
    final filtered = _filtered;

    return MainLayout(
      currentRoute: 'ManageBooks',
      onAddBook: _navigateToAdd,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Manage Books', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                    const SizedBox(height: 4),
                    Text('University of Malawi — Institutional Repository Console',
                        style: TextStyle(fontSize: 13, color: AppTheme.textGrey.withValues(alpha: 0.8), fontWeight: FontWeight.w500)),
                  ]),
                ),
                if (isDesktop)
                  ElevatedButton.icon(
                    onPressed: _navigateToAdd,
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text('ADD NEW BOOK'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0, textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ),
              ],
            ),
            if (!isDesktop) ...[
              const SizedBox(height: 16),
              SizedBox(width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _navigateToAdd,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('ADD NEW BOOK'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),

            // ── Search Bar ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
              ),
              child: Row(children: [
                const Icon(Icons.search_rounded, color: AppTheme.textGrey, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Search by title, author, ISBN, course code...',
                      hintStyle: TextStyle(fontSize: 13, color: AppTheme.textGrey),
                      border: InputBorder.none, enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none, contentPadding: EdgeInsets.zero, filled: false,
                    ),
                  ),
                ),
                if (_query.isNotEmpty)
                  GestureDetector(
                    onTap: () { _searchCtrl.clear(); setState(() => _query = ''); },
                    child: const Icon(Icons.close_rounded, color: AppTheme.textGrey, size: 18),
                  ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), elevation: 0,
                    textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.8),
                  ),
                  child: const Text('SEARCH'),
                ),
              ]),
            ),
            const SizedBox(height: 28),

            // ── Table ─────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(children: [
                // Table header
                Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryNavy,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                  ),
                  child: _tableRow(
                    isHeader: true,
                    title: 'TITLE', author: 'AUTHOR', isbn: 'ISBN',
                    category: 'CATEGORY', course: 'COURSE', searches: 'SEARCHES', actions: 'ACTIONS',
                  ),
                ),
                // Rows
                if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(48),
                    child: Column(children: [
                      Icon(Icons.search_off_rounded, size: 48, color: Color(0xFFD1D5DB)),
                      SizedBox(height: 16),
                      Text('No books found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textGrey)),
                      Text('Adjust your search query', style: TextStyle(fontSize: 13, color: AppTheme.textGrey)),
                    ]),
                  )
                else
                  ...filtered.asMap().entries.map((e) {
                    // find real index in _books for edit/delete
                    final realIndex = _books.indexOf(e.value);
                    return _buildBookRow(e.value, realIndex);
                  }),
                // Pagination footer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFF1F3F9)))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Showing ${filtered.length} of ${_books.length} entries',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textGrey, fontWeight: FontWeight.w600)),
                      Row(children: [
                        _pageBtn(Icons.chevron_left_rounded, false),
                        _pageNum('1', true), _pageNum('2', false), _pageNum('3', false),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('...', style: TextStyle(color: AppTheme.textGrey))),
                        _pageNum('145', false),
                        _pageBtn(Icons.chevron_right_rounded, true),
                      ]),
                    ],
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 40),

            // ── Stats Cards ───────────────────────────────────────────
            if (isDesktop)
              Row(children: [
                Expanded(child: _statsCard('TOTAL VOLUMES', '${_books.length + 14203}', Icons.library_books_rounded, const Color(0xFF4F46E5))),
                const SizedBox(width: 20),
                Expanded(child: _statsCard('ACTIVE RESERVES', '4,520', Icons.bookmark_added_rounded, AppTheme.accentGold)),
                const SizedBox(width: 20),
                Expanded(child: _statsCard('MONTHLY SEARCHES', '89,401', Icons.trending_up_rounded, Colors.green)),
              ])
            else
              Column(children: [
                _statsCard('TOTAL VOLUMES', '${_books.length + 14203}', Icons.library_books_rounded, const Color(0xFF4F46E5)),
                const SizedBox(height: 16),
                _statsCard('ACTIVE RESERVES', '4,520', Icons.bookmark_added_rounded, AppTheme.accentGold),
                const SizedBox(height: 16),
                _statsCard('MONTHLY SEARCHES', '89,401', Icons.trending_up_rounded, Colors.green),
              ]),
            const SizedBox(height: 48),

            // ── Footer ────────────────────────────────────────────────
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                const Icon(Icons.copyright_rounded, size: 13, color: AppTheme.textGrey),
                const SizedBox(width: 6),
                Text('2026 University of Malawi. All Rights Reserved.',
                    style: TextStyle(fontSize: 11, color: AppTheme.textGrey.withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
              ]),
              Wrap(spacing: 20, children: [
                _footerLink('PRIVACY POLICY'),
                _footerLink('TERMS OF USE'),
                _footerLink('CONTACT SUPPORT'),
              ]),
            ]),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── Reusable table row (works for header AND data rows) ────────────────
  Widget _tableRow({
    bool isHeader = false,
    required String title, required String author, required String isbn,
    required String category, required String course, required String searches, required String actions,
  }) {
    final style = isHeader
        ? const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)
        : const TextStyle(fontSize: 11, color: AppTheme.textGrey, fontWeight: FontWeight.w700, letterSpacing: 0.3);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(children: [
        SizedBox(width: 180, child: Text(title, style: style)),
        SizedBox(width: 130, child: Text(author, style: style)),
        SizedBox(width: 130, child: Text(isbn, style: style)),
        SizedBox(width: 90, child: Text(category, style: style, textAlign: TextAlign.center)),
        SizedBox(width: 80, child: Text(course, style: style)),
        SizedBox(width: 80, child: Text(searches, style: style, textAlign: TextAlign.center)),
        SizedBox(width: 160, child: Text(actions, style: style, textAlign: TextAlign.right)),
      ]),
    );
  }

  Widget _buildBookRow(Book book, int realIndex) {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F3F9)))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(children: [
          SizedBox(
            width: 180,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(book.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.primaryNavy), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text(book.status, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF), letterSpacing: 0.3), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
          SizedBox(width: 130, child: Text(book.author, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textGrey), maxLines: 2, overflow: TextOverflow.ellipsis)),
          SizedBox(width: 130, child: Text(book.isbn, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)))),
          SizedBox(
            width: 90,
            child: Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.primaryNavy.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(4)),
              child: Text(book.category, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.primaryNavy), textAlign: TextAlign.center),
            )),
          ),
          SizedBox(width: 80, child: Text(book.course, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textDark))),
          SizedBox(width: 80, child: Text('${book.searchCount}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.textDark))),
          SizedBox(
            width: 160,
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              _actionBtn('Edit', Icons.edit_rounded, AppTheme.primaryNavy, () => _navigateToEdit(realIndex)),
              const SizedBox(width: 8),
              _actionBtn('Delete', Icons.delete_rounded, Colors.red, () => _confirmDelete(realIndex), isDanger: true),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _actionBtn(String label, IconData icon, Color color, VoidCallback onTap, {bool isDanger = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDanger ? Colors.red.withValues(alpha: 0.07) : AppTheme.primaryNavy.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
        ]),
      ),
    );
  }

  Widget _statsCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textGrey, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
        ]),
      ]),
    );
  }

  Widget _pageNum(String label, bool active) {
    return Container(
      width: 30, height: 30, margin: const EdgeInsets.symmetric(horizontal: 2), alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? AppTheme.primaryNavy : Colors.transparent, borderRadius: BorderRadius.circular(5),
        border: active ? null : Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: active ? Colors.white : AppTheme.textDark)),
    );
  }

  Widget _pageBtn(IconData icon, bool enabled) {
    return Container(
      width: 30, height: 30, margin: const EdgeInsets.symmetric(horizontal: 2), alignment: Alignment.center,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Icon(icon, size: 16, color: enabled ? AppTheme.textDark : Colors.grey.shade300),
    );
  }

  Widget _footerLink(String label) {
    return Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textGrey.withValues(alpha: 0.5), letterSpacing: 0.5));
  }
}
