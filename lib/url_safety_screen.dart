import 'package:flutter/material.dart';
import 'package:phisguard/url_safety.dart';
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
  bool _isSafe = true; // Default to safe
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _safetyFuture = URLSafety.isURLSafe(widget.url);
    _safetyFuture.then((value) {
      setState(() {
        _isSafe = value;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('URL Safety Scanner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Scanning URL...'),
                  ],
                ),
              )
            : FutureBuilder<bool>(
                future: _safetyFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error scanning URL: ${snapshot.error}'));
                  }

                  _isSafe = snapshot.data ?? true;

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
                        _isSafe
                            ? 'The URL is safe.'
                            : 'The URL appears to be suspicious!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: _isSafe ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _isSafe
                            ? () => _launchUrl(Uri.parse(chromeUrl), context)
                            : null,
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
