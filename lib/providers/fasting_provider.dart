import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FastingProvider extends ChangeNotifier {
  bool _isFasting = false;
  bool _hadSuhoor = false;
  bool _hadIftar = false;
  int _daysFasted = 0;
  String _lastDate = '';

  bool get isFasting => _isFasting;
  bool get hadSuhoor => _hadSuhoor;
  bool get hadIftar => _hadIftar;
  int get daysFasted => _daysFasted;
  int get totalRamadanDays => 30;
  double get fastingProgress => _daysFasted / totalRamadanDays;

  FastingProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    _lastDate = prefs.getString('fasting_last_date') ?? '';
    _daysFasted = prefs.getInt('fasting_days_count') ?? 0;

    if (_lastDate != today) {
      // New day: carry over fasting count if yesterday was fasting
      _isFasting = false;
      _hadSuhoor = false;
      _hadIftar = false;
      await prefs.setString('fasting_last_date', today);
      await prefs.setBool('fasting_today', false);
      await prefs.setBool('fasting_suhoor', false);
      await prefs.setBool('fasting_iftar', false);
    } else {
      _isFasting = prefs.getBool('fasting_today') ?? false;
      _hadSuhoor = prefs.getBool('fasting_suhoor') ?? false;
      _hadIftar = prefs.getBool('fasting_iftar') ?? false;
    }
    notifyListeners();
  }

  Future<void> toggleFasting() async {
    _isFasting = !_isFasting;
    if (_isFasting) {
      _daysFasted++;
    } else {
      if (_daysFasted > 0) _daysFasted--;
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fasting_today', _isFasting);
    await prefs.setInt('fasting_days_count', _daysFasted);
  }

  Future<void> toggleSuhoor() async {
    _hadSuhoor = !_hadSuhoor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fasting_suhoor', _hadSuhoor);
  }

  Future<void> toggleIftar() async {
    _hadIftar = !_hadIftar;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fasting_iftar', _hadIftar);
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
