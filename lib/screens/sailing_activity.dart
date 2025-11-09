// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';


class HistoricalPoint {
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String category;
  bool visited;

  HistoricalPoint({
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.category,
    this.visited = false,
  });

  factory HistoricalPoint.fromJson(Map<String, dynamic> json) {
    return HistoricalPoint(
      name: json['name'],
      description: json['description'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      category: json['category'],
    );
  }
}

class SailingActivity {
  final DateTime date;
  final double distance;
  final int duration;
  final int zecchiniEarned;

  SailingActivity({
    required this.date,
    required this.distance,
    required this.duration,
    required this.zecchiniEarned,
  });
}

class SailingTrackerPage extends StatefulWidget {
  const SailingTrackerPage({Key? key}) : super(key: key);

  @override
  State<SailingTrackerPage> createState() => _SailingTrackerPageState();
}

class _SailingTrackerPageState extends State<SailingTrackerPage> {
  bool isTracking = false;
  double currentDistance = 0.0;
  double totalDistance = 0.0;
  int zecchini = 0;
  int currentTab = 0;
  Timer? trackingTimer;
  DateTime? activityStartTime;
  LatLng currentPosition = LatLng(45.4408, 12.3155); // Venice center
  
  List<HistoricalPoint> historicalPoints = [];
  List<SailingActivity> activities = [];
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadHistoricalPoints();
  }

  Future<void> _loadHistoricalPoints() async {
    // Load JSON from assets
    final String jsonString = await rootBundle.loadString('assets/places.json');
    final Map<String, dynamic> data = json.decode(jsonString);
    
    setState(() {
      historicalPoints = (data['places'] as List)
          .map((place) => HistoricalPoint.fromJson(place))
          .toList();
    });
  }

  void startTracking() {
    setState(() {
      isTracking = true;
      currentDistance = 0.0;
      activityStartTime = DateTime.now();
    });

    trackingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        // Simulate sailing movement
        double increment = 0.1 + Random().nextDouble() * 0.2;
        currentDistance += increment;
        totalDistance += increment;

        // Update position (simulate movement)
        currentPosition = LatLng(
          currentPosition.latitude + (Random().nextDouble() - 0.5) * 0.001,
          currentPosition.longitude + (Random().nextDouble() - 0.5) * 0.001,
        );

        // Check if user earned a Zecchino
        if (currentDistance >= 5.0) {
          int newZecchini = (currentDistance / 5.0).floor();
          zecchini += newZecchini;
          currentDistance = currentDistance % 5.0;
          _showZecchinoDialog(newZecchini);
        }

        // Check proximity to historical points
        _checkNearbyPoints();
      });
    });
  }

  void _checkNearbyPoints() {
    const double proximityThreshold = 0.05; // ~5km
    
    for (var point in historicalPoints) {
      if (!point.visited) {
        double distance = _calculateDistance(
          currentPosition.latitude,
          currentPosition.longitude,
          point.latitude,
          point.longitude,
        );
        
        if (distance < proximityThreshold) {
          setState(() {
            point.visited = true;
          });
          _showPointDialog(point);
          break;
        }
      }
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return sqrt(pow(lat2 - lat1, 2) + pow(lon2 - lon1, 2));
  }

  void stopTracking() {
    trackingTimer?.cancel();
    
    if (activityStartTime != null) {
      int duration = DateTime.now().difference(activityStartTime!).inMinutes;
      int earnedZecchini = (currentDistance / 5.0).floor();
      
      activities.insert(
        0,
        SailingActivity(
          date: activityStartTime!,
          distance: currentDistance,
          duration: duration,
          zecchiniEarned: earnedZecchini,
        ),
      );
    }

    setState(() {
      isTracking = false;
      currentDistance = 0.0;
      activityStartTime = null;
    });
  }

  void _showZecchinoDialog(int count) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Row(
          children: [
            const Icon(Icons.stars, color: Color(0xFFFFD700), size: 32),
            const SizedBox(width: 12),
            Text('$count Zecchino${count > 1 ? 'i' : ''} Earned!', style: TextStyle(color: Colors.white),),
          ],
        ),
        content: Text('You sailed 5 miles and earned $count Zecchino${count > 1 ? 'i' : ''}!', style: TextStyle(color: Colors.white),),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Sailing'),
          ),
        ],
      ),
    );
  }

  void _showPointDialog(HistoricalPoint point) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Row(
          children: [
            Icon(
              point.category == 'nature' ? Icons.nature : Icons.location_city,
              color: const Color(0xFF3B82F6),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(point.name, style: const TextStyle(fontSize: 16, color: Colors.white))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: point.category == 'nature' 
                    ? Colors.green.withOpacity(0.2)
                    : Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                point.category.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: point.category == 'nature' ? Colors.green : Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(point.description, style: TextStyle( color: Colors.white),),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:const Text( 'Close',
            style: TextStyle(
              color: Colors.white
            ),),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    trackingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.blue[400],
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.sailing, color: Colors.blue[400]),
            const SizedBox(width: 12),
            Text('Laguna Veneta',
            style: TextStyle( color: Colors.blue[400]),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFD700), width: 2),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Color(0xFFFFD700), size: 20),
                const SizedBox(width: 6),
                Text(
                  '$zecchini',
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: currentTab,
        children: [
          _buildTrackingTab(),
          _buildMapTab(),
          _buildActivitiesTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        onTap: (index) => setState(() => currentTab = index),
        backgroundColor: const Color(0xFF0F172A),
        selectedItemColor: Colors.blue[400],
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.navigation),
            label: 'Track',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Activities',
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Distance',
                    '${totalDistance.toStringAsFixed(2)} mi',
                    Icons.trending_up,
                    Colors.blue[400]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Points',
                    '${historicalPoints.where((p) => p.visited).length}/${historicalPoints.length}',
                    Icons.location_on,
                    Colors.green[400]!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue[900]!.withOpacity(0.5),
                    Colors.blue[800]!.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.blue[700]!.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    isTracking ? 'Sailing Now' : 'Ready to Sail',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    currentDistance.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'MILES',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 2,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Next Zecchino'),
                          Text(
                            '${(5.0 - (currentDistance % 5.0)).toStringAsFixed(2)} mi',
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (currentDistance % 5.0) / 5.0,
                          backgroundColor: Colors.grey[800],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFFD700),
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isTracking ? stopTracking : startTracking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isTracking 
                            ? Colors.red[600] 
                            : Colors.blue[600],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            color: Colors.white,
                            isTracking ? Icons.stop : Icons.play_arrow,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isTracking ? 'Stop Tracking' : 'Start Sailing',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapTab() {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: LatLng(45.4408, 12.3155),
            initialZoom: 11.0,
            minZoom: 10.0,
            maxZoom: 15.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.laguna.veneta',
            ),
            MarkerLayer(
              markers: [
                // Current position marker
                if (isTracking)
                  Marker(
                    point: currentPosition,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.navigation,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                // Historical points markers
                ...historicalPoints.map((point) {
                  return Marker(
                    point: LatLng(point.latitude, point.longitude),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showPointDialog(point),
                      child: Icon(
                        point.visited ? Icons.check_circle : Icons.location_on,
                        color: point.visited 
                            ? Colors.green[400]
                            : (point.category == 'nature' 
                                ? Colors.green[200]
                                : Colors.blue[300]),
                        size: 40,
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ],
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: 'zoom_in',
                mini: true,
                backgroundColor: const Color(0xFF1E293B),
                onPressed: () {
                  mapController.move(
                    mapController.camera.center,
                    mapController.camera.zoom + 1,
                  );
                },
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'zoom_out',
                mini: true,
                backgroundColor: const Color(0xFF1E293B),
                onPressed: () {
                  mapController.move(
                    mapController.camera.center,
                    mapController.camera.zoom - 1,
                  );
                },
                child: const Icon(Icons.remove),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'center',
                mini: true,
                backgroundColor: const Color(0xFF1E293B),
                onPressed: () {
                  mapController.move(
                    currentPosition,
                    13.0,
                  );
                },
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesTab() {
    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_boat,
              size: 64,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 16),
            Text(
              'No activities yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start sailing to track your activities',
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Recent Activities',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...activities.map((activity) => _buildActivityCard(activity)),
      ],
    );
  }

  Widget _buildActivityCard(SailingActivity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sailing, color: Colors.blue),
              const SizedBox(width: 12),
              const Text(
                'Sailing Session',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActivityStat(
                'Distance',
                '${activity.distance.toStringAsFixed(2)} mi',
              ),
              _buildActivityStat(
                'Duration',
                '${activity.duration} min',
              ),
              _buildActivityStat(
                'Zecchini',
                '${activity.zecchiniEarned}',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${activity.date.day}/${activity.date.month}/${activity.date.year} at ${activity.date.hour}:${activity.date.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/* 
DEPENDENCIES REQUIRED IN pubspec.yaml:

dependencies:
  flutter:
    sdk: flutter
  flutter_map: ^6.1.0
  latlong2: ^0.9.0

To load from assets instead, create assets/places.json with your JSON
and add to pubspec.yaml:
flutter:
  assets:
    - assets/places.json

Then use:
String jsonString = await rootBundle.loadString('assets/places.json');
*/