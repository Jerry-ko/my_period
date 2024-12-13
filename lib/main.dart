import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_period/screens/menstrual_cycle_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(const App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ko'),
      ],
      locale: const Locale('ko'),
      theme: ThemeData(
          primaryColor: const Color(0xFF99C2C2),
          secondaryHeaderColor: const Color(0xFF222B2B),
          fontFamily: GoogleFonts.gowunDodum().fontFamily),
      home: const MenstrualCycle(),
    );
  }
}
