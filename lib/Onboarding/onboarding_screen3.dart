import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phisguard/home_screen.dart';

class OnboardingPageThree extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF47C3DC), // Background color
      bottomNavigationBar: Container(
        height: 160, // Increased height to accommodate the button below the dots
        color: Color(0xFFCDF7FF), // Bottom navigation bar color
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
                    color: index == 2 ? Color(0xFF47C3DC) : Colors.black26, // Highlight active page (index 2 here)
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            const SizedBox(height: 15), // Space between dots and the button
            // Next button with custom background color and border radius
            TextButton(
              onPressed: () {
                // Define the next action when onboarding is complete
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Color(0xFF2A35FF)), // Set background color
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23), // Set border radius
                )),
              ),
              child: Text(
                "Set as default",
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