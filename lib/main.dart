import 'package:flutter/material.dart';
import 'package:my_period/screens/menstrual_cycle_screen.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MenstrualCycle(),
    );
  }
}
