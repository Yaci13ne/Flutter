import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
class cardit extends StatelessWidget {
  String icon;
  String text;
  cardit({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(  color: Theme.of(context).cardColor,

      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListTile(
          leading:   SvgPicture.asset(
              'icons/$icon.svg',
              width: 30,
              height: 30,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          title:             Text(text,   style: Theme.of(context).textTheme.bodyMedium),

        ),
      ),
    );
  }
}

