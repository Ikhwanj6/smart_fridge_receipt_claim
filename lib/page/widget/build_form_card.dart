import 'package:flutter/material.dart';
import 'package:receipt_claim_flutter_web/theme/color_pallete.dart';
import 'package:receipt_claim_flutter_web/util/ui_util.dart';

Widget buildFormCard(
    GlobalKey<FormState> key,
    TextEditingController controller,
    bool send,
    Future<void> Function() submit,
    String? errorMessage,
    FormFieldValidator<String>? validateTransactionNo) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: key,
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
              style: TextStyle(color: textMuted),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Transaction No',
                hintText: 'Example: 41234141412',
                prefixIcon: Icon(Icons.tag_outlined),
              ),
              validator: validateTransactionNo,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: send ? null : submit,
                icon: send
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
                label: Text(send ? 'Checking receipt...' : 'Claim receipt'),
              ),
            ),
            if ((errorMessage ?? '').isNotEmpty) ...[
              const SizedBox(height: 16),
              StatusBanner(
                color: dangerBackground,
                borderColor: dangerBorder,
                iconColor: ColorPallete.redColor,
                textColor: textStrong,
                icon: Icons.error_outline,
                text: errorMessage!,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
