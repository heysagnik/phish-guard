import 'dart:ui';

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
      if (mounted) {
        setState(() {
          _response = response;
          _isLoading = false;
          _saveScanResult(widget.url, !response.isMalicious);
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: FutureBuilder<URLSafetyResponse>(
            future: _safetyFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingWidget();
              } else if (snapshot.hasError) {
                return _buildErrorWidget(snapshot.error.toString());
              } else if (snapshot.hasData) {
                return _buildResultWidget();
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/scanning_url.json',
              width: 180,
              height: 180,
            ),
            const SizedBox(height: 24),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                int dotCount = (value * 3).round();
                return Transform.scale(
                  scale: 1 + 0.05 * value,
                  child: Text(
                    'Scanning URL${'.' * dotCount}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                );
              },
              onEnd: () {
                setState(() {}); // trigger continuous animation
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Card(
        color: const Color(0xFF1E293B),
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                'Error scanning URL',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.grey[400]),
              ),
              const SizedBox(height: 24),
              _buildButton('Try Again', _startScan),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultWidget() {
    if (_response == null) return const SizedBox();

    final isSafe = _response!.summary.isReallySafe;
    debugPrint('URL: ${widget.url} is safe: $isSafe  Response: $_response');

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 20,
                  vertical: isSmallScreen ? 12 : 20,
                ),
                child: Column(
                  children: [
                    // Modern app bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => _handleBackNavigation(),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.thumbs_up_down_outlined,
                              color: Colors.white),
                          onPressed: () => _showReportDialog(context),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Header with icon, animated score and message
                    Column(
                      children: [
                        // Container(
                        //   width: isSmallScreen ? 60 : 80,
                        //   height: isSmallScreen ? 60 : 80,
                        //   decoration: BoxDecoration(
                        //     color: isSafe ? Colors.green : Colors.red,
                        //     shape: BoxShape.circle,
                        //     boxShadow: [
                        //       BoxShadow(
                        //         color: Colors.black.withOpacity(0.3),
                        //         spreadRadius: 2,
                        //         blurRadius: 8,
                        //       )
                        //     ],
                        //   ),
                        //   child: Icon(
                        //     isSafe ? Icons.verified_user : Icons.warning,
                        //     color: Colors.white,
                        //     size: isSmallScreen ? 30 : 40,
                        //   ),
                        // ),
                        // const SizedBox(height: 16),
                        // Animated circular progress displaying the risk score.
                        AnimatedRiskScore(
                          overallRiskScore: _response!.overallRiskScore,
                          isSafe: isSafe,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _response!.summary.message,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.w600,
                            color:
                                isSafe ? Colors.greenAccent : Colors.redAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Scan completed successfully',
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Main content scroll view
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GeminiContentAnimation(
                                text: _response!.geminiDetails ?? ''),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                                'Category', _response!.siteCategory),
                            if (_response!.hasRedirects) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Redirects',
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey[900],
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _response!.redirects.length,
                                  itemBuilder: (context, index) {
                                    final redirect =
                                        _response!.redirects[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: Text(
                                        redirect,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: isSafe
                              ? _buildActionButton(
                                  'Open in Browser',
                                  icon: Icons.travel_explore_outlined,
                                  onPressed: () => _launchUrl(
                                    Uri.parse(
                                        'googlechrome://navigate?url=${Uri.encodeFull(widget.url)}'),
                                    context,
                                  ),
                                  backgroundColor: const Color(0xFF1A7BFF),
                                )
                              : _buildActionButton(
                                  'Proceed anyway',
                                  icon: Icons.travel_explore_outlined,
                                  onPressed: () => _launchUrl(
                                    Uri.parse(
                                        'googlechrome://navigate?url=${Uri.encodeFull(widget.url)}'),
                                    context,
                                  ),
                                  backgroundColor: Colors.redAccent,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            'More Info',
                            icon: Icons.info_outline,
                            onPressed: () {
                              _showMoreInfoBottomSheet(context);
                            },
                            backgroundColor: Colors.grey[800]!,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showMoreInfoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isSmallScreen = MediaQuery.of(context).size.width < 600;
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1E293B),
                  Color(0xFF0F172A),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 24,
              vertical: 16,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 20),
                  Text(
                    'More Information',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Additional details about the URL\'s reputation and history',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[400],
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildDetailRow('Domain', _response!.domain,
                              canCopy: true),
                          _buildDetailRow(
                              'Domain Age Days', _response!.domainAgeDays),
                          _buildDetailRow('Is Newly Listed',
                              _response!.isNewlyListed.toString()),
                          _buildDetailRow('Google Safe Browsing',
                              (!_response!.googleMalicious).toString()),
                          if (_response!.safeBrowsingDetails != null)
                            _buildDetailRow('Safe Browsing Details',
                                _response!.safeBrowsingDetails!),
                          _buildDetailRow(
                              'Site Category', _response!.siteCategory),
                          if (_response!.geminiDetails != null)
                            _buildDetailRow(
                                'AI Safe', _response!.geminiSafe.toString()),
                          _buildDetailRow('Has Redirects',
                              _response!.hasRedirects.toString()),
                          if (_response!.contentAnalysisScore != null)
                            _buildDetailRow('Content Analysis Score',
                                _response!.contentAnalysisScore.toString()),
                          _buildDetailRow('Has Phishing Indicators',
                              _response!.hasPhishingIndicators.toString()),
                          _buildDetailRow('Overall Risk Score',
                              _response!.overallRiskScore.toString()),
                          _buildDetailRow(
                              'Threat Level', _response!.summary.threatLevel),
                          _buildDetailRow('Is Really Safe',
                              _response!.summary.isReallySafe.toString()),
                          SizedBox(height: isSmallScreen ? 10 : 16),
                          Text(
                            _response!.summary.message,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: _response!.summary.isReallySafe
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isSmallScreen ? 20 : 24),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'Close',
                          backgroundColor: const Color(0xFF1A7BFF),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool canCopy = false, bool isSuccess = false, bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: LayoutBuilder(builder: (context, constraints) {
        final double fontSize = constraints.maxWidth < 400 ? 14 : 16;
        return Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: fontSize,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Text(
                value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: isSuccess
                      ? Colors.greenAccent
                      : isWarning
                          ? Colors.orangeAccent
                          : Colors.white,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildActionButton(
    String text, {
    IconData? icon,
    required VoidCallback onPressed,
    bool isOutlined = false,
    Color? backgroundColor,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth < 350 ? 14 : 16;
    double iconSize = screenWidth < 350 ? 18 : 20;
    EdgeInsetsGeometry padding = screenWidth < 350
        ? const EdgeInsets.symmetric(vertical: 12)
        : const EdgeInsets.symmetric(vertical: 16);

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isOutlined ? Colors.white : backgroundColor ?? Colors.black,
        foregroundColor: isOutlined ? Colors.black : Colors.white,
        side: isOutlined ? BorderSide(color: Colors.grey[300]!) : null,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: iconSize,
                color: isOutlined ? Colors.black : Colors.white),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleBackNavigation() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      SystemNavigator.pop();
    }
  }

  Future<void> _launchUrl(Uri uri, BuildContext context) async {
    try {
      if ((Platform.isAndroid || Platform.isIOS) &&
          (uri.scheme == 'https' || uri.scheme == 'http')) {
        Uri? chromeUri;
        if (Platform.isAndroid) {
          final chromeUrl =
              'googlechrome://navigate?url=${Uri.encodeFull(uri.toString())}';
          chromeUri = Uri.parse(chromeUrl);
        } else if (Platform.isIOS) {
          final chromeUrl = uri.scheme == 'http'
              ? uri.toString().replaceFirst('http', 'googlechrome')
              : uri.toString().replaceFirst('https', 'googlechromes');
          chromeUri = Uri.parse(chromeUrl);
        }
        if (chromeUri != null && await canLaunchUrl(chromeUri)) {
          await launchUrl(chromeUri, mode: LaunchMode.externalApplication);
          return;
        }
      }

      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $uri');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
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
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    TextEditingController reportController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: const Color(0xFF1E293B),
          titlePadding: EdgeInsets.zero,
          title: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: const Text(
                  'Report URL',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter details for the report:',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reportController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Describe the issue',
                  hintStyle: const TextStyle(color: Colors.white70),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withAlpha(128)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withAlpha(128)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // TextButton(
                //   onPressed: () => Navigator.pop(context),
                //   style: TextButton.styleFrom(foregroundColor: Colors.white),
                //   child: const Text('Cancel'),
                // ),
                // const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final reportText = reportController.text;
                    String additionalDetails = '';
                    if (_response != null) {
                      additionalDetails = '''
      
URL: ${widget.url}
Domain: ${_response!.domain}
Domain Age Days: ${_response!.domainAgeDays}
Is Newly Listed: ${_response!.isNewlyListed}
Google Safe Browsing: ${!_response!.googleMalicious}
Safe Browsing Details: ${_response!.safeBrowsingDetails ?? 'N/A'}
Site Category: ${_response!.siteCategory}
Gemini Details: ${_response!.geminiDetails ?? 'N/A'}
AI Safe: ${_response!.geminiSafe}
Has Redirects: ${_response!.hasRedirects}
Content Analysis Score: ${_response!.contentAnalysisScore?.toString() ?? 'N/A'}
Has Phishing Indicators: ${_response!.hasPhishingIndicators}
Overall Risk Score: ${_response!.overallRiskScore}
Threat Level: ${_response!.summary.threatLevel}
Is Really Safe: ${_response!.summary.isReallySafe}
Message: ${_response!.summary.message}
''';
                    }
                    final emailBody = reportText + additionalDetails;
                    final emailUrl =
                        'mailto:io.sakshamgupta@gmail.com?subject=${Uri.encodeComponent("URL Report: ${widget.url}")}&body=${Uri.encodeComponent(emailBody)}';
                    final Uri emailLaunchUri = Uri.parse(emailUrl);

                    try {
                      if (await canLaunchUrl(emailLaunchUri)) {
                        await launchUrl(emailLaunchUri,
                            mode: LaunchMode.externalApplication);
                      } else {
                        throw 'Could not launch email client';
                      }
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to open email client: $e'),
                        ),
                      );
                    }

                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A7BFF),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Send'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class GeminiContentAnimation extends StatelessWidget {
  final String text;
  const GeminiContentAnimation({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          colors: [Colors.deepPurpleAccent, Colors.blue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds);
                      },
                      child: const Icon(
                        Icons.psychology_alt_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Think\u207A',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'contents may not be accurate',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontStyle: FontStyle.normal,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedRiskScore extends StatelessWidget {
  final int overallRiskScore;
  final bool isSafe;

  const AnimatedRiskScore({
    super.key,
    required this.overallRiskScore,
    required this.isSafe,
  });

  @override
  Widget build(BuildContext context) {
    final int score = 100 - overallRiskScore;
    final double progress = score / 100;
    final Color themeColor = isSafe ? Colors.green : Colors.redAccent;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: progress),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOutCubic,
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: themeColor.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
            // Rotating outer ring
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 2 * 3.14159),
              duration: const Duration(seconds: 3),
              curve: Curves.linear,
              builder: (context, rotation, child) {
                return Transform.rotate(
                  angle: rotation,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          themeColor.withOpacity(0.1),
                          themeColor.withOpacity(0.3),
                          themeColor.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            // Inner content
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    themeColor.withOpacity(0.15),
                    Colors.transparent,
                  ],
                  stops: const [0.7, 1.0],
                ),
              ),
            ),
            SizedBox(
              width: 110,
              height: 110,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Main progress indicator
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1500),
                    builder: (context, opacity, child) {
                      return CustomPaint(
                        painter: CircularProgressPainter(
                          progress: value,
                          color: themeColor.withOpacity(opacity),
                          backgroundColor: Colors.grey[850]!,
                          strokeWidth: 12,
                        ),
                      );
                    },
                  ),
                  Center(
                    child: Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.95),
                            Colors.white.withOpacity(0.85),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: themeColor.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: TweenAnimationBuilder<int>(
                          tween: IntTween(begin: 0, end: score),
                          duration: const Duration(milliseconds: 1500),
                          builder: (context, value, child) {
                            return Text(
                              '$value',
                              style: GoogleFonts.poppins(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Draw progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -90 * (3.14159 / 180), // Start from top (90 degrees)
      progress * 2 * 3.14159, // Full circle is 2*PI radians
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
