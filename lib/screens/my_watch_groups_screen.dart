import 'package:flutter/material.dart';
import '../services/watch_group_service.dart';
import '../services/token_manager.dart';
import 'watch_group_messages_screen.dart';
import 'watch_group_details_screen.dart';
import 'browse_watch_groups_screen.dart';
import 'dashboard_screen.dart';

class MyWatchGroupsScreen extends StatefulWidget {
  const MyWatchGroupsScreen({Key? key}) : super(key: key);

  @override
  State<MyWatchGroupsScreen> createState() => _MyWatchGroupsScreenState();
}

class _MyWatchGroupsScreenState extends State<MyWatchGroupsScreen> {
  List<Map<String, dynamic>> _watchGroups = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWatchGroups();
  }

  Future<void> _loadWatchGroups() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await WatchGroupService.getMyWatchGroups();

      if (result['success'] == true) {
        final groups = result['data'] as List<dynamic>? ?? [];
        setState(() {
          _watchGroups = groups.map((g) {
            final members = g['members'] as List<dynamic>? ?? [];
            return {
              'id': g['id']?.toString(),
              'name': g['name'] ?? 'Watch Group',
              'description': g['description'] ?? '',
              'location': g['location'] ?? 'Unknown',
              'memberCount': members.length,
              'status': g['status'] ?? 'ACTIVE',
              'createdAt': g['createdAt'],
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['error']?.toString() ?? 'Failed to load watch groups';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading watch groups: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadWatchGroups,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 18),
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_error != null)
                    _buildErrorState()
                  else if (_watchGroups.isEmpty)
                    _buildEmptyState()
                  else
                    ..._watchGroups.map((group) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildWatchGroupCard(
                            context: context,
                            groupData: group,
                          ),
                        )),
                  const SizedBox(height: 24),
                  _buildFindMoreGroups(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Failed to load watch groups',
            style: TextStyle(color: Colors.red[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadWatchGroups,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.group_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No watch groups yet',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Join or create a watch group to get started',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipPath(
      clipper: CurvedBottomClipper(),
      child: Container(
        width: double.infinity,
        color: const Color(0xFF36599F),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Watch Groups',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Community safety partnerships',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchGroupCard({
    required BuildContext context,
    required Map<String, dynamic> groupData,
  }) {
    final title = groupData['name'] ?? 'Watch Group';
    final subtitle = groupData['description'] ?? groupData['location'] ?? '';
    final members = groupData['memberCount'] ?? 0;
    final status = groupData['status'] ?? 'ACTIVE';
    final groupId = groupData['id'];
    
    // Determine icon based on group name or type
    IconData icon = Icons.location_city;
    if (title.toLowerCase().contains('business') || title.toLowerCase().contains('downtown')) {
      icon = Icons.business;
    } else if (title.toLowerCase().contains('residential') || title.toLowerCase().contains('street')) {
      icon = Icons.apartment;
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100, width: 1.2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF36599F), size: 32),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF36599F))),
                  Text(subtitle, style: const TextStyle(fontSize: 13)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FADF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  status == 'ACTIVE' ? 'Active' : status,
                  style: const TextStyle(
                    color: Color(0xFF039855),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 18),
              const SizedBox(width: 4),
              Text('$members member${members != 1 ? 's' : ''}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text('• $subtitle', style: const TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  if (groupId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WatchGroupDetailsScreen(groupId: groupId),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF36599F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                ),
                child: const Text('View Group', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  if (groupId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WatchGroupMessagesScreen(
                          groupData: {
                            'id': groupId,
                            'name': title,
                            'description': subtitle,
                            'memberCount': members,
                            'status': status,
                          },
                        ),
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF36599F)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                ),
                child: const Text('Message', style: TextStyle(color: Color(0xFF36599F))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFindMoreGroups(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100, width: 1.2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.search, color: Color(0xFF36599F)),
              SizedBox(width: 8),
              Text('Find More Groups', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF36599F), fontSize: 15)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Join watch groups in other areas you frequent', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BrowseWatchGroupsScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF36599F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            ),
            child: const Text('Browse Watch Groups', style: TextStyle(color: Colors.white)),
          ),
        ],
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