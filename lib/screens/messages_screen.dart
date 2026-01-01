import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'my_reports_screen.dart';
import 'profile_screen.dart';
import 'community_forum_screen.dart';
import '../services/message_service.dart';
import '../services/watch_group_service.dart';
import '../services/token_manager.dart';
import 'watch_group_messages_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 2; // For bottom navigation
  
  // State variables
  List<Map<String, dynamic>> _inboxMessages = [];
  List<Map<String, dynamic>> _watchGroups = [];
  bool _isLoadingMessages = true;
  bool _isLoadingWatchGroups = true;
  String? _error;

  @override
  bool get wantKeepAlive => true; // Keep screen alive to prevent freezing

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadInboxMessages(),
      _loadWatchGroups(),
    ]);
  }

  Future<void> _loadInboxMessages() async {
    setState(() {
      _isLoadingMessages = true;
    });

    try {
      final result = await MessageService.getInbox(page: 0, size: 10);
      
      if (result['success'] == true) {
        final messages = result['data'] as List<dynamic>? ?? [];
        setState(() {
          _inboxMessages = messages.map((msg) => msg as Map<String, dynamic>).toList();
          _isLoadingMessages = false;
        });
      } else {
        setState(() {
          _isLoadingMessages = false;
          _error = result['error'] as String?;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingMessages = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadWatchGroups() async {
    setState(() {
      _isLoadingWatchGroups = true;
    });

    try {
      final result = await WatchGroupService.getMyWatchGroups(page: 0, size: 10);
      
      if (result['success'] == true) {
        final groups = result['data'] as List<dynamic>? ?? [];
        setState(() {
          _watchGroups = groups.map((group) => group as Map<String, dynamic>).toList();
          _isLoadingWatchGroups = false;
        });
      } else {
        setState(() {
          _isLoadingWatchGroups = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingWatchGroups = false;
      });
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute\n$period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  DateTime? _parseDateTime(dynamic dateString) {
    if (dateString == null) return null;
    try {
      if (dateString is String) {
        return DateTime.parse(dateString);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 25),
                      _buildSectionTitle('Report Communications'),
                      const SizedBox(height: 10),
                      _buildReportCommunications(),
                      const SizedBox(height: 25),
                      _buildSectionTitle('Watch Groups'),
                      const SizedBox(height: 10),
                      _buildWatchGroups(),
                      const SizedBox(height: 25),
                      _buildSectionTitle('Direct Contact'),
                      const SizedBox(height: 10),
                      _buildDirectContact(),
                      const SizedBox(height: 30),
                      _buildCommunityForumButton(),
                      const SizedBox(height: 100), // Space for bottom nav
                    ],
                  ),
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
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF36599F),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Messages',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Your communications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF36599F),
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildReportCommunications() {
    if (_isLoadingMessages) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF36599F),
            ),
          ),
        ),
      );
    }

    if (_inboxMessages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.inbox, color: Colors.grey, size: 24),
              const SizedBox(width: 12),
              Text(
                'No messages yet',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: _inboxMessages.take(5).map((message) {
          final senderName = message['senderName']?.toString() ?? 
                            message['sender']?['fullName']?.toString() ?? 
                            'Officer';
          final senderId = message['senderId']?.toString() ?? 
                         message['sender']?['id']?.toString();
          final content = message['content']?.toString() ?? '';
          final sentAt = _parseDateTime(message['sentAt'] ?? message['createdAt']);
          final isRead = message['isRead'] as bool? ?? false;
          final reportId = message['reportId']?.toString();
          final reportNumber = message['reportNumber']?.toString() ?? 
                             (reportId != null ? 'Report #${reportId.substring(0, 8)}...' : 'Report');
          
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar with police badge or initials
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFF36599F),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(senderName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // Message content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              senderName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Color(0xFF36599F),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatTime(sentAt),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (!isRead) ...[
                                const SizedBox(height: 8),
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      if (reportNumber.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          reportNumber,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF36599F),
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        content.length > 60 ? '${content.substring(0, 60)}...' : content,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWatchGroups() {
    if (_isLoadingWatchGroups) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF36599F),
            ),
          ),
        ),
      );
    }

    if (_watchGroups.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.group, color: Colors.grey, size: 24),
              const SizedBox(width: 12),
              Text(
                'No watch groups yet',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: _watchGroups.take(5).map((group) {
          final groupName = group['name']?.toString() ?? 'Watch Group';
          final groupId = group['id']?.toString();
          final memberCount = group['memberCount'] as int? ?? 
                            (group['members'] as List?)?.length ?? 0;
          final lastMessage = group['lastMessage'] as Map<String, dynamic>?;
          final lastMessageText = lastMessage?['message']?.toString() ?? 
                                lastMessage?['content']?.toString() ?? '';
          final lastMessageSender = lastMessage?['senderName']?.toString() ?? 
                                  lastMessage?['sender']?['fullName']?.toString() ?? '';
          final lastMessageTime = _parseDateTime(
            lastMessage?['sentAt'] ?? 
            lastMessage?['createdAt'] ?? 
            group['updatedAt']
          );
          
          // Color based on group name hash
          final colorIndex = groupName.hashCode.abs() % 3;
          final colors = [
            const Color(0xFFFF6B35),
            const Color(0xFF6B7280),
            const Color(0xFF36599F),
          ];
          final groupColor = colors[colorIndex];

          return GestureDetector(
            onTap: () {
              if (groupId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WatchGroupMessagesScreen(
                      groupData: group,
                    ),
                  ),
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Building icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: groupColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.apartment,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Message content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                groupName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Color(0xFF36599F),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              _formatTime(lastMessageTime),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$memberCount member${memberCount != 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (lastMessageText.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            lastMessageSender.isNotEmpty 
                              ? '$lastMessageSender: ${lastMessageText.length > 40 ? lastMessageText.substring(0, 40) + "..." : lastMessageText}'
                              : (lastMessageText.length > 50 ? lastMessageText.substring(0, 50) + "..." : lastMessageText),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDirectContact() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Emergency icon
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 15),
            // Content
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency\nContact',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF36599F),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Direct line to\npolice dispatch',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            // Call button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Call 112',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityForumButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CommunityForumScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF36599F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Move to the Community Forum',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
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
          _buildNavItem(Icons.message, 'Messages', 2, true, () {
            // Current screen, no navigation needed
          }),
          _buildNavItem(Icons.person, 'Profile', 3, false, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
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