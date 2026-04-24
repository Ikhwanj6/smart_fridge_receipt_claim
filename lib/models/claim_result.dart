class ClaimResult {
  final bool status;
  final String message;
  final String? receiptUrl;
  final String? receiptToken;
  final String? transactionId;
  final String? transactionNo;
  final String? machineIdentifier;
  final String? paymentDateTime;
  final Map<String, dynamic> raw;

  const ClaimResult({
    required this.status,
    required this.message,
    this.receiptUrl,
    this.receiptToken,
    this.transactionId,
    this.transactionNo,
    this.machineIdentifier,
    this.paymentDateTime,
    required this.raw,
  });

  factory ClaimResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : <String, dynamic>{};

    final rawValue = json['raw'];
    final rawMap =
        rawValue is Map<String, dynamic> ? rawValue : <String, dynamic>{};

    return ClaimResult(
      status: json['status'] == true || json['success'] == true,
      message:
          (json['message'] ?? json['msg'] ?? 'No message returned').toString(),
      receiptUrl: _firstNonEmptyString([
        json['receipt_url'],
        json['receiptUrl'],
        json['pdf_url'],
        json['pdfUrl'],
        json['download_url'],
        json['downloadUrl'],
        json['url'],
        data['receipt_url'],
        data['pdf_url'],
        data['download_url'],
      ]),
      receiptToken: _firstNonEmptyString([
        json['receipt_token'],
        json['receiptToken'],
        json['token'],
        data['receipt_token'],
        data['token'],
      ]),
      transactionId: _firstNonEmptyString([
        json['transaction_id'],
        json['transactionId'],
        data['transaction_id'],
        data['transactionId'],
      ]),
      transactionNo: _firstNonEmptyString([
        json['transaction_no'],
        json['transactionNo'],
        data['transaction_no'],
        data['transactionNo'],
      ]),
      machineIdentifier: _firstNonEmptyString([
        json['machine_identifier'],
        json['machineIdentifier'],
        data['machine_identifier'],
        data['machineIdentifier'],
      ]),
      paymentDateTime: _firstNonEmptyString([
        json['payment_datetime'],
        json['paymentDateTime'],
        data['payment_datetime'],
        data['paymentDateTime'],
      ]),
      raw: rawMap.isNotEmpty ? rawMap : json,
    );
  }

  static String? _firstNonEmptyString(List<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }
}
