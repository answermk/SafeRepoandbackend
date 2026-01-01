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
import '../utils/translation_helper.dart';
import '../utils/theme_helper.dart';
import '../l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 3; // For bottom navigation

  // These will be populated from backend
  String userName = "User";
  String memberSince = "Member";
  String userEmail = "";
  String userPhone = "";
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true; // Keep screen alive to prevent freezing

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _startKeepAlive();
  }

  // Keep-alive mechanism to prevent app from freezing
  void _startKeepAlive() {
    // This will help keep the app active
    // The AutomaticKeepAliveClientMixin will handle the rest
  }

  /// Format "Member since" with exact date
  String _formatMemberSince(dynamic createdAt) {
    if (createdAt == null) {
      print('⚠️ CreatedAt is null');
      return "Member since unknown";
    }
    
    try {
      // Handle different date formats (ISO string, timestamp, etc.)
      DateTime createdDate;
      if (createdAt is String) {
        // Handle ISO 8601 format
        createdDate = DateTime.parse(createdAt);
      } else if (createdAt is int) {
        // Handle timestamp in milliseconds
        createdDate = DateTime.fromMillisecondsSinceEpoch(createdAt);
      } else if (createdAt is DateTime) {
        createdDate = createdAt;
      } else {
        // Try to parse as string
        createdDate = DateTime.parse(createdAt.toString());
      }
      
      // Format as "Member since Month Year" (e.g., "Member since January 2024")
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      
      return "Member since ${months[createdDate.month - 1]} ${createdDate.year}";
    } catch (e) {
      print('Error formatting member since: $e');
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
        
        // Debug: Print user data to see what we're getting
        print('📋 User Profile Data: $userData');
        print('📋 Phone Number: ${userData['phoneNumber']}');
        print('📋 Created At: ${userData['createdAt']}');
        
        // Format "Member since" date with relative or absolute time
        String formattedMemberSince = _formatMemberSince(userData['createdAt']);
        
        setState(() {
          _userData = userData;
          // Prioritize fullName over username
          userName = userData['fullName']?.toString().trim().isNotEmpty == true 
              ? userData['fullName'] 
              : (userData['username'] ?? "User");
          userEmail = userData['email'] ?? "";
          
          // Handle phone number - check multiple possible field names
          final phoneValue = userData['phoneNumber'] ?? 
                            userData['phone'] ?? 
                            userData['phone_number'];
          userPhone = (phoneValue != null && phoneValue.toString().trim().isNotEmpty)
              ? phoneValue.toString().trim()
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
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final t = TranslationHelper.of(context);
    final scaffold = ThemeHelper.getScaffoldBackgroundColor(context);
    final card = ThemeHelper.getCardColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondary = ThemeHelper.getSecondaryTextColor(context);
    final primary = ThemeHelper.getPrimaryColor(context);

    return Scaffold(
      backgroundColor: scaffold,
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
                        left: 0,
                        right: 0,
                        child: _buildProfileCard(textColor, secondary),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 100), // Space for overlapping card
                          _buildAccountInfoCard(t, textColor, secondary),
                          const SizedBox(height: 30),
                          _buildActionButtons(t, primary),
                          const SizedBox(height: 100), // Space for bottom nav
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: _buildBottomNavigation(t, primary),
    );
  }

  Widget _buildHeader() {
    return ClipPath(
      clipper: CurvedBottomClipper(),
      child: Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF36599F),
              const Color(0xFF4A7BC8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(Color textColor, Color secondary) {
    // Get user initials for avatar
    String initials = userName.isNotEmpty
        ? userName.split(' ').map((n) => n.isNotEmpty ? n[0].toUpperCase() : '').take(2).join()
        : 'U';
    if (initials.isEmpty) initials = 'U';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 30, right: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Avatar with gradient background
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF36599F), Color(0xFF4A7BC8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF36599F).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // User name - populated from backend
          Text(
            userName,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: textColor,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          // Member since - populated from backend with icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: secondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  memberSince,
                  style: TextStyle(
                    fontSize: 15,
                    color: secondary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard(AppLocalizations t, Color textColor, Color secondary) {
    // Get username from backend data if available
    final username = _userData?['username']?.toString() ?? "";
    final role = _userData?['role']?.toString() ?? "";
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF36599F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_circle,
                  color: Color(0xFF36599F),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                t.accountInformation,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF36599F),
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow(Icons.person, t.fullName, userName, textColor, secondary),
          if (username.isNotEmpty) ...[
            const SizedBox(height: 18),
            _buildInfoRow(Icons.alternate_email, t.usernameLabel, username, textColor, secondary),
          ],
          const SizedBox(height: 18),
          _buildInfoRow(Icons.email, t.email, userEmail, textColor, secondary, isEmail: true),
          const SizedBox(height: 18),
          _buildInfoRow(Icons.phone, t.phoneNumberLabel, userPhone, textColor, secondary, isRequired: true),
          if (role.isNotEmpty) ...[
            const SizedBox(height: 18),
            _buildInfoRow(Icons.badge, 'Role', role, textColor, secondary),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color textColor, Color secondary, {bool isEmail = false, bool isRequired = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF36599F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF36599F),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  if (isRequired) ...[
                    const SizedBox(width: 4),
                    const Text(
                      '*',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              isEmail
                  ? GestureDetector(
                      onTap: () {
                        // TODO: Open email client or copy email
                      },
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF36599F),
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                  : Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(AppLocalizations t, Color primary) {
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
                backgroundColor: primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.settings, size: 20, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    t.settings,
                    style: const TextStyle(
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
                backgroundColor: primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.help_outline, size: 20, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    t.helpSupport,
                    style: const TextStyle(
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
                side: BorderSide(color: primary, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                t.editProfile,
                style: TextStyle(
                  color: primary,
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
                side: BorderSide(color: primary, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                t.changePassword,
                style: TextStyle(
                  color: primary,
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
                child: Text(
                  t.logout,
                  style: const TextStyle(
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

  Widget _buildBottomNavigation(AppLocalizations t, Color primary) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: ThemeHelper.getCardColor(context),
        boxShadow: [
          BoxShadow(
            color: ThemeHelper.getShadowColor(context),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, t.home, 0, false, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              ),
            );
          }),
          _buildNavItem(Icons.description, t.myReports, 1, false, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyReportsScreen(),
              ),
            );
          }),
          _buildNavItem(Icons.message, t.messages, 2, false, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MessagesScreen(),
              ),
            );
          }),
          _buildNavItem(Icons.person, t.profile, 3, true, () {
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
          color: isSelected ? ThemeHelper.getPrimaryColor(context).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? ThemeHelper.getPrimaryColor(context) : ThemeHelper.getSecondaryTextColor(context),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? ThemeHelper.getPrimaryColor(context) : ThemeHelper.getSecondaryTextColor(context),
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