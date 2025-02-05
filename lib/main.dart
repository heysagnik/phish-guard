import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MyApp());

Future<bool> checkUrlSafety(String url) async {
  const apiKey = 'AIzaSyDNc4dV2hcxkpFGmCn1jmIhfq0UaSNpjRw';
  const clientId =
      '208397729537-qruu6dk9l8gdrqdp1fu1apa2a437rilo.apps.googleusercontent.com';

  final response = await http.post(
    Uri.parse(
        'https://safebrowsing.googleapis.com/v4/threatMatches:find?key=$apiKey'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "client": {"clientId": clientId, "clientVersion": "1.0"},
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

  return jsonDecode(response.body).isEmpty;
}

Future<void> _launchUrl(Uri uri, BuildContext context) async {
  try {
    if (Platform.isAndroid && (uri.scheme == 'https' || uri.scheme == 'http')) {
      final chromeUrl =
          'googlechrome://navigate?url=${Uri.encodeFull(uri.toString())}';
      final chromeUri = Uri.parse(chromeUrl);

      if (await canLaunchUrl(chromeUri)) {
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('onAppLink: $uri');
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => URLSafetyScreen(url: uri.toString()),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: _navigatorKey,
        home: const HomeScreen(),
      );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('PhishGuard')),
        body: const Center(
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

class URLSafetyScreen extends StatefulWidget {
  final String url;

  const URLSafetyScreen({super.key, required this.url});

  @override
  State<URLSafetyScreen> createState() => _URLSafetyScreenState();
}

class _URLSafetyScreenState extends State<URLSafetyScreen> {
  late final Future<bool> _safetyFuture;

  @override
  void initState() {
    super.initState();
    _safetyFuture = checkUrlSafety(widget.url);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('URL Safety Scanner'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<bool>(
            future: _safetyFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Scanning URL...'),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Error scanning URL.'));
              }

              final bool isSafe = snapshot.data ?? false;
              final chromeUrl =
                  'googlechrome://navigate?url=${Uri.encodeFull(widget.url)}';

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.url,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => _launchUrl(Uri.parse(chromeUrl), context),
                    child: const Text('Open in Chrome'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              );
            },
          ),
        ),
      );
}
