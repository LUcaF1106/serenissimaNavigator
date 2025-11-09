import 'package:flutter/material.dart';
import 'package:serenissima/service/request.dart';
import '../routes/app_routes.dart';

// Define custom colors for better maintainability
const Color _kPrimaryColor = Color.fromRGBO(6, 98, 143, 1);
const Color _kAccentColor = Color.fromRGBO(204, 160, 51, 1);
const Color _kCardBackgroundColor = Color.fromRGBO(252, 246, 232, 1);

// ---
// 1. REFACTORED DATA GRID ELEMENT
// ---

/// Private Widget for a specific data point in the grid.
class DataGridElement extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconColor;

  const DataGridElement({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    this.iconColor = _kPrimaryColor, // Default icon color
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kCardBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Icon and Title Row
          Row(
            children: <Widget>[
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(), // Pushes content towards the ends
          // Value and Unit
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                value,
                style: const TextStyle(
                  fontSize: 34, // Prominent size for the main data
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---
// 2. HOMEPAGE REFACTORING
// ---

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final Future<Map<String, Map<String, dynamic>>> marineDataFuture =
      fetchMarineData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header Section
          const Padding(
            padding: EdgeInsets.only(top: 60, left: 20),
            child: Text(
              'Hi Hackthon',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Main Content Section: GridView Card
          Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              color: const Color.fromRGBO(6, 98, 143, 1),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: FutureBuilder<Map<String, Map<String, dynamic>>>(
                  future: marineDataFuture,
                  builder: (context, snapshot) {
                    // 1. Check for Errors
                    if (snapshot.hasError) {
                      return const Center(
                          child: Text('Error loading marine data.'));
                    }

                    // 2. Check for Loading State
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );
                    }

                    // 3. Data is Ready (snapshot.data is the fetched map)
                    final data = snapshot.data!;

                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.2,
                      padding:
                          const EdgeInsets.only(left: 16, bottom: 16, top: 16),

                      // Use the fetched data to build the grid elements
                      children: <Widget>[
                        DataGridElement(
                          title: 'WIND',
                          value: data['WIND']!['value'],
                          unit: data['WIND']!['unit'],
                          icon: data['WIND']!['icon'],
                        ),
                        DataGridElement(
                          title: 'WAVE HEIGHT',
                          value: data['WAVE_HEIGHT']!['value'],
                          unit: data['WAVE_HEIGHT']!['unit'],
                          icon: data['WAVE_HEIGHT']!['icon'],
                        ),
                        DataGridElement(
                          title: 'VISIBILITY',
                          value: data['VISIBILITY']!['value'],
                          unit: data['VISIBILITY']!['unit'],
                          icon: data['VISIBILITY']!['icon'],
                        ),
                        DataGridElement(
                          title: 'ALERT',
                          value: data['ALERT']!['value'],
                          unit: data['ALERT']!['unit'],
                          icon: data['ALERT']!['icon'],
                          iconColor:
                              data['ALERT']!['iconColor'] ?? Colors.black,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      // Custom Bottom Navigation Bar (reused from previous step)
      bottomNavigationBar: const _CustomNavigationBar(),
    );
  }
}

// ---
// 3. CUSTOM NAVIGATION BAR (for completeness)
// ---

class _CustomNavigationBar extends StatelessWidget {
  const _CustomNavigationBar();

  @override
  Widget build(BuildContext context) {
    // Determine screen width once
    final double screenWidth = MediaQuery.of(context).size.width;
    const double centerButtonSize = 70;

    return SizedBox(
      height: 60,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            height: 60,
            decoration: const BoxDecoration(
              color: _kPrimaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  enableFeedback: false,
                  onPressed: () {},
                  icon: const Icon(Icons.home_outlined,
                      color: Colors.white, size: 35),
                ),
                IconButton(
                  enableFeedback: false,
                  onPressed: () {
                    // This assumes AppRoutes.map is defined and works
                    Navigator.pushNamed(context, AppRoutes.map);
                  },
                  icon: const Icon(Icons.map, color: Colors.white, size: 35),
                ),
                const SizedBox(width: centerButtonSize),
                IconButton(
                  enableFeedback: false,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.wallet);
                  },
                  icon: const Icon(Icons.wallet, color: Colors.white, size: 35),
                ),
                IconButton(
                  enableFeedback: false,
                  onPressed: () {},
                  icon: const Icon(Icons.person_outline,
                      color: Colors.white, size: 35),
                ),
              ],
            ),
          ),
          Positioned(
            top: -25,
            left: screenWidth / 2 - (centerButtonSize / 2),
            child: Container(
              width: centerButtonSize,
              height: centerButtonSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: <Color>[
                    _kAccentColor,
                    Color.fromRGBO(205, 161, 52, 1)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Color.fromRGBO(204, 160, 51, 0.4),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Start trip action
                  },
                  borderRadius: BorderRadius.circular(centerButtonSize / 2),
                  child: const Icon(
                    Icons.track_changes,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
