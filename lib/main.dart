import 'package:flutter/material.dart';
import 'package:sound_studio/screens/difficulty_screen.dart';
import 'package:sound_studio/screens/login_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sound_studio/screens/math_quiz_screen.dart';
import 'package:sound_studio/screens/study_result_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
      ],
      home: ResultsScreen(phases: [
        Phase(duration: 120, hasNoise: false)
          ..totalProblemsAttempted = 29
          ..correctAnswers = 26
          ..aiAnalysisResults =
              List.filled(112, '집중함') + List.filled(8, '집중하지 않음'),
        Phase(
            duration: 120,
            hasNoise: true,
            audioAsset: "assets/audio/pink_noise.mp3")
          ..totalProblemsAttempted = 32
          ..correctAnswers = 31
          ..aiAnalysisResults =
              List.filled(117, '집중함') + List.filled(3, '집중하지 않음'),
        Phase(
            duration: 120,
            hasNoise: true,
            audioAsset: "assets/audio/white_noise.mp3")
          ..totalProblemsAttempted = 28
          ..correctAnswers = 26
          ..aiAnalysisResults =
              List.filled(110, '집중함') + List.filled(10, '집중하지 않음'),
        Phase(
            duration: 120,
            hasNoise: true,
            audioAsset: "assets/audio/green_noise.mp3")
          ..totalProblemsAttempted = 30
          ..correctAnswers = 28
          ..aiAnalysisResults =
              List.filled(114, '집중함') + List.filled(6, '집중하지 않음'),
      ]),
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        hintColor: Colors.amber,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          color: Colors.blue,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.grey[800], fontSize: 14),
          displayLarge: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
    );
  }
}
