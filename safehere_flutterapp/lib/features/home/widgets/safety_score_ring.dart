import 'package:flutter/material.dart';

import '../../../core/theme.dart';

class SafetyScoreRing extends StatelessWidget {
  const SafetyScoreRing({super.key, required this.score, this.size = 72});
  final int score;
  final double size;

  Color get _color {
    if (score >= 75) return AppColors.safe;
    if (score >= 45) return AppColors.warning;
    return AppColors.emergency;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 6,
              backgroundColor: _color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(_color),
            ),
          ),
          Text('$score', style: TextStyle(fontWeight: FontWeight.w800, fontSize: size * 0.28, color: _color)),
        ],
      ),
    );
  }
}
