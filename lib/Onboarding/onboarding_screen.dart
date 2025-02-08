import 'package:flutter/material.dart';
import 'onboarding_screen1.dart';
import 'onboarding_screen2.dart';
import 'onboarding_screen3.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  bool _isSwipingLocked = false;

  final List<Widget> _onboardingPages = const [
    OnboardingPageOne(),
    OnboardingPageTwo(),
    OnboardingPageThree(),
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_pageListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_pageListener);
    _controller.dispose();
    super.dispose();
  }

  void _pageListener() {
    if (_controller.page?.round() != _currentPage) {
      setState(() {
        _currentPage = _controller.page!.round();
      });
    }
  }

  void _nextPage() {
    if (!_isSwipingLocked && _currentPage < _onboardingPages.length - 1) {
      _isSwipingLocked = true;
      _controller
          .nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          )
          .then((_) => _isSwipingLocked = false);
    }
  }

  void _previousPage() {
    if (!_isSwipingLocked && _currentPage > 0) {
      _isSwipingLocked = true;
      _controller
          .previousPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          )
          .then((_) => _isSwipingLocked = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Page View
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0 &&
                  details.primaryVelocity!.abs() > 300) {
                _previousPage();
              } else if (details.primaryVelocity! < 0 &&
                  details.primaryVelocity!.abs() > 300) {
                _nextPage();
              }
            },
            child: PageView(
              controller: _controller,
              physics: const ClampingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: _onboardingPages,
            ),
          ),

          // Swipe Indicators
          if (_currentPage < _onboardingPages.length - 1)
            Positioned(
              right: 16,
              top: size.height / 2,
              child: _buildSwipeIndicator(
                Icons.keyboard_arrow_right_rounded,
                "Swipe left",
              ),
            ),
          if (_currentPage > 0)
            Positioned(
              left: 16,
              top: size.height / 2,
              child: _buildSwipeIndicator(
                Icons.keyboard_arrow_left_rounded,
                "Swipe right",
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSwipeIndicator(IconData icon, String tooltip) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Tooltip(
        message: tooltip,
        child: Icon(
          icon,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
