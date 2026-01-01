import 'package:flutter/material.dart';
import 'watch_group_messages_screen.dart';
import '../services/watch_group_service.dart';
import '../services/watch_group_message_service.dart';

class WatchGroupDetailsScreen extends StatefulWidget {
  final String? groupId;
  final Map<String, dynamic>? groupData;

  const WatchGroupDetailsScreen({
    Key? key,
    this.groupId,
    this.groupData,
  }) : super(key: key);

  @override
  State<WatchGroupDetailsScreen> createState() => _WatchGroupDetailsScreenState();
}

class _WatchGroupDetailsScreenState extends State<WatchGroupDetailsScreen> {
  Map<String, dynamic>? _groupData;
  List<Map<String, dynamic>> _recentMessages = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.groupData != null) {
      _groupData = widget.groupData;
      _isLoading = false;
      _loadRecentMessages();
    } else if (widget.groupId != null) {
      _loadGroupData();
    } else {
      setState(() {
        _isLoading = false;
        _error = 'No group ID or data provided';
      });
    }
  }

  Future<void> _loadGroupData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await WatchGroupService.getWatchGroupById(widget.groupId!);

      if (result['success'] == true) {
        setState(() {
          _groupData = result['data'] as Map<String, dynamic>;
          _isLoading = false;
        });
        _loadRecentMessages();
      } else {
        setState(() {
          _isLoading = false;
          _error = result['error'] ?? 'Failed to load group data';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _loadRecentMessages() async {
    final groupId = _groupData?['id']?.toString() ?? widget.groupId;
    if (groupId == null) return;

    try {
      // Get recent messages (last 3)
      final result = await WatchGroupMessageService.getWatchGroupMessages(
        groupId: groupId,
        page: 0,
        size: 3,
        sortDir: 'desc',
      );

      if (result['success'] == true) {
        final messages = result['data'] as List<dynamic>? ?? [];
        setState(() {
          _recentMessages = messages.map((msg) {
            final senderName = msg['senderName'] ?? 'Unknown';
            final sentAt = msg['sentAt'] ?? msg['createdAt'] ?? '';
            return {
              'sender': senderName,
              'message': msg['message'] ?? '',
              'time': _formatTimeAgo(sentAt),
            };
          }).toList();
        });
      }
    } catch (e) {
      // Silently fail for recent messages - not critical
      print('Error loading recent messages: $e');
    }
  }

  String _formatTimeAgo(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return 'Est. ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (widget.groupId != null) {
                              _loadGroupData();
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      if (widget.groupId != null) {
                        await _loadGroupData();
                      } else {
                        await _loadRecentMessages();
                      }
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
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
                            if (_recentMessages.isNotEmpty) ...[
                              _buildRecentActivity(),
                              const SizedBox(height: 18),
                            ],
                            _buildViewAllActivityButton(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final groupName = _groupData?['name'] ?? 'Watch Group';
    final memberCount = _groupData?['memberCount'] ?? _groupData?['members']?.length ?? 0;
    final status = _groupData?['status'] ?? 'UNKNOWN';
    final statusText = status.toString().toUpperCase().replaceAll('_', ' ');

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$memberCount members • $statusText',
                  style: const TextStyle(
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
              final groupId = _groupData?['id']?.toString() ?? widget.groupId;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WatchGroupMessagesScreen(
                    groupData: {
                      'id': groupId,
                      'groupId': groupId,
                      'title': groupName,
                      'name': groupName,
                      'members': memberCount,
                      'status': statusText,
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
    final groupName = _groupData?['name'] ?? 'Watch Group';
    final memberCount = _groupData?['memberCount'] ?? _groupData?['members']?.length ?? 0;
    final createdAt = _groupData?['createdAt'] ?? '';

    return Row(
      children: [
        const Icon(Icons.apartment, color: Color(0xFF36599F), size: 32),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              groupName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF36599F),
              ),
            ),
            Text(
              '${_formatDate(createdAt)} • $memberCount members',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutGroup() {
    final description = _groupData?['description'] ?? 'No description available.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About This Group',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF36599F),
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildCoverageArea() {
    final location = _groupData?['location'] as Map<String, dynamic>?;
    final address = location?['address'] ?? 'Location not specified';
    final latitude = location?['latitude'];
    final longitude = location?['longitude'];
    final district = location?['district'];
    final sector = location?['sector'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Coverage Area',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF36599F),
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (address.isNotEmpty)
                Text(
                  address,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              if (district != null || sector != null) ...[
                const SizedBox(height: 4),
                Text(
                  [
                    if (district != null) 'District: $district',
                    if (sector != null) 'Sector: $sector',
                  ].join(' • '),
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
              if (latitude != null && longitude != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Coordinates: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ],
          ),
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
        const Text(
          'Recent Group Activity',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF36599F),
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 10),
        ..._recentMessages.map((msg) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildActivityCard(
                msg['sender'] ?? 'Unknown',
                msg['message'] ?? '',
                msg['time'] ?? 'Unknown',
              ),
            )),
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
    final groupId = _groupData?['id']?.toString() ?? widget.groupId;
    
    final groupName = _groupData?['name'] ?? 'Watch Group';
    final memberCount = _groupData?['memberCount'] ?? _groupData?['members']?.length ?? 0;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: groupId != null
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WatchGroupMessagesScreen(
                      groupData: {
                        'id': groupId,
                        'groupId': groupId,
                        'title': groupName,
                        'name': groupName,
                        'members': memberCount,
                      },
                    ),
                  ),
                );
              }
            : null,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF36599F)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text(
          'View All Messages',
          style: TextStyle(color: Color(0xFF36599F), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}