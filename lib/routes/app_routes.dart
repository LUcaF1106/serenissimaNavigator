import 'package:flutter/material.dart';
import 'package:serenissima/screens/sailing_activity.dart';
import 'package:serenissima/screens/venice_map.dart';
import 'package:serenissima/screens/wallet_page.dart';
import '../screens/landing_page.dart';
import '../screens/home_page.dart';

class AppRoutes {
  static const String landing = '/';
  static const String home = '/home';
  static const String map = '/map';
  static const String wallet = '/wallet';
  static const String activity = "/activity";

  static Map<String, WidgetBuilder> routes = {
    landing: (context) => const LandingPage(),
    home: (context) => HomePage(),
    map: (context) => const VeniceMapPage(),
    wallet: (context) => const ZecchinoWalletPage(),
    activity: (context)=> const SailingTrackerPage()
  };
}
