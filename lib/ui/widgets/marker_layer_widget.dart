import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MarkerLayerWidget extends StatelessWidget {
  final LatLng? guessPosition;
  final LatLng? realPosition;
  final bool revealed;

  const MarkerLayerWidget({
    super.key,
    required this.guessPosition,
    required this.realPosition,
    required this.revealed,
  });

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      if (guessPosition != null)
        Marker(
          point: guessPosition!,
          width: 40,
          height: 40,
          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
        ),
      if (revealed && realPosition != null)
        Marker(
          point: realPosition!,
          width: 40,
          height: 40,
          child: const Icon(Icons.location_on, color: Colors.green, size: 40),
        ),
    ];

    return MarkerLayer(markers: markers);
  }
}
