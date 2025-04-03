/*
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DashedLineOverlay extends StatelessWidget {
  final LatLng start;
  final LatLng end;
  final GlobalKey mapKey; // No type parameter here.
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  const DashedLineOverlay({
    Key? key,
    required this.start,
    required this.end,
    required this.mapKey,
    this.color = Colors.black,
    this.strokeWidth = 2,
    this.dashLength = 5,
    this.gapLength = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to obtain the available size.
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: DashedLinePainter(
            start: start,
            end: end,
            mapKey: mapKey,
            color: color,
            strokeWidth: strokeWidth,
            dashLength: dashLength,
            gapLength: gapLength,
          ),
        );
      },
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final LatLng start;
  final LatLng end;
  final GlobalKey mapKey;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  DashedLinePainter({
    required this.start,
    required this.end,
    required this.mapKey,
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Access the mapState by casting the currentState to dynamic.
    final mapState = (mapKey.currentState as dynamic)?.mapState;
    if (mapState == null) return;

    // Project the LatLng positions to screen coordinates.
    final startProjected = mapState.project(start);
    final endProjected = mapState.project(end);
    // Subtract the pixelOrigin to convert to screen offset.
    final startOffset = startProjected - mapState.pixelOrigin;
    final endOffset = endProjected - mapState.pixelOrigin;
    final startPoint = Offset(startOffset.x, startOffset.y);
    final endPoint = Offset(endOffset.x, endOffset.y);

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    final dx = endPoint.dx - startPoint.dx;
    final dy = endPoint.dy - startPoint.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final angle = math.atan2(dy, dx);

    double current = 0;
    while (current < distance) {
      final dashEnd = math.min(current + dashLength, distance);
      final x1 = startPoint.dx + current * math.cos(angle);
      final y1 = startPoint.dy + current * math.sin(angle);
      final x2 = startPoint.dx + dashEnd * math.cos(angle);
      final y2 = startPoint.dy + dashEnd * math.sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      current += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant DashedLinePainter oldDelegate) {
    return oldDelegate.start != start ||
        oldDelegate.end != end ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength;
  }
}
*/
