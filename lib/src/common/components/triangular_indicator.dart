import 'package:flutter/material.dart';

class TriangleCircleIndicator extends StatelessWidget {
  final double size;
  final Color triangleColor;
  final Color circleColor;

  const TriangleCircleIndicator({
    super.key,
    this.size = 12.0,
    this.triangleColor = Colors.green,
    this.circleColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: TriangleCirclePainter(
        triangleColor: triangleColor,
        circleColor: circleColor,
      ),
    );
  }
}

class TriangleCirclePainter extends CustomPainter {
  final Color triangleColor;
  final Color circleColor;

  TriangleCirclePainter({
    required this.triangleColor,
    required this.circleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw the downward-facing triangle
    final path = Path();
    path.moveTo(size.width / 2, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.close();

    paint.color = triangleColor;
    canvas.drawPath(path, paint);

    // Draw the circle inside the triangle
    final circleRadius = size.width / 4;
    final circleCenter = Offset(size.width / 2, size.height / 2);
    paint.color = circleColor;
    canvas.drawCircle(circleCenter, circleRadius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
