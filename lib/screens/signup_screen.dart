import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'login_screen.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';
import '../utils/translation_helper.dart';
import '../utils/theme_helper.dart';
import '../l10n/app_localizations.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _registerAnonymously = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAccount() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validate password match
    if (password != confirmPassword) {
      _showMessage('Passwords do not match', isError: true);
      return;
    }

    // Validate password strength
    final passwordError = Validators.password(password);
    if (passwordError != null) {
      _showMessage(passwordError, isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Auto-generate username from email if not provided
      final finalUsername = username.isEmpty 
          ? email.split('@')[0] // Use part before @ as username
          : username;
      
      // Call backend API
      final result = await AuthService.register(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        username: finalUsername,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          // Show success message
          _showMessage(
            result['message'] ?? 'Account created successfully! Please sign in.',
            isError: false,
          );

          // Navigate to login screen after successful signup
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            }
          });
        } else {
          // Show error message
          final errorMessage = result['error'] ?? 'Failed to create account';
          _showMessage(errorMessage, isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showMessage('Connection error: ${e.toString()}', isError: true);
      }
    }
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final scaffold = ThemeHelper.getScaffoldBackgroundColor(context);
    final card = ThemeHelper.getCardColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondary = ThemeHelper.getSecondaryTextColor(context);
    final primary = ThemeHelper.getPrimaryColor(context);

    return Scaffold(
      backgroundColor: scaffold,
      body: Stack(
        children: [
          // Background with curved waves
          _buildBackground(),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  const SizedBox(height: 60),

                  // Title
                  Text(
                    t.signUpTitle,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Full Name field
                  _buildInputField(
                    label: t.fullName,
                    controller: _fullNameController,
                    hintText: t.enterFullName,
                    keyboardType: TextInputType.name,
                    validator: (value) => Validators.required(value, fieldName: t.fullName),
                  ),

                  const SizedBox(height: 20),

                  // Email field
                  _buildInputField(
                    label: t.emailAddress,
                    controller: _emailController,
                    hintText: t.youremailGmailCom,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),

                  const SizedBox(height: 20),

                  // Phone Number field
                  _buildInputField(
                    label: t.phoneNumberLabel,
                    controller: _phoneNumberController,
                    hintText: '+250 788 123 456',
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return t.phoneRequired;
                      }
                      return Validators.phone(value);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Username field (optional)
                  _buildInputField(
                    label: t.usernameOptionalLabel,
                    controller: _usernameController,
                    hintText: t.usernameOptionalHint,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        if (value.length < 3) {
                          return t.usernameMustBeAtLeast3Characters;
                        }
                        if (value.length > 50) {
                          return t.usernameMustBeLessThan50Characters;
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Password field
                  _buildPasswordField(
                    label: t.password,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onToggleVisibility: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // Confirm Password field
                  _buildPasswordField(
                    label: t.confirmPassword,
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),

                  const SizedBox(height: 30),

                  // Register Anonymously toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t.registerAnonymously,
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF4CAF50),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Switch(
                        value: _registerAnonymously,
                        onChanged: (value) {
                          setState(() {
                            _registerAnonymously = value;
                          });
                        },
                        activeColor: Colors.white,
                        activeTrackColor: const Color(0xFF4CAF50),
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey[300],
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Create Account button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleCreateAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF36599F),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              t.createAccount,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Already have account section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t.alreadyHaveAccount,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor,
                        ),
                      ),
                      SizedBox(
                        height: 35,
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
                            side: const BorderSide(color: Color(0xFF36599F)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          child: Text(
                            t.signIn,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        // Top curved wave
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 120,
            child: CustomPaint(
              painter: TopWavePainter(),
              child: Container(),
            ),
          ),
        ),

        // Bottom curved wave
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 150,
            child: CustomPaint(
              painter: BottomWavePainter(),
              child: Container(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ThemeHelper.getTextColor(context),
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
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: ThemeHelper.getSecondaryTextColor(context),
                fontSize: 14,
              ),
              filled: true,
              fillColor: ThemeHelper.getCardColor(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ThemeHelper.getDividerColor(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ThemeHelper.getDividerColor(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ThemeHelper.getPrimaryColor(context)),
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

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ThemeHelper.getTextColor(context),
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
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: '***********',
              hintStyle: TextStyle(
                color: ThemeHelper.getSecondaryTextColor(context),
                fontSize: 14,
              ),
              filled: true,
              fillColor: ThemeHelper.getCardColor(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ThemeHelper.getDividerColor(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ThemeHelper.getDividerColor(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: ThemeHelper.getPrimaryColor(context)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[600],
                  size: 20,
                ),
                onPressed: onToggleVisibility,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TopWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF36599F)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.lineTo(0, size.height * 0.7);

    final controlPoint1 = Offset(size.width * 0.3, size.height * 0.9);
    final controlPoint2 = Offset(size.width * 0.7, size.height * 0.3);
    final endPoint = Offset(size.width, size.height * 0.5);

    path.cubicTo(
      controlPoint1.dx, controlPoint1.dy,
      controlPoint2.dx, controlPoint2.dy,
      endPoint.dx, endPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF36599F)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.5);

    final controlPoint1 = Offset(size.width * 0.3, size.height * 0.7);
    final controlPoint2 = Offset(size.width * 0.7, size.height * 0.1);
    final endPoint = Offset(size.width, size.height * 0.3);

    path.cubicTo(
      controlPoint1.dx, controlPoint1.dy,
      controlPoint2.dx, controlPoint2.dy,
      endPoint.dx, endPoint.dy,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}