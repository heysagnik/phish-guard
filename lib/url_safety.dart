import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class URLSafetyResponse {
  final String domain;
  final int domainAgeDays;
  final bool isNewlyListed;
  final bool isMalicious;
  final bool googleMalicious;
  final List<String> redirects;
  final bool hasRedirects;
  final String siteCategory;

  URLSafetyResponse({
    required this.domain,
    required this.domainAgeDays,
    required this.isNewlyListed,
    required this.isMalicious,
    required this.googleMalicious,
    required this.redirects,
    required this.hasRedirects,
    required this.siteCategory,
  });

  factory URLSafetyResponse.fromJson(Map<String, dynamic> json) {
    return URLSafetyResponse(
      domain: json['domain'] ?? '',
      domainAgeDays: int.tryParse(json['domain_age_days'].toString()) ?? 1000,
      isNewlyListed: json['is_newly_listed'] ?? false,
      isMalicious: json['is_malicious'] ?? false,
      googleMalicious: json['google_malicious'] ?? false,
      redirects: List<String>.from(json['redirects'] ?? []),
      hasRedirects: json['has_redirects'] ?? false,
      siteCategory: json['site_category'] ?? 'IT',
    );
  }
}

class URLSafety {
  static Future<URLSafetyResponse> checkURL(String url) async {
    try {
      final encodedUrl = Uri.encodeComponent(url);
      final response = await http.get(
        Uri.parse('https://phissy.vercel.app/api/check?url=$encodedUrl'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return URLSafetyResponse.fromJson(jsonResponse);
      } else {
        debugPrint('Request failed with status: ${response.statusCode}.');
        throw Exception('Failed to check URL safety');
      }
    } catch (e) {
      debugPrint('Error checking URL safety: $e');
      throw Exception('Error checking URL safety');
    }
  }

  static Future<bool> isURLSafe(String url) async {
    try {
      final result = await checkURL(url);
      // Consider a URL unsafe if it's malicious according to either check
      // or if it's a newly registered domain
      return !result.isMalicious &&
          !result.googleMalicious &&
          !result.isNewlyListed;
    } catch (e) {
      debugPrint('Error in isURLSafe: $e');
      return false; // Treat as unsafe on exception
    }
  }
}
