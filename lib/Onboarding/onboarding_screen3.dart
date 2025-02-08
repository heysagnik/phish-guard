import 'dart:math';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phisguard/home_screen.dart';
import 'package:platform/platform.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardingPageThree extends StatelessWidget {
  const OnboardingPageThree({super.key});

  /// Shows a dialog prompting the user to set PhishGuard as the default browser.
  Future<void> _showDefaultBrowserDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            'Set Default Browser',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Would you like to set PhishGuard as your default browser?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Later',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final localPlatform = LocalPlatform();
                if (localPlatform.isAndroid) {
                  try {
                    // Optionally request SYSTEM_ALERT_WINDOW permission.
                    var status = await Permission.systemAlertWindow.status;
                    if (!status.isGranted) {
                      await Permission.systemAlertWindow.request();
                    }

                    // Launch the system default apps settings so user can set PhishGuard as default.
                    const AndroidIntent intent = AndroidIntent(
                      action: 'android.settings.MANAGE_DEFAULT_APPS_SETTINGS',
                    );
                    await intent.launch();
                  } catch (e) {
                    debugPrint('Error launching default apps settings: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Could not open default apps settings. Please do it manually.',
                        ),
                      ),
                    );
                  }
                }
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
              child: Text(
                'Set as Default',
                style: GoogleFonts.poppins(
                  color: Color(0xFF47C3DC),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final isSmallScreen = width < 380;

    return Scaffold(
      backgroundColor: const Color(0xFF47C3DC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Title Section - Adjusted top padding
                Positioned(
                  top: height * 0.08, // Reduced from 0.1
                  left: width * 0.08, // Reduced from 0.1
                  right: width * 0.08, // Reduced from 0.1
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "Set Our App as the\nDefault Browser",
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

                // Image Section - Increased width and adjusted margins
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width:
                          min(width * 0.8, 350), // Increased from 0.8 and 270
                      height: height * 0.65, // Increased from 0.6
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
                          'assets/setup.gif',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      // Bottom Navigation - Adjusted height and padding
      bottomNavigationBar: Container(
        height: height * 0.12, // Reduced from 0.16
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04, // Reduced from 0.04
          vertical: height * 0.015, // Adjusted from 0.01
        ),
        color: const Color(0xFFCDF7FF),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Privacy Button
            TextButton(
              onPressed: () {},
              child: Text(
                "Privacy",
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: Colors.black,
                ),
              ),
            ),

            // Page Indicators - Adjusted size
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  margin: EdgeInsets.only(
                      right: width * 0.008), // Reduced from 0.01
                  width: width * 0.02, // Reduced from 0.02
                  height: width * 0.02, // Reduced from 0.02
                  decoration: BoxDecoration(
                    color:
                        index == 2 ? const Color(0xFF47C3DC) : Colors.black12,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            // Set as Default Button - Adjusted width
            SizedBox(
              width: width * 0.38, // Reduced from 0.40
              height: height * 0.05, // Reduced from 0.055
              child: ElevatedButton(
                onPressed: () => _showDefaultBrowserDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A35FF),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23),
                  ),
                ),
                child: Text(
                  "Set as default",
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 12 : 14,
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
