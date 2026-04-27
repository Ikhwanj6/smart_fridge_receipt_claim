import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:receipt_claim_flutter_web/page/receipt_claim_page.dart';
import 'package:receipt_claim_flutter_web/services/receipt_pdf_service.dart';
import 'package:receipt_claim_flutter_web/theme/color_pallete.dart';
import 'package:receipt_claim_flutter_web/util/app_config.dart';
import 'package:receipt_claim_flutter_web/util/ui_util.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models/claim_result.dart';
import 'services/receipt_api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ReceiptClaimApp());
}

class ReceiptClaimApp extends StatelessWidget {
  const ReceiptClaimApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: ColorPallete.redColor,
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.appTitle,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: surfaceTint(0.035),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: textMuted),
          hintStyle: TextStyle(color: textMuted.withOpacity(0.85)),
          prefixIconColor: ColorPallete.redColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: surfaceTint(0.16)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: surfaceTint(0.16)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: ColorPallete.redColor, width: 1.4),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: dangerBorder),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: dangerBorder, width: 1.4),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: ColorPallete.redColor,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        expansionTileTheme: ExpansionTileThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          collapsedIconColor: ColorPallete.redColor,
          iconColor: ColorPallete.redColor,
          textColor: textStrong,
          collapsedTextColor: textStrong,
          tilePadding: EdgeInsets.zero,
        ),
      ),
      home: const ReceiptClaimPage(),
    );
  }
}
