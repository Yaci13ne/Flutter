import 'package:flutter/material.dart';

class WeekDaysCard extends StatelessWidget {
  
  final String day;

  
  const WeekDaysCard({super.key,required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 150,
      decoration: BoxDecoration(
        border : Border.all(color : Colors.black),
        color : Colors.amber,
        borderRadius: BorderRadius.all(Radius.circular(10))

      ),
      child: Column(
        children: [
          Expanded(child: Align(
            alignment: AlignmentGeometry.centerLeft,
            child: Text(day,style: TextStyle(


            ),),
          ),     
          ),
          SizedBox(height: 20),

          Expanded (
            child: Row(children: [
                IconButton(onPressed: (){}, icon: Icon(Icons.visibility),
                color : Colors.orange
                ),
                SizedBox(width:20),
                IconButton(onPressed:(){}, icon: Icon(Icons.add),
                color: Colors.black,
                )

          ],),)


        ],


      ),
    );
  }
}