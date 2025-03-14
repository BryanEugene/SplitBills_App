import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/friends_screen.dart';
import '../screens/manual_receipt_screen.dart';
import '../screens/entertainment_screen.dart';
import '../screens/sports_screen.dart';
import '../screens/accommodation_screen.dart';
import '../screens/history_screen.dart';
import '../screens/receipt_split_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => DashboardScreen());
      case '/friends':
        return MaterialPageRoute(builder: (_) => FriendsScreen());
      case '/manual-receipt':
        return MaterialPageRoute(builder: (_) => ManualReceiptScreen());
      case '/entertainment':
        return MaterialPageRoute(builder: (_) => EntertainmentScreen());
      case '/sports':
        return MaterialPageRoute(builder: (_) => SportsScreen());
      case '/accommodation':
        return MaterialPageRoute(builder: (_) => AccommodationScreen());
      case '/history':
        return MaterialPageRoute(builder: (_) => HistoryScreen());
      case '/receipt-split':
        return MaterialPageRoute(builder: (_) => ReceiptSplitScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
