import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final String  TFHintText;
  final Icon TFIcon;
  final TextEditingController TFController; 
  final bool isObscure;
  final String ? Function(String ? ) ? TFValidator;



  const MyTextfield({super.key,required this.TFHintText, required this.TFIcon, required this.TFController, this.isObscure = false, this.TFValidator });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: TFValidator,

      controller: TFController,
      obscureText: isObscure,
      decoration: InputDecoration(
        hintText: TFHintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))
      
        ),

        filled: true,
        prefixIcon: TFIcon
      ),
    );
  }
}