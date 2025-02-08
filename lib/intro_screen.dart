import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phisguard/Onboarding/onboarding_screen1.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isSmallScreen = width < 380;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: const [
                      Color(0xFF352AD6), // Match app theme
                      Color(0xFF2A35FF),
                      Color(0xFF1A7BFF),
                      Color(0xFF055FFA),
                      Color(0xFF47C3DC),
                    ],
                    stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                    transform: GradientRotation(_animation.value * 0.1),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo with animation
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0.8, end: 1.0),
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeOutBack,
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: SvgPicture.asset(
                          'assets/app_logo.svg',
                          height: height * 0.2,
                        ),
                      ),

                      SizedBox(height: height * 0.06),

                      // Tagline with improved typography
                      Text(
                        'Guard your clicks,\nprotect your device.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 28 : 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.3),
                            ),
                            Shadow(
                              offset: const Offset(-1, -1),
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const OnboardingPageOne()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
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
          ),
        ],
      ),
    );
  }
}
