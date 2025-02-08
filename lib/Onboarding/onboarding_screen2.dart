import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phisguard/Onboarding/onboarding_screen3.dart';

class OnboardingPageTwo extends StatelessWidget {
  const OnboardingPageTwo({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final isSmallScreen = width < 380;

    return Scaffold(
      backgroundColor: const Color(0xFF352AD6),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Title Section with reduced padding
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.08, // Reduced from 0.1
                      vertical: height * 0.015, // Reduced from 0.02
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Next-Gen Security\nfor a Safer Future",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 24 : 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),

                // Image Section with increased width
                Expanded(
                  flex: 6,
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: width * 0.08, // Reduced from 0.14
                    ),
                    width: min(width * 0.9, 350), // Increased from 0.7 and 270
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                      border: Border.all(
                        color: Colors.white,
                        width: width * 0.01, // Reduced from 0.015
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(25),
                      ),
                      child: Image.asset(
                        'assets/home_screen.png',
                        fit: BoxFit.cover, // Changed from fill
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      // Bottom Navigation with adjusted spacing
      bottomNavigationBar: Container(
        height: height * 0.11, // Reduced from 0.12
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04, // Reduced from 0.05
          vertical: height * 0.015, // Reduced from 0.02
        ),
        color: const Color(0xFFC8C4FD),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: width * 0.25), // Reduced from 0.28

            // Page Indicators with adjusted size
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  margin: EdgeInsets.only(
                      right: width * 0.008), // Reduced from 0.01
                  width: width * 0.018, // Reduced from 0.02
                  height: width * 0.018, // Reduced from 0.02
                  decoration: BoxDecoration(
                    color:
                        index == 1 ? const Color(0xFF352AD6) : Colors.black12,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            // Next Button with adjusted size
            SizedBox(
              width: width * 0.32, // Reduced from 0.35
              height: height * 0.05, // Reduced from 0.055
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OnboardingPageThree(),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A35FF),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23),
                  ),
                ),
                child: Text(
                  "Let's go",
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
