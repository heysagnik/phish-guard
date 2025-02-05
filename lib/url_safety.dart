import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class URLSafety {
  static const apiKey = 'AIzaSyDNc4dV2hcxkpFGmCn1jmIhfq0UaSNpjRw';
  static const clientId =
      '208397729537-qruu6dk9l8gdrqdp1fu1apa2a437rilo.apps.googleusercontent.com';
  static const clientVersion = '1.0.0';

  static Future<bool> isURLSafe(String url) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://safebrowsing.googleapis.com/v4/threatMatches:find?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "client": {"clientId": clientId, "clientVersion": clientVersion},
          "threatInfo": {
            "threatTypes": [
              "MALWARE",
              "SOCIAL_ENGINEERING",
              "POTENTIALLY_HARMFUL_APPLICATION",
              "UNWANTED_SOFTWARE",
              "THREAT_TYPE_UNSPECIFIED"
              "NEW_THREAD_TYPE"
              
            ],
            "platformTypes": ["ANY_PLATFORM"],
            "threatEntryTypes": ["URL"],
            "threatEntries": [
              {"url": url}
            ]
          }
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['matches'] == null;
      } else {
        debugPrint('Request failed with status: ${response.statusCode}.');
        return true; // Treat as safe on error
      }
    } catch (e) {
      debugPrint('Error checking URL safety: $e');
      return true; // Treat as safe on exception
    }
  }
}
