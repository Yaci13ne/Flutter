import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerScreen extends StatefulWidget {
  const ColorPickerScreen({super.key});

  @override
  State<ColorPickerScreen> createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<ColorPickerScreen> {
  Color selectedColor = Colors.blue;

  void changeColor(Color color) {
    setState(() => selectedColor = color);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Color Picker Tool"),
      ),
      body: Column(
        children: [
          /// Preview Area
          Expanded(
            child: Container(
              width: double.infinity,
              color: selectedColor,
              child: Center(
                child: Text(
                  "Preview Color",
                  style: TextStyle(
                    fontSize: 22,
                    color: selectedColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ),

          /// Picker
          ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: changeColor,
            enableAlpha: true,
            displayThumbColor: true,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
