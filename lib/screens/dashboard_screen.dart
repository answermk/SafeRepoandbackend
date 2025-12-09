import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safereport_mobo/l10n/app_localizations.dart';
import '../services/token_manager.dart';
import '../services/community_service.dart';
import '../services/map_service.dart';
import '../utils/theme_helper.dart';
import 'emergency_mode_screen.dart';
import 'report_crime_screen.dart';
import 'my_watch_groups_screen.dart';
import 'my_reports_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import 'community_statistics_screen.dart'; // NEW
import 'my_impact_screen.dart'; // NEW
import 'nearby_incidents_screen.dart'; // NEW
import 'safety_education_screen.dart'; // NEW

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // These will be populated from backend
  String userName = "User";
  String thisWeekReports = "Loading...";
  String avgResponse = "Loading...";
  String safetyLevel = "Loading...";
  String watchGroupInfo = "Oak Street Watch • 2 new alerts";
  int nearbyIncidentsCount = 0; // populated from backend
  bool isLoadingCommunityStatus = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCommunityStatus();
  }

  Future<void> _loadUserData() async {
    print('Loading user data from backend...');
    // Load username from stored token
    final username = await TokenManager.getUsername();
    if (username != null && username.isNotEmpty) {
      setState(() {
        userName = username;
      });
    }
  }

  Future<void> _loadCommunityStatus() async {
    try {
      setState(() {
        isLoadingCommunityStatus = true;
      });

      // Get user's current location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Use default location (Kigali) if location services are disabled
        _fetchCommunityStatus(-1.9441, 30.0619);
        _fetchNearbyIncidentsCount(-1.9441, 30.0619);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Use default location if permission denied
          _fetchCommunityStatus(-1.9441, 30.0619);
          _fetchNearbyIncidentsCount(-1.9441, 30.0619);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Use default location if permission permanently denied
        _fetchCommunityStatus(-1.9441, 30.0619);
        _fetchNearbyIncidentsCount(-1.9441, 30.0619);
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      _fetchCommunityStatus(position.latitude, position.longitude);
      _fetchNearbyIncidentsCount(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting location: $e');
      // Use default location on error
      _fetchCommunityStatus(-1.9441, 30.0619);
      _fetchNearbyIncidentsCount(-1.9441, 30.0619);
    }
  }

  Future<void> _fetchCommunityStatus(double latitude, double longitude) async {
    try {
      final result = await CommunityService.getCommunityStatus(
        latitude: latitude,
        longitude: longitude,
        radiusKm: 5.0, // 5km radius
      );

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        setState(() {
          final weekCount = data['thisWeekReports'] ?? 0;
          thisWeekReports = '$weekCount ${weekCount == 1 ? 'report' : 'reports'}';
          avgResponse = data['avgResponse'] ?? 'N/A';
          safetyLevel = data['safetyLevel'] ?? 'Unknown';
          isLoadingCommunityStatus = false;
        });
      } else {
        setState(() {
          thisWeekReports = '0 reports';
          avgResponse = 'N/A';
          safetyLevel = 'Unknown';
          isLoadingCommunityStatus = false;
        });
      }
    } catch (e) {
      print('Error fetching community status: $e');
      setState(() {
        thisWeekReports = 'Error';
        avgResponse = 'Error';
        safetyLevel = 'Error';
        isLoadingCommunityStatus = false;
      });
    }
  }

  Future<void> _fetchNearbyIncidentsCount(double latitude, double longitude) async {
    try {
      final result = await MapService.getLiveIncidentsInArea(
        latitude: latitude,
        longitude: longitude,
        radiusKm: 5.0,
        timeRange: '24h',
      );

      if (result['success'] == true && result['data'] != null) {
        final List<dynamic> incidents = result['data'] as List<dynamic>;
        setState(() {
          nearbyIncidentsCount = incidents.length;
        });
      } else {
        setState(() {
          nearbyIncidentsCount = 0;
        });
      }
    } catch (e) {
      print('Error fetching nearby incidents: $e');
      setState(() {
        nearbyIncidentsCount = 0;
      });
    }
  }

  /// Get greeting based on time of day
  String _getGreeting(BuildContext context, String userName) {
    final localizations = AppLocalizations.of(context);
    final hour = DateTime.now().hour;
    String greeting;
    if (hour >= 5 && hour < 12) {
      // Morning: 5:00 AM - 11:59 AM
      greeting = localizations?.goodMorning(userName) ?? 'Good Morning, $userName';
    } else if (hour >= 12 && hour < 17) {
      // Afternoon: 12:00 PM - 4:59 PM
      greeting = localizations?.goodAfternoon(userName) ?? 'Good Afternoon, $userName';
    } else {
      // Evening/Night: 5:00 PM - 4:59 AM
      greeting = localizations?.goodEvening(userName) ?? 'Good Evening, $userName';
    }
    return greeting;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.getScaffoldBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildMainContent()),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          _buildCommunityStatusCard(), // Tappable now
          _buildQuickActions(), // Added My Impact
          _buildNearbyIncidentsCard(), // NEW
          _buildWatchGroups(),
          _buildSafetyEducationCard(), // NEW
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 320,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF36599F), Color(0xFF5D80C1)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
              child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: ThemeHelper.getScaffoldBackgroundColor(context),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Text(
              AppLocalizations.of(context)?.yourCommunitySafetyHub ?? 'Your Community\nSafety Hub',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 30,
            right: 30,
            child: _buildProfileCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: ThemeHelper.getCardColor(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ThemeHelper.getShadowColor(context),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFD700), Color(0xFFFFE55C)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 15),
          Text(
            _getGreeting(context, userName),
            style: TextStyle(
              fontSize: 16,
              color: ThemeHelper.getSecondaryTextColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportCrimeScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 2,
              ),
              child: Text(
                AppLocalizations.of(context)?.reportNow ?? 'Report Now',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ENHANCED - Now tappable to navigate to CommunityStatisticsScreen
  Widget _buildCommunityStatusCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CommunityStatisticsScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(30, 20, 30, 0),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: ThemeHelper.getCardColor(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ThemeHelper.getShadowColor(context),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)?.communityStatus ?? 'Community Status',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF36599F),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatusItem(AppLocalizations.of(context)?.thisWeek ?? 'This Week', thisWeekReports, const Color(0xFF10B981)),
            const SizedBox(height: 12),
            _buildStatusItem(AppLocalizations.of(context)?.avgResponse ?? 'Avg Response', avgResponse, const Color(0xFF3B82F6)),
            const SizedBox(height: 12),
            _buildStatusItem(AppLocalizations.of(context)?.safetyLevel ?? 'Safety Level', safetyLevel, _getSafetyLevelColor(safetyLevel)),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF36599F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart, size: 16, color: Color(0xFF36599F)),
                  SizedBox(width: 6),
                  Text(
                    'Tap for detailed statistics',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF36599F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        isLoadingCommunityStatus && value == 'Loading...'
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(valueColor),
                ),
              )
            : Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
      ],
    );
  }

  Color _getSafetyLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'excellent':
        return const Color(0xFF10B981); // Green
      case 'good':
        return const Color(0xFF3B82F6); // Blue
      case 'moderate':
        return const Color(0xFFFFA500); // Orange
      case 'caution':
        return const Color(0xFFFF9800); // Dark Orange
      case 'high risk':
        return const Color(0xFFDC2626); // Red
      default:
        return Colors.grey;
    }
  }

  // ENHANCED - Added My Impact card
  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 25, 30, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF36599F),
            ),
          ),
          const SizedBox(height: 20),

          // First Row
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.warning,
                  title: AppLocalizations.of(context)?.emergency ?? 'Emergency',
                  subtitle: AppLocalizations.of(context)?.callNow ?? 'Call for help',
                  color: const Color(0xFFDC2626),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmergencyModeScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.description,
                  title: AppLocalizations.of(context)?.reportCrime ?? 'Report',
                  subtitle: AppLocalizations.of(context)?.submit ?? 'Submit Incident',
                  color: const Color(0xFFDC2626),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReportCrimeScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Second Row - NEW My Impact Card
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.emoji_events,
                  title: AppLocalizations.of(context)?.myImpact ?? 'My Impact',
                  subtitle: AppLocalizations.of(context)?.viewDetails ?? 'View contributions',
                  color: const Color(0xFFFFA500),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyImpactScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.school,
                  title: AppLocalizations.of(context)?.safetyEducation ?? 'Learn',
                  subtitle: AppLocalizations.of(context)?.learnMore ?? 'Safety tips',
                  color: const Color(0xFF8B5CF6),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SafetyEducationScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
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
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF36599F),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NEW - Nearby Incidents Card
  Widget _buildNearbyIncidentsCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NearbyIncidentsScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(30, 25, 30, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.notifications_active,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.nearbyIncidents ?? 'Nearby Incidents',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)?.nearbyIncidentsCount(nearbyIncidentsCount) ?? '$nearbyIncidentsCount active alerts in your area',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFB45309),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: Colors.brown[700],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchGroups() {
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 25, 30, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_city, color: Color(0xFF36599F), size: 22),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)?.myWatchGroups ?? 'Your Watch Groups',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF36599F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            watchGroupInfo,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyWatchGroupsScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF36599F),
                side: const BorderSide(color: Color(0xFF36599F), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)?.browseGroups ?? 'View Groups',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // NEW - Safety Education Card
  Widget _buildSafetyEducationCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 25, 30, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)?.safetyEducation ?? 'Safety Education',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B21A8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Learn responsible reporting',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.purple[800],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SafetyEducationScreen(),
                ),
              );
            },
            child: Text(
              AppLocalizations.of(context)?.learnMore ?? 'Learn',
              style: const TextStyle(
                color: Color(0xFF8B5CF6),
                fontWeight: FontWeight.w600,
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
          _buildNavItem(Icons.home, AppLocalizations.of(context)?.dashboard ?? 'Home', 0, true, () {
            setState(() => _selectedIndex = 0);
          }),
          _buildNavItem(Icons.description, AppLocalizations.of(context)?.myReports ?? 'Reports', 1, false, () {
            setState(() => _selectedIndex = 1);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyReportsScreen()),
            );
          }),
          _buildNavItem(Icons.message, AppLocalizations.of(context)?.messages ?? 'Messages', 2, false, () {
            setState(() => _selectedIndex = 2);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MessagesScreen()),
            );
          }),
          _buildNavItem(Icons.person, AppLocalizations.of(context)?.profile ?? 'Profile', 3, false, () {
            setState(() => _selectedIndex = 3);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
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