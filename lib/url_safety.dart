import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class URLSafetyResponse {
  final String domain;
  final String domainAgeDays;
  final bool isNewlyListed;
  final bool googleMalicious;
  final String? safeBrowsingDetails;
  final String siteCategory;
  final String? geminiDetails;
  final bool geminiSafe;
  final List<String> redirects;
  final bool hasRedirects;
  final int? contentAnalysisScore;
  final bool hasPhishingIndicators;
  final int overallRiskScore;
  final Summary summary;

  URLSafetyResponse({
    required this.domain,
    required this.domainAgeDays,
    required this.isNewlyListed,
    required this.googleMalicious,
    this.safeBrowsingDetails,
    required this.siteCategory,
    this.geminiDetails,
    required this.geminiSafe,
    required this.redirects,
    required this.hasRedirects,
    this.contentAnalysisScore,
    required this.hasPhishingIndicators,
    required this.overallRiskScore,
    required this.summary,
  });

  factory URLSafetyResponse.fromJson(Map<String, dynamic> json) {
    return URLSafetyResponse(
      domain: json['domain'] ?? '',
      domainAgeDays: json['domain_age_days']?.toString() ?? 'No Data',
      isNewlyListed: json['is_newly_listed'] ?? false,
      googleMalicious: json['google_malicious'] ?? false,
      safeBrowsingDetails: json['safe_browsing_details'],
      siteCategory: json['category'] ?? 'Unknown',
      geminiDetails: json['gemini_details'],
      geminiSafe: json['gemini_safe'] ?? true,
      redirects: List<String>.from(json['redirects'] ?? []),
      hasRedirects: json['has_redirects'] ?? false,
      contentAnalysisScore: json['content_analysis_score'],
      hasPhishingIndicators: json['has_phishing_indicators'] ?? false,
      overallRiskScore: json['overallRiskScore'] ?? 0,
      summary: Summary.fromJson(json['summary'] ?? {}),
    );
  }

  bool get isMalicious => !summary.isReallySafe;
}

class Summary {
  final String threatLevel;
  final String message;
  final bool isReallySafe;

  Summary({
    required this.threatLevel,
    required this.message,
    required this.isReallySafe,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      threatLevel: json['threatLevel'] ?? 'Unknown',
      message: json['message'] ?? 'No summary available',
      isReallySafe: json['isReallySafe'] ?? true,
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
      return result.summary.isReallySafe;
    } catch (e) {
      debugPrint('Error in isURLSafe: $e');
      return false;
    }
  }
}
