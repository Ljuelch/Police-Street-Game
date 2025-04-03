import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'addresses.dart';
import 'game_logic.dart';
import 'sector_polygon.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MapController _mapController = MapController();

  Map<String, dynamic>? _currentAddress;
  LatLng? _guessPosition;
  LatLng? _realPosition;
  bool _revealed = false;

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

    final distance = Distance().as(
      LengthUnit.Meter,
      _guessPosition!,
      _realPosition!,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You were off by ${distance.toStringAsFixed(2)} meters!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Street Names Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _pickRandomAddress,
            tooltip: 'New Address',
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(52.491574, 13.391966),
          initialZoom: 12.9,
          onTap: (tapPosition, latLng) {
            setState(() {
              _guessPosition = latLng;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
            'https://api.mapbox.com/styles/v1/zlato1-5/cm91icclf009v01r4dugp3262/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiemxhdG8xLTUiLCJhIjoiY204cWdiMnY3MGhzMTJqcXhmeWxybWgydiJ9.evVqvNz-kvwXtPTtVsaGqA',
          ),

          // Draw the big single polygon
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

          // Markers for guess + real location
          MarkerLayer(
            markers: [
              if (_guessPosition != null)
                Marker(
                  point: _guessPosition!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
              if (_revealed && _realPosition != null)
                Marker(
                  point: _realPosition!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on, color: Colors.green, size: 40),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _confirmGuess,
        child: const Icon(Icons.check),
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
