import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


void main() {
  runApp(
MaterialApp(
  home: Home(),
)



  );
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( backgroundColor: const Color.fromRGBO(109, 141, 197, 1),
appBar: AppBar(
title: Text('Profile',style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255),fontFamily:'RethinkSans',
            fontWeight: FontWeight.bold, fontSize: 45
          ),          
          ),
centerTitle: true,
backgroundColor: Colors.blueAccent,

),

body: Padding(
  padding: const EdgeInsets.all(44.0),
  child: Center(
    child: Column(children: [
    SizedBox(height: 40,),
    CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1758550445758-165aeab5b26e?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                ),
              ),
    SizedBox(height: 10,),
    
    Text('ياسين دلاشي' ,style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255),fontFamily: 'Lemonada',fontSize: 48),),
      Text('مبرمج مبدتئ' ,style: TextStyle(color: const Color.fromARGB(255, 180, 174, 174),fontFamily: 'Lemonada',fontSize: 18))
      ,SizedBox(height: 20,)
  ,
  Card(
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row( 
      children: [
      SvgPicture.asset(
                        'icons/Google.svg',
                        width: 30,
                        height: 30,
                        color: const Color.fromRGBO(109, 141, 197, 1),
                      )
      ,SizedBox(width:15),
      Text('dalachiyacine@gmail.com',style: TextStyle(fontSize: 24),)
      
      
      ],
      
      
      ),
    ),
  ),SizedBox(height: 15,),
    Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'icons/smartphone.svg',
                        width: 30,
                        height: 30,
                        color: const Color.fromRGBO(109, 141, 197, 1),
                      ),
                      SizedBox(width: 15),
                      Text(
                        '+213540485958',
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                ),
              ),
    ],
    
    
    
    ),
  ),
),





    );
  }
}