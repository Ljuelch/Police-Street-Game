import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MapControls extends StatelessWidget {
  final bool revealed;
  final LatLng? guessPosition;
  final VoidCallback onReset;
  final VoidCallback onConfirm;

  const MapControls({
    super.key,
    required this.revealed,
    required this.guessPosition,
    required this.onReset,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final icon = revealed ? Icons.refresh : Icons.check;

    return Padding(
      padding: const EdgeInsets.only(bottom: 60.0),
      child: FloatingActionButton(
        backgroundColor: Colors.blue.withOpacity(0.7),
        onPressed: () {
          if (revealed) {
            onReset();
          } else if (guessPosition != null) {
            onConfirm();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bitte auf die Karte tippen, um zu raten!')),
            );
          }
        },
        child: Icon(icon),
      ),
    );
  }
}
