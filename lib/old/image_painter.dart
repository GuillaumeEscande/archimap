import 'package:flutter/material.dart';
import "dart:ui" as ui;

class ImagePainter extends CustomPainter {
  ui.Image image;

  ImagePainter(this.image) : super();

  @override
  Future paint(Canvas canvas, Size size) async {
    Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawImage(image, center, Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return image != (oldDelegate as ImagePainter).image;
  }

  @override
  bool hitTest(Offset position) {
    const Offset center = Offset(100, 100);
    Path path = Path();
    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 200, height: 200),
        Radius.circular(center.dx)));
    path.close();
    return path.contains(position);
  }
}
