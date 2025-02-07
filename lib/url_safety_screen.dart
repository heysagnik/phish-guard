import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:phisguard/url_safety.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class URLSafetyScreen extends StatefulWidget {
  final String url;
  const URLSafetyScreen({super.key, required this.url});

  @override
  _URLSafetyScreenState createState() => _URLSafetyScreenState();
}

// Update _URLSafetyScreenState class to include URLSafetyResponse
class _URLSafetyScreenState extends State<URLSafetyScreen> {
  late Future<URLSafetyResponse> _safetyFuture;
  bool _isLoading = true;
  URLSafetyResponse? _response;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() {
    _safetyFuture = URLSafety.checkURL(widget.url);
    _safetyFuture.then((response) {
      setState(() {
        _response = response;
        _startAnimation();
        _saveScanResult(widget.url, !response.isMalicious);
      });
    });
  }

  /// Save scan results in SharedPreferences
  Future<void> _saveScanResult(String url, bool isSafe) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recentLinks = prefs.getStringList('recentLinks') ?? [];
    int totalScans = prefs.getInt('totalScans') ?? 0;
    int safeSites = prefs.getInt('safeSites') ?? 0;
    int dangerousSites = prefs.getInt('dangerousSites') ?? 0;

    if (!recentLinks.contains(url)) {
      recentLinks.insert(0, url);
      if (recentLinks.length > 10) {
        recentLinks.removeLast();
      }
    }

    totalScans += 1;
    if (isSafe) {
      safeSites += 1;
    } else {
      dangerousSites += 1;
    }

    await prefs.setStringList('recentLinks', recentLinks);
    await prefs.setInt('totalScans', totalScans);
    await prefs.setInt('safeSites', safeSites);
    await prefs.setInt('dangerousSites', dangerousSites);
  }

  /// Simulate scanning animation before showing results
  void _startAnimation() {
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        top: false,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: _isLoading
              ? _buildLoadingWidget()
              : FutureBuilder<URLSafetyResponse>(
                  future: _safetyFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _buildErrorWidget(snapshot.error.toString());
                    }
                    return _buildResultWidget();
                  },
                ),
        ),
      ),
    );
  }

  /// Loading animation while scanning
  Widget _buildLoadingWidget() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF055FFA),
            Color(0xFF0B41B3),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/scanning_url.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              animate: true,
            ),
            const SizedBox(height: 24),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                int dotCount = (value * 3).round();
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..scale(1 + 0.05 * value),
                  child: Text(
                    'Scanning URL${'.' * dotCount}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
              onEnd: () {
                // Trigger a rebuild to continuously repeat the animation.
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Error UI if scan fails
  Widget _buildErrorWidget(String error) {
    return Center(
      child: Card(
        color: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error scanning URL',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              _buildButton('Try Again', _startScan),
            ],
          ),
        ),
      ),
    );
  }

  /// Scan result UI
  Widget _buildResultWidget() {
    if (_response == null) return const SizedBox();

    final isSafe = !_response!.isMalicious &&
        !_response!.googleMalicious &&
        !_response!.isNewlyListed;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF5F7FF),
            Colors.white,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Rest of the widget remains the same
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => SystemNavigator.pop(),
                    ),
                  ],
                ),

                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isSafe ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSafe ? Icons.verified_user : Icons.warning,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isSafe ? 'URL is Safe' : 'Suspicious URL Detected!',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: isSafe ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      'Scan completed successfully',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildDetailRow('Domain', _response!.domain,
                            canCopy: true),
                        _buildDetailRow(
                            'Domain Age', '${_response!.domainAgeDays} days'),
                        _buildDetailRow('Category', _response!.siteCategory),
                        _buildDetailRow(
                          'Status',
                          isSafe ? 'Safe' : 'Unsafe',
                          isSuccess: isSafe,
                        ),
                        _buildDetailRow(
                          'Newly Listed',
                          _response!.isNewlyListed ? 'Yes' : 'No',
                          isWarning: _response!.isNewlyListed,
                        ),
                        _buildDetailRow(
                          'Malicious Content',
                          _response!.isMalicious ? 'Yes' : 'No',
                          isWarning: _response!.isMalicious,
                        ),
                        _buildDetailRow(
                          'Google Safe Browsing',
                          _response!.googleMalicious ? 'Unsafe' : 'Safe',
                          isSuccess: !_response!.googleMalicious,
                        ),
                        if (_response!.hasRedirects) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Redirects',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          ..._response!.redirects
                              .map((redirect) => _buildRedirectRow(redirect)),
                        ],
                      ],
                    ),
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        'Open in Browser',
                        Icons.travel_explore_outlined,
                        () => _launchUrl(
                          Uri.parse(widget.url),
                          context,
                        ),
                        backgroundColor: Color(0xFF055FFA),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool canCopy = false,
    bool isSuccess = false,
    bool isWarning = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: isSuccess
                      ? Colors.green
                      : (isWarning ? Colors.red : Colors.black),
                  fontWeight: (isSuccess || isWarning)
                      ? FontWeight.w600
                      : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              if (canCopy) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.copy, size: 16, color: Colors.grey[600]),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRedirectRow(String redirect) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              redirect,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    VoidCallback onPressed, {
    bool isOutlined = false,
    Color? backgroundColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isOutlined ? Colors.white : (backgroundColor ?? Colors.black),
        foregroundColor: isOutlined ? Colors.black : Colors.white,
        side: isOutlined ? BorderSide(color: Colors.grey[300]!) : null,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: isOutlined ? Colors.black : Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Function to launch URLs safely
  Future<void> _launchUrl(Uri uri, BuildContext context) async {
    try {
      // Try to open in Chrome on Android.
      if (Platform.isAndroid &&
          (uri.scheme == 'https' || uri.scheme == 'http')) {
        final chromeUrl = uri
            .toString()
            .replaceFirst(RegExp(r'^https?://'), 'googlechrome://');
        final chromeUri = Uri.parse(chromeUrl);

        if (await canLaunchUrl(chromeUri)) {
          await launchUrl(chromeUri, mode: LaunchMode.externalApplication);
          return; // Exit early if Chrome successfully launches.
        }
      }

      // Fallback to default browser or user choice.
      final bool launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        throw Exception('Could not launch $uri');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to open the URL. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget _buildButton(String text, VoidCallback onPressed,
      {Color? color, bool outlined = false}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              outlined ? Colors.transparent : (color ?? Colors.blue),
          foregroundColor: outlined ? Colors.white : null,
          side: outlined ? const BorderSide(color: Colors.white) : null,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
