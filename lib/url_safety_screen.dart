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

class _URLSafetyScreenState extends State<URLSafetyScreen> {
  late Future<bool> _safetyFuture;
  bool _isSafe = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  /// Start URL safety scan and update UI
  void _startScan() {
    _safetyFuture = URLSafety.isURLSafe(widget.url);
    _safetyFuture.then((value) {
      setState(() {
        _isSafe = value;
        _startAnimation();
        _saveScanResult(widget.url, value);
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2A35FF),
              Color(0xFF536DFE),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _isLoading
                ? _buildLoadingWidget()
                : FutureBuilder<bool>(
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
      ),
    );
  }

  /// Loading animation while scanning
  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/scanning_url.json',
            width: 150,
            height: 150,
            fit: BoxFit.contain,
            animate: true,
          ),
          const SizedBox(height: 24),
          Text(
            'Scanning URL...',
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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

    final chromeUrl =
        'googlechrome://navigate?url=${Uri.encodeFull(widget.url)}';
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
              Icon(
                _isSafe ? Icons.security : Icons.warning,
                size: 64,
                color: _isSafe ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                _isSafe ? 'URL is Safe' : 'Suspicious URL Detected!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _isSafe ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.url,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_isSafe)
                _buildButton(
                  'Open in Browser',
                      () => _launchUrl(Uri.parse(chromeUrl), context),
                  color: Colors.green,
                ),
              const SizedBox(height: 12),
              _buildButton(
                'Go Back',
                  () {
                  if(Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    SystemNavigator.pop();
                  }
                  },
                outlined: true
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Generic button widget
  Widget _buildButton(String text, VoidCallback onPressed,
      {bool outlined = false, Color? color}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: outlined ? Colors.white : (color ?? const Color(0xFF2A35FF)),
          foregroundColor: outlined ? const Color(0xFF2A35FF) : Colors.white,
          elevation: outlined ? 0 : 4,
          side: outlined ? const BorderSide(color: Color(0xFF2A35FF)) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
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
}