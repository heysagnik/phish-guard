import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import the flutter_svg package
import 'package:google_fonts/google_fonts.dart';
import 'package:phisguard/Onboarding/onboarding_screen1.dart';
import 'Onboarding/onboarding_screen.dart'; // Import the OnboardingScreen

class IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Container
          Container(
            width: double.infinity,
            height: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.21, -0.98),
                end: Alignment(0.21, 0.98),
                colors: [Color(0xFF5D05F4), Color(0xFF36038E)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo at the top
                SvgPicture.asset(
                  'assets/app_logo.svg', // Replace with your SVG file path
                  height: 150,
                ),
                const SizedBox(height: 50), // Space between logo and text

                // Text with Stroke Effect
                Text(
                  'Guard your clicks,\nprotect your device.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2), // Stroke effect
                        blurRadius: 2,
                        color: Colors.black,  // Stroke color
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Positioned "Let's go" text in the bottom trailing corner
          Positioned(
            bottom: 30, // Adjust bottom position
            right: 30, // Adjust right position
            child: GestureDetector(
              onTap: () {
                // Navigate to OnboardingScreen when clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OnboardingPageOne()),
                );
              },
              child: Text(
                "Let's go",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}