// widgets/character_image.dart
import 'package:flutter/material.dart';

class CharacterImage extends StatelessWidget {
  final String imagePath;
  final double size;
  final String? fallbackEmoji;
  final Color? borderColor;
  final double borderWidth;

  const CharacterImage({
    super.key,
    required this.imagePath,
    this.size = 50,
    this.fallbackEmoji,
    this.borderColor,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {
            debugPrint('Error loading image: $imagePath - $exception');
          },
        ),
      ),
      child: fallbackEmoji != null
          ? Center(
              child: Text(
                fallbackEmoji!,
                style: TextStyle(fontSize: size * 0.5),
              ),
            )
          : null,
    );
  }
}
