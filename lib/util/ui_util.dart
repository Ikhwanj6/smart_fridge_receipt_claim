import 'package:flutter/material.dart';
import 'package:receipt_claim_flutter_web/theme/color_pallete.dart';

class InfoChip extends StatelessWidget {
  const InfoChip({required this.icon, required this.text});

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

class StatusBanner extends StatelessWidget {
  const StatusBanner({
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

class DataTile extends StatelessWidget {
  const DataTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceTint(0.035),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: surfaceTint(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textMuted,
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

Color surfaceTint(double amount) {
  return Color.alphaBlend(
    ColorPallete.redColor.withOpacity(amount.clamp(0, 1)),
    Colors.white,
  );
}

Color lighten(Color color, double amount) {
  return Color.lerp(color, Colors.white, amount.clamp(0, 1)) ?? color;
}

Color darken(Color color, double amount) {
  return Color.lerp(color, Colors.black, amount.clamp(0, 1)) ?? color;
}

final Color textStrong = darken(ColorPallete.redColor, 0.56);
final Color textMuted = darken(ColorPallete.redColor, 0.22).withOpacity(0.78);
final Color successBackground = surfaceTint(0.07);
final Color successBorder = surfaceTint(0.16);
final Color infoBackground = surfaceTint(0.055);
final Color infoBorder = surfaceTint(0.14);
final Color dangerBackground = surfaceTint(0.085);
final Color dangerBorder = lighten(ColorPallete.redColor, 0.18);
