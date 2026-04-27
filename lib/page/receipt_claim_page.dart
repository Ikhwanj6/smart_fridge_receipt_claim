import 'package:flutter/material.dart';
import 'package:receipt_claim_flutter_web/models/claim_result.dart';
import 'package:receipt_claim_flutter_web/page/widget/build_form_card.dart';
import 'package:receipt_claim_flutter_web/page/widget/build_hero_card.dart';
import 'package:receipt_claim_flutter_web/page/widget/build_result_details_grid.dart';
import 'package:receipt_claim_flutter_web/services/receipt_api_service.dart';
import 'package:receipt_claim_flutter_web/services/receipt_pdf_service.dart';
import 'package:receipt_claim_flutter_web/theme/color_pallete.dart';
import 'package:receipt_claim_flutter_web/util/app_config.dart';
import 'package:receipt_claim_flutter_web/util/ui_util.dart';

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
                        buildHeroCard(),
                        const SizedBox(height: 16),
                        buildFormCard(
                          _formKey,
                          _transactionNoController,
                          _sending,
                          _submitClaim,
                          _errorMessage,
                          _validateTransactionNo,
                        ),
                        const SizedBox(height: 16),
                        _buildResultCard(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: buildHeroCard()),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              buildFormCard(
                                _formKey,
                                _transactionNoController,
                                _sending,
                                _submitClaim,
                                _errorMessage,
                                _validateTransactionNo,
                              ),
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
                style: TextStyle(color: textMuted),
              )
            else ...[
              StatusBanner(
                color: _result!.status ? successBackground : infoBackground,
                borderColor: _result!.status ? successBorder : infoBorder,
                iconColor: ColorPallete.redColor,
                textColor: textStrong,
                icon: _result!.status
                    ? Icons.check_circle_outline
                    : Icons.info_outline,
                text: _result!.message,
              ),
              const SizedBox(height: 16),
              buildResultDetailsGrid(
                tiles: [
                  DataTile(
                    label: 'Transaction No',
                    value: (_result!.transactionNo ?? '').isEmpty
                        ? '-'
                        : _result!.transactionNo!,
                  ),
                  DataTile(
                    label: 'Transaction ID',
                    value: (_result!.transactionId ?? '').isEmpty
                        ? '-'
                        : _result!.transactionId!,
                  ),
                  DataTile(
                    label: 'Machine Identifier',
                    value: (_result!.machineIdentifier ?? '').isEmpty
                        ? '-'
                        : _result!.machineIdentifier!,
                  ),
                  DataTile(
                    label: 'Payment Time',
                    value: (_result!.paymentDateTime ?? '').isEmpty
                        ? '-'
                        : _result!.paymentDateTime!,
                  ),
                  DataTile(
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
                    color: surfaceTint(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: surfaceTint(0.12)),
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
                      color: surfaceTint(0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: surfaceTint(0.12)),
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
