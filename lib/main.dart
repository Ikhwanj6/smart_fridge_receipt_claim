import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:receipt_claim_flutter_web/services/receipt_pdf_service.dart';
import 'package:receipt_claim_flutter_web/theme/color_pallete.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models/claim_result.dart';
import 'services/receipt_api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ReceiptClaimApp());
}

class AppConfig {
  static const String appTitle = 'Smart Fridge Receipt Claim';

  static const String baseUrl =
      'http://192.168.0.179/smartfridge_api/index.php/';

  static const String claimPath =
      'shopping_app/receipt_claim/Receipt_claim/claim_receipt';

  static final String basicAuths =
      'Basic ${base64.encode(utf8.encode('admin:1234'))}';
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
        scaffoldBackgroundColor: _surfaceTint(0.035),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: _textMuted),
          hintStyle: TextStyle(color: _textMuted.withOpacity(0.85)),
          prefixIconColor: ColorPallete.redColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _surfaceTint(0.16)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _surfaceTint(0.16)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: ColorPallete.redColor, width: 1.4),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _dangerBorder),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _dangerBorder, width: 1.4),
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
          textColor: _textStrong,
          collapsedTextColor: _textStrong,
          tilePadding: EdgeInsets.zero,
        ),
      ),
      home: const ReceiptClaimPage(),
    );
  }
}

class ReceiptClaimPage extends StatefulWidget {
  const ReceiptClaimPage({super.key});

  @override
  State<ReceiptClaimPage> createState() => _ReceiptClaimPageState();
}

class _ReceiptClaimPageState extends State<ReceiptClaimPage> {
  final _formKey = GlobalKey<FormState>();

  late final ReceiptApiService _apiService;

  final _transactionNoController = TextEditingController();

  bool _sending = false;
  ClaimResult? _result;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _apiService = ReceiptApiService(
      baseUrl: AppConfig.baseUrl,
      claimPath: AppConfig.claimPath,
      authorization: AppConfig.basicAuths,
    );

    final query = Uri.base.queryParameters;
    _transactionNoController.text =
        query['transaction_no'] ?? query['ref'] ?? query['reference_id'] ?? '';
  }

  @override
  void dispose() {
    _transactionNoController.dispose();
    super.dispose();
  }

  Future<void> _submitClaim() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _sending = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final result = await _apiService.claimReceipt(
        transactionNo: _transactionNoController.text,
      );

      if (!mounted) return;
      setState(() {
        _result = result;
        _errorMessage = result.status ? null : result.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  String? _validateTransactionNo(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Transaction No is required.';
    if (text.length < 8) return 'Transaction No looks too short.';
    return null;
  }

  String? _resolvedReceiptUrl(ClaimResult? result) {
    if (result == null) return null;
    if ((result.receiptUrl ?? '').trim().isNotEmpty) return result.receiptUrl;
    return null;
  }

  Future<void> _openReceipt() async {
    final _pdfService = const ReceiptPdfService();
    final url = _resolvedReceiptUrl(_result);
    if (url == null || url.isEmpty) return;

    try {
      await _pdfService.openPdfWithBasicAuth(
        url: url,
        authorization: AppConfig.basicAuths,
        fileName: 'receipt_${_result?.transactionNo ?? 'download'}.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  // Future<void> _openReceipt() async {
  //   final url = _resolvedReceiptUrl(_result);
  //   if (url == null || url.isEmpty) return;

  //   final uri = Uri.tryParse(url);
  //   if (uri == null) {
  //     setState(() {
  //       _errorMessage = 'Invalid receipt URL returned by backend.';
  //     });
  //     return;
  //   }

  //   final launched = await launchUrl(uri,
  //       mode: LaunchMode.inAppBrowserView,
  //       webViewConfiguration: WebViewConfiguration(
  //         headers: <String, String>{
  //           'Authorization': AppConfig.basicAuths.trim(),
  //           'Accept': 'application/json',
  //         },
  //       ));
  //   if (!launched && mounted) {
  //     setState(() {
  //       _errorMessage = 'Unable to open the receipt link.';
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final compact = width < 900;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeroCard(),
                        const SizedBox(height: 16),
                        _buildFormCard(),
                        const SizedBox(height: 16),
                        _buildResultCard(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: _buildHeroCard()),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildFormCard(),
                              const SizedBox(height: 16),
                              _buildResultCard(),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _darken(ColorPallete.redColor, 0.04),
              ColorPallete.redColor,
              _lighten(ColorPallete.redColor, 0.14),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: ColorPallete.redColor.withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.receipt_long, color: Colors.white, size: 42),
            SizedBox(height: 16),
            Text(
              'Claim your payment receipt',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Enter your transaction No from the ewallet provider to retrieve the PDF receipt after a screenless QR payment.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            _InfoChip(
              icon: Icons.payments_outlined,
              text: 'QR payment friendly',
            ),
            SizedBox(height: 10),
            _InfoChip(
              icon: Icons.lock_outline,
              text: 'Token-based receipt links',
            ),
            SizedBox(height: 10),
            _InfoChip(
              icon: Icons.mobile_friendly_outlined,
              text: 'Works on mobile browser',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Receipt details',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter your payment transaction No to retrieve the receipt.',
                style: TextStyle(color: _textMuted),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _transactionNoController,
                decoration: const InputDecoration(
                  labelText: 'Transaction No',
                  hintText: 'Example: 41234141412',
                  prefixIcon: Icon(Icons.tag_outlined),
                ),
                validator: _validateTransactionNo,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _sending ? null : _submitClaim,
                  icon: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.search_outlined),
                  label:
                      Text(_sending ? 'Checking receipt...' : 'Claim receipt'),
                ),
              ),
              if ((_errorMessage ?? '').isNotEmpty) ...[
                const SizedBox(height: 16),
                _StatusBanner(
                  color: _dangerBackground,
                  borderColor: _dangerBorder,
                  iconColor: ColorPallete.redColor,
                  textColor: _textStrong,
                  icon: Icons.error_outline,
                  text: _errorMessage!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultDetailsGrid({required List<Widget> tiles}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 760
            ? 3
            : width >= 480
                ? 2
                : 1;
        const spacing = 12.0;
        final itemWidth = columns == 1
            ? width
            : (width - ((columns - 1) * spacing)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final tile in tiles) SizedBox(width: itemWidth, child: tile),
          ],
        );
      },
    );
  }

  Widget _buildResultCard() {
    final receiptUrl = _resolvedReceiptUrl(_result);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Result',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            if (_result == null)
              Text(
                'No receipt claimed yet. Submit the form to retrieve the PDF link.',
                style: TextStyle(color: _textMuted),
              )
            else ...[
              _StatusBanner(
                color: _result!.status ? _successBackground : _infoBackground,
                borderColor: _result!.status ? _successBorder : _infoBorder,
                iconColor: ColorPallete.redColor,
                textColor: _textStrong,
                icon: _result!.status
                    ? Icons.check_circle_outline
                    : Icons.info_outline,
                text: _result!.message,
              ),
              const SizedBox(height: 16),
              _buildResultDetailsGrid(
                tiles: [
                  _DataTile(
                    label: 'Transaction No',
                    value: (_result!.transactionNo ?? '').isEmpty
                        ? '-'
                        : _result!.transactionNo!,
                  ),
                  _DataTile(
                    label: 'Transaction ID',
                    value: (_result!.transactionId ?? '').isEmpty
                        ? '-'
                        : _result!.transactionId!,
                  ),
                  _DataTile(
                    label: 'Machine Identifier',
                    value: (_result!.machineIdentifier ?? '').isEmpty
                        ? '-'
                        : _result!.machineIdentifier!,
                  ),
                  _DataTile(
                    label: 'Payment Time',
                    value: (_result!.paymentDateTime ?? '').isEmpty
                        ? '-'
                        : _result!.paymentDateTime!,
                  ),
                  _DataTile(
                    label: 'Receipt Token',
                    value: (_result!.receiptToken ?? '').isEmpty
                        ? '-'
                        : _result!.receiptToken!,
                  ),
                ],
              ),
              if ((receiptUrl ?? '').isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _surfaceTint(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _surfaceTint(0.12)),
                  ),
                  child: SelectableText(
                    receiptUrl!,
                    style: const TextStyle(fontSize: 13),
                    maxLines: null,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: _openReceipt,
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Open receipt PDF'),
                ),
              ],
              const SizedBox(height: 20),
              ExpansionTile(
                title: const Text('Raw response'),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _surfaceTint(0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _surfaceTint(0.12)),
                    ),
                    child: SelectableText(
                      _result!.raw.toString(),
                      maxLines: null,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.color,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
    required this.text,
  });

  final Color color;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _DataTile extends StatelessWidget {
  const _DataTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceTint(0.035),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _surfaceTint(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: _textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          SelectableText(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            maxLines: null,
          ),
        ],
      ),
    );
  }
}

Color _surfaceTint(double amount) {
  return Color.alphaBlend(
    ColorPallete.redColor.withOpacity(amount.clamp(0, 1)),
    Colors.white,
  );
}

Color _lighten(Color color, double amount) {
  return Color.lerp(color, Colors.white, amount.clamp(0, 1)) ?? color;
}

Color _darken(Color color, double amount) {
  return Color.lerp(color, Colors.black, amount.clamp(0, 1)) ?? color;
}

final Color _textStrong = _darken(ColorPallete.redColor, 0.56);
final Color _textMuted = _darken(ColorPallete.redColor, 0.22).withOpacity(0.78);
final Color _successBackground = _surfaceTint(0.07);
final Color _successBorder = _surfaceTint(0.16);
final Color _infoBackground = _surfaceTint(0.055);
final Color _infoBorder = _surfaceTint(0.14);
final Color _dangerBackground = _surfaceTint(0.085);
final Color _dangerBorder = _lighten(ColorPallete.redColor, 0.18);
