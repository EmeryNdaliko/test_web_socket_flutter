import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:icons_plus/icons_plus.dart';

class MyNavigationBar extends StatefulWidget {
  const MyNavigationBar({super.key});

  @override
  State<MyNavigationBar> createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(child: Icon(Iconsax.home_1_bold)),
          Expanded(child: Icon(Iconsax.user_outline)),
          Expanded(
            child: Icon(Iconsax.add_circle_bold, color: Colors.cyan, size: 30),
          ),
          Expanded(child: Icon(Iconsax.message_2_bold)),
          Expanded(child: Icon(Iconsax.setting_2_bold)),
        ],
      ),
    );
  }
}
