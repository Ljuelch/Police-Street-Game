import 'package:flutter/material.dart';
import '../widgets/map_widget.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MapWidget(),
    );
  }
}
