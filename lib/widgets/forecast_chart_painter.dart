import 'dart:math';
import 'package:flutter/material.dart';

/// Custom Painter per disegnare la linea temporale predittiva senza pacchetti esterni di terze parti
class ForecastChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;

  ForecastChartPainter({required this.data, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = const Color(0xFF334155).withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    // Disegna la griglia orizzontale
    const int gridLines = 4;
    for (int i = 0; i <= gridLines; i++) {
      double y = size.height * (i / gridLines);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final double minVal = data.reduce(min);
    final double maxVal = data.reduce(max);
    final double range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final double dx = size.width / (data.length - 1);
    final path = Path();
    final fillPath = Path();

    // Calcolo coordinate punti
    double getY(double val) {
      double pct = (val - minVal) / range;
      // Inverte per posizionare l'origine in basso a sinistra della canvas
      return size.height - (pct * size.height * 0.8) - (size.height * 0.1);
    }

    path.moveTo(0, getY(data[0]));
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, getY(data[0]));

    for (int i = 1; i < data.length; i++) {
      double x = i * dx;
      double y = getY(data[i]);
      path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Applica gradiente sotto il grafico
    fillPaint.shader = LinearGradient(
      colors: [lineColor.withValues(alpha: 0.15), Colors.transparent],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ForecastChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.lineColor != lineColor;
  }
}
