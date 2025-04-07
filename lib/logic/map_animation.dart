import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

double calculateZoom(LatLngBounds bounds, Size mapSize) {
  final latDiff = bounds.north - bounds.south;
  final lngDiff = bounds.east - bounds.west;
  final maxDiff = math.max(latDiff, lngDiff);
  final zoom = math.log((mapSize.width * 360) / (256 * maxDiff)) / math.ln2;
  return zoom.clamp(0, 18).toDouble();
}

Future<void> animateMapMove({
  required MapController controller,
  required TickerProvider vsync,
  required LatLng fromCenter,
  required double fromZoom,
  required LatLng toCenter,
  required double toZoom,
}) {
  final latTween = Tween<double>(begin: fromCenter.latitude, end: toCenter.latitude);
  final lngTween = Tween<double>(begin: fromCenter.longitude, end: toCenter.longitude);
  final zoomTween = Tween<double>(begin: fromZoom, end: toZoom);

  final animationController = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: vsync,
  );

  final animation = CurvedAnimation(parent: animationController, curve: Curves.fastOutSlowIn);
  final completer = Completer<void>();

  animationController.addListener(() {
    final newLat = latTween.evaluate(animation);
    final newLng = lngTween.evaluate(animation);
    final newZoom = zoomTween.evaluate(animation);
    controller.move(LatLng(newLat, newLng), newZoom);
  });

  animationController.addStatusListener((status) {
    if (status == AnimationStatus.completed) {
      animationController.dispose();
      completer.complete();
    }
  });

  animationController.forward();
  return completer.future;
}
