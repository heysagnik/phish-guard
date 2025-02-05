import 'dart:convert';
import 'package:http/http.dart' as http;

Future<bool> checkUrlSafety(String url) async {
  const apiKey = 'AIzaSyDNc4dV2hcxkpFGmCn1jmIhfq0UaSNpjRw';
  const clientId = '208397729537-qruu6dk9l8gdrqdp1fu1apa2a437rilo.apps.googleusercontent.com';

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