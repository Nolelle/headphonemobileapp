import 'package:flutter/material.dart';
import 'dart:math' as math;

class Audiogram extends StatelessWidget {
  final Map<String, double> leftEarData;
  final Map<String, double> rightEarData;
  final String leftEarLabel;
  final String rightEarLabel;
  final String frequencyLabel;
  final String hearingLevelLabel;
  final String normalHearingLabel;
  final String mildLossLabel;
  final String moderateLossLabel;
  final String severeLossLabel;
  final String profoundLossLabel;

  const Audiogram({
    super.key,
    required this.leftEarData,
    required this.rightEarData,
    this.leftEarLabel = 'Left Ear',
    this.rightEarLabel = 'Right Ear',
    this.frequencyLabel = 'Frequency (Hz)',
    this.hearingLevelLabel = 'Hearing Level (dB)',
    this.normalHearingLabel = 'Normal',
    this.mildLossLabel = 'Mild',
    this.moderateLossLabel = 'Moderate',
    this.severeLossLabel = 'Severe',
    this.profoundLossLabel = 'Profound',
  });

  @override
  Widget build(BuildContext context) {
    // Get device screen size for better responsiveness
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen =
        screenSize.width < 360; // Adjust for small screens like MI A2

    final theme = Theme.of(context); // Get the current theme
    final isDarkMode = theme.brightness == Brightness.dark;

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
                      Text('$leftEarLabel ',
                          style: TextStyle(
                              fontSize: fontSize,
                              color: theme.textTheme.bodyMedium?.color)),
                      CustomPaint(
                        size: Size(fontSize * 1.3, fontSize * 1.3),
                        painter:
                            SymbolPainter(isX: true, color: theme.primaryColor),
                      ),
                    ],
                  ),
                  SizedBox(width: fontSize * 2),
                  Row(
                    children: [
                      Text('$rightEarLabel ',
                          style: TextStyle(
                              fontSize: fontSize,
                              color: theme.textTheme.bodyMedium?.color)),
                      CustomPaint(
                        size: Size(fontSize * 1.3, fontSize * 1.3),
                        painter: SymbolPainter(
                            isX: false, color: theme.colorScheme.error),
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
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.dividerColor),
              ),
              child: CustomPaint(
                size: Size(availableWidth - (padding * 2),
                    graphHeight - (padding * 2)),
                painter: AudiogramPainter(
                  theme: theme,
                  leftEarData: leftEarData,
                  rightEarData: rightEarData,
                  scaleFactor: availableWidth / 400,
                  isSmallScreen: isSmallScreen,
                  hearingLevelLabel: hearingLevelLabel,
                  normalHearingLabel: normalHearingLabel,
                  mildLossLabel: mildLossLabel,
                  moderateLossLabel: moderateLossLabel,
                  severeLossLabel: severeLossLabel,
                  profoundLossLabel: profoundLossLabel,
                ),
              ),
            ),
            // X-Axis Legend (Frequency)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                frequencyLabel,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyMedium?.color,
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
                  _buildHearingLossIndicator(theme, normalHearingLabel,
                      _getHearingLossColor(theme, 0), fontSize * 0.85),
                  _buildHearingLossIndicator(theme, mildLossLabel,
                      _getHearingLossColor(theme, 1), fontSize * 0.85),
                  _buildHearingLossIndicator(theme, moderateLossLabel,
                      _getHearingLossColor(theme, 2), fontSize * 0.85),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildHearingLossIndicator(theme, severeLossLabel,
                      _getHearingLossColor(theme, 3), fontSize * 0.85),
                  _buildHearingLossIndicator(theme, profoundLossLabel,
                      _getHearingLossColor(theme, 4), fontSize * 0.85),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getHearingLossColor(ThemeData theme, int level) {
    final bool isDarkMode = theme.brightness == Brightness.dark;
    // Use shades of grey in dark mode, and subtle blues in light mode
    // Base color is slightly lighter/darker than card color for contrast
    final baseColor = isDarkMode
        ? HSLColor.fromColor(theme.cardColor).withLightness(0.15).toColor()
        : HSLColor.fromColor(theme.cardColor).withLightness(0.95).toColor();
    final endColor = isDarkMode
        ? HSLColor.fromColor(theme.primaryColor).withLightness(0.3).toColor()
        : HSLColor.fromColor(theme.primaryColor).withLightness(0.8).toColor();

    // Interpolate between base and end color based on level
    return Color.lerp(baseColor, endColor, level / 4.0) ?? baseColor;
  }

  Widget _buildHearingLossIndicator(
    ThemeData theme,
    String label,
    Color color,
    double fontSize,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: fontSize,
          height: fontSize,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: theme.dividerColor),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: fontSize, color: theme.textTheme.bodySmall?.color)),
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
  final ThemeData theme;
  final Map<String, double> leftEarData;
  final Map<String, double> rightEarData;
  final double scaleFactor;
  final bool isSmallScreen;
  final String hearingLevelLabel;
  final String normalHearingLabel;
  final String mildLossLabel;
  final String moderateLossLabel;
  final String severeLossLabel;
  final String profoundLossLabel;

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
    required this.theme,
    required this.leftEarData,
    required this.rightEarData,
    required this.scaleFactor,
    this.isSmallScreen = false,
    required this.hearingLevelLabel,
    required this.normalHearingLabel,
    required this.mildLossLabel,
    required this.moderateLossLabel,
    required this.severeLossLabel,
    required this.profoundLossLabel,
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

    final gridPaint = Paint()
      ..color = theme.dividerColor
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
    _drawGrid(canvas, graphRect, gridPaint);

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
    _drawDataPoints(canvas, graphRect);

    canvas.restore();
  }

  void _drawYAxisLegend(Canvas canvas, Size size, double leftPadding) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: "$hearingLevelLabel (dB HL)", // Using proper format "dB HL"
        style: TextStyle(
          color: theme.textTheme.bodyMedium?.color,
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
      (_getHearingLossColor(theme, 0), 120.0, 100.0, normalHearingLabel),
      (_getHearingLossColor(theme, 1), 100.0, 80.0, mildLossLabel),
      (_getHearingLossColor(theme, 2), 80.0, 50.0, moderateLossLabel),
      (_getHearingLossColor(theme, 3), 50.0, 30.0, severeLossLabel),
      (_getHearingLossColor(theme, 4), 30.0, 0.0, profoundLossLabel),
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
            color: theme.textTheme.bodySmall?.color,
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

  void _drawGrid(Canvas canvas, Rect graphRect, Paint gridPaint) {
    // Draw vertical lines
    final xStep = graphRect.width / (frequencies.length - 1);
    for (var i = 0; i < frequencies.length; i++) {
      final x = graphRect.left + (i * xStep);
      canvas.drawLine(
        Offset(x, graphRect.top),
        Offset(x, graphRect.bottom),
        gridPaint,
      );
    }

    // Draw horizontal lines
    for (var db in dbLevels) {
      final y = _getYPosition(db.toDouble(), graphRect);
      canvas.drawLine(
        Offset(graphRect.left, y),
        Offset(graphRect.right, y),
        gridPaint,
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
          color: theme.textTheme.bodyMedium?.color,
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
          color: theme.textTheme.bodyMedium?.color,
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

  void _drawDataPoints(Canvas canvas, Rect graphRect) {
    // Draw left ear points (X)
    final leftPaint = Paint()
      ..color = theme.primaryColor
      ..strokeWidth = 1.5 * scaleFactor
      ..style = PaintingStyle.stroke;
    _drawEarPoints(canvas, graphRect, leftEarData, true, leftPaint);

    // Draw right ear points (O)
    final rightPaint = Paint()
      ..color = theme.colorScheme.error
      ..strokeWidth = 1.5 * scaleFactor
      ..style = PaintingStyle.stroke;
    _drawEarPoints(canvas, graphRect, rightEarData, false, rightPaint);
  }

  void _drawEarPoints(Canvas canvas, Rect graphRect, Map<String, double> data,
      bool isLeft, Paint paint) {
    final points = <Offset>[];

    // Frequency positions with internal padding to keep 250Hz and 4000Hz away from edges
    final graphWidth = graphRect.width;
    final edgePadding = graphWidth *
        (isSmallScreen ? 0.1 : 0.08); // More padding for small screens
    final effectiveWidth = graphWidth - (edgePadding * 2);
    final xStep = effectiveWidth / (frequencies.length - 1);

    final markerSize = 4.0 * scaleFactor * (isSmallScreen ? 0.9 : 1.0);
    final linePaint = Paint()
      ..color = paint.color
      ..strokeWidth = 1.0 * scaleFactor
      ..style = PaintingStyle.stroke;

    Offset? lastPoint;

    for (var i = 0; i < frequencies.length; i++) {
      final freq = frequencies[i];
      final value = data['${isLeft ? "L" : "R"}_user_${freq}Hz_dB'] ?? 0.0;

      // Calculate x position with edge padding
      final x = graphRect.left + edgePadding + (i * xStep);
      final y = _getYPosition(value.abs(), graphRect);
      final currentPoint = Offset(x, y);
      points.add(currentPoint);

      // Draw line between points if last point exists
      if (lastPoint != null) {
        canvas.drawLine(lastPoint, currentPoint, linePaint);
      }
      lastPoint = currentPoint;
    }

    // Draw the markers after drawing lines
    for (final point in points) {
      if (isLeft) {
        // Draw X
        final halfMarker = markerSize / 2;
        canvas.drawLine(Offset(point.dx - halfMarker, point.dy - halfMarker),
            Offset(point.dx + halfMarker, point.dy + halfMarker), paint);
        canvas.drawLine(Offset(point.dx + halfMarker, point.dy - halfMarker),
            Offset(point.dx - halfMarker, point.dy + halfMarker), paint);
      } else {
        // Draw O
        canvas.drawCircle(point, markerSize, paint);
      }
    }
  }

  double _getYPosition(double dbValue, Rect graphRect) {
    // Ensure dbValue is within the expected range [-10, 120]
    final clampedDb = dbValue.clamp(-10.0, 120.0);
    // Normalize the value to a 0-1 range (inverted because y-axis increases downwards)
    final normalized = (clampedDb - (-10)) / (120 - (-10));
    // Map the normalized value to the graph's height
    return graphRect.top + (graphRect.height * (1 - normalized));
  }

  @override
  bool shouldRepaint(covariant AudiogramPainter oldDelegate) {
    // Repaint if theme, data, or dimensions change
    return oldDelegate.theme != theme ||
        oldDelegate.leftEarData != leftEarData ||
        oldDelegate.rightEarData != rightEarData ||
        oldDelegate.scaleFactor != scaleFactor ||
        oldDelegate.isSmallScreen != isSmallScreen;
  }

  Color _getHearingLossColor(ThemeData theme, int level) {
    final bool isDarkMode = theme.brightness == Brightness.dark;
    // Use shades based on card/background color and primary color
    final baseColor = isDarkMode
        ? HSLColor.fromColor(theme.cardColor).withLightness(0.15).toColor()
        : HSLColor.fromColor(theme.cardColor).withLightness(0.95).toColor();
    final endColor = isDarkMode
        ? HSLColor.fromColor(theme.primaryColor).withLightness(0.3).toColor()
        : HSLColor.fromColor(theme.primaryColor).withLightness(0.8).toColor();

    // Interpolate between base and end color based on level
    return Color.lerp(baseColor, endColor, level / 4.0) ?? baseColor;
  }
}
