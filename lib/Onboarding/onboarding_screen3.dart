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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF47C3DC),
      body: Stack(
        children: [
          Positioned(
            top: screenHeight * 0.15,
            left: screenWidth * 0.1,
            right: screenWidth * 0.1,
            child: Text(
              "Set Our App as the Default Browser",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          /// Image with Top Border Radius and White Stroke (Copied from OnboardingPageTwo)
          Positioned(
            bottom: screenHeight * 0.0001,
            left: (screenWidth - 270) / 2,
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
                    color: Colors.white,
                    width: 5,
                  ),
                  left: const BorderSide(
                    color: Colors.white,
                    width: 5,
                  ),
                  right: const BorderSide(
                    color: Colors.white,
                    width: 5,
                  ),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                child: Image.asset(
                  'assets/setup.gif',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: screenHeight * 0.15,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        color: const Color(0xFFCDF7FF),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {},
              child: Text(
                "Privacy",
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.04,
                  color: Colors.black,
                ),
              ),
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
                    color: index == 2 ? const Color(0xFF47C3DC) : Colors.black12,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            SizedBox(
              width: screenWidth * 0.35,
              height: screenHeight * 0.055,
              child: TextButton(
                onPressed: () => _showDefaultBrowserDialog(context),
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
                  "Set as default",
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