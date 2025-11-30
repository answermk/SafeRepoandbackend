import 'package:flutter/material.dart';
import 'onboarding_screen_1.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content
          SafeArea(
        child: Column(
          children: [
                // Top white section with illustration
            Expanded(
                  flex: 5,
              child: Container(
                width: double.infinity,
                color: Colors.white,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Image.network(
                          'https://cdn-icons-png.flaticon.com/512/9305/9305665.png',
                          height: 280,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 280,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: Color(0xFF36599F),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 280,
                              width: 280,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.live_tv, size: 80, color: Color(0xFF36599F)),
                                  SizedBox(height: 10),
                                  Text(
                                    'LIVE',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF36599F),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                                ),
                              ),
                            ),
                // Bottom blue section with wavy background
            Expanded(
                  flex: 5,
                  child: Stack(
                    children: [
                      // Blue wavy background
                      CustomPaint(
                        size: Size(double.infinity, double.infinity),
                        painter: WelcomeWavePainter(),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 60, 30, 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App title
                      Text(
                        'SafeReport',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                            SizedBox(height: 25),
                      // Description
                      Text(
                        'A Real-Time Crime Prevention Platform uses smart technology to detect and respond to crime instantly, helping keep communities safe through quick alerts and data-driven actions.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.95),
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Spacer(),
                      // Get Started Button
                      Container(
                        width: double.infinity,
                              height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OnboardingScreen1(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xFF36599F),
                            shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                    ],
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

// Custom painter for the wavy blue background
class WelcomeWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF36599F)
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Start from top-left with a wave
    path.moveTo(0, size.height * 0.15);
    
    // Create a smooth wave at the top
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.05,
      size.width * 0.5,
      size.height * 0.10,
    );
    
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.15,
      size.width,
      size.height * 0.05,
    );
    
    // Complete the path
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}