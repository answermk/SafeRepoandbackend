import 'package:flutter/material.dart';
import 'privacy_data_screen.dart';

class LocationServicesScreen extends StatefulWidget {
  const LocationServicesScreen({super.key});

  @override
  State<LocationServicesScreen> createState() => _LocationServicesScreenState();
}

class _LocationServicesScreenState extends State<LocationServicesScreen> {
  bool _preciseLocation = true;
  bool _backgroundAccess = false;

  Future<void> _handleAllowLocationAccess() async {
    // Handle allow location access - backend functionality
    print('Allow Location Access button pressed');
    print('Precise Location: $_preciseLocation');
    print('Background Access: $_backgroundAccess');

    // TODO: Implement actual location permission logic with backend
    // For now, simulate successful permission grant

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF36599F)),
      ),
    );

    // Simulate API call and permission request
    await Future.delayed(const Duration(seconds: 2));

    // Close loading dialog
    Navigator.of(context).pop();

    // Navigate to privacy data screen after successful permission
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PrivacyDataScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Map Icon with location pin
              Container(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Map base
                    Container(
                      width: 100,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF4CAF50),
                            Color(0xFF2E7D32),
                            Color(0xFF81C784),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomPaint(
                        painter: MapDetailsPainter(),
                      ),
                    ),
                    // Location pin
                    Positioned(
                      top: 10,
                      child: Container(
                        width: 40,
                        height: 50,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            // Pin body
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF5722),
                                shape: BoxShape.circle,
                              ),
                            ),
                            // Pin center dot
                            Positioned(
                              top: 8,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            // Pin point
                            Positioned(
                              top: 28,
                              child: CustomPaint(
                                painter: PinPointPainter(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Title
              const Text(
                'Enable Location Services',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF36599F),
                ),
              ),

              const SizedBox(height: 20),

              // Description
              Text(
                'SafeReport uses your location to provide\naccurate crime alerts, nearby incidents,\nand faster emergency response.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // Settings Cards
              _buildSettingsCard(
                title: 'Precise Location',
                description: 'Recommended for accurate reporting\nand alerts',
                value: _preciseLocation,
                onChanged: (value) {
                  setState(() {
                    _preciseLocation = value ?? false;
                  });
                },
              ),

              const SizedBox(height: 20),

              _buildSettingsCard(
                title: 'Background Access',
                description: 'Allow alerts when app is not in use',
                value: _backgroundAccess,
                onChanged: (value) {
                  setState(() {
                    _backgroundAccess = value ?? false;
                  });
                },
              ),

              const SizedBox(height: 50),

              // Allow Location Access button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleAllowLocationAccess,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF36599F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Allow Location Access',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Skip for Now button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyDataScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF36599F),
                    side: const BorderSide(color: Color(0xFF36599F), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Skip for Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Footer text
              Text(
                'You can change this later in Settings',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF36599F),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF36599F),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey[400],
          ),
        ],
      ),
    );
  }
}

class MapDetailsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw some map-like lines
    paint.color = Colors.white.withOpacity(0.6);

    // Horizontal lines
    canvas.drawLine(
      Offset(10, size.height * 0.3),
      Offset(size.width - 10, size.height * 0.3),
      paint,
    );

    canvas.drawLine(
      Offset(15, size.height * 0.6),
      Offset(size.width - 15, size.height * 0.6),
      paint,
    );

    // Vertical lines
    canvas.drawLine(
      Offset(size.width * 0.3, 10),
      Offset(size.width * 0.3, size.height - 10),
      paint,
    );

    canvas.drawLine(
      Offset(size.width * 0.7, 15),
      Offset(size.width * 0.7, size.height - 15),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PinPointPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFFFF5722)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(-6, -12);
    path.lineTo(6, -12);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}