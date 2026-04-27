import 'package:flutter/material.dart';

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
      final itemWidth =
          columns == 1 ? width : (width - ((columns - 1) * spacing)) / columns;

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
