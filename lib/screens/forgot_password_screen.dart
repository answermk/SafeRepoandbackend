import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'check_email_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetLink() async {
    // Handle send reset link - backend functionality
    print('Send Reset Link button pressed');
    print('Email: ${_emailController.text}');

    // TODO: Implement actual password reset logic with backend
    // For now, simulate sending reset link

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF36599F)),
      ),
    );

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Close loading dialog
    Navigator.of(context).pop();

    // Navigate to check email screen after successful request
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CheckEmailScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const SizedBox(height: 80),

                // Shield with Key Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF36599F),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Key icon
                      Container(
                        width: 50,
                        height: 50,
                        child: CustomPaint(
                          painter: KeyPainter(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Title
                const Text(
                  'Forgot Your Password?',
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
                  'Enter your email address and we\'ll send you\ninstructions to reset your password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                // Email field
                _buildEmailField(),

                const SizedBox(height: 30),

                // Send Reset Link button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleSendResetLink,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF36599F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Send Reset Link',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Back to Sign In button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
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
                      'Back to Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'youremail@gmail.com',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF36599F)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class KeyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint keyPaint = Paint()
      ..color = const Color(0xFF5B9BD5) // Light blue for the key
      ..style = PaintingStyle.fill;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    // Key head (circle)
    canvas.drawCircle(
      Offset(centerX, centerY - 8),
      8,
      keyPaint,
    );

    // Key head inner circle (hole)
    final Paint holePaint = Paint()
      ..color = const Color(0xFF36599F)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(centerX, centerY - 8),
      4,
      holePaint,
    );

    // Key shaft
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, centerY + 8),
        width: 4,
        height: 16,
      ),
      keyPaint,
    );

    // Key teeth
    canvas.drawRect(
      Rect.fromLTWH(centerX - 6, centerY + 12, 8, 3),
      keyPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(centerX - 4, centerY + 16, 6, 3),
      keyPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}