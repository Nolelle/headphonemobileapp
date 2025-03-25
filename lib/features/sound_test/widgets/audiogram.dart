import 'package:flutter/material.dart';
import 'dart:math' as math;

class Audiogram extends StatelessWidget {
  final Map<String, double> leftEarData;
  final Map<String, double> rightEarData;

  const Audiogram({
    super.key,
    required this.leftEarData,
    required this.rightEarData,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final graphHeight =
            availableWidth * 1.1; // Increased height for better spacing
        final padding = availableWidth * 0.02;

        return Column(
          children: [
            // Legend
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Text('Left Ear ', style: TextStyle(fontSize: 12)),
                      CustomPaint(
                        size: const Size(16, 16),
                        painter: SymbolPainter(isX: true, color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Row(
                    children: [
                      const Text('Right Ear ', style: TextStyle(fontSize: 12)),
                      CustomPaint(
                        size: const Size(16, 16),
                        painter: SymbolPainter(isX: false, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: availableWidth,
              height: graphHeight,
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: CustomPaint(
                size: Size(availableWidth - (padding * 2),
                    graphHeight - (padding * 2)),
                painter: AudiogramPainter(
                  leftEarData: leftEarData,
                  rightEarData: rightEarData,
                  scaleFactor: availableWidth / 400,
                ),
              ),
            ),
            // Hearing Loss Legend
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildHearingLossIndicator('Normal', Colors.white),
                  _buildHearingLossIndicator('Mild', Colors.blue[50]!),
                  _buildHearingLossIndicator('Moderate', Colors.blue[100]!),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildHearingLossIndicator('Severe', Colors.blue[200]!),
                  _buildHearingLossIndicator('Profound', Colors.blue[300]!),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHearingLossIndicator(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.grey[300]!),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}

class SymbolPainter extends CustomPainter {
  final bool isX;
  final Color color;

  SymbolPainter({required this.isX, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (isX) {
      canvas.drawLine(
        Offset(size.width * 0.2, size.height * 0.2),
        Offset(size.width * 0.8, size.height * 0.8),
        paint,
      );
      canvas.drawLine(
        Offset(size.width * 0.8, size.height * 0.2),
        Offset(size.width * 0.2, size.height * 0.8),
        paint,
      );
    } else {
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.width * 0.3,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AudiogramPainter extends CustomPainter {
  final Map<String, double> leftEarData;
  final Map<String, double> rightEarData;
  final double scaleFactor;

  static const List<String> frequencies = [
    '250',
    '500',
    '1000',
    '2000',
    '4000'
  ];
  static const List<int> dbLevels = [
    -10,
    0,
    10,
    20,
    30,
    40,
    50,
    60,
    70,
    80,
    90,
    100,
    110,
    120
  ];

  AudiogramPainter({
    required this.leftEarData,
    required this.rightEarData,
    required this.scaleFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Add padding for labels
    final graphPadding = size.width * 0.1;
    final graphRect = Rect.fromLTWH(
      graphPadding, // Left padding for dB labels
      0, // Top
      size.width - graphPadding, // Width minus left padding
      size.height -
          graphPadding, // Height minus bottom padding for frequency labels
    );

    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 0.5 // Thinner lines
      ..style = PaintingStyle.stroke;

    // Save canvas state and clip to graph area
    canvas.save();
    canvas.clipRect(graphRect);

    // Draw background regions in clipped area
    _drawHearingLossRegions(canvas, graphRect);

    // Draw grid
    _drawGrid(canvas, graphRect, paint);

    canvas.restore();

    // Draw axes labels outside clipped area
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    _drawAxesLabels(canvas, graphRect, textPainter);

    // Save canvas again for data points
    canvas.save();
    canvas.clipRect(graphRect);

    // Draw data points and lines
    _drawDataPoints(canvas, graphRect, paint);

    canvas.restore();
  }

  void _drawHearingLossRegions(Canvas canvas, Rect graphRect) {
    final regions = [
      (Colors.white, 120.0, 100.0, 'Normal Hearing'),
      (Colors.blue[50]!, 100.0, 80.0, 'Mild Loss'),
      (Colors.blue[100]!, 80.0, 50.0, 'Moderate Loss'),
      (Colors.blue[200]!, 50.0, 30.0, 'Severe Loss'),
      (Colors.blue[300]!, 30.0, 0.0, 'Profound Loss'),
    ];

    for (var region in regions) {
      final paint = Paint()
        ..color = region.$1
        ..style = PaintingStyle.fill;

      final top = _getYPosition(region.$2, graphRect);
      final bottom = _getYPosition(region.$3, graphRect);

      canvas.drawRect(
        Rect.fromLTWH(graphRect.left, top, graphRect.width, bottom - top),
        paint,
      );

      // Draw the hearing loss text
      final textPainter = TextPainter(
        text: TextSpan(
          text: region.$4,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 8 * scaleFactor,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          graphRect.left + 4,
          (top + bottom) / 2 - textPainter.height / 2,
        ),
      );
    }
  }

  void _drawGrid(Canvas canvas, Rect graphRect, Paint paint) {
    // Draw vertical lines
    final xStep = graphRect.width / (frequencies.length - 1);
    for (var i = 0; i < frequencies.length; i++) {
      final x = graphRect.left + (i * xStep);
      canvas.drawLine(
        Offset(x, graphRect.top),
        Offset(x, graphRect.bottom),
        paint,
      );
    }

    // Draw horizontal lines
    for (var db in dbLevels) {
      final y = _getYPosition(db.toDouble(), graphRect);
      canvas.drawLine(
        Offset(graphRect.left, y),
        Offset(graphRect.right, y),
        paint,
      );
    }
  }

  void _drawAxesLabels(Canvas canvas, Rect graphRect, TextPainter textPainter) {
    final fontSize = 10.0 * scaleFactor;

    // Draw frequency labels
    final xStep = graphRect.width / (frequencies.length - 1);
    for (var i = 0; i < frequencies.length; i++) {
      textPainter.text = TextSpan(
        text: frequencies[i],
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          graphRect.left + (i * xStep) - (textPainter.width / 2),
          graphRect.bottom + 2,
        ),
      );
    }

    // Draw dB labels
    for (var db in dbLevels) {
      textPainter.text = TextSpan(
        text: db.toString(),
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          0,
          _getYPosition(db.toDouble(), graphRect) - (textPainter.height / 2),
        ),
      );
    }
  }

  void _drawDataPoints(Canvas canvas, Rect graphRect, Paint paint) {
    // Draw left ear points (X)
    paint.color = Colors.blue;
    _drawEarPoints(canvas, graphRect, leftEarData, true);

    // Draw right ear points (O)
    paint.color = Colors.red;
    _drawEarPoints(canvas, graphRect, rightEarData, false);
  }

  void _drawEarPoints(
      Canvas canvas, Rect graphRect, Map<String, double> data, bool isLeft) {
    final points = <Offset>[];
    final xStep = graphRect.width / (frequencies.length - 1);
    final markerSize = 4.0 * scaleFactor;

    for (var i = 0; i < frequencies.length; i++) {
      final freq = frequencies[i];
      final value = data['${isLeft ? "L" : "R"}_user_${freq}Hz_dB'] ?? 0.0;
      final x = graphRect.left + (i * xStep);
      final y = _getYPosition(value.abs(), graphRect);
      points.add(Offset(x, y));

      if (isLeft) {
        _drawX(canvas, Offset(x, y), markerSize, Colors.blue);
      } else {
        _drawO(canvas, Offset(x, y), markerSize, Colors.red);
      }
    }

    // Draw lines connecting points
    final linePaint = Paint()
      ..color = isLeft ? Colors.blue : Colors.red
      ..strokeWidth = 1.0 * scaleFactor
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], linePaint);
    }
  }

  void _drawX(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0 * scaleFactor
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(center.dx - size, center.dy - size),
      Offset(center.dx + size, center.dy + size),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + size, center.dy - size),
      Offset(center.dx - size, center.dy + size),
      paint,
    );
  }

  void _drawO(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0 * scaleFactor
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, paint);
  }

  double _getYPosition(double db, Rect graphRect) {
    // Invert the Y-axis mapping: Higher dB = lower on graph (better hearing)
    return graphRect.top + (graphRect.height * (130 - db) / 130);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
