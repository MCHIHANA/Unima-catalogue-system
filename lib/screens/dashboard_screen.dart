import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/stats_card.dart';
import '../widgets/main_layout.dart';
import 'package:fl_chart/fl_chart.dart';
import 'manage_books_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: 'Dashboard',
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome, Librarian',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
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
                  const Text(
                    'University of Malawi Library Catalogue Reserve System Overview • Academic Session 2023/24',
                    style: TextStyle(fontSize: 14, color: AppTheme.textGrey),
                  ),
                  const SizedBox(height: 32),
                  _buildTopStats(),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildTopBooksSection()),
                      const SizedBox(width: 32),
                      Expanded(flex: 2, child: _buildSearchTrendsSection()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F3F9))),
      ),
      child: Row(
        children: [
          const Text(
            'Librarian Dashboard',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Container(
            width: 300,
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
          const SizedBox(width: 24),
          const Icon(Icons.notifications_none, color: AppTheme.textDark),
          const SizedBox(width: 24),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('M. Phiri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('Chief Librarian', style: TextStyle(color: AppTheme.textGrey, fontSize: 11)),
            ],
          ),
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFE0E0E0),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStats() {
    return const Row(
      children: [
        Expanded(
          child: StatsCard(
            title: 'TOTAL BOOKS',
            value: '12,450',
            subtitle: 'Total catalogued items in reserve',
            trend: '↑2.4%',
            trailingIcon: Icon(Icons.library_books_outlined, size: 40),
          ),
        ),
        SizedBox(width: 24),
        Expanded(
          child: StatsCard(
            title: 'TOTAL SEARCHES',
            value: '85,231',
            subtitle: 'Student queries this semester',
            trend: '↑15.8%',
            trailingIcon: Icon(Icons.search_outlined, size: 40),
          ),
        ),
        SizedBox(width: 24),
        Expanded(
          child: StatsCard(
            title: 'MOST SEARCHED BOOK',
            value: 'Introduction to Economics',
            subtitle: 'S. M. Kambala, 2022',
            hasBorder: true,
            trailingIcon: Icon(Icons.emoji_events_outlined, size: 40),
            trend: '3.2k searches',
          ),
        ),
      ],
    );
  }

  Widget _buildTopBooksSection() {
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
              const Text('Top 5 Most Searched Books', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          _buildTableItem(' #1', 'Introduction to Economics', 'S. M. Kambala', '3,241', true),
          _buildTableItem(' #2', 'Malawi Constitutional Law', 'K. G. Chizumila', '2,890', false),
          _buildTableItem(' #3', 'Biology for Health Sciences', 'M. W. Gondwe', '2,415', false),
          _buildTableItem(' #4', 'Political History of Malawi', 'B. J. Phiri', '2,102', false),
          _buildTableItem(' #5', 'Advanced Microeconomics', 'L. Chiwaya', '1,988', false),
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
          Expanded(flex: 3, child: Text('BOOK TITLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textGrey))),
          Expanded(flex: 2, child: Text('AUTHOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textGrey))),
          Text('COUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textGrey)),
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
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
          Expanded(
            flex: 2,
            child: Text(author, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
          ),
          Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSearchTrendsSection() {
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
              const Text('Search Trends (Top 10)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Container(width: 12, height: 12, color: AppTheme.primaryNavy),
                  const SizedBox(width: 4),
                  const Text('SEARCHES (X100)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildProgressItem('Economics Intro', 0.9),
          _buildProgressItem('Constitutional Law', 0.8),
          _buildProgressItem('Health Bio', 0.7),
          _buildProgressItem('Malawi History', 0.65),
          _buildProgressItem('Microeconomics', 0.6),
          _buildProgressItem('Organic Chemistry', 0.55),
          _buildProgressItem('Statistics I', 0.5),
          _buildProgressItem('Database Systems', 0.45),
          _buildProgressItem('Accounting Prin.', 0.4),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
              Text((value * 36).toStringAsFixed(1), style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: value,
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
