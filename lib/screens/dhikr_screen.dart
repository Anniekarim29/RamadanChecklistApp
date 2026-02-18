import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/dhikr_provider.dart';

class DhikrScreen extends StatelessWidget {
  const DhikrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Dhikr Counter')),
      body: Consumer<DhikrProvider>(
        builder: (context, prov, _) {
          return Column(
            children: [
              // Dhikr Selector
              _DhikrSelector(provider: prov),
              
              const Spacer(),
              
              // Arabic Text
              Text(
                DhikrProvider.dhikrArabic[prov.selectedIndex],
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 32,
                  color: AppTheme.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // English Name
              Text(
                DhikrProvider.dhikrNames[prov.selectedIndex],
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 18,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Counter Button
              _CounterButton(provider: prov),
              
              const SizedBox(height: 40),
              
              // Reset Button
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppTheme.surface,
                      title: const Text('Reset Counter?', style: TextStyle(color: AppTheme.textPrimary)),
                      content: const Text('Are you sure you want to reset the current count?', style: TextStyle(color: AppTheme.textSecondary)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
                        ),
                        TextButton(
                          onPressed: () {
                            prov.resetCurrent();
                            Navigator.pop(ctx);
                          },
                          child: const Text('Reset', style: TextStyle(color: AppTheme.error)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.refresh_rounded, color: AppTheme.textMuted),
                label: const Text('Reset', style: TextStyle(color: AppTheme.textMuted)),
              ),
              
              const Spacer(),
            ],
          );
        },
      ),
    );
  }
}

class _DhikrSelector extends StatelessWidget {
  final DhikrProvider provider;
  const _DhikrSelector({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: DhikrProvider.dhikrNames.length,
        itemBuilder: (context, index) {
          final isSelected = provider.selectedIndex == index;
          return GestureDetector(
            onTap: () => provider.selectDhikr(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.gold : AppTheme.surface,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? AppTheme.gold : AppTheme.cardBorder,
                ),
              ),
              child: Text(
                DhikrProvider.dhikrNames[index],
                style: TextStyle(
                  color: isSelected ? AppTheme.background : AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final DhikrProvider provider;
  const _CounterButton({required this.provider});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: provider.increment,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.surface,
          border: Border.all(color: AppTheme.primary, width: 4),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: CircularProgressIndicator(
                value: provider.currentCount / provider.currentTarget,
                strokeWidth: 8,
                backgroundColor: AppTheme.surfaceLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.gold),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${provider.currentCount}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '/${provider.currentTarget}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
