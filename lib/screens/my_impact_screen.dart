import 'package:flutter/material.dart';

class MyImpactScreen extends StatefulWidget {
  const MyImpactScreen({Key? key}) : super(key: key);

  @override
  State<MyImpactScreen> createState() => _MyImpactScreenState();
}

class _MyImpactScreenState extends State<MyImpactScreen> {
  // TODO: Load from backend
  final int reportsSubmitted = 12;
  final int actionsTaken = 8;
  final int crimesPrevented = 3;
  final String reputationLevel = 'Gold';
  final int reputationPoints = 850;

  final List<Map<String, dynamic>> badges = [
    {'name': 'First Report', 'icon': Icons.flag, 'color': Colors.blue, 'earned': true},
    {'name': 'Week Warrior', 'icon': Icons.calendar_today, 'color': Colors.green, 'earned': true},
    {'name': 'Evidence Expert', 'icon': Icons.camera_alt, 'color': Colors.purple, 'earned': true},
    {'name': 'Community Hero', 'icon': Icons.star, 'color': Colors.amber, 'earned': false},
  ];

  final List<Map<String, String>> timeline = [
    {'action': 'Report submitted', 'detail': 'Suspicious Person', 'time': '2 hours ago'},
    {'action': 'Action taken', 'detail': 'Police responded', 'time': '1 day ago'},
    {'action': 'Badge earned', 'detail': 'Evidence Expert', 'time': '3 days ago'},
    {'action': 'Report resolved', 'detail': 'Vehicle Activity', 'time': '5 days ago'},
  ];

  @override
  Widget build(BuildContext context) {
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
              value: 0.85,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '150 points to Platinum',
            style: TextStyle(
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
}