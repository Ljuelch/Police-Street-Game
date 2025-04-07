import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../game_logic.dart';
import '../../logic/map_animation.dart';
import '../../logic/distance_utils.dart';
import 'distance_overlay.dart';
import 'marker_layer_widget.dart';
import 'polygon_layer_widget.dart';
import 'bubble_overlay.dart';
import 'bottom_bar.dart';
import 'map_controls.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  static const LatLng initialCenter = LatLng(52.474000, 13.395990);
  static const double initialZoom = 13.1;

  LatLng _currentMapCenter = initialCenter;
  double _currentMapZoom = initialZoom;

  Map<String, dynamic>? _currentAddress;
  LatLng? _guessPosition;
  LatLng? _realPosition;
  bool _revealed = false;
  bool _mapInteracted = false;
  bool _ignoreNextMapEvent = false;

  OverlayEntry? _distanceOverlay;

  @override
  void initState() {
    super.initState();
    _pickRandomAddress();
  }

  void _removeDistanceOverlay() {
    _distanceOverlay?.remove();
    _distanceOverlay = null;
  }

  void _showDistanceOverlay(String text) {
    _removeDistanceOverlay();
    _distanceOverlay = DistanceOverlay.show(context, text);
  }

  void _pickRandomAddress() {
    _removeDistanceOverlay();
    final randomAddress = getRandomAddress();
    setState(() {
      _currentAddress = randomAddress;
      _realPosition = LatLng(randomAddress['lat'], randomAddress['lng']);
      _guessPosition = null;
      _revealed = false;
      _mapInteracted = false;
      _ignoreNextMapEvent = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _mapController.move(initialCenter, initialZoom);
      }
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _ignoreNextMapEvent = false;
      }
    });
  }

  Future<void> _confirmGuess() async {
    if (_guessPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please tap on the map to make your guess!')),
      );
      return;
    }

    setState(() {
      _revealed = true;
    });

    final distance = calculateDistance(_guessPosition!, _realPosition!);
    final bounds = calculateBounds(_guessPosition!, _realPosition!);
    final center = bounds.center;
    final newZoom = calculateZoom(bounds, MediaQuery.of(context).size);

    await animateMapMove(
      controller: _mapController,
      vsync: this,
      fromCenter: _currentMapCenter,
      fromZoom: _currentMapZoom,
      toCenter: center,
      toZoom: newZoom,
    );

    if (mounted) {
      _showDistanceOverlay('Du liegst ${distance.toStringAsFixed(0)} Meter daneben!');
    }
  }

  void _handleMapInteraction() {
    if (_ignoreNextMapEvent) return;
    if (!_mapInteracted) {
      setState(() {
        _mapInteracted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: initialZoom,
              interactionOptions: InteractionOptions(
                flags: _revealed ? InteractiveFlag.none : InteractiveFlag.all,
              ),
              onMapEvent: (event) {
                if (event is MapEventMove || event is MapEventTap || event is MapEventMoveEnd) {
                  _handleMapInteraction();
                  if (event is MapEventMoveEnd) {
                    final dynamic e = event;
                    _currentMapCenter = e.center;
                    _currentMapZoom = e.zoom;
                  }
                }
              },
              onTap: (tapPosition, latLng) {
                if (!_revealed) {
                  _handleMapInteraction();
                  setState(() {
                    _guessPosition = latLng;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://api.mapbox.com/styles/v1/zlato1-5/cm91icclf009v01r4dugp3262/tiles/256/{z}/{x}/{y}@2x?access_token=${dotenv.env['ACCESS_TOKEN']}',
              ),
              const PolygonLayerWidget(),
              if (_revealed && _guessPosition != null && _realPosition != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [_guessPosition!, _realPosition!],
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  ],
                ),
              MarkerLayerWidget(
                guessPosition: _guessPosition,
                realPosition: _realPosition,
                revealed: _revealed,
              ),
            ],
          ),

          // Bubble / Walkie
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                switchInCurve: Curves.elasticOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: !_mapInteracted ? BubbleOverlay(address: _currentAddress) : const SizedBox.shrink(),
              ),
            ),
          ),

          // Bottom bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
              child: _mapInteracted ? BottomBar(address: _currentAddress) : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
      floatingActionButton: MapControls(
        revealed: _revealed,
        onConfirm: _confirmGuess,
        onReset: _pickRandomAddress,
        guessPosition: _guessPosition,
      ),
    );
  }
}
