import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _particleController;
  late AnimationController _slideController;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnim = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _particleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 1) {
      _slideController.reset();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
      _slideController.forward();
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _skip() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Animated background particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (_, __) => CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _ParticlePainter(_particleController.value),
            ),
          ),

          // Page content
          Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // click only!
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _buildPage(
                      animValue: _slideAnim,
                      icon: Icons.nightlight_round,
                      emojiIcon: '🌙',
                      title: 'Your Ramadan\nCompanion',
                      subtitle: 'رَمَضَان كَرِيم',
                      description:
                          'Track every prayer, fast, Quran recitation and Dhikr — all in one beautifully crafted app designed for this blessed month.',
                      features: const [
                        (Icons.mosque_rounded, 'Daily Prayer Tracker'),
                        (Icons.menu_book_rounded, 'Quran Progress'),
                        (Icons.nightlight_round, 'Fasting Log'),
                      ],
                      gradientColors: const [
                        Color(0xFF0A1628),
                        Color(0xFF0D2B1A),
                      ],
                      accentColor: AppTheme.emerald,
                    ),
                    _buildPage(
                      animValue: _slideAnim,
                      icon: Icons.star_rounded,
                      emojiIcon: '✨',
                      title: 'Grow Closer\nto Allah',
                      subtitle: 'اللَّهُ أَكْبَر',
                      description:
                          'Build powerful daily habits, earn spiritual streaks, and finish Ramadan feeling transformed — one act of worship at a time.',
                      features: const [
                        (Icons.radio_button_checked_rounded, 'Dhikr Counter'),
                        (Icons.calendar_month_rounded, '30-Day Calendar'),
                        (Icons.insights_rounded, 'Progress Insights'),
                      ],
                      gradientColors: const [
                        Color(0xFF1A0A28),
                        Color(0xFF0A1628),
                      ],
                      accentColor: AppTheme.gold,
                    ),
                  ],
                ),
              ),

              // Bottom controls
              _buildBottomBar(),
            ],
          ),

          // Skip button
          Positioned(
            top: 52,
            right: 24,
            child: TextButton(
              onPressed: _skip,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textMuted,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'Skip',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required Animation<double> animValue,
    required IconData icon,
    required String emojiIcon,
    required String title,
    required String subtitle,
    required String description,
    required List<(IconData, String)> features,
    required List<Color> gradientColors,
    required Color accentColor,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) => AnimatedBuilder(
        animation: animValue,
        builder: (_, child) => Opacity(
          opacity: animValue.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - animValue.value)),
            child: child,
          ),
        ),
        child: SizedBox(
          height: constraints.maxHeight,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 72, 24, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Central glowing icon
                Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          accentColor.withValues(alpha: 0.25),
                          accentColor.withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                      ),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        emojiIcon,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    subtitle,
                    style: GoogleFonts.amiri(
                      fontSize: 20,
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      height: 1.15,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ...features.map((f) => _FeatureRow(
                      icon: f.$1,
                      label: f.$2,
                      accentColor: accentColor,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(2, (i) {
              final isActive = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 32 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.emerald : AppTheme.textMuted,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // Next / Get Started button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.emerald, AppTheme.emeraldLight],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.emerald.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentPage == 0 ? 'Next' : 'Get Started',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _currentPage == 0
                          ? Icons.arrow_forward_rounded
                          : Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;

  const _FeatureRow({
    required this.icon,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          Icon(Icons.check_circle_rounded,
              color: accentColor.withValues(alpha: 0.7), size: 18),
        ],
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  _ParticlePainter(this.progress);

  static final _rand = math.Random(42);
  static final List<_Particle> _particles = List.generate(
    30,
    (i) => _Particle(
      x: _rand.nextDouble(),
      y: _rand.nextDouble(),
      radius: _rand.nextDouble() * 2 + 0.5,
      speed: _rand.nextDouble() * 0.3 + 0.05,
      opacity: _rand.nextDouble() * 0.4 + 0.1,
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final dy = (p.y + progress * p.speed) % 1.0;
      final paint = Paint()
        ..color =
            AppTheme.gold.withValues(alpha: p.opacity * (0.5 + 0.5 * math.sin(progress * math.pi * 2)))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(p.x * size.width, dy * size.height),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

class _Particle {
  final double x, y, radius, speed, opacity;
  const _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
  });
}
