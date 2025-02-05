import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import the lottie package
import 'package:phisguard/intro_screen.dart';
import 'package:phisguard/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    //final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
    final isFirstLaunch = true;
    // Wait for 3 seconds to show the splash screen
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              isFirstLaunch ? IntroPage() : const HomeScreen(),
        ),
      );
      if (isFirstLaunch) {
        await prefs.setBool('is_first_launch', false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a fully opaque background color (alpha 0xFF)
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7b74db),
              Color(0xFF9C27B0),
            ],
          ),
        ),
        child: Center(
          child: Lottie.asset(
            'assets/app_logo.json', // Ensure this asset path is correct and declared in pubspec.yaml.
            width: 150,
            height: 150,
          ),
        ),
      ),
    );
  }
}
