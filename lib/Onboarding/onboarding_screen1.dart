// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'onboarding_screen2.dart';

class OnboardingPageOne extends StatelessWidget {
  final List<Map<String, String>> boxContent = const [
    {
      'title': 'Real-time URL Scanning',
      'description': 'Instantly check if links are safe',
      'image': 'assets/icon1.png',
    },
    {
      'title': 'Phishing Protection',
      'description': 'Block phishing before harm',
      'image': 'assets/icon2.png',
    },
    {
      'title': 'Safe Browsing Experience',
      'description': 'Browse safely with link checks',
      'image': 'assets/icon3.png',
    },
    {
      'title': 'One-Click URL Launch',
      'description': 'Open safe URLs in your browser',
      'image': 'assets/icon4.png',
    },
  ];

  const OnboardingPageOne({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF536A),
              Color(0xFFFF758C),
              Color(0xFFFF8FA3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.1),
              // Title Text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Text(
                  "Security at your\nfingertips",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.16),
              // Boxes
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                child: Column(
                  children: List.generate(4, (index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: screenHeight * 0.01),
                      padding: EdgeInsets.all(screenWidth * 0.03),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD1D1),
                        borderRadius: BorderRadius.only(
                          topLeft: index == 0
                              ? const Radius.circular(17)
                              : Radius.zero,
                          topRight: index == 0
                              ? const Radius.circular(17)
                              : Radius.zero,
                          bottomLeft: index == 3
                              ? const Radius.circular(17)
                              : Radius.zero,
                          bottomRight: index == 3
                              ? const Radius.circular(17)
                              : Radius.zero,
                        ),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            boxContent[index]['image']!,
                            width: screenWidth * 0.1,
                            height: screenWidth * 0.1,
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  boxContent[index]['title']!,
                                  style: GoogleFonts.poppins(
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.005),
                                Text(
                                  boxContent[index]['description']!,
                                  style: GoogleFonts.poppins(
                                    fontSize: screenWidth * 0.035,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: screenHeight * 0.15,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFD1D1),
              const Color(0xFFFFE4E4),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: screenWidth * 0.28, // Match the width of the button
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
                    color:
                        index == 0 ? const Color(0xFFFF536A) : Colors.black12,
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
                        builder: (context) => OnboardingPageTwo()),
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
      ),
    );
  }
}
