import 'package:flutter/material.dart';
import 'Onboarding/onboarding_screen1.dart';
import 'Onboarding/onboarding_screen2.dart';
import 'Onboarding/onboarding_screen3.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Widget> _onboardingPages = [
    OnboardingPageOne(),
    OnboardingPageTwo(),
    OnboardingPageThree(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _onboardingPages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return _onboardingPages[index]; // Only show the onboarding page
              },
            ),
          ),
          // You can add other elements specific to the individual onboarding page if needed
        ],
      ),
    );
  }
}