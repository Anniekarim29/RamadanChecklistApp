import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DhikrProvider extends ChangeNotifier {
  int _subhanallahCount = 0;
  int _alhamdulillahCount = 0;
  int _allahuakbarCount = 0;
  int _customCount = 0;
  int _customTarget = 100;
  int _selectedIndex = 0; // 0=SubhanAllah, 1=Alhamdulillah, 2=AllahuAkbar, 3=Custom

  static const List<String> dhikrNames = [
    'SubhanAllah', 'Alhamdulillah', 'AllahuAkbar', 'Custom'
  ];
  static const List<int> dhikrTargets = [33, 33, 34, 100];
  static const List<String> dhikrArabic = [
    'سُبْحَانَ اللَّهِ', 'الْحَمْدُ لِلَّهِ', 'اللَّهُ أَكْبَرُ', 'ذِكْر'
  ];

  int get subhanallahCount => _subhanallahCount;
  int get alhamdulillahCount => _alhamdulillahCount;
  int get allahuakbarCount => _allahuakbarCount;
  int get customCount => _customCount;
  int get selectedIndex => _selectedIndex;
  int get customTarget => _customTarget;

  int get currentCount {
    switch (_selectedIndex) {
      case 0: return _subhanallahCount;
      case 1: return _alhamdulillahCount;
      case 2: return _allahuakbarCount;
      case 3: return _customCount;
      default: return 0;
    }
  }

  int get currentTarget {
    if (_selectedIndex == 3) return _customTarget;
    return dhikrTargets[_selectedIndex];
  }

  bool get isComplete => currentCount >= currentTarget;

  DhikrProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final lastDate = prefs.getString('dhikr_date') ?? '';

    if (lastDate != today) {
      await prefs.setString('dhikr_date', today);
      await prefs.setInt('dhikr_subhanallah', 0);
      await prefs.setInt('dhikr_alhamdulillah', 0);
      await prefs.setInt('dhikr_allahuakbar', 0);
      await prefs.setInt('dhikr_custom', 0);
    } else {
      _subhanallahCount = prefs.getInt('dhikr_subhanallah') ?? 0;
      _alhamdulillahCount = prefs.getInt('dhikr_alhamdulillah') ?? 0;
      _allahuakbarCount = prefs.getInt('dhikr_allahuakbar') ?? 0;
      _customCount = prefs.getInt('dhikr_custom') ?? 0;
      _customTarget = prefs.getInt('dhikr_custom_target') ?? 100;
    }
    notifyListeners();
  }

  void selectDhikr(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> increment() async {
    HapticFeedback.lightImpact();
    switch (_selectedIndex) {
      case 0: _subhanallahCount++; break;
      case 1: _alhamdulillahCount++; break;
      case 2: _allahuakbarCount++; break;
      case 3: _customCount++; break;
    }
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> resetCurrent() async {
    switch (_selectedIndex) {
      case 0: _subhanallahCount = 0; break;
      case 1: _alhamdulillahCount = 0; break;
      case 2: _allahuakbarCount = 0; break;
      case 3: _customCount = 0; break;
    }
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dhikr_subhanallah', _subhanallahCount);
    await prefs.setInt('dhikr_alhamdulillah', _alhamdulillahCount);
    await prefs.setInt('dhikr_allahuakbar', _allahuakbarCount);
    await prefs.setInt('dhikr_custom', _customCount);
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
