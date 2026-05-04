import 'dart:io';

import 'package:excel/excel.dart' as excelpkg;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/book.dart';
import '../models/search_request.dart';
import '../services/book_service.dart';
import '../services/report_service.dart';
import '../theme/app_theme.dart';
import '../widgets/main_layout.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final BookService _bookService = BookService();
  final ReportService _reportService = ReportService();
  final TextEditingController _recommendationController = TextEditingController();

  List<Book> _books = [];
  List<SearchRequest> _requests = [];
  String? _latestRecommendation;
  bool _isExporting = false;
  DateTime _selectedMonth = DateTime.now();
  int _rankDepth = 10;
  bool _isSavingRecommendation = false;

  @override
  void dispose() {
    _recommendationController.dispose();
    super.dispose();
  }

  String get _todayLabel => DateFormat.yMMMMEEEEd().format(DateTime.now());

  String get _reportGeneratedLabel => DateFormat.yMMMMd().add_jm().format(DateTime.now());

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + delta, 1);
    });
  }

  Future<void> _saveRecommendation() async {
    final text = _recommendationController.text.trim();
    if (text.isEmpty) {
      _showSnack('Please enter a recommendation before saving.');
      return;
    }

    setState(() {
      _isSavingRecommendation = true;
    });

    try {
      await _reportService.saveRecommendation(text);
      _recommendationController.clear();
      _showSnack('Recommendation saved.');
    } catch (error) {
      _showSnack('Unable to save recommendation. Try again.');
    } finally {
      setState(() {
        _isSavingRecommendation = false;
      });
    }
  }

  Future<void> _exportExcel(List<Book> books, List<SearchRequest> requests, String? recommendation) async {
    setState(() {
      _isExporting = true;
    });

    try {
      final excel = excelpkg.Excel.createExcel();
      final sheet = excel['Reports'];
      sheet.appendRow(['UNIMA Library Search Report']);
      sheet.appendRow(['Generated', _reportGeneratedLabel]);
      sheet.appendRow([]);
      sheet.appendRow(['Top Searched Books']);
      sheet.appendRow(['Rank', 'Title', 'Author', 'Category', 'Status', 'Search Count']);

      final topBooks = List<Book>.from(books)
        ..sort((a, b) => b.searchCount.compareTo(a.searchCount));
      for (var i = 0; i < topBooks.length && i < _rankDepth; i++) {
        final book = topBooks[i];
        sheet.appendRow([i + 1, book.title, book.author, book.category, book.status, book.searchCount]);
      }

      sheet.appendRow([]);
      sheet.appendRow(['Most Needed Books']);
      sheet.appendRow(['Title', 'Author', 'Search Count', 'Status']);
      final needed = topBooks.where((book) => book.status.toLowerCase() != 'available').take(10).toList();
      if (needed.isEmpty) {
        sheet.appendRow(['No unavailable books currently flagged']);
      } else {
        for (final book in needed) {
          sheet.appendRow([book.title, book.author, book.searchCount, book.status]);
        }
      }

      sheet.appendRow([]);
      sheet.appendRow(['Unavailable Search Queries']);
      sheet.appendRow(['Query', 'Count', 'Last Searched']);
      final unavailableRequests = requests.where((request) => !request.found).toList();
      if (unavailableRequests.isEmpty) {
        sheet.appendRow(['No unavailable search requests found']);
      } else {
        for (final request in unavailableRequests) {
          sheet.appendRow([request.query, request.count, DateFormat.yMd().add_jm().format(request.lastSearched)]);
        }
      }

      if (recommendation != null && recommendation.isNotEmpty) {
        sheet.appendRow([]);
        sheet.appendRow(['Admin Recommendation']);
        sheet.appendRow([recommendation]);
      }

      final bytes = excel.encode();
      if (bytes == null) throw Exception('Failed to encode Excel workbook.');

      final resultPath = await _writeBinaryFile('unima_library_report_${DateTime.now().millisecondsSinceEpoch}.xlsx', bytes);
      _showSnack('Excel report exported to: $resultPath');
    } catch (error) {
      _showSnack('Report export failed: ${error.toString()}');
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _exportWord(List<Book> books, List<SearchRequest> requests, String? recommendation) async {
    setState(() {
      _isExporting = true;
    });

    try {
      final buffer = StringBuffer();
      buffer.writeln('<html><body>');
      buffer.writeln('<h1>UNIMA Library Search Report</h1>');
      buffer.writeln('<p><strong>Generated:</strong> $_reportGeneratedLabel</p>');
      buffer.writeln('<h2>Top Searched Books</h2>');
      buffer.writeln('<table border="1" cellpadding="6" cellspacing="0">');
      buffer.writeln('<tr><th>Rank</th><th>Title</th><th>Author</th><th>Category</th><th>Status</th><th>Search Count</th></tr>');
      final topBooks = List<Book>.from(books)
        ..sort((a, b) => b.searchCount.compareTo(a.searchCount));
      for (var i = 0; i < topBooks.length && i < _rankDepth; i++) {
        final book = topBooks[i];
        buffer.writeln('<tr><td>${i + 1}</td><td>${book.title}</td><td>${book.author}</td><td>${book.category}</td><td>${book.status}</td><td>${book.searchCount}</td></tr>');
      }
      buffer.writeln('</table>');

      buffer.writeln('<h2>Most Needed Books</h2>');
      final needed = topBooks.where((book) => book.status.toLowerCase() != 'available').take(10).toList();
      if (needed.isEmpty) {
        buffer.writeln('<p>No unavailable books currently flagged.</p>');
      } else {
        buffer.writeln('<ul>');
        for (final book in needed) {
          buffer.writeln('<li><strong>${book.title}</strong> by ${book.author} — ${book.searchCount} searches (${book.status})</li>');
        }
        buffer.writeln('</ul>');
      }

      buffer.writeln('<h2>Unavailable Search Queries</h2>');
      final unavailableRequests = requests.where((request) => !request.found).toList();
      if (unavailableRequests.isEmpty) {
        buffer.writeln('<p>No unavailable search requests found.</p>');
      } else {
        buffer.writeln('<ul>');
        for (final request in unavailableRequests) {
          buffer.writeln('<li>${request.query} — ${request.count} times (last: ${DateFormat.yMd().add_jm().format(request.lastSearched)})</li>');
        }
        buffer.writeln('</ul>');
      }

      if (recommendation != null && recommendation.isNotEmpty) {
        buffer.writeln('<h2>Admin Recommendation</h2>');
        buffer.writeln('<p>${recommendation.replaceAll('\n', '<br/>')}</p>');
      }

      buffer.writeln('</body></html>');
      final resultPath = await _writeTextFile('unima_library_report_${DateTime.now().millisecondsSinceEpoch}.doc', buffer.toString());
      _showSnack('Word report exported to: $resultPath');
    } catch (error) {
      _showSnack('Report export failed: ${error.toString()}');
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }


  Future<String> _writeBinaryFile(String fileName, List<int> bytes) async {
    final downloadsPath = '${Platform.environment['USERPROFILE']}\\Downloads';
    final downloadsDir = Directory(downloadsPath);
    
    // Ensure downloads directory exists
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    
    final path = '$downloadsPath\\$fileName';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return path;
  }

  Future<String> _writeTextFile(String fileName, String content) async {
    final downloadsPath = '${Platform.environment['USERPROFILE']}\\Downloads';
    final downloadsDir = Directory(downloadsPath);
    
    // Ensure downloads directory exists
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    
    final path = '$downloadsPath\\$fileName';
    final file = File(path);
    await file.writeAsString(content, flush: true);
    return path;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1100;

    return MainLayout(
      currentRoute: 'Reports',
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 60 : 20,
                vertical: 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPageHeader(context, isDesktop),
                  const SizedBox(height: 40),
                  StreamBuilder<List<Book>>(
                    stream: _bookService.getBooks(),
                    builder: (context, bookSnapshot) {
                      if (!bookSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final books = bookSnapshot.data!;
                      _books = books; // Update instance variable
                      return StreamBuilder<List<SearchRequest>>(
                        stream: _reportService.getSearchRequests(),
                        builder: (context, requestSnapshot) {
                          final requests = requestSnapshot.data ?? [];
                          _requests = requests; // Update instance variable
                          return StreamBuilder<String?>(
                            stream: _reportService.getLatestRecommendation(),
                            builder: (context, recSnapshot) {
                              final latestRecommendation = recSnapshot.data;
                              _latestRecommendation = latestRecommendation; // Update instance variable
                              return isDesktop
                                  ? Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              _buildReportParameters(books, requests),
                                              const SizedBox(height: 32),
                                              _buildQuickSummary(books, requests),
                                              const SizedBox(height: 32),
                                              _buildRecommendationCard(),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 40),
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            children: [
                                              _buildRankingTable(books, requests, latestRecommendation),
                                              const SizedBox(height: 32),
                                              _buildUnavailableSearchTable(requests),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        _buildReportParameters(books, requests),
                                        const SizedBox(height: 32),
                                        _buildQuickSummary(books, requests),
                                        const SizedBox(height: 32),
                                        _buildRecommendationCard(),
                                        const SizedBox(height: 32),
                                        _buildRankingTable(books, requests, latestRecommendation),
                                        const SizedBox(height: 32),
                                        _buildUnavailableSearchTable(requests),
                                      ],
                                    );
                            },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 60),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bar_chart_rounded, size: 14, color: AppTheme.accentGold),
                  SizedBox(width: 6),
                  Text(
                    'ANALYTICS & REPORTS',
                    style: TextStyle(
                      color: AppTheme.accentGold,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Library Search & Availability Reports',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark,
                      height: 1.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Current date: $_todayLabel',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (isDesktop)
              Row(
                children: [
                  _buildButton('Export Excel', Icons.grid_view_outlined, false, () => _exportExcel(_books, _requests, _latestRecommendation)),
                  const SizedBox(width: 16),
                  _buildButton('Export Word', Icons.description_outlined, true, () => _exportWord(_books, _requests, _latestRecommendation)),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildButton(String label, IconData icon, bool primary, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: primary ? AppTheme.primaryNavy : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: primary ? null : Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: primary
              ? [
                  BoxShadow(
                    color: AppTheme.primaryNavy.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: primary ? Colors.white : AppTheme.textDark),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: primary ? Colors.white : AppTheme.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: AppTheme.textGrey,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Divider(color: Color(0xFFF1F3F9)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_rounded, size: 16, color: AppTheme.textGrey),
                const SizedBox(width: 8),
                Text(
                  '© 2023 University of Malawi Library System',
                  style: TextStyle(color: AppTheme.textGrey.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Row(
              children: [
                _buildFooterLink('HELP CENTER'),
                const SizedBox(width: 32),
                _buildFooterLink('TERMS OF SERVICE'),
                const SizedBox(width: 32),
                _buildFooterLink('DATA PROTECTION'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterLink(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: AppTheme.textGrey.withOpacity(0.6),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildReportParameters(List<Book> books, List<SearchRequest> requests) {
    final monthName = DateFormat.yMMMM().format(_selectedMonth);
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.filter_list_rounded, size: 20, color: AppTheme.primaryNavy),
              SizedBox(width: 12),
              Text('Report Parameters', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 32),
          _buildFieldLabel('ANALYSIS PERIOD'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFF1F3F9)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => _changeMonth(-1),
                      icon: const Icon(Icons.chevron_left_rounded, color: Colors.grey, size: 22),
                    ),
                    Text(monthName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    IconButton(
                      onPressed: () => _changeMonth(1),
                      icon: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  itemCount: daysInMonth,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final isToday = day == DateTime.now().day && _selectedMonth.month == DateTime.now().month && _selectedMonth.year == DateTime.now().year;
                    return Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isToday ? AppTheme.primaryNavy : const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        day.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isToday ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildFieldLabel('RANKING DEPTH'),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildDepthChip(5),
              _buildDepthChip(10),
              _buildDepthChip(25),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildParameterSummary('Total Searches', '${books.fold<int>(0, (total, book) => total + book.searchCount)}')),
              const SizedBox(width: 12),
              Expanded(child: _buildParameterSummary('Unavailable Requests', '${requests.where((request) => !request.found).fold<int>(0, (sum, item) => sum + item.count)}')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParameterSummary(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textGrey, fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
        ],
      ),
    );
  }

  Widget _buildDepthChip(int value) {
    final selected = _rankDepth == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _rankDepth = value),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryNavy : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? AppTheme.accentGold : const Color(0xFFF1F3F9)),
          ),
          alignment: Alignment.center,
          child: Text(
            'Top $value',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppTheme.textDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSummary(List<Book> books, List<SearchRequest> requests) {
    final totalSearches = books.fold<int>(0, (sum, book) => sum + book.searchCount);
    final categoryCounts = <String, int>{};
    for (final book in books) {
      categoryCounts[book.category] = (categoryCounts[book.category] ?? 0) + book.searchCount;
    }
    final topCategory = categoryCounts.entries.isEmpty ? 'N/A' : categoryCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    final mostNeededBooks = books.where((book) => book.status.toLowerCase() != 'available').toList();

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryNavy.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentGold,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'QUICK SUMMARY',
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
          ),
          const SizedBox(height: 32),
          Text('Total Library Searches', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text('$totalSearches', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          const Divider(color: Colors.white12),
          const SizedBox(height: 24),
          Text('Top Category', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(topCategory, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          Text('Most Needed Books', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('${mostNeededBooks.length} books require review', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Admin Recommendation', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 16),
          TextField(
            controller: _recommendationController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share a recommendation or a note for the report',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSavingRecommendation ? null : _saveRecommendation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(_isSavingRecommendation ? 'Saving...' : 'Save Recommendation'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          StreamBuilder<String?>(
            stream: _reportService.getLatestRecommendation(),
            builder: (context, snapshot) {
              final recommendation = snapshot.data;
              if (recommendation == null || recommendation.isEmpty) {
                return const Text('No recommendation has been recorded yet.', style: TextStyle(color: AppTheme.textGrey));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Latest Recommendation', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(recommendation, style: const TextStyle(color: AppTheme.textDark, fontSize: 14)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRankingTable(List<Book> books, List<SearchRequest> requests, String? recommendation) {
    final topBooks = List<Book>.from(books)..sort((a, b) => b.searchCount.compareTo(a.searchCount));
    final selectedBooks = topBooks.take(_rankDepth).toList();
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Top Searched Books', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              Text('Showing top $_rankDepth books', style: const TextStyle(color: AppTheme.textGrey, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(
              color: AppTheme.primaryNavy,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            ),
            child: const Row(
              children: [
                SizedBox(width: 50, child: Text('RANK', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900))),
                Expanded(flex: 2, child: Text('BOOK TITLE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900))),
                Expanded(flex: 1, child: Text('AUTHOR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900))),
                SizedBox(width: 100, child: Text('SEARCH COUNT', textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900))),
              ],
            ),
          ),
          ...List.generate(selectedBooks.length, (index) {
            final book = selectedBooks[index];
            return _buildRankingItem('${index + 1}', book.title, book.author, '${book.searchCount}');
          }),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Report generated on: $_reportGeneratedLabel', style: TextStyle(color: AppTheme.textGrey.withOpacity(0.6), fontSize: 11)),
              Row(
                children: [
                  const Text('Export report:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _isExporting ? null : () => _exportExcel(_books, _requests, _latestRecommendation),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isExporting ? Colors.grey.shade200 : AppTheme.accentGold,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Excel', style: TextStyle(color: _isExporting ? Colors.black38 : Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isExporting ? null : () => _exportWord(_books, _requests, _latestRecommendation),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isExporting ? Colors.grey.shade200 : AppTheme.primaryNavy,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Word', style: TextStyle(color: _isExporting ? Colors.black38 : Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnavailableSearchTable(List<SearchRequest> requests) {
    final unavailableRequests = requests.where((request) => !request.found).toList();
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Unavailable Search Requests', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 16),
          if (unavailableRequests.isEmpty)
            const Text('No missing book searches yet. Students are finding available titles successfully.', style: TextStyle(color: AppTheme.textGrey))
          else
            Column(
              children: unavailableRequests.take(8).map((request) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(request.query, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textDark))),
                      const SizedBox(width: 12),
                      Text('${request.count} searches', style: const TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.w900)),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRankingItem(String rank, String title, String author, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F3F9))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Text(rank, style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.w900, fontSize: 13)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark), overflow: TextOverflow.ellipsis, maxLines: 2),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Text(author, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis, maxLines: 2),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(count, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.primaryNavy)),
          ),
        ],
      ),
    );
  }
}
