import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/book.dart';
import '../services/book_service.dart';

class BooksAvailableScreen extends StatefulWidget {
  const BooksAvailableScreen({super.key});

  @override
  State<BooksAvailableScreen> createState() => _BooksAvailableScreenState();
}

class _BooksAvailableScreenState extends State<BooksAvailableScreen> {
  final BookService _bookService = BookService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortBy = 'title'; // 'title', 'author', 'popularity'
  bool _isGridView = false;

  // Background image rotation for premium header background
  int _currentImageIndex = 0;
  final List<String> _backgroundImages = [
    'assets/images/books.png',
    'assets/images/image2.jpg',
    'assets/images/Library-Shelving-1.jpg',
  ];
  Timer? _imageTimer;

  @override
  void initState() {
    super.initState();
    // Rotate background images
    _imageTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
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

  // Filter and sort books based on query, category, and sorting preference
  List<Book> _filterAndSortBooks(List<Book> books) {
    // 1. Filter by category
    var filtered = books;
    if (_selectedCategory != 'All') {
      filtered = filtered.where((book) {
        // Match category loosely
        return book.category.toLowerCase() == _selectedCategory.toLowerCase() ||
               book.school.toLowerCase().contains(_selectedCategory.toLowerCase()) ||
               _getSchoolNameFriendly(book.school).toLowerCase().contains(_selectedCategory.toLowerCase());
      }).toList();
    }

    // 2. Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((book) {
        return book.title.toLowerCase().contains(_searchQuery) ||
               book.author.toLowerCase().contains(_searchQuery) ||
               book.category.toLowerCase().contains(_searchQuery) ||
               book.course.toLowerCase().contains(_searchQuery) ||
               book.isbn.toLowerCase().contains(_searchQuery) ||
               book.department.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // 3. Sort
    if (_sortBy == 'title') {
      filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    } else if (_sortBy == 'author') {
      filtered.sort((a, b) => a.author.toLowerCase().compareTo(b.author.toLowerCase()));
    } else if (_sortBy == 'popularity') {
      filtered.sort((a, b) => b.searchCount.compareTo(a.searchCount));
    }

    return filtered;
  }

  String _getSchoolNameFriendly(String schoolKey) {
    if (schoolKey.contains('education')) return 'Education';
    if (schoolKey.contains('arts')) return 'Arts & Design';
    if (schoolKey.contains('humanities')) return 'Humanities';
    if (schoolKey.contains('science')) return 'Sciences';
    if (schoolKey.contains('law')) return 'Law & Governance';
    return schoolKey;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final isTablet = size.width >= 600 && size.width < 1000;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: StreamBuilder<List<Book>>(
        stream: _bookService.getBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryNavy),
            );
          }

          final allBooks = snapshot.data ?? [];
          final displayedBooks = _filterAndSortBooks(allBooks);

          // Calculate counts
          final totalCount = allBooks.length;
          final physicalAvailableCount = allBooks.where((b) => b.status.contains('AVAILABLE')).length;
          final eBookCount = allBooks.where((b) => b.status.contains('E-RESOURCE')).length;
          final reservedCount = allBooks.where((b) => b.status.contains('RESERVED')).length;

          // Extract unique categories for filter chips
          final Set<String> categories = {'All'};
          for (var b in allBooks) {
            if (b.category.isNotEmpty) {
              categories.add(b.category);
            }
          }

          return CustomScrollView(
            slivers: [
              // Premium App Bar
              SliverAppBar(
                expandedHeight: isMobile ? 220 : 280,
                floating: false,
                pinned: true,
                backgroundColor: AppTheme.primaryNavy,
                elevation: 10,
                shadowColor: AppTheme.primaryNavy.withOpacity(0.5),
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    children: [
                      // Background Image Rotation
                      AnimatedSwitcher(
                        duration: const Duration(seconds: 1),
                        child: Container(
                          key: ValueKey<int>(_currentImageIndex),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(_backgroundImages[_currentImageIndex]),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.5),
                                BlendMode.darken,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Gold overlay gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.primaryNavy.withOpacity(0.3),
                              AppTheme.primaryNavy.withOpacity(0.9),
                            ],
                          ),
                        ),
                      ),
                      // Text Content
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
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentGold.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppTheme.accentGold.withOpacity(0.5),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.library_books_rounded,
                                      color: AppTheme.accentGold,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Books Repository',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isMobile ? 26 : 34,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.5,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withOpacity(0.5),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Real-time collection directory & analytics',
                                          style: TextStyle(
                                            color: AppTheme.accentGold,
                                            fontSize: isMobile ? 13 : 16,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
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
              ),

              // Content Sliver List
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Real-time Statistics Cards (Glassmorphism inspired layout)
                      _buildStatsDashboard(
                        isMobile: isMobile,
                        total: totalCount,
                        physical: physicalAvailableCount,
                        ebooks: eBookCount,
                        reserved: reservedCount,
                      ),
                      const SizedBox(height: 32),

                      // Search & Control Bar
                      _buildControlBar(isMobile),
                      const SizedBox(height: 24),

                      // Category Filtering Chips
                      _buildCategoryFilter(categories.toList()),
                      const SizedBox(height: 28),

                      // Results Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Showing ${displayedBooks.length} of $totalCount Books',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                          // View Toggle Buttons
                          if (!isMobile)
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.list_rounded,
                                    color: !_isGridView ? AppTheme.accentGold : AppTheme.textGrey,
                                  ),
                                  onPressed: () => setState(() => _isGridView = false),
                                  tooltip: 'List View',
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    Icons.grid_view_rounded,
                                    color: _isGridView ? AppTheme.accentGold : AppTheme.textGrey,
                                  ),
                                  onPressed: () => setState(() => _isGridView = true),
                                  tooltip: 'Grid View',
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Empty State or List/Grid of books
                      displayedBooks.isEmpty
                          ? _buildEmptyResultsState()
                          : _isGridView && !isMobile
                              ? _buildBooksGrid(displayedBooks, isTablet)
                              : _buildBooksList(displayedBooks, isMobile),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Dashboard showing the counter stats
  Widget _buildStatsDashboard({
    required bool isMobile,
    required int total,
    required int physical,
    required int ebooks,
    required int reserved,
  }) {
    final double cardWidth = isMobile ? double.infinity : 240;

    return Center(
      child: Wrap(
        spacing: 20,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: [
          _buildStatIndicator(
            title: 'Total Books Count',
            value: total.toString(),
            icon: Icons.menu_book_rounded,
            color: AppTheme.primaryNavy,
            width: cardWidth,
          ),
          _buildStatIndicator(
            title: 'Physical Books Available',
            value: physical.toString(),
            icon: Icons.check_circle_rounded,
            color: Colors.green.shade700,
            width: cardWidth,
          ),
          _buildStatIndicator(
            title: 'E-Resources / E-Books',
            value: ebooks.toString(),
            icon: Icons.cloud_download_rounded,
            color: Colors.blue.shade700,
            width: cardWidth,
          ),
          _buildStatIndicator(
            title: 'Reserved Copy / Short Loan',
            value: reserved.toString(),
            icon: Icons.bookmark_added_rounded,
            color: Colors.orange.shade700,
            width: cardWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildStatIndicator({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryNavy,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Search, sorting controls
  Widget _buildControlBar(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Field
          Expanded(
            flex: isMobile ? 0 : 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppTheme.textGrey, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search by title, author, category, ISBN...',
                        hintStyle: TextStyle(color: AppTheme.textGrey, fontSize: 14),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppTheme.textGrey, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
                ],
              ),
            ),
          ),
          if (isMobile) const SizedBox(height: 16) else const SizedBox(width: 16),
          // Sorting Dropdown
          IntrinsicWidth(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sort_rounded, color: AppTheme.textGrey, size: 20),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _sortBy,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textGrey),
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'title', child: Text('Sort by Title')),
                      DropdownMenuItem(value: 'author', child: Text('Sort by Author')),
                      DropdownMenuItem(value: 'popularity', child: Text('Sort by Popularity')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _sortBy = val);
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

  // Category filter chips
  Widget _buildCategoryFilter(List<String> categoriesList) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categoriesList.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedCategory = category);
                }
              },
              selectedColor: AppTheme.primaryNavy,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textDark,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryNavy : Colors.grey.shade200,
                  width: 1.5,
                ),
              ),
              showCheckmark: false,
              elevation: isSelected ? 4 : 0,
            ),
          );
        }).toList(),
      ),
    );
  }

  // Books List layout (Mobile or default)
  Widget _buildBooksList(List<Book> books, bool isMobile) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return _buildBookItem(book, isMobile: isMobile);
      },
    );
  }

  // Books Grid layout (Desktop size)
  Widget _buildBooksGrid(List<Book> books, bool isTablet) {
    final int crossAxisCount = isTablet ? 2 : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.4,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return _buildBookItem(book, isMobile: false, isGrid: true);
      },
    );
  }

  // Book Item Card Widget (highly decorated)
  Widget _buildBookItem(Book book, {required bool isMobile, bool isGrid = false}) {
    final statusColor = _getStatusColor(book.status);
    final statusText = _getStatusText(book.status);

    final cardChild = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left icon container with decorative gold highlights
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.accentGold.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: AppTheme.primaryNavy,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Title & Author details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: isGrid ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryNavy,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person_pin_rounded, size: 15, color: AppTheme.textGrey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          book.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isGrid) const SizedBox(height: 16) else const Spacer(),
        const Divider(height: 1),
        const SizedBox(height: 14),
        // Details row / wrap
        Wrap(
          spacing: 16,
          runSpacing: 10,
          children: [
            _buildBookBadge(Icons.category_outlined, book.category),
            _buildBookBadge(Icons.school_rounded, _getSchoolNameFriendly(book.school)),
            _buildBookBadge(Icons.qr_code_rounded, 'ISBN: ${book.isbn}'),
            _buildBookBadge(Icons.trending_up_rounded, '${book.searchCount} Popularity'),
          ],
        ),
        if (!isGrid) const SizedBox(height: 16) else const SizedBox(height: 10),
        // Status row & explore trigger
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Status tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: statusColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            // Info action text/button
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _showBookDetailsDialog(book),
                child: Row(
                  children: [
                    Text(
                      'Details',
                      style: TextStyle(
                        color: AppTheme.accentGold,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, color: AppTheme.accentGold, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );

    return Container(
      margin: EdgeInsets.only(bottom: isGrid ? 0 : 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: cardChild,
    );
  }

  Widget _buildBookBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textGrey),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Beautiful Details Dialog
  void _showBookDetailsDialog(Book book) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final statusColor = _getStatusColor(book.status);
        final statusText = _getStatusText(book.status);

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 16,
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 550),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.accentGold,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dialog Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppTheme.textGrey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Book Title
                Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryNavy,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                // Author
                Row(
                  children: [
                    const Icon(Icons.person_pin_rounded, color: AppTheme.accentGold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      book.author,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppTheme.textGrey,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                // Metadata Details list
                _buildDialogDetailRow('Category', book.category, Icons.category_rounded),
                _buildDialogDetailRow('Course', book.course, Icons.menu_book_rounded),
                _buildDialogDetailRow('School', _getSchoolNameFriendly(book.school), Icons.school_rounded),
                _buildDialogDetailRow('Department', book.department.isEmpty ? 'N/A' : book.department, Icons.business_outlined),
                _buildDialogDetailRow('ISBN / Code', book.isbn, Icons.qr_code_rounded),
                _buildDialogDetailRow('Search popularity', '${book.searchCount} times searched', Icons.trending_up_rounded),
                const SizedBox(height: 32),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryNavy,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Close Directory',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryNavy.withOpacity(0.7), size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textGrey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper styles matching standard screen status colors
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

  // Empty Results State
  Widget _buildEmptyResultsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 72,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'No matching books found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search queries or category filters',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}
