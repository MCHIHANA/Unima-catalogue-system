import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'books_available_screen.dart';
import 'library_info_screen.dart';
import 'login_screen.dart';
import 'school_books_screen.dart';
import 'student_search_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _selectedIndex = 0;

  static const List<_PublicSchool> _schools = [
    _PublicSchool(
      id: 'school-of-natural-and-applied-sciences',
      name: 'School of Natural and Applied Sciences',
      subtitle: 'Science, technology, mathematics and applied research',
      icon: Icons.science_rounded,
    ),
    _PublicSchool(
      id: 'school-of-humanities-and-social-sciences',
      name: 'School of Humanities and Social Sciences',
      subtitle: 'History, culture, society and human development',
      icon: Icons.history_edu_rounded,
    ),
    _PublicSchool(
      id: 'school-of-education',
      name: 'School of Education',
      subtitle: 'Teaching, learning and educational leadership',
      icon: Icons.school_rounded,
    ),
    _PublicSchool(
      id: 'school-of-law-economics-and-governance',
      name: 'School of Law, Economics and Government',
      subtitle: 'Law, economics, policy and public leadership',
      icon: Icons.gavel_rounded,
    ),
    _PublicSchool(
      id: 'kamuzu-college-of-health-sciences',
      name: 'Kamuzu College of Health Sciences',
      subtitle: 'Medicine, health sciences and clinical research',
      icon: Icons.local_hospital_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeDashboard(onNavigate: _handleHomeNavigation),
      _CatalogueGateway(
        onOpenCatalogue: _openCatalogue,
        onOpenStudentSearch: _openStudentSearch,
      ),
      _SchoolsOverview(schools: _schools),
      _ServicesOverview(
        onOpenServices: () => _openInfo(LibraryInfoPage.services),
      ),
      _MoreOverview(onOpenInfo: _openInfo),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      drawer: _ModernDrawer(
        onSelectHome: () => _selectTab(0),
        onSelectCatalogue: _openCatalogue,
        onSelectSchools: () => _selectTab(2),
        onSelectServices: () => _selectTab(3),
        onOpenInfo: _openInfo,
        onStudentSearch: _openStudentSearch,
        onLibrarianLogin: _openLibrarianLogin,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primaryNavy.withValues(alpha: 0.1),
        elevation: 8,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories_rounded),
            label: 'Catalogue',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance_rounded),
            label: 'Schools',
          ),
          NavigationDestination(
            icon: Icon(Icons.design_services_outlined),
            selectedIcon: Icon(Icons.design_services_rounded),
            label: 'Services',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'More',
          ),
        ],
      ),
    );
  }

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  void _handleHomeNavigation(_HomeDestination destination) {
    switch (destination) {
      case _HomeDestination.catalogue:
        _openCatalogue();
      case _HomeDestination.schools:
        _selectTab(2);
      case _HomeDestination.news:
        _openInfo(LibraryInfoPage.news);
      case _HomeDestination.events:
        _openInfo(LibraryInfoPage.events);
      case _HomeDestination.services:
        _selectTab(3);
      case _HomeDestination.locations:
        _openInfo(LibraryInfoPage.locations);
      case _HomeDestination.help:
        _openInfo(LibraryInfoPage.help);
      case _HomeDestination.about:
        _openInfo(LibraryInfoPage.about);
    }
  }

  void _openCatalogue() {
    Navigator.push(context, _fadeRoute(const BooksAvailableScreen()));
  }

  void _openStudentSearch() {
    Navigator.push(context, _fadeRoute(const StudentSearchScreen()));
  }

  void _openLibrarianLogin() {
    Navigator.push(context, _fadeRoute(const LoginScreen()));
  }

  void _openInfo(LibraryInfoPage page) {
    Navigator.push(context, _fadeRoute(LibraryInfoScreen(page: page)));
  }

  PageRouteBuilder<void> _fadeRoute(Widget screen) {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.03, 0.02),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  final ValueChanged<_HomeDestination> onNavigate;

  const _HomeDashboard({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall =
            constraints.maxHeight < 730 || constraints.maxWidth < 380;
        final horizontalPadding = constraints.maxWidth < 420 ? 16.0 : 22.0;
        final cardAspect = constraints.maxWidth < 380 ? 2.6 : 2.35;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            8,
            horizontalPadding,
            10,
          ),
          child: Column(
            children: [
              _HomeTopSection(isCompact: isSmall),
              SizedBox(height: isSmall ? 10 : 14),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: cardAspect,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: isSmall ? 8 : 12,
                  crossAxisSpacing: isSmall ? 8 : 12,
                  children: [
                    _DashboardTile(
                      icon: Icons.auto_stories_rounded,
                      title: 'Catalogue',
                      subtitle: 'Browse resources',
                      onTap: () => onNavigate(_HomeDestination.catalogue),
                    ),
                    _DashboardTile(
                      icon: Icons.account_balance_rounded,
                      title: 'Schools',
                      subtitle: 'Academic collections',
                      onTap: () => onNavigate(_HomeDestination.schools),
                    ),
                    _DashboardTile(
                      icon: Icons.newspaper_rounded,
                      title: 'News',
                      subtitle: 'Library updates',
                      onTap: () => onNavigate(_HomeDestination.news),
                    ),
                    _DashboardTile(
                      icon: Icons.event_rounded,
                      title: 'Library Events',
                      subtitle: 'Workshops and dates',
                      onTap: () => onNavigate(_HomeDestination.events),
                    ),
                    _DashboardTile(
                      icon: Icons.design_services_rounded,
                      title: 'Services',
                      subtitle: 'Research support',
                      onTap: () => onNavigate(_HomeDestination.services),
                    ),
                    _DashboardTile(
                      icon: Icons.location_on_rounded,
                      title: 'Locations',
                      subtitle: 'Libraries and hours',
                      onTap: () => onNavigate(_HomeDestination.locations),
                    ),
                    _DashboardTile(
                      icon: Icons.help_rounded,
                      title: 'Help',
                      subtitle: 'FAQs and rules',
                      onTap: () => onNavigate(_HomeDestination.help),
                    ),
                    _DashboardTile(
                      icon: Icons.info_rounded,
                      title: 'About',
                      subtitle: 'Mission and vision',
                      onTap: () => onNavigate(_HomeDestination.about),
                    ),
                  ],
                ),
              ),
              _QuickAccessBar(
                compact: isSmall,
                onStudentSearch: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentSearchScreen(),
                  ),
                ),
                onLibrarianLogin: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeTopSection extends StatelessWidget {
  final bool isCompact;

  const _HomeTopSection({required this.isCompact});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Builder(
              builder: (context) {
                return IconButton.filledTonal(
                  tooltip: 'Open navigation',
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu_rounded),
                );
              },
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_rounded,
                    size: 15,
                    color: AppTheme.accentGold,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'UNIMA',
                    style: TextStyle(
                      color: AppTheme.primaryNavy,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: isCompact ? 4 : 8),
        Container(
          height: isCompact ? 62 : 74,
          width: isCompact ? 62 : 74,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: AppTheme.cardShadow,
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/unima_logo.jpg',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.account_balance_rounded,
                color: AppTheme.primaryNavy,
              ),
            ),
          ),
        ),
        SizedBox(height: isCompact ? 8 : 12),
        Text(
          'UNIMA Library Catalogue',
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppTheme.primaryNavy,
            fontSize: isCompact ? 22 : 26,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Search, discover and access University Library resources.',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppTheme.textGrey,
            fontSize: isCompact ? 12 : 13,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
        ),
        SizedBox(height: isCompact ? 10 : 14),
        Hero(
          tag: 'catalogue-search',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentSearchScreen(),
                ),
              ),
              borderRadius: BorderRadius.circular(20),
              child: Ink(
                height: isCompact ? 52 : 58,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 34,
                      width: 34,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        color: AppTheme.primaryNavy,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Search books, journals, authors...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppTheme.accentGold,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppTheme.primaryNavy.withValues(alpha: 0.06)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTheme.primaryNavy, size: 23),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textGrey,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAccessBar extends StatelessWidget {
  final bool compact;
  final VoidCallback onStudentSearch;
  final VoidCallback onLibrarianLogin;

  const _QuickAccessBar({
    required this.compact,
    required this.onStudentSearch,
    required this.onLibrarianLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 8 : 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primaryNavy.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onStudentSearch,
              icon: const Icon(Icons.search_rounded, size: 18),
              label: const Text('Student Search'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onLibrarianLogin,
              icon: const Icon(Icons.admin_panel_settings_rounded, size: 18),
              label: const Text('Librarian Login'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogueGateway extends StatelessWidget {
  final VoidCallback onOpenCatalogue;
  final VoidCallback onOpenStudentSearch;

  const _CatalogueGateway({
    required this.onOpenCatalogue,
    required this.onOpenStudentSearch,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionScaffold(
      title: 'Catalogue',
      subtitle: 'Search and browse the University Library collection.',
      icon: Icons.auto_stories_rounded,
      child: Column(
        children: [
          _FeatureCard(
            icon: Icons.library_books_rounded,
            title: 'Browse Full Catalogue',
            subtitle:
                'View all books, e-resources, categories and availability.',
            actionLabel: 'Open catalogue',
            onTap: onOpenCatalogue,
          ),
          const SizedBox(height: 14),
          _FeatureCard(
            icon: Icons.manage_search_rounded,
            title: 'Student Search',
            subtitle:
                'Search quickly by title, author, ISBN, course or subject.',
            actionLabel: 'Start search',
            onTap: onOpenStudentSearch,
          ),
        ],
      ),
    );
  }
}

class _SchoolsOverview extends StatelessWidget {
  final List<_PublicSchool> schools;

  const _SchoolsOverview({required this.schools});

  @override
  Widget build(BuildContext context) {
    return _SectionScaffold(
      title: 'Schools',
      subtitle: 'Browse resources by academic school.',
      icon: Icons.account_balance_rounded,
      child: Column(
        children: schools.map((school) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SchoolCard(school: school),
          );
        }).toList(),
      ),
    );
  }
}

class _ServicesOverview extends StatelessWidget {
  final VoidCallback onOpenServices;

  const _ServicesOverview({required this.onOpenServices});

  @override
  Widget build(BuildContext context) {
    return _SectionScaffold(
      title: 'Library Services',
      subtitle: 'Academic support for study, teaching and research.',
      icon: Icons.design_services_rounded,
      child: Column(
        children: [
          _ServicePill(
            icon: Icons.search_rounded,
            title: 'Research assistance',
          ),
          _ServicePill(
            icon: Icons.cloud_done_rounded,
            title: 'Digital resources',
          ),
          _ServicePill(
            icon: Icons.groups_rounded,
            title: 'Information literacy workshops',
          ),
          _ServicePill(
            icon: Icons.menu_book_rounded,
            title: 'Books, journals and reserve materials',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onOpenServices,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('View all services'),
          ),
        ],
      ),
    );
  }
}

class _MoreOverview extends StatelessWidget {
  final ValueChanged<LibraryInfoPage> onOpenInfo;

  const _MoreOverview({required this.onOpenInfo});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MoreItem(Icons.info_rounded, 'About Library', LibraryInfoPage.about),
      _MoreItem(Icons.newspaper_rounded, 'Announcements', LibraryInfoPage.news),
      _MoreItem(Icons.event_rounded, 'Library Events', LibraryInfoPage.events),
      _MoreItem(
        Icons.location_on_rounded,
        'Contact and Locations',
        LibraryInfoPage.locations,
      ),
      _MoreItem(Icons.rule_rounded, 'Rules and FAQs', LibraryInfoPage.help),
      _MoreItem(Icons.settings_rounded, 'Settings', LibraryInfoPage.settings),
    ];

    return _SectionScaffold(
      title: 'More',
      subtitle: 'Library information, support and settings.',
      icon: Icons.grid_view_rounded,
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              leading: Icon(item.icon, color: AppTheme.primaryNavy),
              title: Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => onOpenInfo(item.page),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _SectionScaffold({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppTheme.backgroundLight,
          foregroundColor: AppTheme.primaryNavy,
          elevation: 0,
          leading: Builder(
            builder: (context) {
              return IconButton(
                tooltip: 'Open navigation',
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu_rounded),
              );
            },
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(title: title, subtitle: subtitle, icon: icon),
                const SizedBox(height: 20),
                child,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryNavy.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppTheme.accentGold),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SchoolCard extends StatelessWidget {
  final _PublicSchool school;

  const _SchoolCard({required this.school});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppTheme.primaryNavy.withValues(alpha: 0.07)),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SchoolBooksScreen(schoolId: school.id, schoolName: school.name),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(school.icon, color: AppTheme.primaryNavy),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      school.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      school.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.accentGold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.primaryNavy.withValues(alpha: 0.08)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppTheme.primaryNavy),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textGrey,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      actionLabel,
                      style: const TextStyle(
                        color: AppTheme.accentGold,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppTheme.accentGold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServicePill extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ServicePill({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryNavy.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryNavy),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernDrawer extends StatelessWidget {
  final VoidCallback onSelectHome;
  final VoidCallback onSelectCatalogue;
  final VoidCallback onSelectSchools;
  final VoidCallback onSelectServices;
  final ValueChanged<LibraryInfoPage> onOpenInfo;
  final VoidCallback onStudentSearch;
  final VoidCallback onLibrarianLogin;

  const _ModernDrawer({
    required this.onSelectHome,
    required this.onSelectCatalogue,
    required this.onSelectSchools,
    required this.onSelectServices,
    required this.onOpenInfo,
    required this.onStudentSearch,
    required this.onLibrarianLogin,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      backgroundColor: Colors.white,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 18),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/images/unima_logo.jpg',
                  height: 48,
                  width: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.account_balance_rounded),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UNIMA Library',
                      style: TextStyle(
                        color: AppTheme.primaryNavy,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Catalogue',
                      style: TextStyle(
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
        _drawerItem(context, Icons.home_rounded, 'Home', onSelectHome),
        _drawerItem(
          context,
          Icons.auto_stories_rounded,
          'Catalogue',
          onSelectCatalogue,
        ),
        _drawerItem(
          context,
          Icons.account_balance_rounded,
          'Schools',
          onSelectSchools,
        ),
        _drawerItem(
          context,
          Icons.design_services_rounded,
          'Library Services',
          onSelectServices,
        ),
        _drawerItem(
          context,
          Icons.event_rounded,
          'Events',
          () => onOpenInfo(LibraryInfoPage.events),
        ),
        _drawerItem(
          context,
          Icons.newspaper_rounded,
          'News',
          () => onOpenInfo(LibraryInfoPage.news),
        ),
        _drawerItem(
          context,
          Icons.info_rounded,
          'About',
          () => onOpenInfo(LibraryInfoPage.about),
        ),
        _drawerItem(
          context,
          Icons.location_on_rounded,
          'Contact',
          () => onOpenInfo(LibraryInfoPage.locations),
        ),
        _drawerItem(
          context,
          Icons.settings_rounded,
          'Settings',
          () => onOpenInfo(LibraryInfoPage.settings),
        ),
        const Divider(),
        _drawerItem(
          context,
          Icons.manage_search_rounded,
          'Student Search',
          onStudentSearch,
        ),
        _drawerItem(
          context,
          Icons.admin_panel_settings_rounded,
          'Librarian Login',
          onLibrarianLogin,
        ),
      ],
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return NavigationDrawerDestination(
      icon: Icon(icon),
      label: Text(title),
    ).wrapWithTap(context, onTap);
  }
}

extension _DrawerDestinationTap on NavigationDrawerDestination {
  Widget wrapWithTap(BuildContext context, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: this,
    );
  }
}

enum _HomeDestination {
  catalogue,
  schools,
  news,
  events,
  services,
  locations,
  help,
  about,
}

class _PublicSchool {
  final String id;
  final String name;
  final String subtitle;
  final IconData icon;

  const _PublicSchool({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
  });
}

class _MoreItem {
  final IconData icon;
  final String title;
  final LibraryInfoPage page;

  const _MoreItem(this.icon, this.title, this.page);
}
