import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WheelScreen(),
    );
  }
}

class WheelScreen extends StatefulWidget {
  const WheelScreen({super.key});

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  double _angle = 0;
  double _startAngle = 0;
  int _result = 1;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        setState(() {
          _angle = _controller.value;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          _calculateResult();
        }
      });
  }

  void _onPanStart(DragStartDetails details) {
    _controller.stop();
    _startAngle = _angle;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _angle += details.delta.dx * 0.01;
    });
  }
void _onPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;

    // Force LOTS of spinning
    final spinPower = velocity * 0.02;
    final extraSpins = (Random().nextInt(6) + 6) * 2 * pi;

    final double targetAngle = _angle + spinPower + extraSpins;

    _controller
      ..stop()
      ..animateTo(
        targetAngle,
        duration: const Duration(seconds: 4),
        curve: Curves.easeOutQuart,
      ).then((_) {
        // Fix final angle after animation
        setState(() {
          _angle = targetAngle;
        });
        _calculateResult();
      });
  }


void _calculateResult() {
    const int totalSlices = 6;
    final double sliceAngle = 2 * pi / totalSlices;

    // Normalize angle to 0 → 2π
    double normalizedAngle = (_angle % (2 * pi) + 2 * pi) % (2 * pi);

    // Because slice 1 starts at UP and arrow is UP
    double arrowAngle = (2 * pi - normalizedAngle) % (2 * pi);

    int index = (arrowAngle / sliceAngle).floor();

    setState(() {
      _result = index + 1;
    });
  }



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Grab & Spin Wheel"), centerTitle: true),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.arrow_drop_down, size: 50),

          GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: Transform.rotate(
              angle: _angle,
              child: SizedBox(
                width: 280,
                height: 280,
                child: CustomPaint(painter: WheelPainter()),
              ),
            ),
          ),

          const SizedBox(height: 30),

          Text(
            "Result: ${_result}",
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),
          const Text("Grab and flick hard to spin"),
        ],
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final paint = Paint()..style = PaintingStyle.fill;

    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    double startAngle = -pi / 2;
    final sweep = 2 * pi / 6;

    for (int i = 0; i < 6; i++) {
      paint.color = colors[i];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        true,
        paint,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final angle = startAngle + sweep / 2;
      final offset = Offset(
        center.dx + cos(angle) * radius * 0.65 - textPainter.width / 2,
        center.dy + sin(angle) * radius * 0.65 - textPainter.height / 2,
      );

      textPainter.paint(canvas, offset);

      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
