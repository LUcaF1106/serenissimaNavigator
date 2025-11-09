import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

Future<Map<String, Map<String, dynamic>>> fetchMarineData() async {
  final Position position = await getCurrentLocation();

  final double latitude = position.latitude;
  final double longitude = position.longitude;

  // Use weather forecast API instead - better coverage
  final url = Uri.parse('https://api.open-meteo.com/v1/forecast?'
      'latitude=$latitude&longitude=$longitude&'
      'current=wind_speed_10m,wind_direction_10m&'
      'hourly=visibility&'
      'timezone=auto&'
      'wind_speed_unit=kn');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Get current wind data
      final windSpeed = data['current']['wind_speed_10m'] ?? 0;

      // Get visibility from hourly data (first hour)
      final visibilityMeters = data['hourly']['visibility'][0] ?? 10000;
      final visibilityKM = (visibilityMeters / 1000).toStringAsFixed(1);

      // Wave height estimation based on wind speed (Beaufort scale approximation)
      final waveHeight = estimateWaveHeight(windSpeed);

      return {
        'WAVE_HEIGHT': {
          'value': waveHeight.toStringAsFixed(1),
          'unit': 'Meters',
          'icon': Icons.waves
        },
        'WIND': {
          'value': windSpeed.toStringAsFixed(0),
          'unit': 'Knots',
          'icon': Icons.air
        },
        'VISIBILITY': {
          'value': visibilityKM,
          'unit': 'KM',
          'icon': Icons.visibility
        },
        'ALERT': {
          'value': calculateRiskLevel(windSpeed, double.parse(visibilityKM)),
          'unit': 'RISK',
          'icon': Icons.warning,
          'iconColor': getRiskColor(windSpeed, double.parse(visibilityKM))
        }
      };
    } else {
      throw Exception('API failed with status: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching marine data: $e');
    return {
      'WAVE_HEIGHT': {'value': 'N/A', 'unit': 'Meters', 'icon': Icons.error},
      'WIND': {'value': 'N/A', 'unit': 'Knots', 'icon': Icons.error},
      'VISIBILITY': {'value': 'N/A', 'unit': 'KM', 'icon': Icons.error},
      'ALERT': {
        'value': 'FAIL',
        'unit': 'RISK',
        'icon': Icons.error,
        'iconColor': Colors.red
      },
    };
  }
}

// Estimate wave height based on wind speed (Beaufort scale)
double estimateWaveHeight(double windSpeedKnots) {
  if (windSpeedKnots < 7) return 0.3;
  if (windSpeedKnots < 10) return 0.6;
  if (windSpeedKnots < 16) return 1.0;
  if (windSpeedKnots < 21) return 2.0;
  if (windSpeedKnots < 27) return 3.0;
  if (windSpeedKnots < 33) return 4.5;
  return 6.0;
}

String calculateRiskLevel(double windSpeed, double visibility) {
  if (windSpeed > 27 || visibility < 1) return 'HIGH';
  if (windSpeed > 16 || visibility < 5) return 'MEDIUM';
  return 'LOW';
}

Color getRiskColor(double windSpeed, double visibility) {
  final risk = calculateRiskLevel(windSpeed, visibility);
  switch (risk) {
    case 'HIGH':
      return Colors.red;
    case 'MEDIUM':
      return Colors.orange;
    default:
      return Colors.green;
  }
}
Future<Position> getCurrentLocation() async {

  bool serviceEnabled;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {

    return Future.error('I servizi di localizzazione sono disabilitati.');
  }
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('I permessi di localizzazione sono stati negati.');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    // I permessi sono negati permanentemente.
    return Future.error(
      'I permessi di localizzazione sono negati in modo permanente; non possiamo richiedere i permessi.'
    );
  }

  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high
  );
}