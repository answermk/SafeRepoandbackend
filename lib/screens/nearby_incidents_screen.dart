import 'package:flutter/material.dart';

class NearbyIncidentsScreen extends StatefulWidget {
  const NearbyIncidentsScreen({Key? key}) : super(key: key);

  @override
  State<NearbyIncidentsScreen> createState() => _NearbyIncidentsScreenState();
}

class _NearbyIncidentsScreenState extends State<NearbyIncidentsScreen> {
  String _selectedRadius = '1km';
  String _selectedTimeFilter = '24h';

  // TODO: Load from backend based on user location
  final List<Map<String, dynamic>> incidents = [
    {
      'type': 'Suspicious Person',
      'location': 'Oak Street & 1st Ave',
      'distance': '0.3 km',
      'time': '15 min ago',
      'severity': 'medium',
      'description': 'Individual loitering near school',
    },
    {
      'type': 'Vehicle Activity',
      'location': 'Main Street',
      'distance': '0.8 km',
      'time': '1 hour ago',
      'severity': 'low',
      'description': 'Car circling neighborhood',
    },
    {
      'type': 'Theft Attempt',
      'location': 'Maple Avenue',
      'distance': '1.2 km',
      'time': '3 hours ago',
      'severity': 'high',
      'description': 'Attempted break-in reported',
    },
  ];

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
            icon: const Icon(Icons.map),
            onPressed: () {
              // TODO: Show map view
            },
            tooltip: 'Map View',
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
                      setState(() => _selectedRadius = radius);
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
                      setState(() => _selectedTimeFilter = time);
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
                const Text(
                  '5 Active Alerts',
                  style: TextStyle(
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
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: incidents.length,
      itemBuilder: (context, index) {
        return _buildIncidentCard(incidents[index]);
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