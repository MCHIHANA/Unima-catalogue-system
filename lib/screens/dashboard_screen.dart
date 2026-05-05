import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../utils/export_helper.dart';
import '../widgets/stats_card.dart';
import '../widgets/main_layout.dart';
import 'package:fl_chart/fl_chart.dart';
import 'manage_books_screen.dart';
import 'student_search_screen.dart';
import '../models/book.dart';
import '../services/book_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isExporting = false;
  final TextEditingController _searchController = TextEditingController();
  List<Book> _allBooks = [];
  List<Book> _filteredBooks = [];
  bool _showSearchResults = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _showSearchResults = false;
        _filteredBooks = [];
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    final results = _allBooks.where((book) {
      return book.title.toLowerCase().contains(lowerQuery) ||
             book.author.toLowerCase().contains(lowerQuery) ||
             book.isbn.toLowerCase().contains(lowerQuery) ||
             book.category.toLowerCase().contains(lowerQuery);
    }).toList();

    setState(() {
      _filteredBooks = results;
      _showSearchResults = true;
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavy,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const StudentSearchScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _exportTopBooksCsv(List<Book> topBooks) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      final buffer = StringBuffer();
      buffer.writeln('Rank,Title,Author,Category,Status,Search Count');
      for (var i = 0; i < topBooks.length; i++) {
        final b = topBooks[i];
        String esc(String v) => '"${v.replaceAll('"', '""')}"';
        buffer.writeln('${i + 1},${esc(b.title)},${esc(b.author)},${esc(b.category)},${esc(b.status)},${b.searchCount}');
      }

      final fileName = 'UNIMA_Top_Books_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      downloadText(buffer.toString(), fileName, 'text/csv');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ CSV downloaded: $fileName'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Export failed: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Book>>(
      stream: BookService().getBooks(),
      builder: (context, snapshot) {
        final books = snapshot.data ?? [];
        _allBooks = books; // Store for search
        
        int totalSearches = 0;
        for (var b in books) {
          totalSearches += b.searchCount;
        }

        final sorted = List<Book>.from(books)..sort((a, b) => b.searchCount.compareTo(a.searchCount));
        final topBooks = sorted.take(5).toList();
        final mostSearched = topBooks.isNotEmpty ? topBooks.first : null;

        return MainLayout(
          currentRoute: 'Dashboard',
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;
              
              return Column(
                children: [
                  _buildHeader(isMobile),
                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          padding: EdgeInsets.all(isMobile ? 16 : 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Welcome, Librarian',
                                      style: TextStyle(
                                        fontSize: isMobile ? 24 : 32,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textDark,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => const StudentSearchScreen()),
                                      );
                                    },
                                    icon: const Icon(Icons.arrow_back, size: 18),
                                    label: const Text('STUDENT VIEW'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.accentGold,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      elevation: 0,
                                      textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ManageBooksScreen()),
                                  );
                                },
                                icon: const Icon(Icons.menu_book_rounded, size: 20),
                                label: const Text('MANAGE BOOKS'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryNavy,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                  textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'University of Malawi Library Catalogue Reserve System Overview • Academic Session 2023/24',
                                style: TextStyle(fontSize: isMobile ? 12 : 14, color: AppTheme.textGrey),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 32),
                              _buildTopStats(books.length, totalSearches, mostSearched, isMobile),
                              const SizedBox(height: 32),
                              if (isMobile || isTablet)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildTopBooksSection(topBooks),
                                    const SizedBox(height: 32),
                                    _buildSearchTrendsSection(topBooks),
                                  ],
                                )
                              else
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(flex: 3, child: _buildTopBooksSection(topBooks)),
                                    const SizedBox(width: 32),
                                    Expanded(flex: 2, child: _buildSearchTrendsSection(topBooks)),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        if (_showSearchResults)
                          _buildSearchResultsOverlay(isMobile),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 32.0, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F3F9))),
      ),
      child: Row(
        children: [
          if (!isMobile)
            const Text(
              'Librarian Dashboard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          if (!isMobile) const Spacer(),
          Expanded(
            flex: isMobile ? 1 : 0,
            child: Container(
              width: isMobile ? null : 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.accentGold.withOpacity(0.5)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _performSearch,
                onSubmitted: (_) => _performSearch(_searchController.text),
                decoration: const InputDecoration(
                  hintText: 'Search library resources...',
                  hintStyle: TextStyle(fontSize: 13, color: AppTheme.textGrey),
                  prefixIcon: Icon(Icons.search, size: 20, color: AppTheme.accentGold),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          SizedBox(width: isMobile ? 16 : 24),
          const Icon(Icons.notifications_none, color: AppTheme.textDark),
          SizedBox(width: isMobile ? 8 : 24),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            offset: const Offset(0, 50),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: AppTheme.primaryNavy),
                    SizedBox(width: 12),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primaryNavy,
              child: Icon(Icons.person, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStats(int totalBooks, int totalSearches, Book? mostSearched, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          StatsCard(
            title: 'TOTAL BOOKS',
            value: '$totalBooks',
            subtitle: 'Total catalogued items in reserve',
            trend: 'Live',
            trailingIcon: const Icon(Icons.library_books_outlined, size: 40),
          ),
          const SizedBox(height: 16),
          StatsCard(
            title: 'TOTAL SEARCHES',
            value: '$totalSearches',
            subtitle: 'Student queries this semester',
            trend: 'Live',
            trailingIcon: const Icon(Icons.search_outlined, size: 40),
          ),
          const SizedBox(height: 16),
          StatsCard(
            title: 'MOST SEARCHED BOOK',
            value: mostSearched?.title ?? 'None yet',
            subtitle: mostSearched?.author ?? '',
            hasBorder: true,
            trailingIcon: const Icon(Icons.emoji_events_outlined, size: 40),
            trend: '${mostSearched?.searchCount ?? 0} searches',
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: StatsCard(
            title: 'TOTAL BOOKS',
            value: '$totalBooks',
            subtitle: 'Total catalogued items in reserve',
            trend: 'Live',
            trailingIcon: const Icon(Icons.library_books_outlined, size: 40),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: StatsCard(
            title: 'TOTAL SEARCHES',
            value: '$totalSearches',
            subtitle: 'Student queries this semester',
            trend: 'Live',
            trailingIcon: const Icon(Icons.search_outlined, size: 40),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: StatsCard(
            title: 'MOST SEARCHED BOOK',
            value: mostSearched?.title ?? 'None yet',
            subtitle: mostSearched?.author ?? '',
            hasBorder: true,
            trailingIcon: const Icon(Icons.emoji_events_outlined, size: 40),
            trend: '${mostSearched?.searchCount ?? 0} searches',
          ),
        ),
      ],
    );
  }

  Widget _buildTopBooksSection(List<Book> topBooks) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(child: Text('Top Most Searched Books', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
              TextButton(
                onPressed: _isExporting ? null : () => _exportTopBooksCsv(topBooks),
                child: Text(
                  _isExporting ? 'Exporting...' : 'Download CSV',
                  style: const TextStyle(color: AppTheme.primaryNavy, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          _buildTableHeader(),
          const Divider(),
          if (topBooks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text('No book data available.')),
            )
          else
            ...topBooks.asMap().entries.map((entry) {
              return _buildTableItem(
                ' #${entry.key + 1}', 
                entry.value.title, 
                entry.value.author, 
                '${entry.value.searchCount}', 
                entry.key == 0
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text('RANK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textGrey))),
          Expanded(flex: 3, child: Text('BOOK TITLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textGrey), overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text('AUTHOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textGrey), overflow: TextOverflow.ellipsis)),
          SizedBox(width: 60, child: Text('COUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textGrey))),
        ],
      ),
    );
  }

  Widget _buildTableItem(String rank, String title, String author, String count, bool isTop) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(rank, style: TextStyle(fontWeight: FontWeight.bold, color: isTop ? AppTheme.accentGold : Colors.grey[300]))),
          Expanded(
            flex: 3,
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis, maxLines: 2),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(author, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 2),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 60, child: Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildSearchTrendsSection(List<Book> topBooks) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(child: Text('Search Trends (Top Books)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
              Row(
                children: [
                  Container(width: 12, height: 12, color: AppTheme.primaryNavy),
                  const SizedBox(width: 4),
                  const Text('SEARCHES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (topBooks.isEmpty)
             const Center(child: Text('No trend data yet.'))
          else
            ...topBooks.map((b) {
              final maxSearch = topBooks.first.searchCount;
              final percentage = maxSearch > 0 ? b.searchCount / maxSearch : 0.0;
              return _buildProgressItem(b.title, percentage, b.searchCount);
            }),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, double percentage, int rawCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Text('$rawCount', style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[100],
            color: AppTheme.primaryNavy,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsOverlay(bool isMobile) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showSearchResults = false;
            _searchController.clear();
          });
        },
        child: Container(
          color: Colors.black54,
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent closing when tapping inside
              child: Container(
                width: isMobile ? MediaQuery.of(context).size.width * 0.9 : 700,
                height: MediaQuery.of(context).size.height * 0.8,
                margin: EdgeInsets.all(isMobile ? 16 : 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryNavy,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Search Results (${_filteredBooks.length} found)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _showSearchResults = false;
                                _searchController.clear();
                              });
                            },
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _filteredBooks.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 64, color: AppTheme.textGrey),
                                  SizedBox(height: 16),
                                  Text(
                                    'No books found',
                                    style: TextStyle(fontSize: 18, color: AppTheme.textGrey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredBooks.length,
                              itemBuilder: (context, index) {
                                final book = _filteredBooks[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 2,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentGold.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.book, color: AppTheme.accentGold),
                                    ),
                                    title: Text(
                                      book.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        Text('Author: ${book.author}'),
                                        Text('Category: ${book.category}'),
                                        Text('ISBN: ${book.isbn}'),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: book.status.toLowerCase() == 'available'
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            book.status,
                                            style: TextStyle(
                                              color: book.status.toLowerCase() == 'available'
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Text(
                                      '${book.searchCount} searches',
                                      style: const TextStyle(
                                        color: AppTheme.primaryNavy,
                                        fontWeight: FontWeight.bold,
                                      ),
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
          ),
        ),
      ),
    );
  }
}
