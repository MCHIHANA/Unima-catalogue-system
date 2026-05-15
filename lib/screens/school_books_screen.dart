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
  String _searchQuery = '';
  late TabController _tabController;
  bool _isLawEconomicsSchool = false;

  @override
  void initState() {
    super.initState();
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
                          'Browse Books & Resources',
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
                    stream: _bookService.getBooks(),
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
                          Text(
                            'Found ${filteredBooks.length} ${filteredBooks.length == 1 ? 'book' : 'books'}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
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
