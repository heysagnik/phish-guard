import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:phisguard/url_safety_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _recentLinks = [];
  int _totalScans = 0;
  int _safeSites = 0;
  int _dangerousSites = 0;
  bool _isLoading = false;
  final TextEditingController _urlController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _loadScanData();
  }

  Future<void> _loadScanData() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        List<String> allLinks = prefs.getStringList('recentLinks') ?? [];
        _recentLinks = allLinks.length > 10 ? allLinks.sublist(0, 10) : allLinks;
        _totalScans = prefs.getInt('totalScans') ?? 0;
        _safeSites = prefs.getInt('safeSites') ?? 0;
        _dangerousSites = prefs.getInt('dangerousSites') ?? 0;
        _isLoading = false;
      });
    }
  }

  void _scanURL() {
    String url = _urlController.text.trim();

    if (url.isNotEmpty) {
      // Ensure the URL starts with HTTP/HTTPS
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url'; // Automatically add 'https://' if missing
      }

      // Navigate to URLSafetyScreen with the entered URL
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => URLSafetyScreen(url: url),
        ),
      );

      // Clear the input field after scanning
      _urlController.clear();
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss the keyboard
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF021028),
        body: RefreshIndicator(
          onRefresh: _loadScanData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight),
              child: Column(
                children: [
                  /// Top Section with Header and Shield Box
                  Container(
                    height: screenHeight * 0.5,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF055FFA),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 65),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Top Row with "PhishGuard" text and settings icon
                          Row(
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
                                icon: const Icon(Icons.settings, color: Colors.white, size: 24),
                                onPressed: () {
                                  print("Settings pressed");
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 27),

                          /// Box with Lottie animation, title, and description
                          Center(
                            child: Container(
                              width: 350,
                              height: 135,
                              decoration: BoxDecoration(
                                color: const Color(0xFF021028),
                                borderRadius: BorderRadius.circular(17),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Lottie.asset(
                                    'assets/shield_animation.json',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(width: 16),

                                  /// Title and Description
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "YOU ARE PROTECTED",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "All Shields are active",
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

                          const SizedBox(height: 30),

                          /// Search Bar Below Box Container
                          Center(
                            child: Container(
                              width: 350,
                              height: 47,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: TextField(
                                controller: _urlController,
                                keyboardType: TextInputType.url,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.arrow_forward, color: Colors.black),
                                    onPressed: _scanURL, // Scan when button is clicked
                                  ),
                                  hintText: "Enter link to scan for threats",
                                  hintStyle: GoogleFonts.poppins(color: Colors.black),
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (_) => _scanURL(), // Scan when user presses Enter
                              ),
                            ),
                          ),

                          /// Scan QR Box Below Search Bar
                          const SizedBox(height: 15),
                          Center(
                            child: Container(
                              width: 115,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.qr_code_scanner, color: Colors.black, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Scan QR",
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// Scan Statistics Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF4D4D4D), width: 2),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildStatBox("URL Scanned", _totalScans),
                          const SizedBox(height: 14),
                          _buildStatBox("Safe Sites", _safeSites, color: Colors.green),
                          const SizedBox(height: 14),
                          _buildStatBox("Dangerous Sites", _dangerousSites, color: Colors.red),
                        ],
                      ),
                    ),
                  ),

                  /// Recent Scans Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Recent Scanned URLs",
                          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        _recentLinks.isEmpty
                            ? Center(
                          child: Text("No recent scans yet.", style: GoogleFonts.poppins(color: Colors.white)),
                        )
                            : Column(
                          children: _recentLinks
                              .map(
                                (link) => Card(
                              color: Colors.white,
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                leading: const Icon(Icons.link, color: Color(0xFF055FFA)),
                                title: Text(
                                  link,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                              ),
                            ),
                          )
                              .toList(),
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
    );
  }

  /// Helper function to build statistics row
  Widget _buildStatBox(String label, int value, {Color color = Colors.blue}) {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
          Text(value.toString(), style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}