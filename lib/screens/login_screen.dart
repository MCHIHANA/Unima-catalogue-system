import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../services/audit_service.dart';
import '../models/activity_log.dart';
import 'dashboard_screen.dart';
import 'welcome_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _rememberDevice = false;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuditService _auditService = AuditService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter both email and password.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Log successful access
      await _auditService.logUserAccess(
        userId: userCredential.user!.uid,
        userEmail: email,
      );

      // Log user login activity
      await _auditService.logActivity(
        userId: userCredential.user!.uid,
        userEmail: email,
        activityType: ActivityType.userLoggedIn,
        description: '$email successfully logged into the system',
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      
      // Log failed login attempt
      await _auditService.logFailedLogin(
        userEmail: email,
        failureReason: e.code,
      );

      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Authentication failed.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      // Log unexpected error during login
      await _auditService.logFailedLogin(
        userEmail: email,
        failureReason: 'Unexpected error: ${e.toString()}',
      );

      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('An unexpected error occurred.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 700;
    // Responsive horizontal padding: tight on phone, none on desktop (card is centred)
    final hPad = isDesktop ? 0.0 : 20.0;
    // Card fills screen width on mobile, capped at 460 on desktop
    final cardWidth = isDesktop ? 460.0 : double.infinity;
    // Inner card padding — tighter on phone
    final cardHPad = size.width < 380 ? 20.0 : (isDesktop ? 40.0 : 28.0);
    final cardVPad = isDesktop ? 44.0 : 32.0;

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          // ── Background gradient ─────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryNavy,
                  Color(0xFF0D1147),
                  AppTheme.primaryNavy,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // ── Decorative gold circle top-right ────────────────────────────
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentGold.withValues(alpha: 0.1),
              ),
            ),
          ),
          // ── Decorative gold circle bottom-left ──────────────────────────
          Positioned(
            bottom: -100,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentGold.withValues(alpha: 0.07),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    vertical: isDesktop ? 40 : 24, horizontal: hPad),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Logo ────────────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentGold.withValues(alpha: 0.4),
                            blurRadius: 28,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/unima_logo.jpg',
                        height: isDesktop ? 100 : 80,
                        width: isDesktop ? 100 : 80,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.account_balance_rounded,
                                size: 70, color: AppTheme.primaryNavy),
                      ),
                    ),
                    SizedBox(height: isDesktop ? 24 : 18),
                    Text(
                      'UNIVERSITY OF MALAWI',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isDesktop ? 24 : 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 3,
                      width: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.accentGold,
                            AppTheme.accentGold.withValues(alpha: 0.4)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'LIBRARY CATALOGUE RESERVE SYSTEM',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isDesktop ? 13 : 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                    SizedBox(height: isDesktop ? 40 : 28),

                    // ── Login card ───────────────────────────────────────────
                    Container(
                      width: cardWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.22),
                            blurRadius: 36,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Gold top border
                          Container(
                            height: 5,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppTheme.accentGold,
                                  Color(0xFFD4A017)
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: cardHPad, vertical: cardVPad),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Librarian Login',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 24 : 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.primaryNavy,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Authenticate with your institutional email and password to access the console.',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 14 : 13,
                                    color: Colors.grey.shade600,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: isDesktop ? 32 : 24),

                                // Email
                                _buildLabel('Email Address'),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark),
                                  decoration: InputDecoration(
                                    hintText: 'admin@unima.ac.mw',
                                    hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                    prefixIcon: const Icon(
                                        Icons.email_outlined,
                                        size: 22,
                                        color: AppTheme.primaryNavy),
                                    filled: true,
                                    fillColor: const Color(0xFFF9FAFB),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: AppTheme.primaryNavy,
                                            width: 2)),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Password
                                _buildLabel('Password'),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark),
                                  decoration: InputDecoration(
                                    hintText: '••••••••',
                                    hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 14),
                                    prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                        size: 22,
                                        color: AppTheme.primaryNavy),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: Colors.grey.shade500,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(() =>
                                          _obscurePassword = !_obscurePassword),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF9FAFB),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: AppTheme.primaryNavy,
                                            width: 2)),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Remember me + Recover password
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _rememberDevice,
                                        onChanged: (value) => setState(
                                            () => _rememberDevice =
                                                value ?? false),
                                        activeColor: AppTheme.primaryNavy,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Remember me',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textGrey)),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize
                                              .shrinkWrap),
                                      child: const Text(
                                        'Recover Password',
                                        style: TextStyle(
                                          color: AppTheme.accentGold,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isDesktop ? 28 : 22),

                                // Sign in button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed:
                                        _isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryNavy,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 17),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      elevation: 0,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2),
                                          )
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'SIGN IN',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 15,
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Icon(
                                                  Icons.arrow_forward_rounded,
                                                  size: 20),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.security_rounded,
                            size: 13,
                            color: Colors.white.withValues(alpha: 0.55)),
                        const SizedBox(width: 6),
                        Text(
                          'Secure Institutional Authentication',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 13,
        color: AppTheme.primaryNavy,
        letterSpacing: 0.5,
      ),
    );
  }
}