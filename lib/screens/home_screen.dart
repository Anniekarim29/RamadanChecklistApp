import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/prayer_provider.dart';
import '../providers/quran_provider.dart';
import '../providers/fasting_provider.dart';
import '../providers/dhikr_provider.dart';
import 'prayer_screen.dart';
import 'quran_screen.dart';
import 'fasting_screen.dart';
import 'dhikr_screen.dart';
import 'calendar_screen.dart';

// ────────────────────────────────────────────────────────────────────────────
// Nav items
// ────────────────────────────────────────────────────────────────────────────
const _navItems = [
  _NavItem(Icons.home_rounded,           'Home'),
  _NavItem(Icons.mosque_rounded,          'Prayers'),
  _NavItem(Icons.menu_book_rounded,       'Quran'),
  _NavItem(Icons.nightlight_round,        'Fasting'),
  _NavItem(Icons.scatter_plot_rounded,    'Dhikr'),
];

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

// ────────────────────────────────────────────────────────────────────────────
// HomeScreen
// ────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;

  late AnimationController _glowController;

  final List<Widget> _screens = [
    const _HomeTab(),
    const PrayerScreen(),
    const QuranScreen(),
    const FastingScreen(),
    const DhikrScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppTheme.background,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: _currentIndex,
        glowController: _glowController,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Floating Curved Bottom Navigation Bar
// ────────────────────────────────────────────────────────────────────────────
class _FloatingNavBar extends StatefulWidget {
  final int currentIndex;
  final AnimationController glowController;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.glowController,
    required this.onTap,
  });

  @override
  State<_FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<_FloatingNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnim;
  int _prevIndex = 0;

  @override
  void initState() {
    super.initState();
    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _indicatorAnim = CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void didUpdateWidget(_FloatingNavBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _prevIndex = old.currentIndex;
      _indicatorController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: AnimatedBuilder(
        animation: widget.glowController,
        builder: (_, child) {
          final glow = 0.3 + 0.2 * widget.glowController.value;
          return Container(
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF151F2E),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: AppTheme.gold.withValues(alpha: 0.25),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.gold.withValues(alpha: glow * 0.25),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: child,
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (i) {
            final item = _navItems[i];
            final isActive = i == widget.currentIndex;
            return _NavBarItem(
              item: item,
              isActive: isActive,
              onTap: () => widget.onTap(i),
            );
          }),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: isActive
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.emerald.withValues(alpha: 0.25),
                    AppTheme.gold.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppTheme.emerald.withValues(alpha: 0.4),
                  width: 1,
                ),
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 22,
              color: isActive ? AppTheme.emerald : AppTheme.textMuted,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                item.label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.emerald,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Home Tab
// ────────────────────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  int _getRamadanDay() {
    final ramadanStart = DateTime(2026, 3, 1);
    final today = DateTime.now();
    final diff = today.difference(ramadanStart).inDays + 1;
    return diff.clamp(1, 30);
  }

  @override
  Widget build(BuildContext context) {
    final prayerProv = context.watch<PrayerProvider>();
    final quranProv  = context.watch<QuranProvider>();
    final fastingProv = context.watch<FastingProvider>();
    final dhikrProv  = context.watch<DhikrProvider>();

    final today      = DateTime.now();
    final dateStr    = DateFormat('EEEE, d MMMM yyyy').format(today);
    final ramadanDay = _getRamadanDay();

    final prayerScore = prayerProv.prayerProgress;
    final quranScore  = quranProv.overallProgress.clamp(0.0, 1.0);
    final fastingScore = fastingProv.fastingProgress;
    final dhikrScore = ((dhikrProv.subhanallahCount / 33) +
            (dhikrProv.alhamdulillahCount / 33) +
            (dhikrProv.allahuakbarCount / 34)) /
        3;
    final overallProgress =
        (prayerScore + quranScore + fastingScore + dhikrScore.clamp(0.0, 1.0)) / 4;

    return CustomScrollView(
      slivers: [
        // ── Hero header with lantern ──────────────────────────────────
        SliverToBoxAdapter(
          child: _LanternHeroHeader(
            dateStr: dateStr,
            ramadanDay: ramadanDay,
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 20),

              // Overall progress ring card
              _OverallProgressCard(progress: overallProgress),

              const SizedBox(height: 24),

              // Section label
              _SectionLabel(label: "Today's Worship", arabic: 'عِبَادَةُ الْيَوْم'),

              const SizedBox(height: 14),

              // 2×2 grid of feature cards
              _WarmFeatureGrid(
                prayerProv: prayerProv,
                quranProv: quranProv,
                fastingProv: fastingProv,
                dhikrProv: dhikrProv,
                prayerScore: prayerScore,
                quranScore: quranScore,
                fastingScore: fastingScore,
                dhikrScore: dhikrScore.clamp(0.0, 1.0),
                onNavigate: (i) {
                  final state = context.findAncestorStateOfType<_HomeScreenState>();
                  state?.setState(() => state._currentIndex = i);
                },
              ),

              const SizedBox(height: 24),

              // Calendar shortcut
              _CalendarBanner(ramadanDay: ramadanDay),

              const SizedBox(height: 24),

              // Hadith card
              const _HadithCard(),

              const SizedBox(height: 16),
            ]),
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Lantern Hero Header
// ────────────────────────────────────────────────────────────────────────────
class _LanternHeroHeader extends StatefulWidget {
  final String dateStr;
  final int ramadanDay;

  const _LanternHeroHeader({required this.dateStr, required this.ramadanDay});

  @override
  State<_LanternHeroHeader> createState() => _LanternHeroHeaderState();
}

class _LanternHeroHeaderState extends State<_LanternHeroHeader>
    with TickerProviderStateMixin {
  late AnimationController _swayController;
  late AnimationController _glowController;
  late Animation<double> _sway;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _sway = Tween<double>(begin: -0.06, end: 0.06).animate(
      CurvedAnimation(parent: _swayController, curve: Curves.easeInOut),
    );
    _glow = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _swayController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_swayController, _glowController]),
      builder: (_, __) {
        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A), // Deep Midnight/Charcoal base
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // Top row: greeting + day badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'رَمَضَان كَرِيم',
                            style: GoogleFonts.amiri(
                              fontSize: 22,
                              color: AppTheme.gold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.dateStr,
                            style: GoogleFonts.poppins(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      // Day badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.gold.withValues(alpha: 0.25),
                              AppTheme.gold.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.gold.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Day ${widget.ramadanDay}',
                              style: GoogleFonts.poppins(
                                color: AppTheme.gold,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'of Ramadan',
                              style: GoogleFonts.poppins(
                                color: AppTheme.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Lantern
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Warm glow behind lantern
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFFF8C00)
                                  .withValues(alpha: 0.22 * _glow.value),
                              const Color(0xFFFFD700)
                                  .withValues(alpha: 0.10 * _glow.value),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      // Swaying lantern
                      Transform.rotate(
                        angle: _sway.value,
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: 100,
                          height: 140,
                          child: CustomPaint(
                            painter: _LanternPainter(glowIntensity: _glow.value),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Fanoos (Lantern) Painter
// ────────────────────────────────────────────────────────────────────────────
class _LanternPainter extends CustomPainter {
  final double glowIntensity;
  const _LanternPainter({required this.glowIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Chain / hanger ────────────────────────────────────────────
    final chainPaint = Paint()
      ..color = AppTheme.gold.withValues(alpha: 0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, h * 0.12), chainPaint);

    // Hanger cap
    final capPaint = Paint()
      ..color = AppTheme.gold
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(w / 2, h * 0.13), width: w * 0.28, height: h * 0.05),
        const Radius.circular(4),
      ),
      capPaint,
    );

    // ── Inner glow ────────────────────────────────────────────────
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFB347).withValues(alpha: 0.9 * glowIntensity),
          const Color(0xFFFF8C00).withValues(alpha: 0.5 * glowIntensity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(w / 2, h * 0.55),
        width: w * 0.85,
        height: h * 0.5,
      ));
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w / 2, h * 0.56), width: w * 0.72, height: h * 0.45),
      glowPaint,
    );

    // ── Body of lantern ───────────────────────────────────────────
    final bodyPath = Path();
    // Top dome
    bodyPath.moveTo(w * 0.28, h * 0.22);
    bodyPath.quadraticBezierTo(w / 2, h * 0.14, w * 0.72, h * 0.22);
    // Right side curve
    bodyPath.quadraticBezierTo(w * 0.88, h * 0.5, w * 0.72, h * 0.78);
    // Bottom dome
    bodyPath.quadraticBezierTo(w / 2, h * 0.86, w * 0.28, h * 0.78);
    // Left side curve
    bodyPath.quadraticBezierTo(w * 0.12, h * 0.5, w * 0.28, h * 0.22);
    bodyPath.close();

    // Gold border
    final borderPaint = Paint()
      ..color = AppTheme.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(bodyPath, borderPaint);

    // Translucent amber body
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFFD700).withValues(alpha: 0.18),
          const Color(0xFFFF8C00).withValues(alpha: 0.28 * glowIntensity),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.14, w, h * 0.72));
    canvas.drawPath(bodyPath, fillPaint);

    // ── Vertical ribbing lines ────────────────────────────────────
    final ribbingPaint = Paint()
      ..color = AppTheme.gold.withValues(alpha: 0.45)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (int i = 1; i < 4; i++) {
      final x = w * (0.28 + i * 0.11);
      canvas.drawLine(
        Offset(x, h * 0.24),
        Offset(x, h * 0.76),
        ribbingPaint,
      );
    }

    // Horizontal band mid
    canvas.drawLine(
      Offset(w * 0.18, h * 0.5),
      Offset(w * 0.82, h * 0.5),
      ribbingPaint,
    );

    // ── Star cutout decoration ────────────────────────────────────
    _drawStar(
        canvas,
        Offset(w / 2, h * 0.50),
        w * 0.1,
        Paint()
          ..color = AppTheme.gold.withValues(alpha: 0.9)
          ..style = PaintingStyle.fill);

    // ── Bottom tassel ─────────────────────────────────────────────
    final tasselPaint = Paint()
      ..color = AppTheme.gold
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(w / 2, h * 0.89), width: w * 0.2, height: h * 0.04),
        const Radius.circular(3),
      ),
      tasselPaint,
    );
    // Fringe lines
    for (int i = -2; i <= 2; i++) {
      canvas.drawLine(
        Offset(w / 2 + i * w * 0.04, h * 0.91),
        Offset(w / 2 + i * w * 0.04, h * 0.97),
        chainPaint,
      );
    }
  }

  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    const pts = 8;
    final path = Path();
    for (int i = 0; i < pts * 2; i++) {
      final radius = i.isEven ? r : r * 0.45;
      final angle = (i * math.pi / pts) - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LanternPainter old) =>
      old.glowIntensity != glowIntensity;
}

// ────────────────────────────────────────────────────────────────────────────
// Section Label
// ────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final String arabic;
  const _SectionLabel({required this.label, required this.arabic});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.gold, AppTheme.emerald],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            Text(
              arabic,
              style: GoogleFonts.amiri(
                color: AppTheme.gold.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Overall Progress Card
// ────────────────────────────────────────────────────────────────────────────
class _OverallProgressCard extends StatelessWidget {
  final double progress;
  const _OverallProgressCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface, // Solid deep surface
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.gold.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular ring
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 7,
                    backgroundColor: AppTheme.surfaceLight,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppTheme.gold),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(progress * 100).round()}%',
                      style: GoogleFonts.poppins(
                        color: AppTheme.gold,
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      'done',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Progress',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  progress >= 1.0
                      ? '🎉 All tasks complete! Masha\'Allah!'
                      : progress >= 0.5
                          ? '💫 You\'re more than halfway! Keep going!'
                          : '🌙 Start your worship for today',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                // Progress bar segments
                _ProgressSegments(progress: progress),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSegments extends StatelessWidget {
  final double progress;
  const _ProgressSegments({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 6,
        backgroundColor: AppTheme.surfaceLight,
        valueColor: AlwaysStoppedAnimation<Color>(
          progress >= 1.0 ? AppTheme.emerald : AppTheme.gold,
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// 2×2 Warm Feature Grid
// ────────────────────────────────────────────────────────────────────────────
class _WarmFeatureGrid extends StatelessWidget {
  final PrayerProvider prayerProv;
  final QuranProvider quranProv;
  final FastingProvider fastingProv;
  final DhikrProvider dhikrProv;
  final double prayerScore, quranScore, fastingScore, dhikrScore;
  final void Function(int) onNavigate;

  const _WarmFeatureGrid({
    required this.prayerProv,
    required this.quranProv,
    required this.fastingProv,
    required this.dhikrProv,
    required this.prayerScore,
    required this.quranScore,
    required this.fastingScore,
    required this.dhikrScore,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _FeatureCardData(
        icon: Icons.mosque_rounded,
        title: 'Prayers',
        subtitle: '${prayerProv.completedPrayers}/${prayerProv.totalPrayers} done',
        arabic: 'الصَّلَاة',
        progress: prayerScore,
        gradientColors: const [Color(0xFF0D2B1A), Color(0xFF142D21)],
        accentColor: AppTheme.emerald,
        navIndex: 1,
      ),
      _FeatureCardData(
        icon: Icons.menu_book_rounded,
        title: 'Quran',
        subtitle: '${quranProv.todayPagesRead} pages today',
        arabic: 'الْقُرْآن',
        progress: quranScore,
        gradientColors: const [Color(0xFF0F1E2D), Color(0xFF162536)],
        accentColor: const Color(0xFF60A5FA),
        navIndex: 2,
      ),
      _FeatureCardData(
        icon: Icons.nightlight_round,
        title: 'Fasting',
        subtitle: '${fastingProv.daysFasted}/30 days',
        arabic: 'الصِّيَام',
        progress: fastingScore,
        gradientColors: const [Color(0xFF1A142E), Color(0xFF231B3A)],
        accentColor: const Color(0xFFA78BFA),
        navIndex: 3,
      ),
      _FeatureCardData(
        icon: Icons.scatter_plot_rounded,
        title: 'Dhikr',
        subtitle:
            '${dhikrProv.subhanallahCount + dhikrProv.alhamdulillahCount + dhikrProv.allahuakbarCount} total',
        arabic: 'الذِّكْر',
        gradientColors: const [Color(0xFF1E1B15), Color(0xFF2D2820)],
        accentColor: AppTheme.gold,
        navIndex: 4,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemCount: cards.length,
      itemBuilder: (_, i) =>
          _WarmFeatureCard(data: cards[i], onTap: () => onNavigate(cards[i].navIndex)),
    );
  }
}

class _FeatureCardData {
  final IconData icon;
  final String title, subtitle, arabic;
  final double progress;
  final List<Color> gradientColors;
  final Color accentColor;
  final int navIndex;

  const _FeatureCardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.arabic,
    required this.progress,
    required this.gradientColors,
    required this.accentColor,
    required this.navIndex,
  });
}

class _WarmFeatureCard extends StatelessWidget {
  final _FeatureCardData data;
  final VoidCallback onTap;

  const _WarmFeatureCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: data.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: data.accentColor.withValues(alpha: 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: data.accentColor.withValues(alpha: 0.08),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: data.accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(data.icon, color: data.accentColor, size: 20),
                ),
                Text(
                  '${(data.progress * 100).round()}%',
                  style: GoogleFonts.poppins(
                    color: data.progress >= 1.0
                        ? AppTheme.emerald
                        : data.accentColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              data.arabic,
              style: GoogleFonts.amiri(
                color: data.accentColor.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              data.title,
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            Text(
              data.subtitle,
              style: GoogleFonts.poppins(
                color: AppTheme.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: data.progress,
                minHeight: 4,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  data.progress >= 1.0 ? AppTheme.emerald : data.accentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Calendar Banner
// ────────────────────────────────────────────────────────────────────────────
class _CalendarBanner extends StatelessWidget {
  final int ramadanDay;
  const _CalendarBanner({required this.ramadanDay});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CalendarScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.gold.withValues(alpha: 0.15),
              AppTheme.gold.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.gold.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.calendar_month_rounded,
                  color: AppTheme.gold, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '30-Day Ramadan Calendar',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Day $ramadanDay of 30 • Tap to view',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.gold, size: 22),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Hadith Card
// ────────────────────────────────────────────────────────────────────────────
class _HadithCard extends StatelessWidget {
  const _HadithCard();

  static const _quotes = [
    {
      'arabic': 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
      'translation': 'Actions are judged by intentions.',
      'source': 'Bukhari & Muslim',
    },
    {
      'arabic': 'مَنْ صَامَ رَمَضَانَ إِيمَانًا وَاحْتِسَابًا',
      'translation':
          'Whoever fasts Ramadan out of faith and hope for reward, his past sins are forgiven.',
      'source': 'Bukhari',
    },
    {
      'arabic': 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
      'translation':
          'The best of you are those who learn the Quran and teach it.',
      'source': 'Bukhari',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final q = _quotes[DateTime.now().day % _quotes.length];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface, // Solid deep surface
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_quote_rounded,
                  color: AppTheme.gold, size: 20),
              const SizedBox(width: 8),
              Text(
                'Hadith of the Day',
                style: GoogleFonts.poppins(
                  color: AppTheme.gold,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              q['arabic']!,
              textAlign: TextAlign.right,
              style: GoogleFonts.amiri(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '"${q['translation']!}"',
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary,
              fontSize: 12.5,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '— ${q['source']!}',
            style: GoogleFonts.poppins(
              color: AppTheme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
