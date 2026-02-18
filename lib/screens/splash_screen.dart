import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _moonController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _moonRotation;
  late Animation<double> _fadeIn;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _moonController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _moonRotation = Tween<double>(begin: -0.3, end: 0.0).animate(
      CurvedAnimation(parent: _moonController, curve: Curves.elasticOut),
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _moonController.forward();
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _moonController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([_moonController, _scaleController]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _scale.value,
                  child: Transform.rotate(
                    angle: _moonRotation.value,
                    child: _buildLogo(),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            FadeTransition(
              opacity: _fadeIn,
              child: Column(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppTheme.gold, AppTheme.goldLight, AppTheme.gold],
                    ).createShader(bounds),
                    child: const Text(
                      'Ramadan',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const Text(
                    'CHECKLIST',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      color: AppTheme.textSecondary,
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'رَمَضَان كَرِيم',
                    style: TextStyle(
                      fontSize: 22,
                      color: AppTheme.gold,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
            FadeTransition(
              opacity: _fadeIn,
              child: const CircularProgressIndicator(
                color: AppTheme.gold,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 140,
      height: 140,
      child: CustomPaint(
        painter: _CrescentPainter(),
      ),
    );
  }
}

class _CrescentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Glow effect
    final glowPaint = Paint()
      ..color = AppTheme.gold.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, radius + 10, glowPaint);

    // Crescent moon
    final moonPaint = Paint()
      ..color = AppTheme.gold
      ..style = PaintingStyle.fill;

    final path = Path();
    // Outer circle
    path.addOval(Rect.fromCircle(center: center, radius: radius * 0.75));

    // Inner circle (cutout) - offset to create crescent
    final innerPath = Path();
    innerPath.addOval(Rect.fromCircle(
      center: Offset(center.dx + radius * 0.25, center.dy - radius * 0.1),
      radius: radius * 0.62,
    ));

    final crescent = Path.combine(PathOperation.difference, path, innerPath);
    canvas.drawPath(crescent, moonPaint);

    // Star
    final starPaint = Paint()
      ..color = AppTheme.gold
      ..style = PaintingStyle.fill;

    _drawStar(
      canvas,
      Offset(center.dx + radius * 0.55, center.dy - radius * 0.45),
      radius * 0.12,
      starPaint,
    );
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    const points = 5;
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : radius * 0.4;
      final angle = (i * math.pi / points) - math.pi / 2;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
