import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadScanData();
  }

  /// Load data from SharedPreferences
  Future<void> _loadScanData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (mounted) {
      setState(() {
        _recentLinks = prefs.getStringList('recentLinks') ?? [];
        _totalScans = prefs.getInt('totalScans') ?? 0;
        _safeSites = prefs.getInt('safeSites') ?? 0;
        _dangerousSites = prefs.getInt('dangerousSites') ?? 0;
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: const Color(0xFF2A35FF),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadScanData(); // Manually refresh page data
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Display Statistics
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Scan Statistics",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildStatRow("Total Scans", _totalScans),
                    _buildStatRow("Safe Sites", _safeSites, color: Colors.green),
                    _buildStatRow("Dangerous Sites", _dangerousSites, color: Colors.red),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            /// Display Recent Links
            Text(
              "Recent Scanned URLs",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadScanData, // Pull-to-refresh feature
                child: _recentLinks.isEmpty
                    ? Center(child: Text("No recent scans yet."))
                    : ListView.builder(
                  itemCount: _recentLinks.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        leading: Icon(Icons.link, color: Colors.blue),
                        title: Text(
                          _recentLinks[index],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper function to build statistics row
  Widget _buildStatRow(String label, int value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text(
            value.toString(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}




Widget _buildStatRow(String label, int value, {Color? color, Color textColor = Colors.white}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: textColor)),
        Text(
          value.toString(),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color ?? textColor),
        ),
      ],
    ),
  );
}