import 'dart:convert';

class AppConfig {
  static const String appTitle = 'Smart Fridge Receipt Claim';

  // for local environment testing
  static const String baseUrl =
      'http://192.168.0.179/smartfridge_api/index.php/';
  // for staging environment testing, uncomment the below and comment the above to use staging API
  // static const String baseUrl = 'https://stg-sfapi.nuboxtech.com/index.php/';

  static const String claimPath =
      'shopping_app/receipt_claim/Receipt_claim/claim_receipt';

  static final String basicAuths =
      'Basic ${base64.encode(utf8.encode('admin:1234'))}';
}
