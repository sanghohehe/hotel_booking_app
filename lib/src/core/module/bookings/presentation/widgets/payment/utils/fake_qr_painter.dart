import 'dart:math';
import 'package:flutter/material.dart';

class FakeQrPainter extends CustomPainter {
  final int seed;
  const FakeQrPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final rng = Random(seed);
    final cell = size.width / 21;

    _drawCornerSquare(canvas, paint, 0, 0, cell);
    _drawCornerSquare(canvas, paint, 14 * cell, 0, cell);
    _drawCornerSquare(canvas, paint, 0, 14 * cell, cell);

    for (int r = 0; r < 21; r++) {
      for (int c = 0; c < 21; c++) {
        if (_isCornerZone(r, c)) continue;
        if (rng.nextBool()) {
          canvas.drawRect(
            Rect.fromLTWH(c * cell + 1, r * cell + 1, cell - 2, cell - 2),
            paint,
          );
        }
      }
    }
  }

  void _drawCornerSquare(Canvas canvas, Paint paint, double x, double y, double cell) {
    canvas.drawRect(Rect.fromLTWH(x, y, cell * 7, cell * 7), paint);
    canvas.drawRect(
      Rect.fromLTWH(x + cell, y + cell, cell * 5, cell * 5),
      Paint()..color = Colors.white,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + cell * 2, y + cell * 2, cell * 3, cell * 3),
      paint,
    );
  }

  bool _isCornerZone(int r, int c) {
    return (r < 8 && c < 8) || (r < 8 && c > 12) || (r > 12 && c < 8);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}