import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

double calculateDistance(LatLng guess, LatLng real) {
  return const Distance().as(LengthUnit.Meter, guess, real);
}

LatLngBounds calculateBounds(LatLng a, LatLng b) {
  final bounds = LatLngBounds.fromPoints([a, b]);
  final latPadding = (bounds.north - bounds.south) * 0.2;
  final lngPadding = (bounds.east - bounds.west) * 0.2;

  return LatLngBounds(
    LatLng(bounds.south - latPadding, bounds.west - lngPadding),
    LatLng(bounds.north + latPadding, bounds.east + lngPadding),
  );
}
