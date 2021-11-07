import 'dart:ui';
import 'package:flutter/material.dart' hide TextStyle;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const InfiniteCanvasPage(),
    );
  }
}

enum CanvasState { pan, draw }

class InfiniteCanvasPage extends StatefulWidget {
  const InfiniteCanvasPage({Key? key}) : super(key: key);

  @override
  _InfiniteCanvasPageState createState() => _InfiniteCanvasPageState();
}

class _InfiniteCanvasPageState extends State<InfiniteCanvasPage> {
  List<Offset> points = [];
  CanvasState canvasState = CanvasState.draw;
  Offset lastOffset = const Offset(0, 0);
  Offset offset = Offset.infinite;
  double lastScale = 1;
  double scale = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Text(canvasState == CanvasState.draw ? "Draw" : "Pan"),
        backgroundColor:
            canvasState == CanvasState.draw ? Colors.red : Colors.blue,
        onPressed: () {
          setState(() {
            canvasState = canvasState == CanvasState.draw
                ? CanvasState.pan
                : CanvasState.draw;
          });
        },
      ),
      body: GestureDetector(
        onScaleStart: (scaleDetails) {
          setState(() {
            if (canvasState == CanvasState.draw) {
              points.add(offset -
                  (scaleDetails.focalPoint -
                          Offset(context.size!.width / 2.0,
                              context.size!.height / 2.0)) *
                      scale);
            }
            scale = lastScale;
            offset = lastOffset;
          });
        },
        onScaleUpdate: (scaleDetails) {
          setState(() {
            if (canvasState == CanvasState.pan) {
              if (scaleDetails.scale != 1) {
                scale = lastScale * scaleDetails.scale;
              } else {
                offset = lastOffset + scaleDetails.delta / scale;
              }
            } else {
              points.add(offset -
                  (scaleDetails.focalPoint -
                          Offset(context.size!.width / 2.0,
                              context.size!.height / 2.0)) /
                      scale);
            }
          });
        },
        onScaleEnd: (detaiscaleDetailsls) {
          setState(() {
            if (canvasState == CanvasState.draw) {
              points.add(Offset.infinite);
            }
            lastScale = scale;
            lastOffset = offset;
          });
        },
        child: SizedBox.expand(
          child: ClipRRect(
            child: CustomPaint(
              painter: CanvasCustomPainter(
                  points: points, offset: offset, scale: scale),
            ),
          ),
        ),
      ),
    );
  }
}

class CanvasCustomPainter extends CustomPainter {
  List<Offset> points;
  Offset offset;
  double scale;

  CanvasCustomPainter(
      {required this.points, required this.offset, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    //define canvas background color
    Paint background = Paint()..color = Colors.white;

    //define canvas size
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawRect(rect, background);
    canvas.clipRect(rect);

    //define the paint properties to be used for drawing
    Paint drawingPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = Colors.black
      ..strokeWidth = 1.5;

    //a single line is defined as a series of points followed by a null at the end
    for (int x = 0; x < points.length - 1; x++) {
      //drawing line between the points to form a continuous line
      if (points[x] != Offset.infinite && points[x + 1] != Offset.infinite) {
        canvas.drawLine(
            (points[x] + offset).scale(scale, scale) +
                Offset(size.width / 2.0, size.height / 2.0),
            (points[x + 1] + offset).scale(scale, scale) +
                Offset(size.width / 2.0, size.height / 2.0),
            drawingPaint);
      }
      //if next point is null, means the line ends here
      else if (points[x] != Offset.infinite &&
          points[x + 1] == Offset.infinite) {
        canvas.drawPoints(
            PointMode.points,
            [
              (points[x] + offset).scale(scale, scale) +
                  Offset(size.width / 2.0, size.height / 2.0)
            ],
            drawingPaint);
      }

      // draw text
      ParagraphStyle paragraphStyle = ParagraphStyle(textAlign: TextAlign.left);
      ParagraphBuilder paragraphBuilder = ParagraphBuilder(paragraphStyle)
        ..pushStyle(TextStyle(color: Colors.black))
        ..addText(offset.toString());
      Paragraph paragraph = paragraphBuilder.build()
        ..layout(const ParagraphConstraints(width: 200));
      canvas.drawParagraph(paragraph, const Offset(10, 40));

      paragraphBuilder = ParagraphBuilder(paragraphStyle)
        ..pushStyle(TextStyle(color: Colors.black))
        ..addText(scale.toString());
      paragraph = paragraphBuilder.build()
        ..layout(const ParagraphConstraints(width: 200));
      canvas.drawParagraph(paragraph, const Offset(10, 60));
    }
  }

  @override
  bool shouldRepaint(CanvasCustomPainter oldDelegate) {
    return true;
  }
}
