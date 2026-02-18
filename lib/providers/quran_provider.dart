import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranProvider extends ChangeNotifier {
  int _totalPagesRead = 0;
  int _todayPagesRead = 0;
  int _currentJuz = 1;
  String _lastResetDate = '';

  static const int totalQuranPages = 604;
  static const int totalJuz = 30;

  int get totalPagesRead => _totalPagesRead;
  int get todayPagesRead => _todayPagesRead;
  int get currentJuz => _currentJuz;
  double get overallProgress => _totalPagesRead / totalQuranPages;
  double get juzProgress => (_currentJuz - 1) / totalJuz;

  QuranProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    _lastResetDate = prefs.getString('quran_reset_date') ?? '';

    _totalPagesRead = prefs.getInt('quran_total_pages') ?? 0;
    _currentJuz = prefs.getInt('quran_current_juz') ?? 1;

    if (_lastResetDate != today) {
      _todayPagesRead = 0;
      await prefs.setString('quran_reset_date', today);
      await prefs.setInt('quran_today_pages', 0);
    } else {
      _todayPagesRead = prefs.getInt('quran_today_pages') ?? 0;
    }
    notifyListeners();
  }

  Future<void> addPages(int pages) async {
    if (pages <= 0) return;
    _todayPagesRead += pages;
    _totalPagesRead = (_totalPagesRead + pages).clamp(0, totalQuranPages);
    _currentJuz = ((_totalPagesRead / totalQuranPages) * totalJuz).ceil().clamp(1, totalJuz);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quran_today_pages', _todayPagesRead);
    await prefs.setInt('quran_total_pages', _totalPagesRead);
    await prefs.setInt('quran_current_juz', _currentJuz);
  }

  Future<void> setJuz(int juz) async {
    _currentJuz = juz.clamp(1, totalJuz);
    _totalPagesRead = ((_currentJuz - 1) / totalJuz * totalQuranPages).round();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quran_current_juz', _currentJuz);
    await prefs.setInt('quran_total_pages', _totalPagesRead);
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
