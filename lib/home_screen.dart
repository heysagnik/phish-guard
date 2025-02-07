// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:phisguard/url_safety_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phisguard/Onboarding/onboarding_screen3.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:platform/platform.dart';

class DefaultBrowserChecker {
  static const platform =
      MethodChannel('com.phisguard.phisguard/default_browser');

  static Future<bool> isDefaultBrowser() async {
    try {
      final bool isDefault = await platform.invokeMethod('isDefaultBrowser');
      return isDefault;
    } catch (e) {
      debugPrint('Error checking default browser: $e');
      return false;
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class PatternPainter extends CustomPainter {
  final Color color;

  PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 5; i++) {
      canvas.drawLine(
        Offset(size.width - (i * 20), size.height),
        Offset(size.width, size.height - (i * 20)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<String> _recentLinks = [];
  int _totalScans = 0;
  int _safeSites = 0;
  int _dangerousSites = 0;
  final TextEditingController _urlController = TextEditingController();

  // Scroll and animation properties
  final ScrollController _scrollController = ScrollController();
  double _headerHeight = 0.47;
  bool _isCollapsed = false;
  late AnimationController _animationController;

  // Add these properties to the state class
  double _previousOffset = 0;
  bool _isScrollingUp = false;
  bool _isProtected = false;

  @override
  void initState() {
    super.initState();
    _loadScanData();
    _checkDefaultBrowserStatus();
    _scrollController.addListener(_onScroll);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Replace the existing _onScroll method with this version
  void _onScroll() {
    // Determine scroll direction
    _isScrollingUp = _scrollController.offset < _previousOffset;

    if (_scrollController.offset > 100 && !_isCollapsed && !_isScrollingUp) {
      setState(() {
        _isCollapsed = true;
        _headerHeight = 0.15; // Collapsed height
      });
      _animationController.forward();
    } else if (_isScrollingUp && _isCollapsed) {
      setState(() {
        _isCollapsed = false;
        _headerHeight = 0.47; // Expanded height
      });
      _animationController.reverse();
    }

    _previousOffset = _scrollController.offset;
  }

  Future<void> _loadScanData() async {
    setState(() {});

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        List<String> allLinks = prefs.getStringList('recentLinks') ?? [];
        _recentLinks =
            allLinks.length > 10 ? allLinks.sublist(0, 10) : allLinks;
        _totalScans = prefs.getInt('totalScans') ?? 0;
        _safeSites = prefs.getInt('safeSites') ?? 0;
        _dangerousSites = prefs.getInt('dangerousSites') ?? 0;
      });
    }
  }

  Future<void> _checkDefaultBrowserStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isDefault = prefs.getBool('isDefaultBrowser') ?? false;

    // If not already marked as default in preferences, perform a platform-specific check.
    if (!isDefault) {
      if (LocalPlatform().isAndroid) {
        try {
          // Use DefaultBrowserChecker to check if our app is set as the default browser.
          isDefault = await DefaultBrowserChecker.isDefaultBrowser();
        } catch (e) {
          debugPrint('Default browser check failed: $e');
        }
      } else {
        // On other platforms, implement your own logic if needed.
        isDefault = false;
      }
    }

    setState(() {
      _isProtected = isDefault;
    });
  }

  void _handleProtectionCardTap() async {
    if (!_isProtected) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const OnboardingPageThree(),
        ),
      );
    }
  }

  void _scanURL() {
    String url = _urlController.text.trim();

    if (url.isNotEmpty) {
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => URLSafetyScreen(url: url),
        ),
      );

      _urlController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF021028),
        body: Stack(
          children: [
            // Animated Header
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: screenHeight * _headerHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xFF1A7BFF), Color(0xFF055FFA)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(_isCollapsed ? 35 : 45),
                ),
              ),
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(horizontal: 16)
                    .copyWith(top: _isCollapsed ? 40 : 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Settings - Only visible when expanded
                    if (!_isCollapsed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "PhishGuard",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings,
                                  color: Colors.white, size: 24),
                              onPressed: () {
                                debugPrint("Settings pressed");
                              },
                            ),
                          ],
                        ),
                      ),
                    // Protection Status Box - Only visible when expanded
                    if (!_isCollapsed) _buildProtectionStatusBox(),
                    // Search Bar - Always visible
                    Padding(
                      padding: EdgeInsets.only(top: _isCollapsed ? 0 : 20),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: 350,
                          height: 47,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              if (_urlController.text.isNotEmpty ||
                                  FocusScope.of(context).hasFocus)
                                BoxShadow(
                                  color: const Color(0xFF055FFA),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                            ],
                          ),
                          child: Focus(
                            onFocusChange: (hasFocus) {
                              setState(() {});
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _urlController,
                                    keyboardType: TextInputType.url,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 14, horizontal: 16),
                                      prefixIcon: const Icon(Icons.search,
                                          color: Colors.black),
                                      hintText: "Type a URL to scan...",
                                      hintStyle: GoogleFonts.poppins(
                                          color: Colors.black54),
                                      border: InputBorder.none,
                                    ),
                                    onSubmitted: (_) => _scanURL(),
                                  ),
                                ),
                                Container(
                                  height: 47,
                                  decoration: const BoxDecoration(),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            Icons.photo_camera_outlined,
                                            color: Colors.black),
                                        onPressed: () {
                                          debugPrint("QR Scan pressed");
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.arrow_forward,
                                            color: Colors.black),
                                        onPressed: _scanURL,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Scrollable Content with pull-to-refresh
            Padding(
              padding: EdgeInsets.only(top: screenHeight * _headerHeight),
              child: RefreshIndicator(
                color: const Color(0xFF055FFA),
                backgroundColor: Colors.white,
                onRefresh: _loadScanData,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Add a small invisible container to ensure pull-to-refresh works even when content is short
                      SizedBox(
                          height:
                              1), // This ensures refresh works when content is short
                      // Scan Statistics Section
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                            child: Stack(
                              children: [
                                _buildStatBox(
                                  "URL Scanned",
                                  _totalScans,
                                  color: const Color(0xFF055FFA),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: CustomPaint(
                                    size: const Size(200, 200),
                                    painter: PatternPainter(
                                        color: const Color(0xFF055FFA)
                                            .withOpacity(0.1)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildStatBox(
                                    "Safe Sites",
                                    _safeSites,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStatBox(
                                    "Malicious Sites",
                                    _dangerousSites,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Recent Scans Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Recent Scanned URLs",
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.history_outlined,
                                      color: Colors.white),
                                  onPressed: _loadScanData,
                                ),
                              ],
                            ),
                            _recentLinks.isEmpty
                                ? Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        children: [
                                          Icon(Icons.history_rounded,
                                              size: 48,
                                              color: Colors.white
                                                  .withOpacity(0.5)),
                                          const SizedBox(height: 16),
                                          Text(
                                            "No recent scans yet",
                                            style: GoogleFonts.poppins(
                                              color:
                                                  Colors.white.withOpacity(0.7),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _recentLinks.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF055FFA)
                                                  .withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          leading: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF055FFA)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.link_rounded,
                                              color: Color(0xFF055FFA),
                                            ),
                                          ),
                                          title: Text(
                                            _recentLinks[index],
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          trailing: const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 16,
                                            color: Color(0xFF055FFA),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper function to build statistics box
  Widget _buildStatBox(String label, int value, {Color color = Colors.blue}) {
    return Container(
      height: 146,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIconForLabel(label),
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case "URL Scanned":
        return Icons.link_rounded;
      case "Safe Sites":
        return Icons.verified_rounded;
      case "Malicious Sites":
        return Icons.gpp_bad_rounded;
      default:
        return Icons.analytics_rounded;
    }
  }

  Widget _buildProtectionStatusBox() {
    return GestureDetector(
      onTap: _handleProtectionCardTap,
      child: Center(
        child: Container(
          width: 350,
          height: 150,
          decoration: BoxDecoration(
            color: const Color(0xFF021028),
            borderRadius: BorderRadius.circular(17),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(
                _isProtected
                    ? 'assets/shield_animation.json'
                    : 'assets/warning-animation.json', // Add this animation
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isProtected ? "YOU ARE PROTECTED" : "YOU ARE AT RISK",
                      style: GoogleFonts.poppins(
                        color: _isProtected ? Colors.white : Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isProtected
                          ? "All Shields are active"
                          : "Tap to set as default browser",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
