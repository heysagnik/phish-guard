import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services for SystemChrome.
import 'package:app_links/app_links.dart';
import 'package:phisguard/splash_screen.dart';
import 'package:phisguard/url_safety_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Inverse the status bar theme: use light icons on a dark status bar background.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    // Optionally set a background color if desired:
    statusBarColor: Colors.black,
  ));
  runApp(const MyApp());
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
        home: const SplashScreen(),
      );
}
