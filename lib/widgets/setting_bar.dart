import 'package:flutter/material.dart';

  const colorNav = Color(0xFF1B0161);
  const colorAppBar = Color(0xFF6052a6);

class SettingBar extends StatelessWidget {
  SettingBar(this.tileName, this.tileIcon, this.onTap);

  final Function() onTap;
  final String tileName;
  final IconData tileIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 6),
      child: Card(
        child: ListTile(
          leading: Icon(
            tileIcon,
            color: colorNav,
          ),
          title: Text(
            tileName,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
