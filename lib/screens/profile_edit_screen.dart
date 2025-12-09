import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/user_service.dart';
import '../services/token_manager.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _emergencyNameController = TextEditingController();
  final TextEditingController _emergencyPhoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasError = false;
  String _errorMessage = '';
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get user ID from token
      _userId = await TokenManager.getUserId();
      if (_userId == null) {
        // Fallback: try to get from email
        final email = await TokenManager.getEmail();
        if (email != null) {
          // Use token data as fallback
          final username = await TokenManager.getUsername();
          setState(() {
            _nameController.text = username ?? '';
            _emailController.text = email;
            _phoneController.text = '';
            _locationController.text = '';
            _emergencyNameController.text = '';
            _emergencyPhoneController.text = '';
            _isLoading = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unable to load full profile. Using available data.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        } else {
          // No user ID and no email - show error
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = 'User ID not found. Please login again.';
          });
          return;
        }
      }

      // Fetch user profile from backend
      final result = await UserService.getUserProfile(_userId!);
      
      if (result['success'] == true && result['data'] != null) {
        final userData = result['data'] as Map<String, dynamic>;
        
        setState(() {
          _nameController.text = userData['fullName']?.toString().trim() ?? 
                                userData['username']?.toString().trim() ?? '';
          _emailController.text = userData['email']?.toString().trim() ?? '';
          _phoneController.text = userData['phoneNumber']?.toString().trim() ?? '';
          _locationController.text = ''; // Location not in UserDTO
          _emergencyNameController.text = ''; // Emergency contact not in UserDTO
          _emergencyPhoneController.text = ''; // Emergency contact not in UserDTO
          _isLoading = false;
        });
      } else {
        // Fallback to token data
        final username = await TokenManager.getUsername();
        final email = await TokenManager.getEmail();
        
        setState(() {
          _nameController.text = username ?? '';
          _emailController.text = email ?? '';
          _phoneController.text = '';
          _locationController.text = '';
          _emergencyNameController.text = '';
          _emergencyPhoneController.text = '';
          _isLoading = false;
        });
        
        if (mounted) {
          final errorMsg = result['error']?.toString() ?? 'Failed to load profile';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Warning: $errorMsg. Using available data.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
      // Fallback to token data
      final username = await TokenManager.getUsername();
      final email = await TokenManager.getEmail();
      
      setState(() {
        _nameController.text = username ?? '';
        _emailController.text = email ?? '';
        _phoneController.text = '';
        _locationController.text = '';
        _emergencyNameController.text = '';
        _emergencyPhoneController.text = '';
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF36599F)),
              )
            : _hasError && _nameController.text.isEmpty
                ? _buildErrorState()
                : Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(
                                'Full Name',
                                'Enter your Full Name',
                                _nameController,
                                isRequired: true,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                'Email Address',
                                'youremail@gmail.com',
                                _emailController,
                                isEmail: true,
                                isReadOnly: true, // Email usually shouldn't be changed
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                'Phone Number',
                                '+250 7............',
                                _phoneController,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                'Location',
                                'Enter your location',
                                _locationController,
                              ),
                              const SizedBox(height: 24),
                              _buildEmergencyContactSection(),
                              const SizedBox(height: 32),
                              _buildSaveCancelButtons(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
      child: Container(
        width: double.infinity,
        color: const Color(0xFF36599F),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Manage your personal information',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.shade300,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isRequired = false,
    bool isEmail = false,
    bool isReadOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          enabled: !isReadOnly,
          readOnly: isReadOnly,
          keyboardType: keyboardType,
          validator: (value) {
            if (isRequired && (value == null || value.trim().isEmpty)) {
              return 'Please enter $label';
            }
            if (isEmail && value != null && value.isNotEmpty) {
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address';
              }
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF36599F), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 15,
            ),
            suffixIcon: isReadOnly
                ? const Icon(Icons.lock_outline, size: 18, color: Colors.grey)
                : null,
          ),
          style: TextStyle(
            fontSize: 15,
            color: isReadOnly ? Colors.grey[600] : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyContactSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emergency Contact',
            style: TextStyle(
              color: Color(0xFF36599F),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emergencyNameController,
            decoration: InputDecoration(
              hintText: 'Jane Doe',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF36599F), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 15,
              ),
            ),
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emergencyPhoneController,
            decoration: InputDecoration(
              hintText: '+250 7............',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF36599F), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 15,
              ),
            ),
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if user ID exists
    if (_userId == null) {
      // Try to get user ID again
      _userId = await TokenManager.getUserId();
      if (_userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User ID not found. Please login again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          // Navigate back after showing error
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }
        return;
      }
    }

    // Validate required fields
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Full Name is required'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final result = await UserService.updateUserProfile(
        userId: _userId!,
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        // Note: location, emergencyContactName, emergencyContactPhone are not in backend DTO yet
        // They will be ignored by the backend
      );

      setState(() {
        _isSaving = false;
      });

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate refresh needed
      } else {
        // Parse error message from backend
        String errorMessage = 'Failed to update profile';
        final error = result['error'];
        
        if (error != null) {
          try {
            // Try to parse JSON error response
            final errorData = error is String ? error : error.toString();
            if (errorData.contains('{')) {
              final parsed = jsonDecode(errorData);
              errorMessage = parsed['message'] ?? parsed['error'] ?? errorMessage;
            } else {
              errorMessage = errorData;
            }
          } catch (e) {
            // If not JSON, use the error string directly
            errorMessage = error.toString();
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      
      if (!mounted) return;
      
      String errorMessage = 'An error occurred while updating profile';
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        errorMessage = 'No internet connection. Please check your network and try again.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Request timed out. Please try again.';
      } else {
        errorMessage = 'Error: ${e.toString()}';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _buildSaveCancelButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF36599F),
              disabledBackgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _isSaving ? null : () {
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: _isSaving ? Colors.grey[300]! : const Color(0xFF36599F),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: _isSaving ? Colors.grey[600] : const Color(0xFF36599F),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            const Text(
              'Unable to Load Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage.isNotEmpty 
                  ? _errorMessage 
                  : 'An error occurred while loading your profile. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _errorMessage = '';
                });
                _loadUserProfile();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF36599F),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF36599F), width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Go Back',
                style: TextStyle(
                  color: Color(0xFF36599F),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}