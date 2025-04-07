import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../sector_polygon.dart';

class PolygonLayerWidget extends StatelessWidget {
  const PolygonLayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PolygonLayer(
      polygons: [
        Polygon(
          points: sectorPolygon,
          color: Colors.blue.withOpacity(0.2),
          borderColor: Colors.blue,
          borderStrokeWidth: 2,
        ),
      ],
    );
  }
}
