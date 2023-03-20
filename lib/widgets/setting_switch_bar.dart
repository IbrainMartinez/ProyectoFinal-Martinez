import 'package:flutter/material.dart';

 const colorNav = Color(0xFF1B0161);
  const colorAppBar = Color(0xFF6052a6);
  
class SettingSwitchBar extends StatelessWidget {
  SettingSwitchBar(this.tileName, this.tileIcon, this.value, this.onChanged);

  final Function(bool) onChanged;
  final bool value;
  final String tileName;
  final IconData tileIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 6),
      child: Card(
        child: SwitchListTile(
          secondary: Icon(tileIcon, color: colorNav),
          title: Text(
            tileName,
          ),
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
