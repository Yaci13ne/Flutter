import 'package:flutter/material.dart';

class MyTextButton extends StatelessWidget {
  
  final String buttonLabel;
  final Function() onPressedFct;

  
  
  
  const MyTextButton({super.key,required this.buttonLabel, required this.onPressedFct});



  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressedFct,
      child : Text(buttonLabel,style: TextStyle(
        )
      ));

  }
}

class MyElevatedButton extends StatelessWidget {

  final String buttonLabel;
  final Function() onPressedFct;



  const MyElevatedButton({super.key,required this.buttonLabel, required this.onPressedFct});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10,
      width : 10,

      child: ElevatedButton(onPressed: onPressedFct , child: Text(buttonLabel),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.orange,
      side : BorderSide(),
      shape : RoundedRectangleBorder(),
      padding: EdgeInsets.all(8),
      textStyle: TextStyle()

      
      
      
      
      
      ),


      
      )




    );
  }
}