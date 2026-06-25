import 'package:excel/excel.dart' as excelpkg;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/book.dart';
import '../models/search_request.dart';
import '../services/book_service.dart';
import '../services/report_service.dart';
import '../theme/app_theme.dart';
import '../utils/export_helper.dart';
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
  int _rankDepth = 10;
  bool _isSavingRecommendation = false;
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime.now(),
  );

  @override
  void dispose() {
    _recommendationController.dispose();
    super.dispose();
  }

  String get _todayLabel => DateFormat.yMMMMEEEEd().format(DateTime.now());

  String get _reportGeneratedLabel => DateFormat.yMMMMd().add_jm().format(DateTime.now());

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
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
      sheet.appendRow(['UNIMA LIBRARY SEARCH & AVAILABILITY REPORT']);
      sheet.appendRow([]);
      sheet.appendRow(['Generated', _reportGeneratedLabel]);
      sheet.appendRow(['Analysis Period', '${DateFormat.yMMMd().format(_selectedDateRange.start)} — ${DateFormat.yMMMd().format(_selectedDateRange.end)}']);
      sheet.appendRow(['Ranking Depth', 'Top $_rankDepth Books']);
      sheet.appendRow([]);

      // Top Searched Books Section
      sheet.appendRow(['TOP SEARCHED BOOKS']);
      sheet.appendRow(['Rank', 'Title', 'Author', 'Category', 'Status', 'Search Count']);
      final topBooks = List<Book>.from(books)..sort((a, b) => b.searchCount.compareTo(a.searchCount));
      for (var i = 0; i < topBooks.length && i < _rankDepth; i++) {
        final book = topBooks[i];
        sheet.appendRow([i + 1, book.title, book.author, book.category, book.status, book.searchCount]);
      }

      // Most Needed Books Section
      sheet.appendRow([]);
      sheet.appendRow(['MOST NEEDED BOOKS (Unavailable)']);
      sheet.appendRow(['Title', 'Author', 'Search Count', 'Status']);
      final needed = topBooks.where((book) => book.status.toLowerCase() != 'available').take(10).toList();
      if (needed.isEmpty) {
        sheet.appendRow(['No unavailable books currently flagged']);
      } else {
        for (final book in needed) {
          sheet.appendRow([book.title, book.author, book.searchCount, book.status]);
        }
      }

      // Unavailable Search Queries Section
      sheet.appendRow([]);
      sheet.appendRow(['UNAVAILABLE SEARCH QUERIES']);
      sheet.appendRow(['Query', 'Count', 'Last Searched', 'Status']);
      final unavailableRequests = requests.where((request) => !request.found).toList();
      if (unavailableRequests.isEmpty) {
        sheet.appendRow(['No unavailable search requests found']);
      } else {
        for (final request in unavailableRequests) {
          sheet.appendRow([request.query, request.count, DateFormat.yMd().add_jm().format(request.lastSearched), 'Not Found']);
        }
      }

      // Librarian Recommendation Section
      if (recommendation != null && recommendation.isNotEmpty) {
        sheet.appendRow([]);
        sheet.appendRow(['LIBRARIAN RECOMMENDATION & NOTES']);
        sheet.appendRow([recommendation]);
      }

      // Summary Statistics
      sheet.appendRow([]);
      sheet.appendRow(['SUMMARY STATISTICS']);
      sheet.appendRow(['Total Books in Catalog', books.length]);
      sheet.appendRow(['Total Search Requests', requests.fold<int>(0, (sum, r) => sum + r.count)]);
      sheet.appendRow(['Available Books', books.where((b) => b.status.toLowerCase() == 'available').length]);
      sheet.appendRow(['Unavailable Books Searched', needed.length]);

      final bytes = excel.encode();
      if (bytes == null) throw Exception('Failed to encode Excel workbook.');

      final fileName = 'UNIMA_Library_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      downloadBytes(bytes, fileName, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      _showSnack('✓ Excel report downloaded: $fileName');
    } catch (error) {
      _showSnack('❌ Report export failed: ${error.toString()}');
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
      buffer.writeln('<html>');
      buffer.writeln('<head>');
      buffer.writeln('<meta charset="UTF-8">');
      buffer.writeln('<style>');
      buffer.writeln('body { font-family: Arial, sans-serif; line-height: 1.6; margin: 20px; }');
      buffer.writeln('h1 { color: #003366; border-bottom: 3px solid #FFB81C; padding-bottom: 10px; }');
      buffer.writeln('h2 { color: #003366; margin-top: 20px; }');
      buffer.writeln('table { width: 100%; border-collapse: collapse; margin: 15px 0; }');
      buffer.writeln('th { background-color: #003366; color: white; padding: 10px; text-align: left; }');
      buffer.writeln('td { border: 1px solid #ddd; padding: 8px; }');
      buffer.writeln('tr:nth-child(even) { background-color: #f9f9f9; }');
      buffer.writeln('.meta { color: #666; font-size: 0.9em; margin: 5px 0; }');
      buffer.writeln('.recommendation { background-color: #fff3cd; padding: 15px; border-left: 4px solid #FFB81C; margin: 20px 0; }');
      buffer.writeln('</style>');
      buffer.writeln('</head>');
      buffer.writeln('<body>');

      // Header
      buffer.writeln('<h1>UNIMA LIBRARY SEARCH & AVAILABILITY REPORT</h1>');
      buffer.writeln('<div class="meta">');
      buffer.writeln('<p><strong>Generated:</strong> $_reportGeneratedLabel</p>');
      buffer.writeln('<p><strong>Analysis Period:</strong> ${DateFormat.yMMMd().format(_selectedDateRange.start)} — ${DateFormat.yMMMd().format(_selectedDateRange.end)}</p>');
      buffer.writeln('<p><strong>Ranking Depth:</strong> Top $_rankDepth Books</p>');
      buffer.writeln('</div>');

      // Top Searched Books
      buffer.writeln('<h2>Top Searched Books</h2>');
      buffer.writeln('<table border="1" cellpadding="6" cellspacing="0">');
      buffer.writeln('<tr><th>Rank</th><th>Title</th><th>Author</th><th>Category</th><th>Status</th><th>Search Count</th></tr>');
      final topBooks = List<Book>.from(books)..sort((a, b) => b.searchCount.compareTo(a.searchCount));
      for (var i = 0; i < topBooks.length && i < _rankDepth; i++) {
        final book = topBooks[i];
        buffer.writeln('<tr><td>${i + 1}</td><td><strong>${book.title}</strong></td><td>${book.author}</td><td>${book.category}</td><td>${book.status}</td><td>${book.searchCount}</td></tr>');
      }
      buffer.writeln('</table>');

      // Most Needed Books
      buffer.writeln('<h2>Most Needed Books (Unavailable)</h2>');
      final needed = topBooks.where((book) => book.status.toLowerCase() != 'available').take(10).toList();
      if (needed.isEmpty) {
        buffer.writeln('<p><em>No unavailable books currently flagged.</em></p>');
      } else {
        buffer.writeln('<table border="1" cellpadding="6" cellspacing="0">');
        buffer.writeln('<tr><th>Title</th><th>Author</th><th>Search Count</th><th>Status</th></tr>');
        for (final book in needed) {
          buffer.writeln('<tr><td><strong>${book.title}</strong></td><td>${book.author}</td><td>${book.searchCount}</td><td>${book.status}</td></tr>');
        }
        buffer.writeln('</table>');
      }

      // Unavailable Search Queries
      buffer.writeln('<h2>Unavailable Search Queries</h2>');
      final unavailableRequests = requests.where((request) => !request.found).toList();
      if (unavailableRequests.isEmpty) {
        buffer.writeln('<p><em>No unavailable search requests found. Students are finding available titles successfully.</em></p>');
      } else {
        buffer.writeln('<table border="1" cellpadding="6" cellspacing="0">');
        buffer.writeln('<tr><th>Query</th><th>Search Count</th><th>Last Searched</th><th>Status</th></tr>');
        for (final request in unavailableRequests) {
          buffer.writeln('<tr><td>${request.query}</td><td>${request.count}</td><td>${DateFormat.yMd().add_jm().format(request.lastSearched)}</td><td>Not Found</td></tr>');
        }
        buffer.writeln('</table>');
      }

      // Librarian Recommendation
      if (recommendation != null && recommendation.isNotEmpty) {
        buffer.writeln('<div class="recommendation">');
        buffer.writeln('<h2>Librarian Recommendation & Notes</h2>');
        buffer.writeln('<p>${recommendation.replaceAll('\n', '<br/>')}</p>');
        buffer.writeln('</div>');
      }

      // Summary Statistics
      buffer.writeln('<h2>Summary Statistics</h2>');
      buffer.writeln('<ul>');
      buffer.writeln('<li><strong>Total Books in Catalog:</strong> ${books.length}</li>');
      buffer.writeln('<li><strong>Total Search Requests:</strong> ${requests.fold<int>(0, (sum, r) => sum + r.count)}</li>');
      buffer.writeln('<li><strong>Available Books:</strong> ${books.where((b) => b.status.toLowerCase() == 'available').length}</li>');
      buffer.writeln('<li><strong>Unavailable Books Searched:</strong> ${needed.length}</li>');
      buffer.writeln('</ul>');

      buffer.writeln('</body>');
      buffer.writeln('</html>');

      final fileName = 'UNIMA_Library_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.html';
      downloadText(buffer.toString(), fileName, 'text/html');
      _showSnack('✓ HTML report downloaded: $fileName');
    } catch (error) {
      _showSnack('❌ Report export failed: ${error.toString()}');
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _exportPDF(List<Book> books, List<SearchRequest> requests, String? recommendation) async {
    setState(() {
      _isExporting = true;
    });

    try {
      final pdf = pw.Document();
      final topBooks = List<Book>.from(books)..sort((a, b) => b.searchCount.compareTo(a.searchCount));
      final needed = topBooks.where((book) => book.status.toLowerCase() != 'available').take(10).toList();
      final unavailableRequests = requests.where((request) => !request.found).toList();
      final displayCount = topBooks.length > _rankDepth ? _rankDepth : topBooks.length;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'UNIMA LIBRARY SEARCH & AVAILABILITY REPORT',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Generated: $_reportGeneratedLabel', style: const pw.TextStyle(fontSize: 11)),
                pw.Text('Analysis Period: ${DateFormat.yMMMd().format(_selectedDateRange.start)} — ${DateFormat.yMMMd().format(_selectedDateRange.end)}', style: const pw.TextStyle(fontSize: 11)),
                pw.Text('Ranking Depth: Top $_rankDepth Books', style: const pw.TextStyle(fontSize: 11)),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Header(
              level: 1,
              child: pw.Text('Top Searched Books', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headers: ['Rank', 'Title', 'Author', 'Category', 'Status', 'Count'],
              data: List.generate(
                displayCount,
                (index) => [
                  (index + 1).toString(),
                  topBooks[index].title,
                  topBooks[index].author,
                  topBooks[index].category,
                  topBooks[index].status,
                  topBooks[index].searchCount.toString(),
                ],
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(height: 20),
            pw.Header(
              level: 1,
              child: pw.Text('Most Needed Books (Unavailable)', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 10),
            if (needed.isEmpty)
              pw.Text('No unavailable books currently flagged.', style: pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic))
            else
              pw.TableHelper.fromTextArray(
                headers: ['Title', 'Author', 'Search Count', 'Status'],
                data: needed.map((book) => [book.title, book.author, book.searchCount.toString(), book.status]).toList(),
                cellStyle: const pw.TextStyle(fontSize: 9),
                headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            pw.SizedBox(height: 20),
            pw.Header(
              level: 1,
              child: pw.Text('Unavailable Search Queries', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 10),
            if (unavailableRequests.isEmpty)
              pw.Text('No unavailable search requests found. Students are finding available titles successfully.', style: pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic))
            else
              pw.TableHelper.fromTextArray(
                headers: ['Query', 'Count', 'Last Searched', 'Status'],
                data: unavailableRequests.map((r) => [r.query, r.count.toString(), DateFormat.yMd().format(r.lastSearched), 'Not Found']).toList(),
                cellStyle: const pw.TextStyle(fontSize: 9),
                headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            pw.SizedBox(height: 20),
            pw.Header(
              level: 1,
              child: pw.Text('Summary Statistics', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 10),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('• Total Books in Catalog: ${books.length}', style: const pw.TextStyle(fontSize: 11)),
                pw.Text('• Total Search Requests: ${requests.fold<int>(0, (sum, r) => sum + r.count)}', style: const pw.TextStyle(fontSize: 11)),
                pw.Text('• Available Books: ${books.where((b) => b.status.toLowerCase() == 'available').length}', style: const pw.TextStyle(fontSize: 11)),
                pw.Text('• Unavailable Books Searched: ${needed.length}', style: const pw.TextStyle(fontSize: 11)),
              ],
            ),
            if (recommendation != null && recommendation.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border(left: pw.BorderSide(width: 4)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Librarian Recommendation & Notes', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 10),
                    pw.Text(recommendation, style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ],
        ),
      );

      final bytes = await pdf.save();
      final fileName = 'UNIMA_Library_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      downloadBytes(bytes, fileName, 'application/pdf');
      _showSnack('✓ PDF report downloaded: $fileName');
    } catch (error) {
      _showSnack('❌ Report export failed: ${error.toString()}');
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
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
                        stream: _reportService.getSearchRequests(
                          startDate: DateTime(
                            _selectedDateRange.start.year,
                            _selectedDateRange.start.month,
                            _selectedDateRange.start.day,
                          ),
                          endDate: DateTime(
                            _selectedDateRange.end.year,
                            _selectedDateRange.end.month,
                            _selectedDateRange.end.day,
                            23,
                            59,
                            59,
                            999,
                          ),
                        ),
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
    final start = _selectedDateRange.start;
    final end = _selectedDateRange.end;
    final totalSearches = requests.fold<int>(0, (sum, request) => sum + request.count);
    final unavailableSearches = requests.where((request) => !request.found).fold<int>(0, (sum, request) => sum + request.count);

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
          GestureDetector(
            onTap: _pickDateRange,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFF1F3F9)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range_rounded, color: AppTheme.primaryNavy, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${DateFormat.yMMMd().format(start)} — ${DateFormat.yMMMd().format(end)}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                  const Icon(Icons.edit, color: Colors.grey, size: 20),
                ],
              ),
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
              onPressed: () => setState(() {}),
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
              Expanded(child: _buildParameterSummary('Total Searches', '$totalSearches')),
              const SizedBox(width: 12),
              Expanded(child: _buildParameterSummary('Unavailable Requests', '$unavailableSearches')),
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
          const Text('Librarian Recommendation', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
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
                      child: Text('HTML', style: TextStyle(color: _isExporting ? Colors.black38 : Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isExporting ? null : () => _exportPDF(_books, _requests, _latestRecommendation),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isExporting ? Colors.grey.shade200 : Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('PDF', style: TextStyle(color: _isExporting ? Colors.black38 : Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
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
