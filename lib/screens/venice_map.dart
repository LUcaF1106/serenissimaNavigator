// venice_map_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'place_details.dart'; // <-- Import the new detail page

// The Place class remains the same (as in your original code)
class Place {
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String category;

  Place({
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.category,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'],
      description: json['description'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      category: json['category'],
    );
  }
}

class VeniceMapPage extends StatefulWidget {
  const VeniceMapPage({super.key});

  @override
  State<VeniceMapPage> createState() => _VeniceMapPageState();
}

class _VeniceMapPageState extends State<VeniceMapPage> {
  final MapController _mapController = MapController();
  final List<Place> _places = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPlacesFromAssets();
  }

  Future<void> _loadPlacesFromAssets() async {
    try {
      // Load JSON from assets folder
      final String jsonString = await rootBundle.loadString('assets/places.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> placesJson = data['places'];
      
      setState(() {
        _places.clear();
        for (var placeJson in placesJson) {
          _places.add(Place.fromJson(placeJson));
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading places: $e';
        _isLoading = false;
      });
    }
  }

  // New method for navigation
  void _navigateToPlaceDetail(BuildContext context, Place place) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlaceDetailPage(place: place),
      ),
    );
  }

  // Updated _buildMarkers to navigate on tap
  List<Marker> _buildMarkers() {
    return _places.map((place) {
      return Marker(
        point: LatLng(place.latitude, place.longitude),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () {
            // Navigate to the detail page on marker tap
            _navigateToPlaceDetail(context, place);
            
            // Optional: Recenter map on the tapped marker
            _mapController.move(
              LatLng(place.latitude, place.longitude),
              _mapController.camera.zoom,
            );
          },
          child: Icon(
            Icons.location_pin,
            size: 40,
            color: place.category == 'nature' ? Colors.green : Colors.blue,
            shadows: const [
              Shadow(color: Colors.black54, blurRadius: 4),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _recenterMap() {
    _mapController.move(
      const LatLng(45.4408, 12.3155),
      11.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // ... (Loading state remains the same) ...
      return Scaffold(
        appBar: AppBar(
          title: const Text('Venice Lagoon Places'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      // ... (Error state remains the same) ...
      return Scaffold(
        appBar: AppBar(
          title: const Text('Venice Lagoon Places'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadPlacesFromAssets();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Venice Lagoon Places'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              // Updated: Now the list tile also navigates to the detail page
              showModalBottomSheet(
                context: context,
                builder: (context) => ListView.builder(
                  itemCount: _places.length,
                  itemBuilder: (context, index) {
                    final place = _places[index];
                    return ListTile(
                      leading: Icon(
                        Icons.location_pin,
                        color: place.category == 'nature' 
                            ? Colors.green 
                            : Colors.blue,
                      ),
                      title: Text(place.name),
                      subtitle: Text(place.category.toUpperCase()),
                      onTap: () {
                        Navigator.pop(context); // Close the bottom sheet
                        _navigateToPlaceDetail(context, place); // Navigate
                        _mapController.move(
                          LatLng(place.latitude, place.longitude),
                          13.0,
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(45.4408, 12.3155),
              initialZoom: 11.0,
              minZoom: 8.0,
              maxZoom: 18.0,
            ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.serenissima.sailing', 
                  maxZoom: 19,
                ),
                MarkerLayer(markers: _buildMarkers()),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      '© OpenStreetMap contributors',
                      onTap: () => launchUrl(Uri.parse('https://www.openstreetmap.org/copyright')),
                    ),
                  ],
                ),
              ],
          ),
          // --- Removed the Positioned widget for _selectedPlace ---
          // The detail view is now a full-screen page, not a bottom sheet.
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _recenterMap,
        tooltip: 'Recenter Map',
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
}