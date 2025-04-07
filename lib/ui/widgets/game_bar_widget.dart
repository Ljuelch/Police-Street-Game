import 'package:flutter/material.dart';

class GameBarWidget extends StatelessWidget {
  final double progress; // 0.0 to 1.0

  const GameBarWidget({super.key, required this.progress});

  Color _barColor(double value) {
    if (value <= 0.2) return Colors.red;
    if (value <= 0.5) return Colors.yellow;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        width: 20,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              height: 200 * progress,
              decoration: BoxDecoration(
                color: _barColor(progress),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
