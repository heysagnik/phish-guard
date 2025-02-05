import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phisguard/Onboarding/onboarding_screen3.dart';

class OnboardingPageTwo extends StatelessWidget {
  const OnboardingPageTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF352AD6), // Background color
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = MediaQuery.of(context).size.width;
          double screenHeight = MediaQuery.of(context).size.height;
          return Container(
            height: screenHeight * 0.15,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            color: Color(0xFFC8C4FD), // Keeping the original background color
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: screenWidth * 0.28,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Container(
                      margin: EdgeInsets.only(right: screenWidth * 0.01),
                      width: screenWidth * 0.015,
                      height: screenWidth * 0.015,
                      decoration: BoxDecoration(
                        color: index == 1 ? Color(0xFF352AD6) : Colors.black12,
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
                        MaterialPageRoute(
                            builder: (context) => OnboardingPageThree()),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        const Color(0xFF2A35FF),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23),
                        ),
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
