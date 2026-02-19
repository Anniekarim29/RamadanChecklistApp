import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/prayer_provider.dart';
import 'providers/quran_provider.dart';
import 'providers/fasting_provider.dart';
import 'providers/dhikr_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RamadanApp());
}

class RamadanApp extends StatelessWidget {
  const RamadanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
        ChangeNotifierProvider(create: (_) => QuranProvider()),
        ChangeNotifierProvider(create: (_) => FastingProvider()),
        ChangeNotifierProvider(create: (_) => DhikrProvider()),
      ],
      child: MaterialApp(
        title: 'Ramadan Checklist',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
