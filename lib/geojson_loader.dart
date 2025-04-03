import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';

/// A small class to store each feature's geometry type and its list of points.
class FeatureData {
  final String type; // e.g., "LineString" or "Polygon"
  final List<LatLng> points;

  FeatureData(this.type, this.points);
}

/// Loads all LineString or Polygon features from a GeoJSON file
/// and returns them as a list of [FeatureData].
Future<List<FeatureData>> loadFeaturesFromGeojson(String assetPath) async {
  final data = await rootBundle.loadString(assetPath);
  final jsonData = jsonDecode(data);

  final features = jsonData['features'];
  if (features == null || features.isEmpty) {
    throw Exception('No features found in GeoJSON');
  }

  List<FeatureData> result = [];

  for (final feature in features) {
    final geometry = feature['geometry'];
    if (geometry == null) continue;

    final type = geometry['type'];

    if (type == 'LineString') {
      // Convert each coordinate [lng, lat] to LatLng.
      final coords = geometry['coordinates'] as List;
      final points = coords
          .map((c) => LatLng(c[1], c[0])) // swap to lat, lng
          .toList();
      result.add(FeatureData('LineString', points));
    } else if (type == 'Polygon') {
      // A Polygon's coordinates is a list of "rings". The first ring is the outer boundary.
      // We'll just take the first ring for a simple polygon.
      final coords = geometry['coordinates'][0] as List;
      final points = coords
          .map((c) => LatLng(c[1], c[0]))
          .toList();
      result.add(FeatureData('Polygon', points));
    }
    // If you had MultiLineString or MultiPolygon, you'd parse them similarly.
  }

  return result;
}
