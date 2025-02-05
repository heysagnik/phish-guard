import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'onboarding_screen2.dart';

class OnboardingPageOne extends StatelessWidget {
  final List<Map<String, String>> boxContent = [
    {
      'title': 'Real-time URL Scanning',
      'description': 'Instantly check if links are safe',
      'image': 'assets/icon1.png', // Add your image asset path here
    },
    {
      'title': 'Phishing Protection',
      'description': 'Block phishing before harm',
      'image': 'assets/icon2.png', // Add your image asset path here
    },
    {
      'title': 'Safe Browsing Experience',
      'description': 'Browse safely with link checks',
      'image': 'assets/icon3.png', // Add your image asset path here
    },
    {
      'title': 'One-Click URL Launch',
      'description': 'Open safe URLs in your browser easily',
      'image': 'assets/icon4.png', // Add your image asset path here
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFFFF536A), // Set background color
        child: Stack(
          children: [
            // Text with white color, font size 30, font weight bold, and black stroke
            Positioned(
              top: 132,
              left: 20,
              right: 20,
              child: Text(
                "Security at your\nfingertips",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            // Column of 4 rectangle boxes with title, description, and image
            Positioned(
              top: 280, // Adjust to place the rectangles below the text
              left: 40,
              right: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(4, (index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10), // Space between boxes
                    height: 70, // Increased height to accommodate title and description
                    decoration: BoxDecoration(
                      color: Color(0xFFFFD1D1), // Box color
                      borderRadius: BorderRadius.only(
                        topLeft: index == 0 ? Radius.circular(17) : Radius.zero,
                        topRight: index == 0 ? Radius.circular(17) : Radius.zero,
                        bottomLeft: index == 3 ? Radius.circular(17) : Radius.zero,
                        bottomRight: index == 3 ? Radius.circular(17) : Radius.zero,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10), // Padding inside the box
                      child: Row(
                        children: [
                          // Image at the start of each box
                          Image.asset(
                            boxContent[index]['image']!,
                            width: 40, // Adjust image size
                            height: 40,
                          ),
                          const SizedBox(width: 10), // Space between image and text
                          // Column for title and description
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                boxContent[index]['title']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                boxContent[index]['description']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 160, // Increased height to accommodate the button below the dots
        color: Color(0xFFFFD1D1), // Set bottom nav bar color
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
                    color: index == 0 ? Color(0xFFFF536A) : Colors.black26, // Highlight active page (index 0 here)
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            const SizedBox(height: 15), // Space between dots and the button
            // Next button with custom background color and border radius
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OnboardingPageTwo()),
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