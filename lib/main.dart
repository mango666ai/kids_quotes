import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('zh');
  runApp(const KidsQuotesApp());
}

const _primaryOrange = Color(0xFFFF8C42);
const _inputFill = Color(0xFFF1F2F6);
const _inputFillDark = Color(0xFF2A2D38);

ThemeData _buildTheme(Brightness brightness) {
  final isLight = brightness == Brightness.light;
  final cs = ColorScheme.fromSeed(
    seedColor: _primaryOrange,
    brightness: brightness,
  ).copyWith(
    surfaceContainerLowest:
        isLight ? const Color(0xFFFFF8F4) : const Color(0xFF111318),
    surface: isLight ? Colors.white : const Color(0xFF1C1F28),
    surfaceContainerHighest: isLight ? _inputFill : _inputFillDark,
  );

  return ThemeData(
    colorScheme: cs,
    useMaterial3: true,
    scaffoldBackgroundColor: isLight ? const Color(0xFFFFF8F4) : const Color(0xFF111318),
    cardTheme: CardTheme(
      elevation: 0,
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outline.withOpacity(0.25), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outline.withOpacity(0.2)),
      ),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: isLight ? const Color(0xFFFFF8F4) : const Color(0xFF111318),
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: cs.onSurface,
      ),
      iconTheme: IconThemeData(color: cs.onSurface),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: cs.surfaceContainerHighest,
      labelStyle: const TextStyle(fontSize: 13),
    ),
  );
}

class KidsQuotesApp extends StatelessWidget {
  const KidsQuotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '童言童语',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('zh', 'CN')],
      home: const HomeScreen(),
    );
  }
}
