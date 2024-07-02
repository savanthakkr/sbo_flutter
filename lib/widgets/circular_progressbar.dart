import 'package:flutter/material.dart';

import '../utils/custom_color.dart';

class CircularProgressBar extends StatelessWidget {

  final Color progressColor;

  const CircularProgressBar({
    super.key,
    this.progressColor = CustomColor.primaryColor
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: progressColor,
        strokeWidth: 3,
      ),
    );
  }
}
