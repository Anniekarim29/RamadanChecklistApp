import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../providers/prayer_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Future<Map<int, double>> _dailyProgressFuture;

  @override
  void initState() {
    super.initState();
    _dailyProgressFuture = _loadDailyProgress();
  }

  Future<Map<int, double>> _loadDailyProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<int, double> progressMap = {};
    
    // Using a predefined start date for Ramadan 2025 (March 1)
    final ramadanStart = DateTime(2025, 3, 1);
    
    for (int i = 0; i < 30; i++) {
      final date = ramadanStart.add(Duration(days: i));
      final dateKey = '${date.year}-${date.month}-${date.day}';
      
      // Calculate daily score from saved prefs if available
      // Note: This is an approximation since we don't store historical daily progress explicitly
      // In a real app, we would store a daily summary record.
      // Here we check if data exists for that day.
      
      bool hasData = prefs.containsKey('prayer_${dateKey}_Fajr') || 
                     prefs.containsKey('fasting_${dateKey}_today');
      
      if (hasData) {
        // Calculate a rough score based on what we can find
        int prayersDone = 0;
        for (var p in PrayerProvider.prayerNames) {
          if (prefs.getBool('prayer_${dateKey}_$p') ?? false) prayersDone++;
        }
        
        bool fasted = prefs.getBool('fasting_${dateKey}_today') ?? false;
        
        // Simple scoring: 70% prayers, 30% fasting
        double score = (prayersDone / 7.0 * 0.7) + (fasted ? 0.3 : 0.0);
        progressMap[i + 1] = score;
      } else {
        // Future days or no data
        progressMap[i + 1] = -1.0; 
      }
    }
    return progressMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Ramadan Calendar')),
      body: FutureBuilder<Map<int, double>>(
        future: _dailyProgressFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.gold));
          }
          
          final data = snapshot.data!;
          // Current day
          final ramadanStart = DateTime(2025, 3, 1);
          final today = DateTime.now();
          final diff = today.difference(ramadanStart).inDays + 1;
          final currentDay = diff.clamp(1, 30);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: 30,
              itemBuilder: (context, index) {
                final day = index + 1;
                final score = data[day] ?? -1.0;
                final isToday = day == currentDay;
                final isFuture = day > currentDay;
                
                Color bg;
                if (isFuture) {
                  bg = AppTheme.surface;
                } else if (score >= 0.8) {
                  bg = AppTheme.primary;
                } else if (score >= 0.4) {
                  bg = AppTheme.gold.withValues(alpha: 0.6);
                } else if (score >= 0) {
                  bg = Colors.orange.withValues(alpha: 0.6);
                } else {
                  bg = AppTheme.surfaceLight; // Past day with no data
                }
                
                if (isToday) {
                  bg = AppTheme.gold;
                }

                return Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(12),
                    border: isToday 
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                    boxShadow: isToday 
                        ? [BoxShadow(color: AppTheme.gold.withValues(alpha: 0.5), blurRadius: 12)]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Day',
                        style: TextStyle(
                          color: isToday ? AppTheme.background : AppTheme.textMuted,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        '$day',
                        style: TextStyle(
                          color: isToday ? AppTheme.background : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      if (!isFuture && !isToday && score >= 0)
                        Icon(
                          score >= 0.8 ? Icons.star_rounded : Icons.star_half_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
