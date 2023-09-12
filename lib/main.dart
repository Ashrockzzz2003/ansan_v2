import 'package:dynamic_color/dynamic_color.dart';
import 'package:eperimetry_vtwo/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final _defaultLightColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.greenAccent,
    brightness: Brightness.light,
  );

  static final _defaultDarkColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.greenAccent,
    brightness: Brightness.dark,
  );

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Survey App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightColorScheme ?? _defaultLightColorScheme,
          fontFamily: GoogleFonts.raleway().fontFamily,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
        ),
        themeMode: ThemeMode.system,
        home: const WelcomeScreen(),
      );
    });
  }
}
