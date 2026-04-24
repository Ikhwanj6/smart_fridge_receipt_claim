/*
{
    "status": true,
    "message": "Receipt found.",
    "receipt_url": "http://localhost/smartfridge_api/shopping_app/machine/Transaction/download_pdf/20250827100414168?token=myStaticQrToken123",
    "receipt_token": "myStaticQrToken123",
    "transaction_id": "20250827100414168",
    "transaction_no": "3084390290",
    "machine_identifier": "20250708992",
    "payment_datetime": "2025-08-27 10:04:15",
    "raw": {
        "machine_primary_type_id": 9,
        "json_response": {
            "amount": "0.10",
            "applicationCode": "902daa9d16f241604fe947b1f43096f5",
            "authorizationCode": "281011026338023491896456",
            "authorizationCodeType": "",
            "baseAmount": "0.10",
            "baseCurrencyCode": "MYR",
            "channelId": "17",
            "currencyCode": "MYR",
            "errorCode": "",
            "exchangeRate": "1.0000",
            "molTransactionId": "3084390290",
            "payerId": "20250827211212800100171598697741772",
            "referenceId": "20250827100414168",
            "statusCode": "00",
            "transactionDateTime": "2025-08-27T10:04:15",
            "version": "v2",
            "signature": "a9aa443731be2a1f4289d9a1fad7b9c54df7f8a9e310743194f09b1122fa5b59"
        }
    }
}

is an example of the expected JSON response from the claim endpoint, which the `ClaimResult` class is designed to parse and represent in a structured way.
build the api according to the above response
note: transaction_no from response actually is molTransactionId in payment.json_response, but in ewallet it was called transaction_no, so we will try to parse both for better compatibility with different APIs.
*/

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
