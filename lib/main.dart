import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_period/screens/home_screen.dart';
import 'package:my_period/screens/menstrual_cycle_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(const App()));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late SharedPreferences prefs;
  bool isSetUp = false;

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    final int? period = prefs.getInt('period');

    if (period != null) {
      setState(() {
        isSetUp = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

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
      home: isSetUp ? const HomeScreen() : const MenstrualCycle(),
    );
  }
}
