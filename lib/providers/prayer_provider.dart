import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerProvider extends ChangeNotifier {
  static const List<String> prayerNames = [
    'Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha', 'Tarawih', 'Tahajjud'
  ];

  static const List<String> sunnahPrayers = [
    'Fajr Sunnah', 'Dhuhr Sunnah', 'Asr Sunnah', 'Maghrib Sunnah', 'Isha Sunnah'
  ];

  final Map<String, bool> _prayerStatus = {};
  final Map<String, bool> _sunnahStatus = {};
  String _lastResetDate = '';

  Map<String, bool> get prayerStatus => _prayerStatus;
  Map<String, bool> get sunnahStatus => _sunnahStatus;

  int get completedPrayers =>
      _prayerStatus.values.where((v) => v).length;

  int get totalPrayers => prayerNames.length;

  double get prayerProgress =>
      totalPrayers == 0 ? 0 : completedPrayers / totalPrayers;

  PrayerProvider() {
    _initPrayers();
    _loadFromPrefs();
  }

  void _initPrayers() {
    for (var p in prayerNames) {
      _prayerStatus[p] = false;
    }
    for (var s in sunnahPrayers) {
      _sunnahStatus[s] = false;
    }
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();

    // Reset if new day
    _lastResetDate = prefs.getString('prayer_reset_date') ?? '';
    if (_lastResetDate != today) {
      await _resetForNewDay(prefs, today);
      return;
    }

    for (var p in prayerNames) {
      _prayerStatus[p] = prefs.getBool('prayer_${today}_$p') ?? false;
    }
    for (var s in sunnahPrayers) {
      _sunnahStatus[s] = prefs.getBool('sunnah_${today}_$s') ?? false;
    }
    notifyListeners();
  }

  Future<void> _resetForNewDay(SharedPreferences prefs, String today) async {
    _initPrayers();
    await prefs.setString('prayer_reset_date', today);
    notifyListeners();
  }

  Future<void> togglePrayer(String prayer) async {
    _prayerStatus[prayer] = !(_prayerStatus[prayer] ?? false);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prayer_${_todayKey()}_$prayer', _prayerStatus[prayer]!);
  }

  Future<void> toggleSunnah(String sunnah) async {
    _sunnahStatus[sunnah] = !(_sunnahStatus[sunnah] ?? false);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sunnah_${_todayKey()}_$sunnah', _sunnahStatus[sunnah]!);
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
