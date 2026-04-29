import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/stats_card.dart';
import '../widgets/main_layout.dart';
import 'package:fl_chart/fl_chart.dart';
import 'manage_books_screen.dart';
import '../models/book.dart';
import '../services/book_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Book>>(
      stream: BookService().getBooks(),
      builder: (context, snapshot) {
        final books = snapshot.data ?? [];
        
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
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isMobile ? 16 : 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, Librarian',
                            style: TextStyle(
                              fontSize: isMobile ? 24 : 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
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
              child: const TextField(
                decoration: InputDecoration(
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
          if (!isMobile) SizedBox(width: 24),
          SizedBox(width: isMobile ? 8 : 12),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFE0E0E0),
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
                onPressed: () {},
                child: const Text('Download CSV', style: TextStyle(color: AppTheme.primaryNavy, fontSize: 13)),
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
}
