import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phisguard/Onboarding/onboarding_screen3.dart';

class OnboardingPageTwo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF352AD6), // Background color
      bottomNavigationBar: Container(
        height: 160, // Increased height to accommodate the button below the dots
        color: Color(0xFFC8C4FD), // Bottom navigation bar color
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Row for the dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  width: 10, // Size of the circles
                  height: 10,
                  decoration: BoxDecoration(
                    color: index == 1 ? Color(0xFF352AD6) : Colors.black26, // Highlight active page (index 1 here)
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            const SizedBox(height: 15), // Space between dots and the button
            // Next button with custom background color and border radius
            TextButton(
              onPressed: () {
                // Navigate to next page (replace with actual next page)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OnboardingPageThree()),
                );
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Color(0xFF2A35FF)), // Set background color
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23), // Set border radius
                )),
              ),
              child: Text(
                "Let's go",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}