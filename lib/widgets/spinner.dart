import 'package:flutter/material.dart';

  const colorNav = Color(0xFF1B0161);
  const colorAppBar = Color(0xFF6052a6);

class Spinner extends StatelessWidget {
  const Spinner({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(colorNav),
      ),
    );
  }
}
