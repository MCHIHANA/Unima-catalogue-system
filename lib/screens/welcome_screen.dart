import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import 'student_search_screen.dart';
import 'login_screen.dart';
import 'books_available_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _textController;
  late AnimationController _statsController;
  late AnimationController _graphController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _textAnimation;

  int _currentImageIndex = 0;
  final List<String> _backgroundImages = [
    'assets/images/books.png',
    'assets/images/image2.jpg',
  ];
  Timer? _imageTimer;

  // Animated statistics
  int _booksCount = 0;
  int _studentsCount = 0;
  int _resourcesCount = 0;
  int _schoolsCount = 0;

  int _targetBooks = 0;       // loaded from Firestore stream
  final int _targetStudents = 8500;
  final int _targetResources = 2300;
  final int _targetSchools = 5;

  StreamSubscription<QuerySnapshot>? _booksSubscription;
  Timer? _statsTimer;

  @override
  void initState() {
    super.initState();
    
    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    // Scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    // Text animation (continuous pulse)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _textAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    // Stats animation
    _statsController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Graph animation
    _graphController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();

    // Listen to real-time book count from Firestore
    _booksSubscription = FirebaseFirestore.instance
        .collection('books')
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;
      final newCount = snapshot.docs.length;
      if (newCount != _targetBooks) {
        setState(() {
          _targetBooks = newCount;
          // Immediately show the real count (no animation lag for updates)
          _booksCount = newCount;
        });
      }
    });

    // Animate the other static counters after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _animateStats();
    });

    // Start background image rotation
    _imageTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _backgroundImages.length;
        });
      }
    });
  }

  void _animateStats() {
    _statsController.forward();
    _statsTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        if (_studentsCount < _targetStudents) {
          _studentsCount += (_targetStudents / 80).round().clamp(1, _targetStudents);
          if (_studentsCount > _targetStudents) _studentsCount = _targetStudents;
        }
        if (_resourcesCount < _targetResources) {
          _resourcesCount += (_targetResources / 80).round().clamp(1, _targetResources);
          if (_resourcesCount > _targetResources) _resourcesCount = _targetResources;
        }
        if (_schoolsCount < _targetSchools) {
          _schoolsCount += 1;
          if (_schoolsCount > _targetSchools) _schoolsCount = _targetSchools;
        }
        
        if (_studentsCount >= _targetStudents && 
            _resourcesCount >= _targetResources &&
            _schoolsCount >= _targetSchools) {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _textController.dispose();
    _statsController.dispose();
    _graphController.dispose();
    _imageTimer?.cancel();
    _statsTimer?.cancel();
    _booksSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            child: Container(
              key: ValueKey<int>(_currentImageIndex),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_backgroundImages[_currentImageIndex]),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryNavy.withOpacity(0.8),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 24 : 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with scale animation
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentGold.withOpacity(0.5),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/unima_logo.jpg',
                            height: isMobile ? 120 : 150,
                            width: isMobile ? 120 : 150,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.account_balance_rounded,
                              size: isMobile ? 100 : 130,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // University Name with slide animation
                      SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            Text(
                              'UNIVERSITY OF MALAWI',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isMobile ? 28 : 42,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    offset: const Offset(0, 4),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 4,
                              width: 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.accentGold,
                                    AppTheme.accentGold.withOpacity(0.3),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentGold.withOpacity(0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'LIBRARY CATALOGUE RESERVE SYSTEM',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 60),

                      // Animated Welcome Message
                      ScaleTransition(
                        scale: _textAnimation,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 700),
                          padding: EdgeInsets.all(isMobile ? 28 : 40),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentGold.withOpacity(0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.auto_stories_rounded,
                                size: isMobile ? 56 : 72,
                                color: AppTheme.accentGold,
                              ),
                              const SizedBox(height: 20),
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    AppTheme.primaryNavy,
                                    AppTheme.accentGold,
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  'Welcome to UNIMA Library',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isMobile ? 28 : 38,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Discover Knowledge, Empower Learning',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isMobile ? 16 : 20,
                                  color: AppTheme.primaryNavy.withOpacity(0.7),
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Access our extensive collection of academic resources, journals, and research materials',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  color: AppTheme.textGrey,
                                  fontWeight: FontWeight.w500,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Action Cards with hover effect
                      Container(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: isMobile
                            ? Column(
                                children: [
                                  _buildActionCard(
                                    context,
                                    icon: Icons.search_rounded,
                                    title: 'Search Books',
                                    description: 'Explore our digital catalogue',
                                    color: AppTheme.primaryNavy,
                                    gradient: LinearGradient(
                                      colors: [AppTheme.primaryNavy, AppTheme.primaryNavy.withOpacity(0.8)],
                                    ),
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const StudentSearchScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  _buildActionCard(
                                    context,
                                    icon: Icons.admin_panel_settings_rounded,
                                    title: 'librarian POrtal',
                                    description: 'Manage library resources',
                                    color: AppTheme.accentGold,
                                    gradient: LinearGradient(
                                      colors: [AppTheme.accentGold, const Color(0xFFD4A017)],
                                    ),
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const LoginScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: _buildActionCard(
                                      context,
                                      icon: Icons.search_rounded,
                                      title: 'Search Books',
                                      description: 'Explore our digital catalogue',
                                      color: AppTheme.primaryNavy,
                                      gradient: LinearGradient(
                                        colors: [AppTheme.primaryNavy, AppTheme.primaryNavy.withOpacity(0.8)],
                                      ),
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const StudentSearchScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 32),
                                  Expanded(
                                    child: _buildActionCard(
                                      context,
                                      icon: Icons.admin_panel_settings_rounded,
                                      title: 'librarian POrtal',
                                      description: 'Manage library resources',
                                      color: AppTheme.accentGold,
                                      gradient: LinearGradient(
                                        colors: [AppTheme.accentGold, const Color(0xFFD4A017)],
                                      ),
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const LoginScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 60),

                      // Statistics Section with Animated Counters
                      Container(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        padding: EdgeInsets.all(isMobile ? 24 : 40),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryNavy.withOpacity(0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.analytics_rounded,
                                  color: AppTheme.accentGold,
                                  size: isMobile ? 28 : 36,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Library at a Glance',
                                  style: TextStyle(
                                    fontSize: isMobile ? 22 : 32,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.primaryNavy,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Real-time statistics and insights',
                              style: TextStyle(
                                fontSize: isMobile ? 13 : 15,
                                color: AppTheme.textGrey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 40),
                            
                            // Statistics Grid
                             isMobile
                                 ? Column(
                                     children: [
                                       _buildStatCard(
                                         icon: Icons.school_rounded,
                                         count: _schoolsCount,
                                         label: 'Academic Schools',
                                         color: AppTheme.primaryNavy,
                                         isMobile: isMobile,
                                         onTap: () {
                                           Navigator.push(
                                             context,
                                             MaterialPageRoute(
                                               builder: (context) => const StudentSearchScreen(),
                                             ),
                                           );
                                         },
                                       ),
                                       const SizedBox(height: 16),
                                       _buildStatCard(
                                         icon: Icons.menu_book_rounded,
                                         count: _booksCount,
                                         label: 'Books Available',
                                         color: AppTheme.primaryNavy,
                                         isMobile: isMobile,
                                         onTap: () {
                                           Navigator.push(
                                             context,
                                             MaterialPageRoute(
                                               builder: (context) => const StudentSearchScreen(),
                                             ),
                                           );
                                         },
                                       ),
                                       const SizedBox(height: 16),
                                       _buildStatCard(
                                         icon: Icons.people_rounded,
                                         count: _studentsCount,
                                         label: 'Active Students',
                                         color: AppTheme.primaryNavy,
                                         isMobile: isMobile,
                                       ),
                                       const SizedBox(height: 16),
                                       _buildStatCard(
                                         icon: Icons.article_rounded,
                                         count: _resourcesCount,
                                         label: 'Digital Resources',
                                         color: AppTheme.primaryNavy,
                                         isMobile: isMobile,
                                       ),
                                     ],
                                   )
                                 : Wrap(
                                     spacing: 20,
                                     runSpacing: 20,
                                     alignment: WrapAlignment.center,
                                     children: [
                                       _buildStatCard(
                                         icon: Icons.school_rounded,
                                         count: _schoolsCount,
                                         label: 'Academic Schools',
                                         color: AppTheme.primaryNavy,
                                         isMobile: isMobile,
                                         onTap: () {
                                           Navigator.push(
                                             context,
                                             MaterialPageRoute(
                                               builder: (context) => const StudentSearchScreen(),
                                             ),
                                           );
                                         },
                                       ),
                                       _buildStatCard(
                                         icon: Icons.menu_book_rounded,
                                         count: _booksCount,
                                         label: 'Books Available',
                                         color: AppTheme.primaryNavy,
                                         isMobile: isMobile,
                                         onTap: () {
                                           Navigator.push(
                                             context,
                                             MaterialPageRoute(
                                               builder: (context) => const StudentSearchScreen(),
                                             ),
                                           );
                                         },
                                       ),
                                       _buildStatCard(
                                         icon: Icons.people_rounded,
                                         count: _studentsCount,
                                         label: 'Active Students',
                                         color: AppTheme.primaryNavy,
                                         isMobile: isMobile,
                                       ),
                                       _buildStatCard(
                                         icon: Icons.article_rounded,
                                         count: _resourcesCount,
                                         label: 'Digital Resources',
                                         color: AppTheme.primaryNavy,
                                         isMobile: isMobile,
                                       ),
                                     ],
                                   ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),

                      // Library Showcase Images Section
                      Container(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: isMobile
                            ? Column(
                                children: [
                                  _buildImageShowcase(
                                    'assets/images/books.png',
                                    'Extensive Book Collection',
                                    'Thousands of academic resources at your fingertips',
                                    isMobile,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const StudentSearchScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  _buildImageShowcase(
                                    'assets/images/image2.jpg',
                                    'Modern Library Facilities',
                                    'State-of-the-art study spaces and digital resources',
                                    isMobile,
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: _buildImageShowcase(
                                      'assets/images/books.png',
                                      'Extensive Book Collection',
                                      'Thousands of academic resources at your fingertips',
                                      isMobile,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const StudentSearchScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: _buildImageShowcase(
                                      'assets/images/image2.jpg',
                                      'Modern Library Facilities',
                                      'State-of-the-art study spaces and digital resources',
                                      isMobile,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 50),

                      // About the Library Section
                      Container(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        padding: EdgeInsets.all(isMobile ? 28 : 48),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryNavy,
                              AppTheme.primaryNavy.withOpacity(0.9),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryNavy.withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // About Section
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentGold.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.info_rounded,
                                    color: AppTheme.accentGold,
                                    size: isMobile ? 28 : 36,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'About the Library',
                                    style: TextStyle(
                                      fontSize: isMobile ? 24 : 32,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.accentGold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'The University of Malawi Library supports the core and non-core functions of the university. The library is an integral part of the University\'s mission which revolves around teaching, research and consultancy. This is in-line with the library\'s primary objective of providing access to information resources, conservation and preservation of knowledge.',
                              style: TextStyle(
                                fontSize: isMobile ? 15 : 17,
                                color: Colors.white.withOpacity(0.95),
                                fontWeight: FontWeight.w500,
                                height: 1.8,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'The University of Malawi Library is located at the center of the teaching area of the campus, easily accessible to all members, who include staff, students and registered members of the community.',
                              style: TextStyle(
                                fontSize: isMobile ? 15 : 17,
                                color: Colors.white.withOpacity(0.95),
                                fontWeight: FontWeight.w500,
                                height: 1.8,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Vision & Mission Cards
                            isMobile
                                ? Column(
                                    children: [
                                      _buildInfoCard(
                                        icon: Icons.visibility_rounded,
                                        title: 'Vision',
                                        content: 'To be a library with a global perspective, providing an excellent academic environment for learning, teaching, research and collaboration.',
                                        isMobile: isMobile,
                                      ),
                                      const SizedBox(height: 20),
                                      _buildInfoCard(
                                        icon: Icons.flag_rounded,
                                        title: 'Mission',
                                        content: 'Provide quality information resources and services to support learning, teaching, research, and consultancy to the college and the wider community for the sustainable development of the country.',
                                        isMobile: isMobile,
                                      ),
                                    ],
                                  )
                                : Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _buildInfoCard(
                                          icon: Icons.visibility_rounded,
                                          title: 'Vision',
                                          content: 'To be a library with a global perspective, providing an excellent academic environment for learning, teaching, research and collaboration.',
                                          isMobile: isMobile,
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: _buildInfoCard(
                                          icon: Icons.flag_rounded,
                                          title: 'Mission',
                                          content: 'Provide quality information resources and services to support learning, teaching, research, and consultancy to the college and the wider community for the sustainable development of the country.',
                                          isMobile: isMobile,
                                        ),
                                      ),
                                    ],
                                  ),
                            const SizedBox(height: 40),

                            // Access to Library Section
                            Container(
                              padding: EdgeInsets.all(isMobile ? 24 : 32),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppTheme.accentGold.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.library_books_rounded,
                                        color: AppTheme.accentGold,
                                        size: isMobile ? 28 : 32,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Access to the Library',
                                          style: TextStyle(
                                            fontSize: isMobile ? 20 : 26,
                                            fontWeight: FontWeight.w900,
                                            color: AppTheme.accentGold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'The University of Malawi library offers a wide range of services designed to support the academic and research needs of its students, researchers, staff, and the surrounding community. These services include access to a vast collection of books, journals, and digital resources, providing essential information for study and research.',
                                    style: TextStyle(
                                      fontSize: isMobile ? 14 : 16,
                                      color: Colors.white.withOpacity(0.95),
                                      fontWeight: FontWeight.w500,
                                      height: 1.8,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'The library also offers personalized research assistance, training workshops on information literacy, and a comfortable environment for individual and group study. Its commitment to serving not only the university community but also local residents highlights its role as a vital resource hub, fostering learning and knowledge sharing beyond campus boundaries.',
                                    style: TextStyle(
                                      fontSize: isMobile ? 14 : 16,
                                      color: Colors.white.withOpacity(0.95),
                                      fontWeight: FontWeight.w500,
                                      height: 1.8,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 60),

                      // Footer
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.copyright_rounded,
                              size: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '2026 University of Malawi • All Rights Reserved',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 200),
          tween: Tween(begin: 1.0, end: 1.0),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 56,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Get Started',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: color,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
    required bool isMobile,
    VoidCallback? onTap,
  }) {
    final bool isClickable = onTap != null;
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setStateBuilder) {
        return MouseRegion(
          cursor: isClickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onEnter: (_) {
            if (isClickable) {
              setStateBuilder(() => isHovered = true);
            }
          },
          onExit: (_) {
            if (isClickable) {
              setStateBuilder(() => isHovered = false);
            }
          },
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              transform: isHovered 
                  ? (Matrix4.diagonal3Values(1.03, 1.03, 1.0)..setTranslationRaw(0.0, -8.0, 0.0)) 
                  : Matrix4.identity(),
              width: isMobile ? double.infinity : 260,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    isHovered ? color.withOpacity(0.95) : color.withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isHovered ? AppTheme.accentGold : AppTheme.accentGold.withOpacity(0.5),
                  width: isHovered ? 2.5 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isHovered ? AppTheme.accentGold.withOpacity(0.4) : color.withOpacity(0.4),
                    blurRadius: isHovered ? 25 : 20,
                    offset: isHovered ? const Offset(0, 12) : const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isHovered ? AppTheme.accentGold.withOpacity(0.3) : AppTheme.accentGold.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isHovered ? AppTheme.accentGold : AppTheme.accentGold.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 44,
                      color: AppTheme.accentGold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1500),
                    tween: Tween(begin: 0, end: count.toDouble()),
                    builder: (context, value, child) {
                      return Text(
                        value.toInt().toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        ),
                        style: TextStyle(
                          fontSize: isMobile ? 40 : 48,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.accentGold,
                          height: 1,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isMobile ? 15 : 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            height: 1.3,
                          ),
                        ),
                      ),
                      if (isClickable) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppTheme.accentGold,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentGold.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.accentGold,
                  size: isMobile ? 24 : 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.accentGold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.white.withOpacity(0.95),
              fontWeight: FontWeight.w500,
              height: 1.8,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageShowcase(
    String imagePath,
    String title,
    String description,
    bool isMobile, {
    VoidCallback? onTap,
  }) {
    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryNavy.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Image
            AspectRatio(
              aspectRatio: isMobile ? 1.2 : 1.5,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppTheme.primaryNavy.withOpacity(0.1),
                  child: Center(
                    child: Icon(
                      Icons.image_rounded,
                      size: 80,
                      color: AppTheme.primaryNavy.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),
            // Text Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(isMobile ? 20 : 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'FEATURED',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryNavy,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.95),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Decorative Corner
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentGold.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: AppTheme.primaryNavy,
                  size: isMobile ? 20 : 24,
                ),
              ),
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }
}
