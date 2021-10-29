import 'package:flutter/material.dart';
import "dart:math" show pi, cos, sin;
import "dart:ui" as ui;

import 'image_painter.dart';
import 'resource_loader.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'PlaceDrawerPage',
      home: PlaceDrawerPage(),
    );
  }
}

class PlaceDrawerPage extends StatefulWidget {
  const PlaceDrawerPage({Key? key}) : super(key: key);
  @override
  State<PlaceDrawerPage> createState() => _PlaceDrawerPageState();
}

class _PlaceDrawerPageState extends State<PlaceDrawerPage> {
  late Future<ui.Image> _image;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    _image = ResourceLoader().loadImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PlaceDrawerPage"),
      ),
      body: FittedBox(
          child: SizedBox(
              child: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(100.0),
        minScale: 0.1,
        maxScale: 1000,
        child: Container(
            width: 1000,
            height: 1000,
            color: Colors.green,
            child: Stack(children: [
              CustomPaint(painter: MyPainter(), child: Container()),
              FutureBuilder(
                  future: _image,
                  builder:
                      (BuildContext context, AsyncSnapshot<ui.Image> image) {
                    return CustomPaint(
                        painter: ImagePainter(image.data!), child: Container());
                  })
            ])),
      ))),
    );
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.teal
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    var path = Path();
    var radius = 100;
    var side = 4;
    var angle = (pi * 2) / side;

    Offset center = Offset(size.width / 2, size.height / 2);

    // startPoint => (100.0, 0.0)
    Offset startPoint = Offset(radius * cos(0.0), radius * sin(0.0));

    path.moveTo(startPoint.dx + center.dx, startPoint.dy + center.dy);

    for (int i = 1; i <= side; i++) {
      double x = radius * cos(angle * i) + center.dx;
      double y = radius * sin(angle * i) + center.dy;
      path.lineTo(x, y);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
