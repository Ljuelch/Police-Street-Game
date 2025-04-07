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
import 'game_dialogs.dart';
import 'bubble_overlay.dart';

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
  double _lifePercentage = 1.0;
  int _roundCounter = 0;

  OverlayEntry? _distanceOverlay;

  bool _isAnimatingLife = false;
  double _barWidth = 20.0;

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

    final newLife = calculateLifeReduction(_lifePercentage, distance);

    if (mounted) {
      _showDistanceOverlay('Du liegst ${distance.toStringAsFixed(0)} Meter daneben!');
    }

    _roundCounter++;

    setState(() => _isAnimatingLife = true);

    // Step 1: Make bar wider
    setState(() => _barWidth = 30.0);
    await Future.delayed(const Duration(milliseconds: 400)); // ⬅️ stays wider longer

// Step 2: Reduce life
    setState(() {
      _lifePercentage = newLife;
    });

// Step 3: Stay wide briefly after reduction
    await Future.delayed(const Duration(milliseconds: 500));

// Step 4: Shrink bar width back
    setState(() => _barWidth = 20.0);

// Step 5: Finish animation
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _isAnimatingLife = false);

    setState(() {
      _lifePercentage = newLife;
      _barWidth = 20.0;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _isAnimatingLife = false);

    if (_lifePercentage <= 0) {
      setState(() => _mapInteracted = true);
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        await showLossDialog(context, () {
          setState(() {
            _lifePercentage = 1.0;
            _roundCounter = 0;
            _mapInteracted = false;
          });
          _pickRandomAddress();
        });
      }
    } else if (_roundCounter >= 10) {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        showVictoryDialog(context, () {
          setState(() {
            _lifePercentage = 1.0;
            _roundCounter = 0;
          });
          _pickRandomAddress();
        });
      }
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
    final fabIcon = _revealed ? Icons.refresh : Icons.check;

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
                child: !_mapInteracted
                    ? BubbleOverlay(address: _currentAddress)
                    : const SizedBox.shrink(),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: _mapInteracted ? _buildBottomBar() : const SizedBox.shrink(),
            ),
          ),

          // Game bar
          Positioned(
            top: 335,
            bottom: 200,
            right: 10,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: _barWidth,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween<double>(begin: 0.0, end: _lifePercentage),
                builder: (context, value, child) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: value > 0.5
                              ? Colors.blue
                              : value > 0.2
                              ? Colors.yellow
                              : Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60.0),
        child: FloatingActionButton(
          backgroundColor:
          _isAnimatingLife ? Colors.grey : Colors.blue.withOpacity(0.7),
          onPressed: _isAnimatingLife ? null : (_revealed ? _pickRandomAddress : _confirmGuess),
          child: Icon(fabIcon),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      key: const ValueKey('bottomBar'),
      height: 60,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Center(
        child: Text(
          _currentAddress != null
              ? '${_currentAddress!['street']} ${_currentAddress!['houseNumber']}'
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
