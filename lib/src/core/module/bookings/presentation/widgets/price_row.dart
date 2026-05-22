import 'package:flutter/material.dart';

class PriceRow extends StatelessWidget {
  final String label;
  final double price;
  final bool isTotal;

  const PriceRow({
    super.key,
    required this.label,
    required this.price,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), Text('\$${price.toStringAsFixed(0)}')],
    );
  }
}
