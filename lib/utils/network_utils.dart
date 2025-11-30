import 'package:connectivity_plus/connectivity_plus.dart';

/// Network Utility
/// Helper functions for network connectivity
class NetworkUtils {
  /// Check if device is connected to internet
  static Future<bool> isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.ethernet);
  }

  /// Check if device is on WiFi
  static Future<bool> isOnWifi() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.wifi);
  }

  /// Check if device is on mobile data
  static Future<bool> isOnMobile() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.mobile);
  }

  /// Get connection type
  static Future<String> getConnectionType() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.wifi)) {
      return 'WiFi';
    } else if (connectivityResult.contains(ConnectivityResult.mobile)) {
      return 'Mobile';
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else {
      return 'None';
    }
  }
}

