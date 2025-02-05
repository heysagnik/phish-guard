import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';

class DashboardStats {
  final int urlsScanned;
  final int dangerousUrls;

  const DashboardStats({
    this.urlsScanned = 0,
    this.dangerousUrls = 0,
  });
}

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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late Future<bool> _defaultBrowserCheck;
  DashboardStats _stats = const DashboardStats();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeData(); // Refresh when app is resumed
    }
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    try {
      _defaultBrowserCheck = DefaultBrowserChecker.isDefaultBrowser();
      await _loadStats();
    } catch (e) {
      debugPrint('Error initializing data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _stats = DashboardStats(
            urlsScanned: prefs.getInt('urls_scanned') ?? 0,
            dangerousUrls: prefs.getInt('dangerous_urls') ?? 0,
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const _LoadingScreen();
    }

    return FutureBuilder<bool>(
      future: _defaultBrowserCheck,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        if (snapshot.hasError) {
          return _ErrorScreen(onRetry: _initializeData);
        }

        final isDefault = snapshot.data ?? false;
        if (!isDefault) {
          return _NotDefaultBrowserScreen(onSetDefault: _initializeData);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('PhishGuard Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _initializeData,
              ),
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _initializeData,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Text(
                    'Security Statistics',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.link,
                          title: 'URLs Scanned',
                          value: _stats.urlsScanned.toString(),
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.warning,
                          title: 'Dangerous Sites',
                          value: _stats.dangerousUrls.toString(),
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _SecurityStatusCard(isSecure: isDefault),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 8), // Added const here
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 4), // Added const here
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityStatusCard extends StatelessWidget {
  final bool isSecure;

  const _SecurityStatusCard({required this.isSecure});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSecure ? Colors.green.shade50 : Colors.orange.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isSecure ? Icons.security : Icons.security_update_warning,
              size: 40,
              color: isSecure ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                isSecure
                    ? 'Your browsing is protected'
                    : 'Protection status: Limited',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading dashboard...'),
          ],
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorScreen({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Failed to load dashboard'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotDefaultBrowserScreen extends StatelessWidget {
  final VoidCallback onSetDefault;

  const _NotDefaultBrowserScreen({required this.onSetDefault});

  Future<void> _launchBrowserSettings() async {
    const AndroidIntent intent = AndroidIntent(
      action: 'android.settings.MANAGE_DEFAULT_APPS_SETTINGS',
    );
    await intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.security_update_warning,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              Text(
                'Your browsing is not protected',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Set PhishGuard as your default browser to protect against malicious URLs',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  await _launchBrowserSettings();
                  onSetDefault();
                },
                icon: const Icon(Icons.security),
                label: const Text('Set as Default Browser'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
