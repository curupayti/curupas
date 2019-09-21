import 'package:flutter/material.dart';

class CurvePainter extends CustomPainter {
  double _b, _y;

  CurvePainter(this._y, this._b);

  @override
  void paint(Canvas canvas, Size size) {
    double top;
    if (_y != null) {
      top = _y;
    }
    if (_b != null) {
      top = size.height - _b;
    }
    var paint = Paint();
    paint.color = Colors.amber;
    paint.strokeWidth = 10;
    canvas.drawLine(
      Offset(0, top),
      Offset(size.width, top),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
