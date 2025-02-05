import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phisguard/url_safety.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class URLSafetyScreen extends StatefulWidget {
  final String url;
  const URLSafetyScreen({super.key, required this.url});

  @override
  _URLSafetyScreenState createState() => _URLSafetyScreenState();
}

class _URLSafetyScreenState extends State<URLSafetyScreen>
    with SingleTickerProviderStateMixin {
  late Future<bool> _safetyFuture;
  bool _isSafe = true;
  bool _isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _safetyFuture = URLSafety.isURLSafe(widget.url);
    _safetyFuture.then((value) {
      setState(() {
        _isSafe = value;
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RotationTransition(
                          turns: _animationController,
                          child: Icon(
                            Icons.security,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 24),
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
                  )
                : FutureBuilder<bool>(
                    future: _safetyFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return _buildErrorWidget(snapshot.error.toString());
                      }

                      _isSafe = snapshot.data ?? true;
                      return _buildResultWidget();
                    },
                  ),
          ),
        ),
      ),
    );
  }

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
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Error scanning URL',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
              SizedBox(height: 24),
              _buildButton('Try Again', () => _initializeData()),
            ],
          ),
        ),
      ),
    );
  }

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
              SizedBox(height: 24),
              Text(
                _isSafe ? 'URL is Safe' : 'Suspicious URL Detected!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _isSafe ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
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
              SizedBox(height: 24),
              if (_isSafe)
                _buildButton(
                  'Open in Chrome',
                  () => _launchUrl(Uri.parse(chromeUrl), context),
                  color: Colors.green,
                ),
              SizedBox(height: 12),
              _buildButton(
                'Go Back',
                () => Navigator.of(context).pop(),
                outlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed,
      {bool outlined = false, Color? color}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          backgroundColor:
              outlined ? Colors.white : (color ?? Color(0xFF2A35FF)),
          foregroundColor: outlined ? Color(0xFF2A35FF) : Colors.white,
          elevation: outlined ? 0 : 4,
          side: outlined ? BorderSide(color: Color(0xFF2A35FF)) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
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

  void _initializeData() {
    setState(() {
      _isLoading = true;
      _safetyFuture = URLSafety.isURLSafe(widget.url);
      _safetyFuture.then((value) {
        setState(() {
          _isSafe = value;
          _isLoading = false;
        });
      });
    });
  }

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
