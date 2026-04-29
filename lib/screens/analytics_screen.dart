import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/main_layout.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

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
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              _buildReportParameters(),
                              const SizedBox(height: 32),
                              _buildQuickSummary(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          flex: 2,
                          child: _buildRankingTable(),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildReportParameters(),
                        const SizedBox(height: 32),
                        _buildQuickSummary(),
                        const SizedBox(height: 32),
                        _buildRankingTable(),
                      ],
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
                    'ANALYTICS & STATISTICS',
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
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Most Frequently Searched Books',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark,
                      height: 1.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Academic Session: 2023/2024 • University of Malawi Main Library',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            if (isDesktop)
              Row(
                children: [
                  _buildExportButton('CSV Export', Icons.file_download_outlined, false),
                  const SizedBox(width: 16),
                  _buildExportButton('PDF Report', Icons.picture_as_pdf_outlined, true),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildExportButton(String label, IconData icon, bool isPrimary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isPrimary ? AppTheme.primaryNavy : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: isPrimary ? null : Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: AppTheme.primaryNavy.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isPrimary ? Colors.white : AppTheme.textDark),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isPrimary ? Colors.white : AppTheme.textDark,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportParameters() {
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
              Text(
                'Report Parameters',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildFieldLabel('ANALYSIS PERIOD'),
          const SizedBox(height: 16),
          // Simplified Calendar UI
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
                    const Icon(Icons.chevron_left_rounded, color: Colors.grey, size: 20),
                    const Text('September 2023', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                // Calendar Days Grid placeholder
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(35, (index) {
                    bool isSelected = index >= 14 && index <= 19;
                    return Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryNavy : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${(index % 31) + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : AppTheme.textGrey,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildFieldLabel('RANKING DEPTH'),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildFilterChip('Top 5', false),
              _buildFilterChip('Top 10', true),
              _buildFilterChip('Top 25', false),
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
        ],
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

  Widget _buildFilterChip(String label, bool selected) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppTheme.accentGold : const Color(0xFFF1F3F9)),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.accentGold.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? AppTheme.accentGold : AppTheme.textGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSummary() {
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
          const Text('Total Library Searches', style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          const Text('14,208', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          const Divider(color: Colors.white12),
          const SizedBox(height: 24),
          const Text('Most Searched Category', style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          const Text('Legal Studies', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildRankingTable() {
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
              const Flexible(child: Text('Generated Ranking Table', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18), overflow: TextOverflow.ellipsis)),
              const Flexible(child: Text('Showing data from Sept 5 - Sept 20, 2023', style: TextStyle(color: AppTheme.textGrey, fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 32),
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(
              color: AppTheme.primaryNavy,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            ),
            child: const Row(
              children: [
                SizedBox(width: 50, child: Text('RANK', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis)),
                Expanded(flex: 2, child: Text('BOOK TITLE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis)),
                Expanded(flex: 1, child: Text('AUTHOR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis)),
                SizedBox(width: 100, child: Text('SEARCH COUNT', textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          _buildRankingItem('1', 'Introduction to Malawian Law', 'Dr. Chimwemwe Phiri', '1,240'),
          _buildRankingItem('2', 'Principles of Economics for Africa', 'Prof. J. Gondwe', '1,012'),
          _buildRankingItem('3', 'Public Health in Developing Nations', 'S. M. Bandah', '895'),
          _buildRankingItem('4', 'Structural Engineering Fundamentals', 'Dr. Kenneth Kaunda', '762'),
          _buildRankingItem('5', 'History of Southern Africa', 'M. C. Chambo', '644'),
          _buildRankingItem('6', 'Biology: An African Perspective', 'Prof. Rose Mumba', '531'),
          _buildRankingItem('7', 'Database Systems Design', 'B. T. Kumwenda', '498'),
          _buildRankingItem('8', 'Psychology of Learning', 'Dr. Alice Nkhoma', '422'),
          _buildRankingItem('9', 'Chichewa Grammar and Syntax', 'L. S. Chimombo', '388'),
          _buildRankingItem('10', 'Business Mathematics', 'T. K. Tembo', '315'),
          const SizedBox(height: 32),
          // Pagination Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Report generated on: October 24, 2026 - 14:45 CAT', style: TextStyle(color: AppTheme.textGrey.withOpacity(0.6), fontSize: 11)),
              Row(
                children: [
                  const Text('Items per page: 10', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 20),
                  _buildPageAction(Icons.chevron_left_rounded, false),
                  _buildPageNumber('1', true),
                  _buildPageNumber('2', false),
                  _buildPageAction(Icons.chevron_right_rounded, true),
                ],
              ),
            ],
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

  Widget _buildPageNumber(String label, bool active) {
    return Container(
      width: 28,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? AppTheme.primaryNavy : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: active ? null : Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: active ? Colors.white : AppTheme.textDark,
        ),
      ),
    );
  }

  Widget _buildPageAction(IconData icon, bool available) {
    return Container(
      width: 28,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Icon(icon, size: 16, color: available ? AppTheme.textDark : Colors.grey[300]),
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
}
