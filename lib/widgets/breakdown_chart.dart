// ============================================================
//  widgets/breakdown_chart.dart
//  Кругова діаграма розподілу платежів / доходності
// ============================================================

import 'package:flutter/material.dart';
import '../utils/formatters.dart';

class BreakdownChart extends StatelessWidget {
  final double value1;
  final double value2;
  final String label1;
  final String label2;
  final Color color1;
  final Color color2;

  const BreakdownChart({
    super.key,
    required this.value1,
    required this.value2,
    required this.label1,
    required this.label2,
    required this.color1,
    required this.color2,
  });

  @override
  Widget build(BuildContext context) {
    final total = value1 + value2;
    final p1 = total == 0 ? 0.0 : value1 / total;
    final p2 = total == 0 ? 0.0 : value2 / total;

    return Row(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: CustomPaint(
            painter: _PiePainter(
              fraction1: p1,
              color1: color1,
              color2: color2,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _LegendItem(
                color: color1,
                label: label1,
                value: Formatters.currency(value1),
                percent: '${(p1 * 100).toStringAsFixed(1)} %',
              ),
              const SizedBox(height: 8),
              _LegendItem(
                color: color2,
                label: label2,
                value: Formatters.currency(value2),
                percent: '${(p2 * 100).toStringAsFixed(1)} %',
              ),
              const Divider(height: 16),
              _LegendItem(
                color: Colors.grey.shade400,
                label: 'Разом',
                value: Formatters.currency(total),
                percent: '100 %',
                bold: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PiePainter extends CustomPainter {
  final double fraction1;
  final Color color1;
  final Color color2;

  _PiePainter({
    required this.fraction1,
    required this.color1,
    required this.color2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const startAngle = -3.14159 / 2; // -90°
    final sweepAngle1 = 2 * 3.14159 * fraction1;
    final sweepAngle2 = 2 * 3.14159 * (1 - fraction1);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.butt;

    paint.color = color2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + sweepAngle1,
      sweepAngle2,
      false,
      paint,
    );

    paint.color = color1;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle1,
      false,
      paint,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(fraction1 * 100).toStringAsFixed(0)}%',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: color1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(_PiePainter oldDelegate) =>
      oldDelegate.fraction1 != fraction1;
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final String percent;
  final bool bold;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.percent,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            Text(
              percent,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
