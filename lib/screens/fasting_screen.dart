import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/fasting_provider.dart';

class FastingScreen extends StatelessWidget {
  const FastingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Fasting Tracker')),
      body: Consumer<FastingProvider>(
        builder: (context, prov, _) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Fasting Status Card
                  _FastingStatusCard(provider: prov),
                  const SizedBox(height: 30),
                  // Suhoor & Iftar Checkboxes
                  _MealChecklist(provider: prov),
                  const SizedBox(height: 30),
                  // Days Fasted Stats
                  _FastingStats(provider: prov),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FastingStatusCard extends StatelessWidget {
  final FastingProvider provider;
  const _FastingStatusCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isFasting = provider.isFasting;
    return GestureDetector(
      onTap: provider.toggleFasting,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isFasting
                ? [const Color(0xFF4A1A6B), const Color(0xFF6A2A9B)]
                : [AppTheme.surface, AppTheme.surfaceLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isFasting ? const Color(0xFF8A4AB5) : AppTheme.cardBorder,
            width: 2,
          ),
          boxShadow: [
            if (isFasting)
              BoxShadow(
                color: const Color(0xFF6A2A9B).withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              isFasting ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              size: 60,
              color: isFasting ? AppTheme.gold : AppTheme.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              isFasting ? 'I am Fasting Today' : 'Not Fasting Today',
              style: TextStyle(
                color: isFasting ? Colors.white : AppTheme.textSecondary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFasting
                  ? 'May Allah accept your fast'
                  : 'Tap to mark as fasting',
              style: TextStyle(
                color: isFasting ? AppTheme.goldLight : AppTheme.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealChecklist extends StatelessWidget {
  final FastingProvider provider;
  const _MealChecklist({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MealTile(
          title: 'Had Suhoor?',
          subtitle: 'The blessed pre-dawn meal',
          isChecked: provider.hadSuhoor,
          onToggle: provider.toggleSuhoor,
          icon: Icons.wb_twilight_rounded,
        ),
        const SizedBox(height: 16),
        _MealTile(
          title: 'Had Iftar?',
          subtitle: 'Breaking the fast at sunset',
          isChecked: provider.hadIftar,
          onToggle: provider.toggleIftar,
          icon: Icons.nights_stay_rounded,
        ),
      ],
    );
  }
}

class _MealTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isChecked;
  final VoidCallback onToggle;
  final IconData icon;

  const _MealTile({
    required this.title,
    required this.subtitle,
    required this.isChecked,
    required this.onToggle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isChecked
              ? AppTheme.primary.withValues(alpha: 0.15)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isChecked ? AppTheme.primary : AppTheme.cardBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isChecked
                    ? AppTheme.primary.withValues(alpha: 0.2)
                    : AppTheme.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isChecked ? AppTheme.gold : AppTheme.textMuted,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isChecked ? AppTheme.textPrimary : AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: isChecked,
              onChanged: (_) => onToggle(),
              activeColor: AppTheme.primary,
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FastingStats extends StatelessWidget {
  final FastingProvider provider;
  const _FastingStats({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          const Text(
            'Ramadan Progress',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${provider.daysFasted}',
                style: const TextStyle(
                  color: AppTheme.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
              ),
              const Text(
                '/30',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Days Fasted',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: provider.fastingProgress,
              minHeight: 8,
              backgroundColor: AppTheme.surfaceLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.gold),
            ),
          ),
        ],
      ),
    );
  }
}
