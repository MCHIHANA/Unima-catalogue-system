import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../utils/schools_and_departments.dart';

class SchoolBooksScreen extends StatefulWidget {
  final String schoolId;
  final String schoolName;

  const SchoolBooksScreen({
    super.key,
    required this.schoolId,
    required this.schoolName,
  });

  @override
  State<SchoolBooksScreen> createState() => _SchoolBooksScreenState();
}

class _SchoolBooksScreenState extends State<SchoolBooksScreen> with SingleTickerProviderStateMixin {
  final BookService _bookService = BookService();
  final TextEditingController _searchController = TextEditingController();
  // Cache the stream so rebuilds from setState (branch filter, search) don't reset it
  late final Stream<List<Book>> _booksStream;
  String _searchQuery = '';
  late TabController _tabController;
  bool _isLawEconomicsSchool = false;
  // Currently selected branch for filtering (null = all books)
  String? _selectedBranch;

  @override
  void initState() {
    super.initState();
    _booksStream = _bookService.getBooks(); // cached once — never recreated
    _isLawEconomicsSchool = widget.schoolId == 'school-of-law-economics-and-governance';
    _tabController = TabController(
      length: _isLawEconomicsSchool ? 2 : 1,
      vsync: this,
    );
    // Listen for tab changes to rebuild the UI
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<Book> _filterBooks(List<Book> books, {String? departmentFilter}) {
    // Filter by school
    var schoolBooks = books.where((book) => book.school == widget.schoolId).toList();
    
    // If this is the Law, Economics and Governance school, filter by department
    if (_isLawEconomicsSchool && departmentFilter != null) {
      schoolBooks = schoolBooks.where((book) {
        return book.department.toLowerCase().contains(departmentFilter.toLowerCase());
      }).toList();
    }

    // Filter by selected branch (matches book.branch field)
    if (_selectedBranch != null) {
      schoolBooks = schoolBooks.where((book) {
        return book.branch != null &&
            book.branch!.toLowerCase() == _selectedBranch!.toLowerCase();
      }).toList();
    }
    
    // Apply search if any
    if (_searchQuery.isNotEmpty) {
      schoolBooks = schoolBooks.where((book) {
        return book.title.toLowerCase().contains(_searchQuery) ||
               book.author.toLowerCase().contains(_searchQuery) ||
               book.category.toLowerCase().contains(_searchQuery) ||
               book.course.toLowerCase().contains(_searchQuery) ||
               book.isbn.toLowerCase().contains(_searchQuery);
      }).toList();
    }
    
    return schoolBooks;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final schoolProfile = SchoolsAndDepartments.getSchoolProfile(widget.schoolId);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: isMobile ? 200 : 250,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryNavy,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryNavy,
                      AppTheme.primaryNavy.withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 20 : 40,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getSchoolIcon(widget.schoolId),
                            size: isMobile ? 40 : 50,
                            color: AppTheme.accentGold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.schoolName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 22 : 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          schoolProfile?.description ?? 'Browse Books & Resources',
                          style: TextStyle(
                            color: AppTheme.accentGold,
                            fontSize: isMobile ? 13 : 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppTheme.primaryNavy, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value.toLowerCase();
                              });
                            },
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Search books in this school...',
                              hintStyle: TextStyle(
                                color: AppTheme.textGrey,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.close, color: AppTheme.textGrey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildBranchAndNavigationSection(),
                  const SizedBox(height: 24),

                  // Tab bar for Law & Economics school
                  if (_isLawEconomicsSchool)
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicatorColor: AppTheme.primaryNavy,
                            labelColor: AppTheme.primaryNavy,
                            unselectedLabelColor: AppTheme.textGrey,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            tabs: const [
                              Tab(
                                text: 'Law',
                                icon: Icon(Icons.gavel_rounded, size: 20),
                              ),
                              Tab(
                                text: 'Economics',
                                icon: Icon(Icons.trending_up_rounded, size: 20),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Books List
                  StreamBuilder<List<Book>>(
                    stream: _booksStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState();
                      }

                      // Handle both regular schools and Law & Economics school
                      late List<Book> filteredBooks;
                      if (_isLawEconomicsSchool) {
                        if (_tabController.index == 0) {
                          // Law tab
                          filteredBooks = _filterBooks(snapshot.data!, departmentFilter: 'Law');
                        } else {
                          // Economics tab
                          filteredBooks = _filterBooks(snapshot.data!, departmentFilter: 'Economics');
                        }
                      } else {
                        filteredBooks = _filterBooks(snapshot.data!);
                      }

                      if (filteredBooks.isEmpty) {
                        return _buildNoResults();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Found ${filteredBooks.length} ${filteredBooks.length == 1 ? 'book' : 'books'}${_selectedBranch != null ? ' in "$_selectedBranch"' : ''}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ),
                              if (_selectedBranch != null)
                                TextButton.icon(
                                  onPressed: () => setState(() => _selectedBranch = null),
                                  icon: const Icon(Icons.close_rounded, size: 15),
                                  label: const Text('Clear branch filter', style: TextStyle(fontSize: 12)),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          ...filteredBooks.map((book) => _buildBookCard(book, isMobile)),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchAndNavigationSection() {
    final schoolProfile = SchoolsAndDepartments.getSchoolProfile(widget.schoolId);
    final branches = schoolProfile?.branches ?? [];
    final otherSchools = SchoolsAndDepartments.getSchools()
        .where((schoolId) => schoolId != widget.schoolId)
        .toList();

    // Show only 5 branches; reveal the rest via "See more"
    const int previewCount = 5;
    final previewBranches = branches.take(previewCount).toList();
    final hasMore = branches.length > previewCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryNavy.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.explore_rounded,
                  color: AppTheme.primaryNavy,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Academic branches & quick navigation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Browse specialisations in this school and jump to another school instantly.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textGrey,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Branch filter active banner ─────────────────────────────
          if (_selectedBranch != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primaryNavy.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt_rounded, size: 16, color: AppTheme.primaryNavy),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Showing books for: $_selectedBranch',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _selectedBranch = null),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Key branches',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryNavy,
                ),
              ),
              if (_selectedBranch != null)
                TextButton.icon(
                  onPressed: () => setState(() => _selectedBranch = null),
                  icon: const Icon(Icons.clear_all_rounded, size: 15),
                  label: const Text('Show all', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textGrey,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Branch chips (preview only) ─────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...previewBranches.map((branch) => _buildBranchChip(branch)),
              // "See more" button
              if (hasMore)
                GestureDetector(
                  onTap: () => _showAllBranchesSheet(branches),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryNavy.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppTheme.primaryNavy.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded, size: 14, color: AppTheme.primaryNavy),
                        const SizedBox(width: 4),
                        Text(
                          'See ${branches.length - previewCount} more',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),
          const Text(
            'Explore other schools',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: otherSchools.map((schoolId) {
              final profile = SchoolsAndDepartments.getSchoolProfile(schoolId);
              if (profile == null) {
                return const SizedBox.shrink();
              }
              return InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SchoolBooksScreen(
                      schoolId: profile.id,
                      schoolName: profile.displayName,
                    ),
                  ),
                ),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.primaryNavy.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(profile.icon, size: 18, color: AppTheme.primaryNavy),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          profile.displayName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Single branch chip — highlighted when selected
  Widget _buildBranchChip(String branch) {
    final isSelected = _selectedBranch == branch;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBranch = isSelected ? null : branch;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryNavy
              : AppTheme.accentGold.withOpacity(0.12),
          borderRadius: BorderRadius.circular(999),
          border: isSelected
              ? Border.all(color: AppTheme.primaryNavy)
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_rounded, size: 13, color: Colors.white),
              const SizedBox(width: 5),
            ],
            Text(
              branch,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppTheme.primaryNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom sheet showing all branches
  void _showAllBranchesSheet(List<String> branches) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.account_tree_rounded, color: AppTheme.primaryNavy, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'All Academic Branches',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textDark,
                            ),
                          ),
                          Text(
                            '${branches.length} branches in this school',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded, color: AppTheme.textGrey),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Branch list
              Expanded(
                child: ListView.separated(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: branches.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final branch = branches[i];
                    final isSelected = _selectedBranch == branch;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedBranch = isSelected ? null : branch;
                        });
                        Navigator.pop(ctx); // close sheet after selection
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryNavy.withOpacity(0.06)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryNavy.withOpacity(0.3)
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? AppTheme.primaryNavy : AppTheme.accentGold,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                branch,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? AppTheme.primaryNavy : AppTheme.textDark,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded,
                                  color: AppTheme.primaryNavy, size: 18),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookCard(Book book, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppTheme.primaryNavy,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryNavy,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: AppTheme.textGrey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            book.author,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textGrey,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(book.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getStatusColor(book.status).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _getStatusText(book.status),
                  style: TextStyle(
                    color: _getStatusColor(book.status),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              _buildInfoChip(Icons.category_outlined, book.category),
              _buildInfoChip(Icons.school_outlined, book.course),
              _buildInfoChip(Icons.qr_code, book.isbn),
              _buildInfoChip(Icons.business_outlined, book.department),
              _buildInfoChip(Icons.trending_up, '${book.searchCount} searches'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.textGrey),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textGrey,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No books available in ${widget.schoolName}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new additions',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          const Text(
            'No books found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSchoolIcon(String school) {
    if (school.contains('education')) return Icons.school_rounded;
    if (school.contains('arts')) return Icons.palette_rounded;
    if (school.contains('humanities')) return Icons.history_edu_rounded;
    if (school.contains('science')) return Icons.science_rounded;
    if (school.contains('law')) return Icons.gavel_rounded;
    return Icons.school_rounded;
  }

  Color _getStatusColor(String status) {
    if (status.contains('AVAILABLE')) return Colors.green;
    if (status.contains('E-RESOURCE')) return Colors.blue;
    if (status.contains('RESERVED')) return Colors.orange;
    if (status.contains('UNAVAILABLE')) return Colors.red;
    return AppTheme.primaryNavy;
  }

  String _getStatusText(String status) {
    if (status.contains('PHYSICAL COPY AVAILABLE')) return 'AVAILABLE';
    if (status.contains('E-RESOURCE')) return 'E-BOOK';
    if (status.contains('SHORT TERM')) return 'SHORT LOAN';
    if (status.contains('NEW ARRIVAL')) return 'NEW';
    if (status.contains('RESERVED')) return 'RESERVED';
    if (status.contains('UNAVAILABLE')) return 'UNAVAILABLE';
    return status;
  }
}
