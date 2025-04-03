import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'game_logic.dart';
import 'map_view.dart';
import 'sector_polygon.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();

  // Initial map settings.
  static const LatLng initialCenter = LatLng(52.491574, 13.395990);
  static const double initialZoom = 13.1;

  // Track the current map center and zoom.
  LatLng _currentMapCenter = initialCenter;
  double _currentMapZoom = initialZoom;

  Map<String, dynamic>? _currentAddress;
  LatLng? _guessPosition;
  LatLng? _realPosition;
  bool _revealed = false; // false -> check icon, true -> refresh icon

  @override
  void initState() {
    super.initState();
    _pickRandomAddress();
  }

  void _pickRandomAddress() {
    final randomAddress = getRandomAddress();
    setState(() {
      _currentAddress = randomAddress;
      _realPosition = LatLng(randomAddress['lat'], randomAddress['lng']);
      _guessPosition = null;
      _revealed = false;
    });

    // Reset the map view to the initial center and zoom after build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _mapController.move(initialCenter, initialZoom);
      }
    });
  }

  /// Calculates an approximate zoom level that fits the [bounds] into the available [mapSize].
  double _calculateZoom(LatLngBounds bounds, Size mapSize) {
    final latDiff = bounds.north - bounds.south;
    final lngDiff = bounds.east - bounds.west;
    final maxDiff = math.max(latDiff, lngDiff);
    final zoom = math.log((mapSize.width * 360) / (256 * maxDiff)) / math.ln2;
    return zoom.clamp(0, 18).toDouble();
  }

  /// Smoothly animates the map move from the current center/zoom to [destCenter] and [destZoom].
  void animateMapMove(LatLng destCenter, double destZoom) {
    final currentCenter = _currentMapCenter;
    final currentZoom = _currentMapZoom;
    final latTween =
    Tween<double>(begin: currentCenter.latitude, end: destCenter.latitude);
    final lngTween =
    Tween<double>(begin: currentCenter.longitude, end: destCenter.longitude);
    final zoomTween = Tween<double>(begin: currentZoom, end: destZoom);

    final controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    final animation =
    CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      final newLat = latTween.evaluate(animation);
      final newLng = lngTween.evaluate(animation);
      final newZoom = zoomTween.evaluate(animation);
      _mapController.move(LatLng(newLat, newLng), newZoom);
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      }
    });
    controller.forward();
  }

  void _confirmGuess() {
    if (_guessPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please tap on the map to make your guess!')),
      );
      return;
    }
    setState(() {
      _revealed = true;
    });

    final distance = const Distance().as(
      LengthUnit.Meter,
      _guessPosition!,
      _realPosition!,
    );

    // Create bounds that contain both guess and real positions.
    final bounds = LatLngBounds.fromPoints([_guessPosition!, _realPosition!]);
    final latPadding = (bounds.north - bounds.south) * 0.2;
    final lngPadding = (bounds.east - bounds.west) * 0.2;
    final paddedBounds = LatLngBounds(
      LatLng(bounds.south - latPadding, bounds.west - lngPadding),
      LatLng(bounds.north + latPadding, bounds.east + lngPadding),
    );
    final center = paddedBounds.center;
    final mapSize = MediaQuery.of(context).size;
    final newZoom = _calculateZoom(paddedBounds, mapSize);

    // Animate the map move.
    animateMapMove(center, newZoom);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You were off by ${distance.toStringAsFixed(2)} meters!'),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).size.height - 100,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine FAB action: if revealed, refresh; if not and marker is set, confirm; else disabled.
    final fabOnPressed =
    _revealed ? _pickRandomAddress : (_guessPosition != null ? _confirmGuess : null);
    final fabIcon = _revealed ? Icons.refresh : Icons.check;

    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: initialCenter,
          initialZoom: initialZoom,
          onMapEvent: (event) {
            if (event is MapEventMoveEnd) {
              // Cast event to dynamic to access center and zoom.
              final dynamic e = event;
              _currentMapCenter = e.center;
              _currentMapZoom = e.zoom;
            }
          },
          onTap: (tapPosition, latLng) {
            if (!_revealed) {
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
          // Use your separate MapView widget if desired, or keep inline.
          // Here we'll simply include the layers inline:
          PolygonLayer(
            polygons: [
              Polygon(
                points: sectorPolygon,
                color: Colors.blue.withOpacity(0.2),
                borderColor: Colors.blue,
                borderStrokeWidth: 2,
              ),
            ],
          ),
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
          MarkerLayer(
            markers: [
              if (_guessPosition != null)
                Marker(
                  point: _guessPosition!,
                  width: 40,
                  height: 40,
                  child:
                  const Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
              if (_revealed && _realPosition != null)
                Marker(
                  point: _realPosition!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on,
                      color: Colors.green, size: 40),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60.0),
        child: FloatingActionButton(
          backgroundColor: Colors.blue.withOpacity(0.7),
          onPressed: fabOnPressed,
          child: Icon(fabIcon),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            _currentAddress != null
                ? 'Find: ${_currentAddress!['street']} ${_currentAddress!['houseNumber']}'
                : 'Loading address...',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
