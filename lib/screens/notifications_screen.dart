import 'package:flutter/material.dart';
import 'privacy_data_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Future<void> _handleEnableNotifications() async {
    // Handle enable notifications - backend functionality
    print('Enable Notifications button pressed');

    // TODO: Implement actual notification permission logic with backend
    // For now, simulate successful notification permission grant

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF36599F)),
      ),
    );

    // Simulate API call and notification permission request
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

              // Person with megaphone illustration
              Container(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Decorative dots
                    Positioned(
                      top: 10,
                      left: 20,
                      child: _buildDot(Colors.pink, 4),
                    ),
                    Positioned(
                      top: 25,
                      right: 15,
                      child: _buildDot(Colors.pink, 3),
                    ),
                    Positioned(
                      bottom: 30,
                      left: 10,
                      child: _buildDot(Colors.grey[400]!, 3),
                    ),
                    Positioned(
                      bottom: 15,
                      right: 25,
                      child: _buildDot(Colors.grey[400]!, 4),
                    ),

                    // Main illustration
                    Container(
                      width: 100,
                      height: 120,
                      child: Column(
                        children: [
                          // Person's head
                          Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Color(0xFFFFDBD1),
                              shape: BoxShape.circle,
                            ),
                            child: Stack(
                              children: [
                                // Hair
                                Positioned(
                                  top: 5,
                                  left: 8,
                                  right: 8,
                                  child: Container(
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF2C3E50),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),

                          // Person's body and megaphone
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Body
                              Container(
                                width: 30,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color(0xFF5D80C1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              SizedBox(width: 5),

                              // Megaphone
                              Container(
                                width: 35,
                                height: 25,
                                child: CustomPaint(
                                  painter: MegaphonePainter(),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),

                          // Legs
                          Container(
                            width: 25,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Color(0xFF2C3E50),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Sound waves from megaphone
                    Positioned(
                      right: 10,
                      top: 45,
                      child: CustomPaint(
                        size: Size(30, 20),
                        painter: SoundWavesPainter(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Title
              const Text(
                'Enable Notifications',
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
                'Receive real-time alerts about crimes,\nemergencies, and safety updates in your\narea.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // Notification Type Cards
              _buildNotificationCard(
                icon: Icons.notifications_active,
                iconColor: Colors.red,
                title: 'Emergency Alerts',
                description: 'Critical incidents near you',
              ),

              const SizedBox(height: 15),

              _buildNotificationCard(
                icon: Icons.group,
                iconColor: Colors.orange,
                title: 'Community Updates',
                description: 'Local safety news',
              ),

              const SizedBox(height: 15),

              _buildNotificationCard(
                icon: Icons.campaign,
                iconColor: const Color(0xFF36599F),
                title: 'Report Status',
                description: 'Updates on your submissions',
              ),

              const SizedBox(height: 50),

              // Enable Notifications button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleEnableNotifications,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF36599F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Enable Notifications',
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
                'You can customize notifications later',
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

  Widget _buildDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
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
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
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
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MegaphonePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Megaphone body (light gray)
    paint.color = Color(0xFFE0E0E0);
    canvas.drawRRect(
      RRect.fromLTRBR(0, 8, size.width * 0.7, size.height - 8, Radius.circular(4)),
      paint,
    );

    // Megaphone cone (white)
    paint.color = Colors.white;
    final path = Path();
    path.moveTo(size.width * 0.65, 5);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width * 0.65, size.height - 5);
    path.close();
    canvas.drawPath(path, paint);

    // Handle
    paint.color = Color(0xFFBDBDBD);
    canvas.drawRRect(
      RRect.fromLTRBR(5, size.height - 3, 15, size.height + 8, Radius.circular(2)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SoundWavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF5D80C1).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw sound wave lines
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(15, size.height * 0.2), paint);
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(20, size.height * 0.4), paint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(15, size.height * 0.8), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}