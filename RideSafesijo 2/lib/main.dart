import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ridesafe/screens/intro_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://hrttfgmuhfuzxaifdzcp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhydHRmZ211aGZ1enhhaWZkemNwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM1MDE1OTEsImV4cCI6MjA1OTA3NzU5MX0.y9Gf2yODtFxuQ4RlEazP53KQPnO8ZYR4h83lHkSIulg',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RideSafe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const IntroPage(), // Keep IntroPage as initial screen
      // You can use AuthGate after intro if needed:
      // home: const AuthGate(),
    );
  }
}