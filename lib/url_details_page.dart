import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UrlDetailsPage extends StatelessWidget {
  final String url;

  const UrlDetailsPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "URL Details",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF055FFA),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Scanned URL:",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SelectableText(
              url,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.blue),
            ),
            const SizedBox(height: 20),
            Text(
              "Analysis Details:",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            // TODO: Display real details here (API response or local storage)
            Text(
              "Details about this URL will be shown here...",
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}