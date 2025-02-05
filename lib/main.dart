import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io'; // For Platform detection

void main() {
  runApp(const MyApp());
}

// Global function to check URL safety using Google Safe Browsing API.
Future<bool> checkUrlSafety(String url) async {
  final apiKey = 'AIzaSyDNc4dV2hcxkpFGmCn1jmIhfq0UaSNpjRw';
  final response = await http.post(
    Uri.parse(
        'https://safebrowsing.googleapis.com/v4/threatMatches:find?key=$apiKey'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "client": {
        "clientId":
            "208397729537-qruu6dk9l8gdrqdp1fu1apa2a437rilo.apps.googleusercontent.com",
        "clientVersion": "1.0"
      },
      "threatInfo": {
        "threatTypes": ["MALWARE", "SOCIAL_ENGINEERING"],
        "platformTypes": ["ANY_PLATFORM"],
        "threatEntryTypes": ["URL"],
        "threatEntries": [
          {"url": url}
        ]
      }
    }),
  );
  final data = jsonDecode(response.body);
  return data.isEmpty; // True if no threats found
}

// Global function to launch a URL in Chrome (preferred) or default browser.
Future<void> _launchUrl(Uri uri, BuildContext context) async {
  try {
    // Try to open in Chrome on Android.
    if (Platform.isAndroid && (uri.scheme == 'https' || uri.scheme == 'http')) {
      final chromeUrl =
          uri.toString().replaceFirst(RegExp(r'^https?://'), 'googlechrome://');
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
    // Show an error dialog if launching fails.
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to open the URL. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle incoming links.
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('onAppLink: $uri');
      _handleIncomingLink(uri.toString());
    });
  }

  void _handleIncomingLink(String url) {
    // Push the URLSafetyScreen when a link is received.
    _navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => URLSafetyScreen(url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PhishGuard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'PhishGuard is running in the background.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Click any link across your Android device to test.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Screen to display URL safety results.
class URLSafetyScreen extends StatefulWidget {
  final String url;
  const URLSafetyScreen({super.key, required this.url});

  @override
  State<URLSafetyScreen> createState() => _URLSafetyScreenState();
}

class _URLSafetyScreenState extends State<URLSafetyScreen> {
  late Future<bool> _safetyFuture;

  @override
  void initState() {
    super.initState();
    _safetyFuture = checkUrlSafety(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('URL Safety Scanner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<bool>(
          future: _safetyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Scanning URL...')
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error scanning URL.'));
            } else {
              bool isSafe = snapshot.data ?? false;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.url,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Text(
                    isSafe
                        ? 'The URL is safe.'
                        : 'The URL appears to be suspicious!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: isSafe ? Colors.green : Colors.red,
                    ),
                  ),
                  SizedBox(height: 30),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      debugPrint(widget.url);
                      _launchUrl(
                          Uri.parse(
                              'googlechrome://navigate?url=${widget.url}'),
                          context);
                    },
                    child: Text('Open URL'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Go Back'),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
