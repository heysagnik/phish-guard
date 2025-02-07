import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phisguard/Onboarding/onboarding_screen3.dart';

class OnboardingPageTwo extends StatelessWidget {
  const OnboardingPageTwo({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF352AD6), // Background color
      body: Stack(
        children: [
          /// Title above the image
          Positioned(
            top: screenHeight * 0.15,
            left: screenWidth * 0.1,
            right: screenWidth * 0.1,
            child: Text(
              "Next-Gen Security\nfor a Safer Future",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          /// Image with Top Border Radius and White Stroke
          Positioned(
            bottom: screenHeight * 0.0001, // Adjusted to fit above bottom nav
            left: (screenWidth - 270) / 2, // Centering the image horizontally
            child: Container(
              width: 270,
              height: 490,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                border: Border(
                  top: const BorderSide(
                    color: Colors.white, // White stroke on top
                    width: 5, // Stroke width
                  ),
                  left: const BorderSide(
                    color: Colors.white, // White stroke on left
                    width: 5, // Stroke width
                  ),
                  right: const BorderSide(
                    color: Colors.white, // White stroke on right
                    width: 5, // Stroke width
                  ),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                child: Image.asset(
                  'assets/home_screen.png', // Replace with your image path
                  fit: BoxFit.cover, // Ensures the image covers the given dimensions
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: screenHeight * 0.15,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            color: const Color(0xFFC8C4FD), // Keeping the original background color
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: screenWidth * 0.28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Container(
                      margin: EdgeInsets.only(right: screenWidth * 0.01),
                      width: screenWidth * 0.015,
                      height: screenWidth * 0.015,
                      decoration: BoxDecoration(
                        color: index == 1 ? const Color(0xFF352AD6) : Colors.black12,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
                SizedBox(
                  width: screenWidth * 0.35,
                  height: screenHeight * 0.055,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OnboardingPageThree()),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(const Color(0xFF2A35FF)),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                      ),
                      elevation: WidgetStateProperty.all(8),
                      overlayColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(MaterialState.pressed)
                            ? Colors.white.withOpacity(0.1)
                            : null,
                      ),
                    ),
                    child: Text(
                      "Let's go",
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.04,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}