import 'package:flutter/material.dart';
import '../services/impact_service.dart';
import '../services/token_manager.dart';

class MyImpactScreen extends StatefulWidget {
  const MyImpactScreen({Key? key}) : super(key: key);

  @override
  State<MyImpactScreen> createState() => _MyImpactScreenState();
}

class _MyImpactScreenState extends State<MyImpactScreen> {
  int reportsSubmitted = 0;
  int actionsTaken = 0;
  int crimesPrevented = 0;
  String reputationLevel = 'Bronze';
  int reputationPoints = 0;
  int pointsToNextLevel = 0;
  double progressToNextLevel = 0.0;

  List<Map<String, dynamic>> badges = [];
  List<Map<String, String>> timeline = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadImpactData();
  }

  Future<void> _loadImpactData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Get current user ID
      var userId = await TokenManager.getUserId();
      
      // If userId is not stored, show error and ask user to log in again
      if (userId == null) {
        setState(() {
          _error = 'User ID not found. Please log out and log in again to refresh your session.';
          _loading = false;
        });
        return;
      }

      // Fetch impact data from backend
      final result = await ImpactService.getUserImpact(userId);

      if (!mounted) return;

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        
        // Extract metrics from backend response
        setState(() {
          reportsSubmitted = data['reportsSubmitted'] ?? 0;
          actionsTaken = data['actionsTaken'] ?? 0;
          crimesPrevented = data['crimesPrevented'] ?? 0;
          reputationPoints = data['reputationPoints'] ?? 0;
          reputationLevel = data['reputationLevel'] ?? 'Bronze';
          pointsToNextLevel = data['pointsToNextLevel'] ?? 0;
          progressToNextLevel = (data['progressToNextLevel'] ?? 0.0).toDouble();

          // Convert backend badges to UI format
          final backendBadges = data['badges'] as List<dynamic>? ?? [];
          badges = backendBadges.map<Map<String, dynamic>>((b) {
            final iconName = b['icon'] as String? ?? 'star';
            IconData iconData;
            switch (iconName) {
              case 'flag':
                iconData = Icons.flag;
                break;
              case 'calendar_today':
                iconData = Icons.calendar_today;
                break;
              case 'check_circle':
                iconData = Icons.check_circle;
                break;
              case 'star':
                iconData = Icons.star;
                break;
              default:
                iconData = Icons.star;
            }
            
            final colorStr = b['color'] as String? ?? '#FF9800';
            Color badgeColor;
            try {
              badgeColor = Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
            } catch (e) {
              badgeColor = Colors.amber;
            }
            
            return {
              'name': b['name'] ?? 'Badge',
              'icon': iconData,
              'color': badgeColor,
              'earned': b['earned'] ?? false,
            };
          }).toList();

          // Convert backend timeline to UI format
          final backendTimeline = data['recentActivity'] as List<dynamic>? ?? [];
          timeline = backendTimeline.map<Map<String, String>>((item) {
            return {
              'action': item['action'] ?? 'Activity',
              'detail': item['detail'] ?? '',
              'time': item['time'] ?? 'Unknown',
            };
          }).toList();

          _loading = false;
        });
      } else {
        setState(() {
          _error = result['error']?.toString() ?? 'Failed to load impact data';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error loading impact data: ${e.toString()}';
        _loading = false;
      });
    }
  }


  String _formatTimeAgo(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'Unknown';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      final weeks = (diff.inDays / 7).floor();
      if (weeks < 5) return '${weeks}w ago';
      final months = (diff.inDays / 30).floor();
      return '${months}mo ago';
    } catch (_) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Impact', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF36599F),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Impact', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF36599F),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loadImpactData,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF36599F)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Impact', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF36599F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildReputationHeader(),
            _buildStatsGrid(),
            _buildBadgesSection(),
            _buildTimelineSection(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildReputationHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFE55C)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events, size: 60, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            '$reputationLevel Member',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$reputationPoints points',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressToNextLevel.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            pointsToNextLevel > 0 
                ? '$pointsToNextLevel points to ${_getNextLevel(reputationLevel)}'
                : 'Maximum level reached!',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Reports\nSubmitted', reportsSubmitted.toString(), Colors.blue, Icons.description),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Actions\nTaken', actionsTaken.toString(), Colors.green, Icons.check_circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Crimes\nPrevented', crimesPrevented.toString(), Colors.red, Icons.shield),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Achievements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF36599F),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              return _buildBadge(badge);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(Map<String, dynamic> badge) {
    final earned = badge['earned'] as bool;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: earned ? badge['color'] as Color : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              badge['icon'] as IconData,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Flexible(
          child: Text(
            badge['name'] as String,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              color: earned ? Colors.black87 : Colors.grey[500],
              fontWeight: earned ? FontWeight.w600 : FontWeight.normal,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity Timeline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF36599F),
            ),
          ),
          const SizedBox(height: 16),
          ...timeline.map((item) => _buildTimelineItem(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, String> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFF36599F),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 40,
                color: Colors.grey[300],
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['action']!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['detail']!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['time']!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getNextLevel(String currentLevel) {
    switch (currentLevel) {
      case 'Bronze':
        return 'Silver';
      case 'Silver':
        return 'Gold';
      case 'Gold':
        return 'Platinum';
      default:
        return 'Platinum';
    }
  }
}