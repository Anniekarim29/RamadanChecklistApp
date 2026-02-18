import 'package:flutter/material.dart';
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _greetingController;
  late Animation<double> _greetingFade;

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
    _greetingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _greetingFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _greetingController, curve: Curves.easeIn),
    );
    _greetingController.forward();
  }

  @override
  void dispose() {
    _greetingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.cardBorder, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.mosque_rounded), label: 'Prayers'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Quran'),
            BottomNavigationBarItem(icon: Icon(Icons.nightlight_round), label: 'Fasting'),
            BottomNavigationBarItem(icon: Icon(Icons.radio_button_checked_rounded), label: 'Dhikr'),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  int _getRamadanDay() {
    // Approximate Ramadan 2025 start: March 1
    final ramadanStart = DateTime(2025, 3, 1);
    final today = DateTime.now();
    final diff = today.difference(ramadanStart).inDays + 1;
    return diff.clamp(1, 30);
  }

  @override
  Widget build(BuildContext context) {
    final prayerProv = context.watch<PrayerProvider>();
    final quranProv = context.watch<QuranProvider>();
    final fastingProv = context.watch<FastingProvider>();
    final dhikrProv = context.watch<DhikrProvider>();

    final today = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(today);
    final ramadanDay = _getRamadanDay();

    // Overall progress
    final prayerScore = prayerProv.prayerProgress;
    final quranScore = quranProv.overallProgress;
    final fastingScore = fastingProv.fastingProgress;
    final dhikrScore = (dhikrProv.subhanallahCount / 33 +
            dhikrProv.alhamdulillahCount / 33 +
            dhikrProv.allahuakbarCount / 34) /
        3;
    final overallProgress =
        (prayerScore + quranScore.clamp(0, 1) + fastingScore + dhikrScore.clamp(0, 1)) / 4;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 180,
          pinned: true,
          backgroundColor: AppTheme.background,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D2818), AppTheme.background],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'رَمَضَان كَرِيم',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: AppTheme.gold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dateStr,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.primary),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Day $ramadanDay',
                                  style: const TextStyle(
                                    color: AppTheme.gold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Text(
                                  'of Ramadan',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall Progress
                _OverallProgressCard(progress: overallProgress),
                const SizedBox(height: 20),
                const Text(
                  'Today\'s Tracker',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                // Feature Cards Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    _FeatureCard(
                      title: 'Prayers',
                      subtitle:
                          '${prayerProv.completedPrayers}/${prayerProv.totalPrayers} done',
                      icon: Icons.mosque_rounded,
                      progress: prayerScore,
                      color: const Color(0xFF1B6B3A),
                      onTap: () => _navigateTo(context, 1),
                    ),
                    _FeatureCard(
                      title: 'Quran',
                      subtitle: '${quranProv.todayPagesRead} pages today',
                      icon: Icons.menu_book_rounded,
                      progress: quranProv.overallProgress.clamp(0, 1),
                      color: const Color(0xFF1A3A6B),
                      onTap: () => _navigateTo(context, 2),
                    ),
                    _FeatureCard(
                      title: 'Fasting',
                      subtitle:
                          '${fastingProv.daysFasted}/30 days',
                      icon: Icons.nightlight_round,
                      progress: fastingProv.fastingProgress,
                      color: const Color(0xFF4A1A6B),
                      onTap: () => _navigateTo(context, 3),
                    ),
                    _FeatureCard(
                      title: 'Dhikr',
                      subtitle:
                          '${dhikrProv.subhanallahCount + dhikrProv.alhamdulillahCount + dhikrProv.allahuakbarCount} total',
                      icon: Icons.radio_button_checked_rounded,
                      progress: dhikrScore.clamp(0, 1),
                      color: const Color(0xFF6B3A1A),
                      onTap: () => _navigateTo(context, 4),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Calendar shortcut
                _CalendarShortcut(ramadanDay: ramadanDay),
                const SizedBox(height: 20),
                // Motivational quote
                _MotivationalCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _navigateTo(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_HomeScreenState>();
    state?.setState(() => state._currentIndex = index);
  }
}

class _OverallProgressCard extends StatelessWidget {
  final double progress;
  const _OverallProgressCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D2818), Color(0xFF1B4332)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: AppTheme.surfaceLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.gold),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: AppTheme.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Progress',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  progress >= 1.0
                      ? '🎉 All tasks complete! Masha\'Allah!'
                      : progress >= 0.5
                          ? '💪 Keep going, you\'re doing great!'
                          : 'Start your worship for today',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
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

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final double progress;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.progress,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder),
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
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppTheme.gold, size: 22),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    color: progress >= 1.0 ? AppTheme.success : AppTheme.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0 ? AppTheme.success : AppTheme.gold,
                ),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarShortcut extends StatelessWidget {
  final int ramadanDay;
  const _CalendarShortcut({required this.ramadanDay});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CalendarScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.calendar_month_rounded,
                  color: AppTheme.gold, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ramadan Calendar',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Day $ramadanDay of 30 • Tap to view full calendar',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

class _MotivationalCard extends StatelessWidget {
  final List<Map<String, String>> _quotes = const [
    {
      'arabic': 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
      'translation': 'Actions are judged by intentions.',
      'source': 'Bukhari & Muslim'
    },
    {
      'arabic': 'مَنْ صَامَ رَمَضَانَ إِيمَانًا وَاحْتِسَابًا',
      'translation': 'Whoever fasts Ramadan out of faith and hope for reward...',
      'source': 'Bukhari'
    },
    {
      'arabic': 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
      'translation': 'The best of you are those who learn the Quran and teach it.',
      'source': 'Bukhari'
    },
  ];

  const _MotivationalCard();

  @override
  Widget build(BuildContext context) {
    final quote = _quotes[DateTime.now().day % _quotes.length];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.gold.withValues(alpha: 0.1),
            AppTheme.gold.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_quote_rounded,
                  color: AppTheme.gold, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Hadith of the Day',
                style: TextStyle(
                  color: AppTheme.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            quote['arabic']!,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 8),
          Text(
            '"${quote['translation']!}"',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '— ${quote['source']!}',
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
