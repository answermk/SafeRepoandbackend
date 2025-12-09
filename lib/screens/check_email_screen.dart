import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'change_password_screen.dart';

class CheckEmailScreen extends StatefulWidget {
  final String email;
  
  const CheckEmailScreen({super.key, required this.email});

  @override
  State<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends State<CheckEmailScreen> {
  final _verificationController = TextEditingController();

  @override
  void dispose() {
    _verificationController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyEmail() async {
    final code = _verificationController.text.trim();
    
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 6-digit code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    try {
      final result = await AuthService.verifyCode(
        email: widget.email,
        code: code,
      );

      // Close loading dialog
      Navigator.of(context).pop();

      if (result['success'] == true) {
        // Navigate to change password screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChangePasswordScreen.forReset(
              email: widget.email,
              code: code,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Invalid or expired code'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleSendNewCode() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    try {
      final result = await AuthService.forgotPassword(widget.email);
      
      // Close loading dialog
      Navigator.of(context).pop();

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New verification code sent to your email.'),
            backgroundColor: Color(0xFF36599F),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to send new code'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF36599F),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Status Bar

              // Main content
              Expanded(
                child: _buildMainContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      color: const Color(0xFF36599F),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          const SizedBox(height: 80),

          // Email Icon with envelope design
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Envelope body
                Container(
                  width: 60,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Color(0xFF36599F), width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Envelope flap
                Container(
                  width: 60,
                  height: 30,
                  child: CustomPaint(
                    painter: EnvelopeFlapPainter(),
                  ),
                ),
                // Checkmark circle
                Positioned(
                  bottom: 15,
                  right: 15,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFF36599F),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Title
          const Text(
            'Check Your Email',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 20),

          // Subtitle
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'we\'ve sent a verification code to\n'),
                TextSpan(
                  text: widget.email,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 50),

          // Verification Code field
          _buildVerificationField(),

          const SizedBox(height: 30),

          // Verify Email button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _handleVerifyEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF5722), // Orange-red color from image
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Verify Email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const Spacer(),

          // Bottom links
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  // Handle didn't receive code - could show info dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Didn\'t receive code?'),
                      content: const Text('Please check your spam folder or try sending a new code.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text(
                  'Didn\'t receive code?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _handleSendNewCode,
                child: const Text(
                  'Send new code',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildVerificationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verification Code',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _verificationController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: const TextStyle(
            color: Color(0xFF36599F),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Enter 6 Digits',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            counterText: '', // Hide character counter
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class EnvelopeFlapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF36599F)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height * 0.6);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}