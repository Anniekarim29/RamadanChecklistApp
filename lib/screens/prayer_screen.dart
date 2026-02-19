import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/prayer_provider.dart';

class PrayerScreen extends StatelessWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Prayer Tracker'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Consumer<PrayerProvider>(
              builder: (_, prov, __) => Center(
                child: Text(
                  '${prov.completedPrayers}/${prov.totalPrayers}',
                  style: const TextStyle(
                    color: AppTheme.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<PrayerProvider>(
        builder: (context, prov, _) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Progress header
                      _PrayerProgressHeader(provider: prov),
                      const SizedBox(height: 24),
                      // Fard Prayers
                      _SectionHeader(
                        title: 'Fard Prayers',
                        subtitle: 'الصَّلَوَاتُ الْمَفْرُوضَة',
                      ),
                      const SizedBox(height: 12),
                      ...PrayerProvider.prayerNames
                          .where((p) => !['Tarawih', 'Tahajjud'].contains(p))
                          .map((prayer) => _PrayerTile(
                                prayer: prayer,
                                isChecked: prov.prayerStatus[prayer] ?? false,
                                onToggle: () => prov.togglePrayer(prayer),
                                icon: _getPrayerIcon(prayer),
                                time: _getPrayerTime(prayer),
                              )),
                      const SizedBox(height: 20),
                      // Night Prayers
                      _SectionHeader(
                        title: 'Night Prayers',
                        subtitle: 'صَلَاةُ اللَّيْل',
                      ),
                      const SizedBox(height: 12),
                      _PrayerTile(
                        prayer: 'Tarawih',
                        isChecked: prov.prayerStatus['Tarawih'] ?? false,
                        onToggle: () => prov.togglePrayer('Tarawih'),
                        icon: Icons.nights_stay_rounded,
                        time: 'After Isha',
                      ),
                      _PrayerTile(
                        prayer: 'Tahajjud',
                        isChecked: prov.prayerStatus['Tahajjud'] ?? false,
                        onToggle: () => prov.togglePrayer('Tahajjud'),
                        icon: Icons.star_rounded,
                        time: 'Last third of night',
                      ),
                      const SizedBox(height: 20),
                      // Sunnah Prayers
                      _SectionHeader(
                        title: 'Sunnah Prayers',
                        subtitle: 'السُّنَن الرَّوَاتِب',
                      ),
                      const SizedBox(height: 12),
                      ...PrayerProvider.sunnahPrayers.map((s) => _SunnahTile(
                            sunnah: s,
                            isChecked: prov.sunnahStatus[s] ?? false,
                            onToggle: () => prov.toggleSunnah(s),
                          )),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _getPrayerIcon(String prayer) {
    switch (prayer) {
      case 'Fajr': return Icons.wb_twilight_rounded;
      case 'Dhuhr': return Icons.wb_sunny_rounded;
      case 'Asr': return Icons.wb_cloudy_rounded;
      case 'Maghrib': return Icons.wb_sunny_rounded;
      case 'Isha': return Icons.nightlight_round;
      default: return Icons.circle_rounded;
    }
  }

  String _getPrayerTime(String prayer) {
    switch (prayer) {
      case 'Fajr': return 'Before sunrise';
      case 'Dhuhr': return 'Midday';
      case 'Asr': return 'Afternoon';
      case 'Maghrib': return 'After sunset';
      case 'Isha': return 'Night';
      default: return '';
    }
  }
}

class _PrayerProgressHeader extends StatelessWidget {
  final PrayerProvider provider;
  const _PrayerProgressHeader({required this.provider});

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
            width: 70,
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: provider.prayerProgress,
                  strokeWidth: 7,
                  backgroundColor: AppTheme.surfaceLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.gold),
                ),
                Text(
                  '${provider.completedPrayers}',
                  style: const TextStyle(
                    color: AppTheme.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Today\'s Prayers',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${provider.completedPrayers} of ${provider.totalPrayers} completed',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                provider.completedPrayers == provider.totalPrayers
                    ? '✅ All prayers done! Alhamdulillah!'
                    : '${provider.totalPrayers - provider.completedPrayers} prayers remaining',
                style: TextStyle(
                  color: provider.completedPrayers == provider.totalPrayers
                      ? AppTheme.success
                      : AppTheme.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PrayerTile extends StatelessWidget {
  final String prayer;
  final bool isChecked;
  final VoidCallback onToggle;
  final IconData icon;
  final String time;

  const _PrayerTile({
    required this.prayer,
    required this.isChecked,
    required this.onToggle,
    required this.icon,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isChecked
            ? AppTheme.primary.withValues(alpha: 0.2)
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isChecked ? AppTheme.primary : AppTheme.cardBorder,
          width: isChecked ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isChecked
                ? AppTheme.primary.withValues(alpha: 0.3)
                : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isChecked ? AppTheme.gold : AppTheme.textMuted,
            size: 22,
          ),
        ),
        title: Text(
          prayer,
          style: TextStyle(
            color: isChecked ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          time,
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
        ),
        trailing: GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isChecked ? AppTheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isChecked ? AppTheme.primary : AppTheme.textMuted,
                width: 2,
              ),
            ),
            child: isChecked
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 18)
                : null,
          ),
        ),
        onTap: onToggle,
      ),
    );
  }
}

class _SunnahTile extends StatelessWidget {
  final String sunnah;
  final bool isChecked;
  final VoidCallback onToggle;

  const _SunnahTile({
    required this.sunnah,
    required this.isChecked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isChecked
            ? AppTheme.gold.withValues(alpha: 0.1)
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isChecked ? AppTheme.gold.withValues(alpha: 0.4) : AppTheme.cardBorder,
        ),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          Icons.auto_awesome_rounded,
          color: isChecked ? AppTheme.gold : AppTheme.textMuted,
          size: 18,
        ),
        title: Text(
          sunnah,
          style: TextStyle(
            color: isChecked ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        trailing: Checkbox(
          value: isChecked,
          onChanged: (_) => onToggle(),
          activeColor: AppTheme.gold,
          checkColor: AppTheme.background,
        ),
        onTap: onToggle,
      ),
    );
  }
}
