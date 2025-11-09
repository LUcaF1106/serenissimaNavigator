// place_detail_page.dart
import 'package:flutter/material.dart';
import 'venice_map.dart'; // Import to use the Place class

class PlaceDetailPage extends StatelessWidget {
  final Place place;

  const PlaceDetailPage({super.key, required this.place});

  // Simulated function to analyze change using "Copernicus Data"
  // In a real application, this would involve API calls to Copernicus services
  // (e.g., land cover, water level, or vegetation index data)
  String _analyzeCopernicusData() {
    switch (place.category) {
      case 'nature':
        return 'Copernicus Sentinel data suggests a **slight decrease (3-5%)** in nearby wetland extent over the last decade, primarily due to **salt marsh erosion**. This indicates a need for conservation efforts.';
      case 'historical':
        return 'Analysis of high-resolution imagery from the Copernicus Programme shows **no significant change** to the structure of the site over the last 20 years, confirming its **stable preservation**.';
      case 'city':
        return 'Urban heat island analysis using Copernicus Land Monitoring Service data indicates an **average summer temperature increase of 1.5°C** in the city center compared to 1990, pointing to climate change impacts.';
      default:
        return 'No specific Copernicus analysis data available for this category.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final copernicusAnalysis = _analyzeCopernicusData();

    return Scaffold(
      appBar: AppBar(
        title: Text(place.name),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Basic Place Information ---
            Text(
              place.category.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: place.category == 'nature' ? Colors.green.shade700 : Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              place.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),

            // --- Map Location ---
            const Text(
              'Location',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Divider(),
            Text('Latitude: ${place.latitude}', style: const TextStyle(fontSize: 14)),
            Text('Longitude: ${place.longitude}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 20),
            
            // Placeholder for a static map image of the location
            Center(
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Image.asset('assets/venice.webp')
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- Copernicus Data Analysis Section ---
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.satellite_alt, color: Colors.blue, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Copernicus Environmental Analysis',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.blueAccent),
                  const SizedBox(height: 8),
                  Text(
                    copernicusAnalysis,
                    style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Data simulated based on general Sentinel/Copernicus Land Monitoring Service indicators for illustrative purposes.',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}