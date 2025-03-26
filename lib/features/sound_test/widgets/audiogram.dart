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
    // Get device screen size for better responsiveness
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen =
        screenSize.width < 360; // Adjust for small screens like MI A2

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        // Adjust height based on screen width with a minimum for small screens
        final graphHeight = isSmallScreen
            ? availableWidth * 1.2 // Taller for small screens
            : availableWidth * 1.1; // Standard height for larger screens

        final padding = availableWidth *
            (isSmallScreen ? 0.03 : 0.02); // More padding for small screens
        final fontSize =
            (availableWidth * 0.03).clamp(9.0, 14.0); // Responsive font size

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
                      Text('Left Ear ', style: TextStyle(fontSize: fontSize)),
                      CustomPaint(
                        size: Size(fontSize * 1.3, fontSize * 1.3),
                        painter: SymbolPainter(isX: true, color: Colors.blue),
                      ),
                    ],
                  ),
                  SizedBox(width: fontSize * 2),
                  Row(
                    children: [
                      Text('Right Ear ', style: TextStyle(fontSize: fontSize)),
                      CustomPaint(
                        size: Size(fontSize * 1.3, fontSize * 1.3),
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
                  isSmallScreen: isSmallScreen,
                ),
              ),
            ),
            // X-Axis Legend (Frequency)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Frequency (Hz)',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Hearing Loss Legend
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildHearingLossIndicator(
                      'Normal', Colors.white, fontSize * 0.85),
                  _buildHearingLossIndicator(
                      'Mild', Colors.blue[50]!, fontSize * 0.85),
                  _buildHearingLossIndicator(
                      'Moderate', Colors.blue[100]!, fontSize * 0.85),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildHearingLossIndicator(
                      'Severe', Colors.blue[200]!, fontSize * 0.85),
                  _buildHearingLossIndicator(
                      'Profound', Colors.blue[300]!, fontSize * 0.85),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHearingLossIndicator(
      String label, Color color, double fontSize) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: fontSize,
          height: fontSize,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.grey[300]!),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: fontSize)),
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
  final bool isSmallScreen;

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
    this.isSmallScreen = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Add padding for labels and edges
    final leftPadding = size.width *
        (isSmallScreen ? 0.18 : 0.15); // More padding for small screens
    final topPadding = size.height * 0.05;
    final bottomPadding = size.width *
        (isSmallScreen ? 0.15 : 0.12); // More bottom padding for small screens
    final rightPadding = size.width *
        (isSmallScreen ? 0.1 : 0.08); // More right padding for small screens

    final graphRect = Rect.fromLTWH(
      leftPadding, // Left padding for dB labels
      topPadding, // Top padding
      size.width -
          leftPadding -
          rightPadding, // Width minus left and right padding
      size.height -
          topPadding -
          bottomPadding, // Height minus top and bottom padding
    );

    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 0.5 // Thinner lines
      ..style = PaintingStyle.stroke;

    // Draw Y-Axis Legend (Hearing Level in dB)
    _drawYAxisLegend(canvas, size, leftPadding);

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

  void _drawYAxisLegend(Canvas canvas, Size size, double leftPadding) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Hearing Level (dB)',
        style: TextStyle(
          color: Colors.black,
          fontSize: 10 * scaleFactor * (isSmallScreen ? 0.9 : 1.0),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();

    // Position vertically centered and rotated 90 degrees
    canvas.save();
    canvas.translate(
        leftPadding * (isSmallScreen ? 0.25 : 0.3), size.height / 2);
    canvas.rotate(-math.pi / 2); // Rotate 90 degrees counter-clockwise
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
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
    final fontSize = 10.0 * scaleFactor * (isSmallScreen ? 0.9 : 1.0);

    // Calculate the same positions as the data points
    final graphWidth = graphRect.width;
    final edgePadding = graphWidth *
        (isSmallScreen ? 0.1 : 0.08); // More padding for small screens
    final effectiveWidth = graphWidth - (edgePadding * 2);
    final xStep = effectiveWidth / (frequencies.length - 1);

    // Draw frequency labels
    for (var i = 0; i < frequencies.length; i++) {
      // Append unit to frequency label for better readability
      String label = frequencies[i];
      if (label == '1000')
        label = '1k';
      else if (label == '2000')
        label = '2k';
      else if (label == '4000') label = '4k';

      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize,
        ),
      );
      textPainter.layout();

      // Calculate x position with edge padding, same as the data points
      final x = graphRect.left + edgePadding + (i * xStep);

      textPainter.paint(
        canvas,
        Offset(
          x - (textPainter.width / 2),
          graphRect.bottom + (isSmallScreen ? 5 : 4),
        ),
      );
    }

    // Draw dB labels
    for (var db in dbLevels) {
      // If small screen, show fewer dB labels to avoid overcrowding
      if (isSmallScreen && db % 20 != 0 && db != -10) continue;

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
          graphRect.left - textPainter.width - (isSmallScreen ? 3 : 4),
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

    // Frequency positions with internal padding to keep 250Hz and 4000Hz away from edges
    final graphWidth = graphRect.width;
    final edgePadding = graphWidth *
        (isSmallScreen ? 0.1 : 0.08); // More padding for small screens
    final effectiveWidth = graphWidth - (edgePadding * 2);
    final xStep = effectiveWidth / (frequencies.length - 1);

    final markerSize = 4.0 * scaleFactor * (isSmallScreen ? 0.9 : 1.0);

    for (var i = 0; i < frequencies.length; i++) {
      final freq = frequencies[i];
      final value = data['${isLeft ? "L" : "R"}_user_${freq}Hz_dB'] ?? 0.0;

      // Calculate x position with edge padding
      final x = graphRect.left + edgePadding + (i * xStep);
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
      ..strokeWidth = 1.0 * scaleFactor * (isSmallScreen ? 0.9 : 1.0)
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], linePaint);
    }
  }

  void _drawX(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0 * scaleFactor * (isSmallScreen ? 0.9 : 1.0)
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
      ..strokeWidth = 1.0 * scaleFactor * (isSmallScreen ? 0.9 : 1.0)
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
