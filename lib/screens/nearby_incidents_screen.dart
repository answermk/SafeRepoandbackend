import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../services/map_service.dart';

class NearbyIncidentsScreen extends StatefulWidget {
  const NearbyIncidentsScreen({Key? key}) : super(key: key);

  @override
  State<NearbyIncidentsScreen> createState() => _NearbyIncidentsScreenState();
}

class _NearbyIncidentsScreenState extends State<NearbyIncidentsScreen> {
  String _selectedRadius = '1km';
  String _selectedTimeFilter = '24h';
  
  // Location
  double _latitude = -1.9441; // Default: Kigali
  double _longitude = 30.0619;
  
  // Data
  List<Map<String, dynamic>> _incidents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Get user's current location
      await _getCurrentLocation();
      
      // Load incidents
      await _loadIncidents();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading incidents: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return; // Use default location
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return; // Use default location
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return; // Use default location
      }
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }
  
  Future<void> _loadIncidents() async {
    try {
      // Convert radius to km
      double radiusKm = _convertRadiusToKm(_selectedRadius);
      
      // Convert time filter to backend format
      String timeRange = _convertTimeFilterToBackend(_selectedTimeFilter);
      
      final result = await MapService.getLiveIncidentsInArea(
        latitude: _latitude,
        longitude: _longitude,
        radiusKm: radiusKm,
        timeRange: timeRange,
      );
      
      if (result['success'] == true && result['data'] != null) {
        final incidents = result['data'] as List<dynamic>;
        
        // Calculate distance for each incident and format data
        List<Map<String, dynamic>> formattedIncidents = [];
        for (var incident in incidents) {
          final incidentData = incident as Map<String, dynamic>;
          final lat = (incidentData['latitude'] ?? 0.0) as double;
          final lng = (incidentData['longitude'] ?? 0.0) as double;
          
          // Calculate distance
          double distanceKm = 0.0;
          if (lat != 0.0 && lng != 0.0) {
            distanceKm = _calculateDistance(_latitude, _longitude, lat, lng);
          }
          
          // Format time ago
          String timeAgo = 'Unknown';
          if (incidentData['reportedAt'] != null) {
            timeAgo = _formatTimeAgo(incidentData['reportedAt']);
          }
          
          // Determine severity based on priority
          String severity = _getSeverityFromPriority(incidentData['priority'] ?? 'NORMAL');
          
          formattedIncidents.add({
            'id': incidentData['incidentId'],
            'type': incidentData['title'] ?? incidentData['crimeType'] ?? 'Unknown',
            'description': incidentData['description'] ?? 'No description',
            'location': incidentData['location'] ?? 'Unknown location',
            'distance': _formatDistance(distanceKm),
            'distanceKm': distanceKm,
            'time': timeAgo,
            'severity': severity,
            'status': incidentData['status'] ?? 'PENDING',
            'priority': incidentData['priority'] ?? 'NORMAL',
            'reportedAt': incidentData['reportedAt'],
            'latitude': lat,
            'longitude': lng,
          });
        }
        
        // Sort by distance (nearest first)
        formattedIncidents.sort((a, b) => 
          (a['distanceKm'] as double).compareTo(b['distanceKm'] as double)
        );
        
        setState(() {
          _incidents = formattedIncidents;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Failed to load incidents';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  double _convertRadiusToKm(String radius) {
    if (radius.contains('m')) {
      // Convert meters to km
      final meters = double.tryParse(radius.replaceAll('m', '')) ?? 500;
      return meters / 1000.0;
    } else if (radius.contains('km')) {
      return double.tryParse(radius.replaceAll('km', '')) ?? 1.0;
    }
    return 1.0; // Default 1km
  }
  
  String _convertTimeFilterToBackend(String timeFilter) {
    switch (timeFilter.toLowerCase()) {
      case '1h':
        return '1h';
      case '24h':
        return '24h';
      case 'week':
        return '7d';
      default:
        return '24h';
    }
  }
  
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
  
  String _formatDistance(double distanceKm) {
    if (distanceKm < 1.0) {
      return '${(distanceKm * 1000).toStringAsFixed(0)} m';
    } else {
      return '${distanceKm.toStringAsFixed(1)} km';
    }
  }
  
  String _formatTimeAgo(dynamic reportedAt) {
    try {
      DateTime reportedDate;
      if (reportedAt is String) {
        // Parse ISO 8601 format
        reportedDate = DateTime.parse(reportedAt);
      } else {
        return 'Unknown';
      }
      
      final now = DateTime.now();
      final difference = now.difference(reportedDate);
      
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else {
        return DateFormat('MMM d, y').format(reportedDate);
      }
    } catch (e) {
      return 'Unknown';
    }
  }
  
  String _getSeverityFromPriority(String priority) {
    switch (priority.toUpperCase()) {
      case 'URGENT':
        return 'high';
      case 'HIGH':
        return 'high';
      case 'MEDIUM':
        return 'medium';
      case 'NORMAL':
      case 'LOW':
      default:
        return 'low';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Nearby Incidents', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF36599F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadIncidents,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          _buildAlertBanner(),
          Expanded(child: _buildIncidentsList()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              const Text('Radius:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              ...['500m', '1km', '5km'].map((radius) {
                final isSelected = _selectedRadius == radius;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(radius),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedRadius = radius;
                      });
                      _loadIncidents();
                    },
                    selectedColor: const Color(0xFF36599F),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Time:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              ...['1h', '24h', 'Week'].map((time) {
                final isSelected = _selectedTimeFilter == time;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(time),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedTimeFilter = time;
                      });
                      _loadIncidents();
                    },
                    selectedColor: const Color(0xFF36599F),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, color: Color(0xFFD97706)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_incidents.length} Active Alert${_incidents.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
                Text(
                  'Within $_selectedRadius of your location',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadIncidents,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_incidents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No incidents found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No incidents reported within $_selectedRadius in the last $_selectedTimeFilter',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _incidents.length,
      itemBuilder: (context, index) {
        return _buildIncidentCard(_incidents[index]);
      },
    );
  }

  Widget _buildIncidentCard(Map<String, dynamic> incident) {
    final severity = incident['severity'] as String;
    Color severityColor;
    IconData severityIcon;

    switch (severity) {
      case 'high':
        severityColor = Colors.red;
        severityIcon = Icons.warning;
        break;
      case 'medium':
        severityColor = Colors.orange;
        severityIcon = Icons.info;
        break;
      case 'low':
      default:
        severityColor = Colors.blue;
        severityIcon = Icons.info_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        border: Border(
          left: BorderSide(color: severityColor, width: 4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(severityIcon, color: severityColor, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    incident['type'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF36599F),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    severity.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: severityColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              incident['description'] as String,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    incident['location'] as String,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.near_me, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  incident['distance'] as String,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  incident['time'] as String,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _showIncidentDetails(incident);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF36599F),
                  side: const BorderSide(color: Color(0xFF36599F)),
                ),
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showIncidentDetails(Map<String, dynamic> incident) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      incident['type'] as String,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF36599F),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(Icons.description, 'Description', incident['description'] as String),
                    _buildDetailRow(Icons.location_on, 'Location', incident['location'] as String),
                    _buildDetailRow(Icons.near_me, 'Distance', incident['distance'] as String),
                    _buildDetailRow(Icons.access_time, 'Reported', incident['time'] as String),
                    _buildDetailRow(Icons.flag, 'Status', incident['status'] as String),
                    _buildDetailRow(Icons.priority_high, 'Priority', incident['priority'] as String),
                    const SizedBox(height: 24),
                    const Text(
                      'Safety Recommendations',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSafetyTip('Stay alert in this area'),
                    _buildSafetyTip('Avoid the area if possible'),
                    _buildSafetyTip('Report any related activity'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
