import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'student_search_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 24 : 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/unima_logo.jpg',
                    height: isMobile ? 100 : 120,
                    width: isMobile ? 100 : 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.account_balance_rounded,
                      size: isMobile ? 80 : 100,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'UNIVERSITY OF MALAWI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 24 : 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 4,
                  width: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'LIBRARY CATALOGUE RESERVE SYSTEM',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppTheme.textGrey,
                  ),
                ),
                const SizedBox(height: 48),

                // Welcome Message
                Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryNavy.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.waving_hand_rounded,
                        size: 48,
                        color: AppTheme.accentGold,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome to UNIMA Library',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 20 : 24,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Search our extensive collection of academic resources or manage the library catalogue',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          color: AppTheme.textGrey,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Action Cards
                Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: isMobile
                      ? Column(
                          children: [
                            _buildActionCard(
                              context,
                              icon: Icons.search_rounded,
                              title: 'Search Books',
                              description: 'Find books, journals, and academic resources',
                              color: AppTheme.primaryNavy,
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const StudentSearchScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildActionCard(
                              context,
                              icon: Icons.admin_panel_settings_rounded,
                              title: 'Admin Login',
                              description: 'Manage library catalogue and resources',
                              color: AppTheme.accentGold,
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
                                description: 'Find books, journals, and academic resources',
                                color: AppTheme.primaryNavy,
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
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildActionCard(
                                context,
                                icon: Icons.admin_panel_settings_rounded,
                                title: 'Admin Login',
                                description: 'Manage library catalogue and resources',
                                color: AppTheme.accentGold,
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
                const SizedBox(height: 48),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.copyright_rounded,
                      size: 14,
                      color: AppTheme.textGrey.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '2024 University of Malawi',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textGrey.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: color,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textGrey,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
