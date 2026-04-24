import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/claim_result.dart';

class ReceiptApiService {
  ReceiptApiService({
    required this.baseUrl,
    required this.claimPath,
    this.authorization,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final String claimPath;
  final String? authorization;
  final http.Client _client;

  Future<ClaimResult> claimReceipt({
    required String transactionNo,
  }) async {
    final endpoint = _buildUri();

    final response = await _client.post(
      endpoint,
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
        if ((authorization ?? '').trim().isNotEmpty)
          'Authorization': authorization!.trim(),
      },
      body: <String, String>{
        'transaction_no': transactionNo.trim(),
      },
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Claim request failed (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected response format from claim endpoint.');
    }

    return ClaimResult.fromJson(decoded);
  }

  Uri _buildUri() {
    final base = baseUrl.trim();
    final normalizedBase = base.endsWith('/') ? base : '$base/';
    final normalizedPath = claimPath.trim().replaceAll(RegExp(r'^/+'), '');
    return Uri.parse('$normalizedBase$normalizedPath');
  }
}
