import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/dashboard_screen.dart';
import '../screens/manage_books_screen.dart';
import '../screens/analytics_screen.dart';
import '../screens/add_book_screen.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String currentRoute;
  /// Optional callback for the ADD NEW BOOK button.
  /// When provided, the button is shown; when null, navigation goes to ManageBooks.
  final VoidCallback? onAddBook;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentRoute,
    this.onAddBook,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      drawer: !isDesktop ? _buildDrawer(context) : null,
      appBar: isDesktop
          ? PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: _buildTopNav(context),
            )
          : AppBar(
              title: const Text('UNIMA Library'),
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryNavy,
              elevation: 1,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  tooltip: 'Add New Book',
                  onPressed: _handleAddBook(context),
                ),
              ],
            ),
      body: Row(
        children: [
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  /// Returns the correct onPressed handler for ADD NEW BOOK.
  VoidCallback _handleAddBook(BuildContext context) {
    if (widget.onAddBook != null) {
      return widget.onAddBook!;
    }
    // Default: navigate to ManageBooks (from Dashboard, Reports, etc.)
    return () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ManageBooksScreen()),
        );
  }

  Widget _buildTopNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F3F9))),
      ),
      child: Row(
        children: [
          // Logo & Title
          Image.asset('assets/images/unima_logo.jpg', height: 40),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'UNIMA LIBRARY CATALOGUE',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: AppTheme.primaryNavy,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'RESERVE SYSTEM',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.accentGold,
                  letterSpacing: 1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const Spacer(),
          // Nav Links
          _buildNavLink('Dashboard', widget.currentRoute == 'Dashboard', () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
          }),
          _buildNavLink('Reports', widget.currentRoute == 'Reports', () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
          }),
          _buildNavLink('Manage Books', widget.currentRoute == 'ManageBooks', () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ManageBooksScreen()));
          }),
          const SizedBox(width: 20),
          // ADD NEW BOOK Button — properly wired
          ElevatedButton.icon(
            onPressed: _handleAddBook(context),
            icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
            label: const Text('ADD NEW BOOK'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
              textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
            ),
          ),
          const SizedBox(width: 32),
          // Profile
          Row(
            children: [
              Container(height: 32, width: 1, color: const Color(0xFFF1F3F9)),
              const SizedBox(width: 24),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    'Administrator',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Library Services',
                    style: TextStyle(fontSize: 11, color: AppTheme.textGrey, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(width: 14),
              const CircleAvatar(radius: 20, backgroundColor: Color(0xFFE5E7EB)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(String title, bool isActive, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isActive ? AppTheme.primaryNavy : AppTheme.textGrey,
                  fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (isActive) ...[
                const SizedBox(height: 4),
                Container(height: 3, width: 30, color: AppTheme.primaryNavy),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primaryNavy),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/unima_logo.jpg', height: 40),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'UNIMA LIBRARY',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.grid_view_rounded),
            title: const Text('Dashboard'),
            selected: widget.currentRoute == 'Dashboard',
            selectedColor: AppTheme.primaryNavy,
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.analytics_outlined),
            title: const Text('Reports'),
            selected: widget.currentRoute == 'Reports',
            selectedColor: AppTheme.primaryNavy,
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_rounded),
            title: const Text('Manage Books'),
            selected: widget.currentRoute == 'ManageBooks',
            selectedColor: AppTheme.primaryNavy,
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ManageBooksScreen())),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.accentGold),
            title: const Text('Add New Book', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.w700)),
            onTap: () {
              Navigator.pop(context); // close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddBookScreen()),
              );
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
    );
  }
}
