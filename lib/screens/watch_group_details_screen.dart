import 'package:flutter/material.dart';
import 'watch_group_messages_screen.dart';

class WatchGroupDetailsScreen extends StatelessWidget {
  const WatchGroupDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 18),
                _buildGroupInfo(),
                const SizedBox(height: 18),
                _buildAboutGroup(),
                const SizedBox(height: 18),
                _buildCoverageArea(),
                const SizedBox(height: 18),
                _buildPatrolSchedule(),
                const SizedBox(height: 18),
                _buildRecentActivity(),
                const SizedBox(height: 18),
                _buildViewAllActivityButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF36599F),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Oak Street Watch',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '15 members • Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.message, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WatchGroupMessagesScreen(
                    groupData: {
                      'title': 'Oak Street Residential',
                      'subtitle': 'Oak Street Neighborhood',
                      'members': 15,
                      'alerts': 2,
                      'status': 'Active',
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGroupInfo() {
    return Row(
      children: [
        const Icon(Icons.apartment, color: Color(0xFF36599F), size: 32),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Oak Street Residential', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF36599F))),
            Text('Est. Jan 2023 • 15 members', style: TextStyle(fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('About This Group', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF36599F), fontSize: 15)),
        SizedBox(height: 6),
        Text('Neighborhood watch program covering Oak Street between 1st and 5th avenues. We organize regular patrols and share safety updates.', style: TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _buildCoverageArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Coverage Area', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF36599F), fontSize: 15)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: Text('Map Placeholder', style: TextStyle(color: Colors.grey))),
        ),
      ],
    );
  }

  Widget _buildPatrolSchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Current Patrol Schedule', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF36599F), fontSize: 15)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('WeekDays'),
            Text('6-8 PM', style: TextStyle(color: Color(0xFF36599F), fontWeight: FontWeight.bold)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Weekends'),
            Text('8-10 PM', style: TextStyle(color: Color(0xFF36599F), fontWeight: FontWeight.bold)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Your Next Shift'),
            Text('Sat 8 PM', style: TextStyle(color: Color(0xFF36599F), fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF36599F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('View Full Schedule', style: TextStyle(color: Colors.white)),

          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Group Activity', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF36599F), fontSize: 15)),
        const SizedBox(height: 10),
        _buildActivityCard('Sarah Johnson', 'Reported suspicious vehicle circling the block three times this evening. Plate number logged.', '2 hrs ago'),
        const SizedBox(height: 10),
        _buildActivityCard('Mike Chen', 'Completed evening patrol - all clear. New motion lights installed on Elm corner.', 'Yesterday'),
      ],
    );
  }

  Widget _buildActivityCard(String name, String message, String time) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100, width: 1.2),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFE8F0FE),
            child: Icon(Icons.person, color: Color(0xFF36599F)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(message, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(time, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildViewAllActivityButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF36599F)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text('View All Activity', style: TextStyle(color: Color(0xFF36599F), fontWeight: FontWeight.bold)),
      ),
    );
  }
}