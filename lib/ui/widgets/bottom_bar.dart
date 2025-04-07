import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  final Map<String, dynamic>? address;

  const BottomBar({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('bottomBar'),
      height: 60,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Center(
        child: Text(
          address != null
              ? '${address!['street']} ${address!['houseNumber']}'
              : 'Adresse wird geladen...',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
