import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/token_manager.dart';
import 'login_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String? email;
  final String? code;
  final String? userId;
  
  // For password reset flow (forgot password)
  const ChangePasswordScreen.forReset({
    super.key,
    required String email,
    required String code,
  }) : email = email,
       code = code,
       userId = null;
  
  // For settings flow (authenticated user)
  const ChangePasswordScreen.forSettings({
    super.key,
    String? userId,
  }) : email = null,
       code = null,
       userId = userId;
  
  // Legacy constructor for backward compatibility
  const ChangePasswordScreen({
    super.key,
    this.email,
    this.code,
    this.userId,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  
  bool get _isResetFlow => widget.email != null && widget.code != null;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
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
        child: CircularProgressIndicator(color: Color(0xFF36599F)),
      ),
    );

    try {
      Map<String, dynamic> result;
      
      if (_isResetFlow) {
        // Password reset flow (forgot password)
        result = await AuthService.changePassword(
          email: widget.email!,
          code: widget.code!,
          newPassword: newPassword,
          confirmPassword: confirmPassword,
        );
      } else {
        // Settings flow (authenticated user) - check 30-day rule
        final userId = widget.userId ?? await TokenManager.getUserId();
        if (userId == null) {
          Navigator.of(context).pop(); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User not found. Please login again.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        // Check if password can be changed (30-day rule)
        final userInfo = await UserService.getUserProfile(userId);
        if (userInfo['success'] == true && userInfo['data'] != null) {
          final userData = userInfo['data'] as Map<String, dynamic>;
          final passwordChangedAt = userData['passwordChangedAt'];
          
          if (passwordChangedAt != null) {
            final changedDate = DateTime.parse(passwordChangedAt);
            final now = DateTime.now();
            final daysSinceChange = now.difference(changedDate).inDays;
            
            if (daysSinceChange < 30) {
              Navigator.of(context).pop(); // Close loading
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Password can only be changed once every 30 days. Last changed $daysSinceChange days ago. Please wait ${30 - daysSinceChange} more days.',
                  ),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 5),
                ),
              );
              return;
            }
          }
        }
        
        final currentPassword = _currentPasswordController.text.trim();
        if (currentPassword.isEmpty) {
          Navigator.of(context).pop(); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter your current password'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        result = await UserService.changePassword(
          userId: userId,
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
      }

      // Close loading dialog
      Navigator.of(context).pop();

      if (result['success'] == true) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );

        if (_isResetFlow) {
          // Navigate to login screen for reset flow
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
            (route) => false,
          );
        } else {
          // Just go back for settings flow
          Navigator.of(context).pop();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to change password'),
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 80),

                  // Lock Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF36599F),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Title
                  const Text(
                    'Change Your Password',
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
                    _isResetFlow
                        ? 'Enter your new password below.'
                        : 'Enter your current password and new password below.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Current Password field (only for settings flow)
                  if (!_isResetFlow)
                    _buildPasswordField(
                      controller: _currentPasswordController,
                      label: 'Current Password',
                      obscureText: _obscureCurrentPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        });
                      },
                    ),

                  if (!_isResetFlow) const SizedBox(height: 20),

                  // New Password field
                  _buildPasswordField(
                    controller: _newPasswordController,
                    label: 'New Password',
                    obscureText: _obscureNewPassword,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // Confirm Password field
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    obscureText: _obscureConfirmPassword,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),

                  const SizedBox(height: 30),

                  // Change Password button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleChangePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF36599F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Back button (different text based on flow)
                  if (_isResetFlow)
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
                  if (!_isResetFlow)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF36599F),
                          side: const BorderSide(color: Color(0xFF36599F), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
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
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
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
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              if (label != 'Current Password' && value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Enter $label',
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
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[600],
                ),
                onPressed: onToggleVisibility,
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
