import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/home_screen.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calender App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade100),
        useMaterial3: true,

      ),



      home:
      // splash screen
      AnimatedSplashScreen(
          duration: 3000,
          splash: Icons.calendar_month_outlined, splashIconSize: 100,
          nextScreen: HomePage(),
          splashTransition: SplashTransition.fadeTransition,
          backgroundColor: Colors.blue.shade100),
          color: Colors.white,
    );
  }
}

