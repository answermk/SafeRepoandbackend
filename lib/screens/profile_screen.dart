import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/token_manager.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'my_reports_screen.dart';
import 'messages_screen.dart';
import 'profile_edit_screen.dart';
import 'account_settings_screen.dart';
import 'help_support_screen.dart';
import 'login_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3; // For bottom navigation

  // These will be populated from backend
  String userName = "User";
  String memberSince = "Member";
  String userEmail = "";
  String userPhone = "";
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  /// Format "Member since" with relative time or absolute year
  String _formatMemberSince(dynamic createdAt) {
    if (createdAt == null) return "Member";
    
    try {
      final createdDate = DateTime.parse(createdAt.toString());
      final now = DateTime.now();
      final difference = now.difference(createdDate);
      
      // Less than 1 hour
      if (difference.inHours < 1) {
        final minutes = difference.inMinutes;
        return minutes <= 1 ? "Member since just now" : "Member since $minutes minutes ago";
      }
      // Less than 24 hours
      else if (difference.inHours < 24) {
        final hours = difference.inHours;
        return "Member since $hours ${hours == 1 ? 'hour' : 'hours'} ago";
      }
      // Less than 30 days
      else if (difference.inDays < 30) {
        final days = difference.inDays;
        return "Member since $days ${days == 1 ? 'day' : 'days'} ago";
      }
      // Less than 12 months
      else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return "Member since $months ${months == 1 ? 'month' : 'months'} ago";
      }
      // More than 1 year - show year only
      else {
        return "Member since ${createdDate.year}";
      }
    } catch (e) {
      return "Member";
    }
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get user ID from token
      final userId = await TokenManager.getUserId();
      if (userId == null) {
        // Try to get username and email from token as fallback
        final username = await TokenManager.getUsername();
        final email = await TokenManager.getEmail();
        
        setState(() {
          userName = username ?? "User";
          userEmail = email ?? "";
          memberSince = "Member";
          _isLoading = false;
        });
        return;
      }

      // Fetch user profile from backend
      final result = await UserService.getUserProfile(userId);
      
      if (result['success'] == true && result['data'] != null) {
        final userData = result['data'] as Map<String, dynamic>;
        
        // Format "Member since" date with relative or absolute time
        String formattedMemberSince = _formatMemberSince(userData['createdAt']);
        
        setState(() {
          _userData = userData;
          // Prioritize fullName over username
          userName = userData['fullName']?.toString().trim().isNotEmpty == true 
              ? userData['fullName'] 
              : (userData['username'] ?? "User");
          userEmail = userData['email'] ?? "";
          userPhone = userData['phoneNumber']?.toString().trim().isNotEmpty == true 
              ? userData['phoneNumber'] 
              : "Not provided";
          memberSince = formattedMemberSince;
          _isLoading = false;
        });
      } else {
        // Fallback to token data
        final username = await TokenManager.getUsername();
        final email = await TokenManager.getEmail();
        
        setState(() {
          userName = username ?? "User";
          userEmail = email ?? "";
          memberSince = "Member";
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
      // Fallback to token data
      final username = await TokenManager.getUsername();
      final email = await TokenManager.getEmail();
      
      setState(() {
        userName = username ?? "User";
        userEmail = email ?? "";
        memberSince = "Member";
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout != true) {
      return; // User cancelled
    }

    // Show loading indicator
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF36599F)),
      ),
    );

    try {
      // Call logout service (this will clear tokens)
      await AuthService.logout();
    } catch (e) {
      print('Error during logout: $e');
      // Continue with logout even if API call fails
    }

    // Close loading dialog
    if (!mounted) return;
    Navigator.of(context).pop();

    // Navigate to login screen and clear all previous routes
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF36599F)),
              )
            : Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      _buildHeader(),
                      Positioned(
                        top: 120, // Position to overlap blue header
                        child: _buildProfileCard(),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 100), // Space for overlapping card
                          _buildAccountInfoCard(),
                          const SizedBox(height: 30),
                          _buildActionButtons(),
                          const SizedBox(height: 100), // Space for bottom nav
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return ClipPath(
      clipper: CurvedBottomClipper(),
      child: Container(
        width: double.infinity,
        height: 200,
        color: const Color(0xFF36599F),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 30, right: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Profile Avatar - overlapping the blue background
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF36599F),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          // User name - populated from backend
          Text(
            userName,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Member since - populated from backend
          Text(
            memberSince,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard() {
    // Get username from backend data if available
    final username = _userData?['username']?.toString() ?? "";
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Information',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF36599F),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Full Name', userName),
          if (username.isNotEmpty) ...[
            const SizedBox(height: 15),
            _buildInfoRow('Username', username),
          ],
          const SizedBox(height: 15),
          _buildInfoRow('Email', userEmail, isEmail: true),
          const SizedBox(height: 15),
          _buildInfoRow('Phone Number', userPhone, isRequired: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isEmail = false, bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        isEmail
            ? GestureDetector(
                onTap: () {
                  // TODO: Open email client or copy email
                },
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF36599F),
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
            : Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w400,
                ),
              ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          // Settings Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountSettingsScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF36599F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.settings, size: 20, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Help & Support Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpSupportScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF36599F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.help_outline, size: 20, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Help & Support',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileEditScreen(),
                  ),
                );
                // Refresh profile if changes were saved
                if (result == true) {
                  _loadUserProfile();
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF36599F), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(
                  color: Color(0xFF36599F),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Change Password Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen.forSettings(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF36599F), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Change Password',
                style: TextStyle(
                  color: Color(0xFF36599F),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),

          // Logout Button - centered and slightly narrower
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA580C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', 0, false, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              ),
            );
          }),
          _buildNavItem(Icons.description, 'Reports', 1, false, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyReportsScreen(),
              ),
            );
          }),
          _buildNavItem(Icons.message, 'Messages', 2, false, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MessagesScreen(),
              ),
            );
          }),
          _buildNavItem(Icons.person, 'Profile', 3, true, () {
            // Current screen, no navigation needed
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0E7FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF36599F) : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? const Color(0xFF36599F) : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}