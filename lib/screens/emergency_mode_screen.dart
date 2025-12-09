import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../services/emergency_service.dart';
import 'dashboard_screen.dart';

class EmergencyModeScreen extends StatefulWidget {
  const EmergencyModeScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyModeScreen> createState() => _EmergencyModeScreenState();
}

class _EmergencyModeScreenState extends State<EmergencyModeScreen> {
  String? _emergencyId;
  int _etaMin = 4;
  int _etaMax = 6;
  bool _isLoading = true;
  bool _isRequesting = false;
  double _latitude = -1.9441; // Default: Kigali
  double _longitude = 30.0619;
  
  @override
  void initState() {
    super.initState();
    _initializeEmergency();
  }
  
  Future<void> _initializeEmergency() async {
    try {
      // Get user's current location
      await _getCurrentLocation();
      
      // Get initial ETA
      await _fetchETA();
      
      // Create emergency request
      await _createEmergencyRequest();
      
      // Start periodic ETA updates
      _startETAUpdates();
    } catch (e) {
      print('Error initializing emergency: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return; // Use default location
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return; // Use default location
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return; // Use default location
      }
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }
  
  Future<void> _fetchETA() async {
    try {
      final result = await EmergencyService.getPoliceETA(
        latitude: _latitude,
        longitude: _longitude,
      );
      
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        setState(() {
          _etaMin = data['etaMin'] ?? 4;
          _etaMax = data['etaMax'] ?? 6;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching ETA: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _createEmergencyRequest() async {
    if (_isRequesting) return;
    
    setState(() {
      _isRequesting = true;
    });
    
    try {
      final result = await EmergencyService.createEmergencyRequest(
        latitude: _latitude,
        longitude: _longitude,
        emergencyType: 'POLICE',
        description: 'Emergency assistance requested',
      );
      
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        setState(() {
          _emergencyId = data['emergencyId'];
          _etaMin = data['etaMin'] ?? _etaMin;
          _etaMax = data['etaMax'] ?? _etaMax;
        });
      }
    } catch (e) {
      print('Error creating emergency request: $e');
    } finally {
      setState(() {
        _isRequesting = false;
      });
    }
  }
  
  void _startETAUpdates() {
    // Update ETA every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _emergencyId != null) {
        _updateEmergencyStatus();
        _startETAUpdates(); // Schedule next update
      }
    });
  }
  
  Future<void> _updateEmergencyStatus() async {
    if (_emergencyId == null) return;
    
    try {
      final result = await EmergencyService.getEmergencyStatus(_emergencyId!);
      
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        setState(() {
          _etaMin = data['etaMin'] ?? _etaMin;
          _etaMax = data['etaMax'] ?? _etaMax;
        });
      }
    } catch (e) {
      print('Error updating emergency status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFB3221),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                _buildSOSIcon(),
                const SizedBox(height: 24),
                const Text(
                  'Emergency Mode',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Help is on the way.\nYour location is being shared with emergency services.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Police ETA', style: TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(width: 16),
                    _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            '$_etaMin-$_etaMax minutes',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _isLoading ? null : (1.0 - (_etaMin / 20.0).clamp(0.0, 1.0)),
                  backgroundColor: Colors.white24,
                  color: Colors.white,
                  minHeight: 6,
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showEmergencyCallDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'CALL NOW',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Cancel Emergency',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Your emergency contacts have been notified',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSOSIcon() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'SOS',
          style: TextStyle(
            color: Colors.red.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 36,
          ),
        ),
      ),
    );
  }

  void _showEmergencyCallDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Select Emergency Service',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF36599F),
                ),
              ),
            ),
            const Divider(height: 1),
            _buildEmergencyOption(
              context: context,
              icon: Icons.local_police,
              title: 'Police Emergency',
              subtitle: '911',
              phoneNumber: '911',
              color: const Color(0xFF36599F),
            ),
            _buildEmergencyOption(
              context: context,
              icon: Icons.fire_truck,
              title: 'Fire Department',
              subtitle: '911',
              phoneNumber: '911',
              color: const Color(0xFFEF4444),
            ),
            _buildEmergencyOption(
              context: context,
              icon: Icons.local_hospital,
              title: 'Ambulance',
              subtitle: '911',
              phoneNumber: '911',
              color: const Color(0xFF10B981),
            ),
            _buildEmergencyOption(
              context: context,
              icon: Icons.phone,
              title: 'Non-Emergency Police',
              subtitle: '311',
              phoneNumber: '311',
              color: Colors.grey[700]!,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String phoneNumber,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.phone,
            color: Colors.white,
            size: 20,
          ),
        ),
        onPressed: () async {
          Navigator.pop(context); // Close dialog
          await _makePhoneCall(phoneNumber);
        },
      ),
      onTap: () async {
        Navigator.pop(context); // Close dialog
        await _makePhoneCall(phoneNumber);
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        // Fallback: show error message
        if (phoneNumber == '911' || phoneNumber == '311') {
          // For emergency numbers, we still try to launch
          // Some devices may not support canLaunchUrl for emergency numbers
          await launchUrl(phoneUri);
        }
      }
    } catch (e) {
      // Handle error - in a real app, you might want to show a snackbar
      debugPrint('Error making phone call: $e');
    }
  }
}