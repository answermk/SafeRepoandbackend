import 'package:flutter/material.dart';
import '../services/watch_group_service.dart';
import 'watch_group_details_screen.dart';

class BrowseWatchGroupsScreen extends StatefulWidget {
  const BrowseWatchGroupsScreen({Key? key}) : super(key: key);

  @override
  State<BrowseWatchGroupsScreen> createState() => _BrowseWatchGroupsScreenState();
}

class _BrowseWatchGroupsScreenState extends State<BrowseWatchGroupsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allGroups = [];
  List<Map<String, dynamic>> _filteredGroups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
    _searchController.addListener(_filterGroups);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await WatchGroupService.getAllWatchGroups(page: 0, size: 100);
      
      if (result['success'] == true) {
        final groups = result['data'] as List<dynamic>? ?? [];
        setState(() {
          _allGroups = groups.map((g) {
            final members = g['members'] as List<dynamic>? ?? [];
            final groupName = g['name'] ?? 'Watch Group';
            
            // Determine icon based on group name or type
            IconData icon = Icons.location_city;
            final nameLower = groupName.toString().toLowerCase();
            if (nameLower.contains('business') || nameLower.contains('downtown') || nameLower.contains('commercial') || nameLower.contains('shopping')) {
              icon = Icons.business;
            } else if (nameLower.contains('residential') || nameLower.contains('street') || nameLower.contains('avenue') || nameLower.contains('neighborhood')) {
              icon = Icons.home;
            } else if (nameLower.contains('university') || nameLower.contains('campus') || nameLower.contains('school')) {
              icon = Icons.school;
            } else if (nameLower.contains('park') || nameLower.contains('riverside')) {
              icon = Icons.park;
            } else if (nameLower.contains('industrial') || nameLower.contains('factory')) {
              icon = Icons.factory;
            }
            
            return {
              'id': g['id']?.toString(),
              'title': groupName,
              'subtitle': g['description'] ?? g['location'] ?? 'Watch Group',
              'members': members.length,
              'status': g['status'] ?? 'ACTIVE',
              'icon': icon,
              'location': g['location'] ?? 'Unknown',
              'description': g['description'] ?? '',
            };
          }).toList();
          _filteredGroups = List.from(_allGroups);
          _isLoading = false;
        });
      } else {
        // If loading fails, show empty state
        setState(() {
          _allGroups = [];
          _filteredGroups = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      // On error, show empty state
      setState(() {
        _allGroups = [];
        _filteredGroups = [];
        _isLoading = false;
      });
    }
  }

  void _filterGroups() {
    final query = _searchController.text.toLowerCase().trim();
    
    if (query.isEmpty) {
      setState(() {
        _filteredGroups = List.from(_allGroups);
      });
    } else {
      setState(() {
        _filteredGroups = _allGroups.where((group) {
          final title = group['title']?.toString().toLowerCase() ?? '';
          final subtitle = group['subtitle']?.toString().toLowerCase() ?? '';
          final location = group['location']?.toString().toLowerCase() ?? '';
          final description = group['description']?.toString().toLowerCase() ?? '';
          
          return title.contains(query) ||
              subtitle.contains(query) ||
              location.contains(query) ||
              description.contains(query);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Browse Watch Groups',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF36599F),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _filteredGroups.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredGroups.length,
                        itemBuilder: (context, index) {
                          return _buildGroupCard(_filteredGroups[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name, location, or description...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF36599F)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF36599F), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No groups found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'No watch groups available yet'
                : 'Try a different search term',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          final groupId = group['id']?.toString();
          if (groupId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WatchGroupDetailsScreen(groupId: groupId),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF36599F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      group['icon'] as IconData? ?? Icons.group,
                      color: const Color(0xFF36599F),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group['title'] ?? 'Unknown Group',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF36599F),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          group['subtitle'] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FADF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      group['status'] ?? 'Active',
                      style: const TextStyle(
                        color: Color(0xFF039855),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    group['location'] ?? 'Unknown Location',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${group['members'] ?? 0} members',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (group['description'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  group['description'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final groupId = group['id']?.toString();
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

