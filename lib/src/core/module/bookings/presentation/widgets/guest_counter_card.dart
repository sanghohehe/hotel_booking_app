import 'package:flutter/material.dart';

class CounterCard extends StatelessWidget {
  final int adults;
  final int children;
  final bool isOverCapacity;
  final int maxCapacity;
  final Function(int) onAdultsChanged;
  final Function(int) onChildrenChanged;

  const CounterCard({
    super.key,
    required this.adults,
    required this.children,
    required this.isOverCapacity,
    required this.maxCapacity,
    required this.onAdultsChanged,
    required this.onChildrenChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row('Người lớn', adults, onAdultsChanged, min: 1),
        _row('Trẻ em', children, onChildrenChanged),
        if (isOverCapacity)
          Text(
            'Tối đa $maxCapacity người',
            style: const TextStyle(color: Colors.red),
          ),
      ],
    );
  }

  Widget _row(String label, int value, Function(int) onChanged, {int min = 0}) {
    return Row(
      children: [
        Text(label),
        const Spacer(),
        IconButton(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        Text('$value'),
        IconButton(
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
