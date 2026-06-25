import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../services/report_service.dart';
import '../utils/schools_and_departments.dart';
import '../widgets/hierarchical_search_widget.dart';
import 'login_screen.dart';
import 'school_books_screen.dart';

class StudentSearchScreen extends StatefulWidget {
  const StudentSearchScreen({super.key});

  @override
  State<StudentSearchScreen> createState() => _StudentSearchScreenState();
}

class _StudentSearchScreenState extends State<StudentSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BookService _bookService = BookService();
  final ReportService _reportService = ReportService();
  String _searchQuery = '';
  bool _isSearching = false;
  bool _hasHierarchyActive = false;
  List<Book> _hierarchyFilteredBooks = [];
  List<Book> _allBooks = [];
  final Set<String> _searchedBookIds = {}; // Track which books have been counted
  String _lastLoggedQuery = '';

  // Background image rotation
  int _currentImageIndex = 0;
  final List<String> _backgroundImages = [
    'assets/images/books.png',
    'assets/images/image2.jpg',
    'assets/images/books22.avif',
    'assets/images/Library-Shelving-1.jpg',
  ];
  Timer? _imageTimer;

  @override
  void initState() {
    super.initState();
    // Start background image rotation every 5 seconds
    _imageTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _backgroundImages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _imageTimer?.cancel();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _searchedBookIds.clear(); // Reset when search is cleared
      }
    });
  }

  void _submitSearch() {
    final query = _searchController.text.trim();
    _performSearch(query);
    if (query.isEmpty || _lastLoggedQuery == query) return;
    _lastLoggedQuery = query;
    final results = _filterBooks(_allBooks);
    _reportService.logSearchQuery(query, results.isNotEmpty);
  }

  void _onHierarchySearchResults(List<Book> results, bool isActive) {
    if (!mounted) return;
    setState(() {
      _hierarchyFilteredBooks = results;
      _hasHierarchyActive = isActive;
    });
  }

  List<Book> _filterBooks(List<Book> books) {
    final baseBooks = _hasHierarchyActive ? _hierarchyFilteredBooks : books;
    if (_searchQuery.isEmpty) {
      return _hasHierarchyActive ? baseBooks : [];
    }
    
    final results = baseBooks.where((book) {
      return book.title.toLowerCase().contains(_searchQuery) ||
             book.author.toLowerCase().contains(_searchQuery) ||
             book.category.toLowerCase().contains(_searchQuery) ||
             book.course.toLowerCase().contains(_searchQuery) ||
             book.isbn.toLowerCase().contains(_searchQuery);
    }).toList();

    // Increment search count for found books (only once per book per session)
    for (var book in results) {
      if (book.id != null && !_searchedBookIds.contains(book.id)) {
        _searchedBookIds.add(book.id!);
        _bookService.incrementSearchCount(book.id!);
      }
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final isTablet = size.width >= 600 && size.width < 900;

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
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Rotating background images with smooth transitions
                  Container(
                    key: ValueKey<int>(_currentImageIndex),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(_backgroundImages[_currentImageIndex]),
                        fit: BoxFit.cover,
                        opacity: 0.3,
                      ),
                    ),
                  ),
                  // Dark overlay for better text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryNavy.withValues(alpha: 0.7),
                          AppTheme.primaryNavy.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                  // Content
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 20 : 40,
                        vertical: 20,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/unima_logo.jpg',
                                height: isMobile ? 40 : 50,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  Icons.account_balance_rounded,
                                  size: isMobile ? 40 : 50,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'UNIMA Library',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isMobile ? 20 : 24,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Book Search & Catalogue',
                                      style: TextStyle(
                                        color: AppTheme.accentGold,
                                        fontSize: isMobile ? 12 : 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                icon: const Icon(Icons.admin_panel_settings, color: AppTheme.accentGold, size: 20),
                label: Text(
                  isMobile ? 'Admin' : 'Admin Login',
                  style: const TextStyle(
                    color: AppTheme.accentGold,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
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
                              onChanged: _performSearch,
                              onSubmitted: (_) => _submitSearch(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Search by title, author, course, ISBN...',
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
                          IconButton(
                            icon: const Icon(Icons.search, color: AppTheme.primaryNavy),
                            onPressed: _searchQuery.isNotEmpty ? _submitSearch : null,
                          ),
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.close, color: AppTheme.textGrey),
                              onPressed: () {
                                _searchController.clear();
                                _performSearch('');
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // School Navigation Bar
                  _buildSchoolNavigationBar(isMobile),
                  const SizedBox(height: 24),

                  // Advanced School / Department Filters
                  StreamBuilder<List<Book>>(
                    stream: _bookService.getBooks(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      final allBooks = snapshot.data!;
                      return HierarchicalSearchWidget(
                        allBooks: allBooks,
                        onSearchResults: _onHierarchySearchResults,
                      );
                    },
                  ),
                  const SizedBox(height: 30),

                  // Search Results or Recommended Books
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

                      final allBooks = snapshot.data!;
                      _allBooks = allBooks;

                      if (_isSearching || _hasHierarchyActive) {
                        final searchResults = _filterBooks(allBooks);
                        return _buildSearchResults(searchResults, isMobile);
                      } else {
                        return _buildRecommendedBooks(allBooks, isMobile, isTablet);
                      }
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

  Widget _buildSearchResults(List<Book> results, bool isMobile) {
    if (results.isEmpty) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Found ${results.length} ${results.length == 1 ? 'book' : 'books'}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 24),
        ...results.map((book) => _buildBookCard(book, isMobile)),
      ],
    );
  }

  Widget _buildRecommendedBooks(List<Book> allBooks, bool isMobile, bool isTablet) {
    // Get top searched books
    final topSearched = List<Book>.from(allBooks)
      ..sort((a, b) => b.searchCount.compareTo(a.searchCount));
    final mustRead = topSearched.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppTheme.accentGold, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Must-Read Books',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Most searched and recommended by students',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 32),
        if (isMobile || isTablet)
          ...mustRead.map((book) => _buildBookCard(book, isMobile))
        else
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: mustRead.map((book) => SizedBox(
              width: (MediaQuery.of(context).size.width - 128) / 2,
              child: _buildBookCard(book, isMobile),
            )).toList(),
          ),
      ],
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
            color: Colors.black.withValues(alpha: 0.04),
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
                  color: AppTheme.primaryNavy.withValues(alpha: 0.1),
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
                  color: _getStatusColor(book.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getStatusColor(book.status).withValues(alpha: 0.3),
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
          const Text(
            'No books available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The library catalogue is currently empty',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
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

  Widget _buildSchoolNavigationBar(bool isMobile) {
    final schools = SchoolsAndDepartments.getSchools();
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: AppTheme.accentGold,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Browse by School',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Select a school to view all available books',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate card width based on screen size
                // For mobile: 2 cards per row, for tablet: 3 cards, for desktop: 5 cards
                int cardsPerRow;
                if (screenWidth < 600) {
                  cardsPerRow = 2; // Mobile
                } else if (screenWidth < 900) {
                  cardsPerRow = 3; // Tablet
                } else if (screenWidth < 1200) {
                  cardsPerRow = 4; // Small desktop
                } else {
                  cardsPerRow = 5; // Large desktop - all 5 schools in one row
                }
                
                // Calculate card width with proper spacing
                final totalSpacing = (cardsPerRow - 1) * 16.0; // 16px gap between cards
                final cardWidth = (constraints.maxWidth - totalSpacing) / cardsPerRow;
                
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.spaceBetween,
                  children: schools.map((school) {
                    final schoolName = SchoolsAndDepartments.formatSchoolName(school);
                    final icon = _getSchoolIcon(school);
                    
                    return SizedBox(
                      width: cardWidth,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SchoolBooksScreen(
                                schoolId: school,
                                schoolName: schoolName,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.primaryNavy,
                                AppTheme.primaryNavy.withOpacity(0.9),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.accentGold.withOpacity(0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryNavy.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentGold.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.accentGold.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  icon,
                                  color: AppTheme.accentGold,
                                  size: 36,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                schoolName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppTheme.accentGold,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                  height: 1.3,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentGold.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.accentGold.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Explore',
                                      style: TextStyle(
                                        color: AppTheme.accentGold,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: AppTheme.accentGold,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
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

  Color _getSchoolColor(String school) {
    if (school.contains('education')) return const Color(0xFF10B981);
    if (school.contains('arts')) return const Color(0xFFEC4899);
    if (school.contains('humanities')) return const Color(0xFF8B5CF6);
    if (school.contains('science')) return const Color(0xFF3B82F6);
    if (school.contains('law')) return const Color(0xFFF59E0B);
    return AppTheme.primaryNavy;
  }

  Widget _buildSchoolBooks(List<Book> books, String school, bool isMobile) {
    final schoolName = SchoolsAndDepartments.formatSchoolName(school);
    final color = _getSchoolColor(school);
    
    if (books.isEmpty) {
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
              'No books available in $schoolName',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getSchoolIcon(school),
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schoolName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${books.length} ${books.length == 1 ? 'book' : 'books'} available',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ...books.map((book) => _buildBookCard(book, isMobile)),
      ],
    );
  }
}
