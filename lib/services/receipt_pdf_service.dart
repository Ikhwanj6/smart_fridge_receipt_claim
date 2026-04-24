import 'dart:html' as html;
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class ReceiptPdfService {
  const ReceiptPdfService();

  Future<void> openPdfWithBasicAuth({
    required String url,
    required String authorization,
    String fileName = 'receipt.pdf',
  }) async {
    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Authorization': authorization.trim(),
        'Accept': 'application/pdf',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to fetch PDF (${response.statusCode}): ${response.body}',
      );
    }

    final bytes = Uint8List.fromList(response.bodyBytes);
    final blob = html.Blob(<dynamic>[bytes], 'application/pdf');
    final objectUrl = html.Url.createObjectUrlFromBlob(blob);

    // Open in new tab
    html.window.open(objectUrl, '_blank');

    // Optional cleanu
    Future<void>.delayed(const Duration(seconds: 10), () {
      html.Url.revokeObjectUrl(objectUrl);
    });
  }

  Future<void> downloadPdfWithBasicAuth({
    required String url,
    required String authorization,
    String fileName = 'receipt.pdf',
  }) async {
    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Authorization': authorization.trim(),
        'Accept': 'application/pdf',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to fetch PDF (${response.statusCode}): ${response.body}',
      );
    }

    final bytes = Uint8List.fromList(response.bodyBytes);
    final blob = html.Blob(<dynamic>[bytes], 'application/pdf');
    final objectUrl = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: objectUrl)
      ..setAttribute('download', fileName)
      ..click();

    Future<void>.delayed(const Duration(seconds: 10), () {
      html.Url.revokeObjectUrl(objectUrl);
    });
  }
}
