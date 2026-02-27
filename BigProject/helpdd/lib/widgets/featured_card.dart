import 'package:flutter/material.dart';

class FeaturedCard extends StatelessWidget {
  final VoidCallback? onTap;
  const FeaturedCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF4B4FD9), Color(0xFF7B5CFF), Color(0xFF8B6FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B5FEF).withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            right: 80,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: const Text(
                    'FEATURED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'AI Image Upscaler',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enhance your photos instantly with our\npowerful neural network. Restore clarity up\nto 4K resolution.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Try Now →',
                      style: TextStyle(
                        color: Color(0xFF4B4FD9),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomPaint(painter: _ShellPainter()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShellPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2A2060), Color(0xFF1A1040)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    final p1 = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF9A4A), Color(0xFFE8622A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.15)
      ..cubicTo(
        size.width * 0.8,
        size.height * 0.1,
        size.width * 0.9,
        size.height * 0.4,
        size.width * 0.75,
        size.height * 0.65,
      )
      ..cubicTo(
        size.width * 0.6,
        size.height * 0.9,
        size.width * 0.3,
        size.height * 0.85,
        size.width * 0.2,
        size.height * 0.7,
      )
      ..cubicTo(
        size.width * 0.1,
        size.height * 0.55,
        size.width * 0.2,
        size.height * 0.3,
        size.width * 0.5,
        size.height * 0.15,
      )
      ..close();
    canvas.drawPath(path, p1);

    final p2 = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFCA80), Color(0xFFFF8C42)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path2 = Path()
      ..moveTo(size.width * 0.5, size.height * 0.25)
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.2,
        size.width * 0.78,
        size.height * 0.45,
        size.width * 0.65,
        size.height * 0.65,
      )
      ..cubicTo(
        size.width * 0.52,
        size.height * 0.82,
        size.width * 0.32,
        size.height * 0.75,
        size.width * 0.27,
        size.height * 0.6,
      )
      ..cubicTo(
        size.width * 0.2,
        size.height * 0.45,
        size.width * 0.28,
        size.height * 0.3,
        size.width * 0.5,
        size.height * 0.25,
      )
      ..close();
    canvas.drawPath(path2, p2);

    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.25),
      2.5,
      dotPaint,
    );
    dotPaint.color = Colors.white.withOpacity(0.5);
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.45),
      1.5,
      dotPaint,
    );
    dotPaint.color = Colors.orangeAccent.withOpacity(0.8);
    canvas.drawCircle(
      Offset(size.width * 0.55, size.height * 0.18),
      1.5,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
