import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/community_service.dart';
import '../services/map_service.dart';

class CommunityStatisticsScreen extends StatefulWidget {
  const CommunityStatisticsScreen({Key? key}) : super(key: key);

  @override
  State<CommunityStatisticsScreen> createState() => _CommunityStatisticsScreenState();
}

class _CommunityStatisticsScreenState extends State<CommunityStatisticsScreen> {
  String _selectedPeriod = 'Week';
  bool _isLoading = true;
  
  // Statistics data
  int _totalReports = 0;
  int _resolvedReports = 0;
  String _avgResponseTime = 'Loading...';
  
  // Location
  double _latitude = -1.9441; // Default: Kigali
  double _longitude = 30.0619;
  double _radiusKm = 5.0;
  
  // Map controller
  GoogleMapController? _mapController;
  
  // Heat map data
  List<HeatMapPoint> _heatMapPoints = [];
  Set<Circle> _heatMapCircles = {};
  
  // Top active areas
  List<Map<String, dynamic>> _topAreas = [];
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get user's current location
      await _getCurrentLocation();
      
      // Load community statistics
      await _loadCommunityStatistics();
      
      // Load heat map data
      await _loadHeatMapData();
      
      // Load top active areas
      await _loadTopActiveAreas();
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
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
  
  Future<void> _loadCommunityStatistics() async {
    try {
      final result = await CommunityService.getCommunityStatus(
        latitude: _latitude,
        longitude: _longitude,
        radiusKm: _radiusKm,
      );
      
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        setState(() {
          _totalReports = (data['totalReports'] ?? 0) as int;
          _resolvedReports = (data['resolvedReports'] ?? 0) as int;
          _avgResponseTime = data['avgResponse'] ?? 'N/A';
        });
      }
    } catch (e) {
      print('Error loading community statistics: $e');
    }
  }
  
  Future<void> _loadHeatMapData() async {
    try {
      // Calculate bounding box (approximately 5km radius)
      double latOffset = 0.045; // ~5km
      double lngOffset = 0.045;
      
      final result = await MapService.getHeatMap(
        timeRange: _getTimeRangeForPeriod(_selectedPeriod),
        north: _latitude + latOffset,
        south: _latitude - latOffset,
        east: _longitude + lngOffset,
        west: _longitude - lngOffset,
      );
      
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        final heatmapData = data['heatmapData'] as List<dynamic>?;
        
        if (heatmapData != null) {
          List<HeatMapPoint> points = [];
          Set<Circle> circles = {};
          
          // Find max weight for normalization
          double maxWeight = 0.0;
          for (var pointData in heatmapData) {
            final weight = (pointData['weight'] ?? 0.0) as double;
            if (weight > maxWeight) maxWeight = weight;
          }
          
          int circleId = 0;
          for (var pointData in heatmapData) {
            final lat = (pointData['latitude'] ?? 0.0) as double;
            final lng = (pointData['longitude'] ?? 0.0) as double;
            final weight = (pointData['weight'] ?? 0.0) as double;
            final count = (pointData['crimeCount'] ?? 0) as int;
            
            if (lat != 0.0 && lng != 0.0) {
              points.add(HeatMapPoint(
                latitude: lat,
                longitude: lng,
                weight: weight,
                count: count,
              ));
              
              // Create circle for heat map visualization
              double intensity = maxWeight > 0 ? (weight / maxWeight) : 0.0;
              double radius = 200 + (intensity * 300); // 200-500 meters
              
              // Color based on intensity (green -> yellow -> orange -> red)
              Color circleColor;
              if (intensity < 0.25) {
                circleColor = Colors.green.withOpacity(0.3);
              } else if (intensity < 0.5) {
                circleColor = Colors.yellow.withOpacity(0.4);
              } else if (intensity < 0.75) {
                circleColor = Colors.orange.withOpacity(0.5);
              } else {
                circleColor = Colors.red.withOpacity(0.6);
              }
              
              circles.add(Circle(
                circleId: CircleId('heat_${circleId++}'),
                center: LatLng(lat, lng),
                radius: radius,
                fillColor: circleColor,
                strokeColor: circleColor.withOpacity(0.8),
                strokeWidth: 1,
              ));
            }
          }
          
          setState(() {
            _heatMapPoints = points;
            _heatMapCircles = circles;
          });
          
          // Update map camera to show all points
          if (points.isNotEmpty && _mapController != null) {
            _updateMapBounds();
          }
        }
      }
    } catch (e) {
      print('Error loading heat map data: $e');
    }
  }
  
  Future<void> _loadTopActiveAreas() async {
    try {
      final result = await CommunityService.getTopActiveAreas(
        latitude: _latitude,
        longitude: _longitude,
        radiusKm: _radiusKm,
        limit: 5,
      );
      
      if (result['success'] == true && result['data'] != null) {
        final areas = result['data'] as List<dynamic>;
        setState(() {
          _topAreas = areas.map((area) => area as Map<String, dynamic>).toList();
        });
      }
    } catch (e) {
      print('Error loading top active areas: $e');
    }
  }
  
  String _getTimeRangeForPeriod(String period) {
    switch (period) {
      case 'Week':
        return '7d';
      case 'Month':
        return '30d';
      case 'Year':
        return '1y';
      default:
        return '7d';
    }
  }
  
  void _updateMapBounds() {
    if (_heatMapPoints.isEmpty || _mapController == null) return;
    
    double minLat = _heatMapPoints[0].latitude;
    double maxLat = _heatMapPoints[0].latitude;
    double minLng = _heatMapPoints[0].longitude;
    double maxLng = _heatMapPoints[0].longitude;
    
    for (var point in _heatMapPoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }
    
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - 0.01, minLng - 0.01),
          northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
        ),
        50.0, // padding in pixels
      ),
    );
  }
  
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_heatMapPoints.isNotEmpty) {
      _updateMapBounds();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Community Statistics', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF36599F),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildPeriodSelector(),
                  _buildSummaryCards(),
                  _buildHeatMapSection(),
                  _buildTopAreasSection(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
  
  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: ['Week', 'Month', 'Year'].map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
                _loadHeatMapData();
                _loadTopActiveAreas();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF36599F) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF36599F) : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Reports',
              '$_totalReports',
              Colors.blue,
              Icons.description,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Resolved',
              '$_resolvedReports',
              Colors.green,
              Icons.check_circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Avg Response',
              _avgResponseTime,
              Colors.orange,
              Icons.timer,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
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
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeatMapSection() {
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
            'Activity Heat Map',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF36599F),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(_latitude, _longitude),
                  zoom: 13.0,
                ),
                circles: _heatMapCircles,
                markers: {
                  // User location marker
                  Marker(
                    markerId: const MarkerId('user_location'),
                    position: LatLng(_latitude, _longitude),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                    infoWindow: const InfoWindow(title: 'Your Location'),
                  ),
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                mapType: MapType.normal,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildHeatMapLegend(),
        ],
      ),
    );
  }
  
  Widget _buildHeatMapLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Colors.green, 'Low'),
        const SizedBox(width: 16),
        _buildLegendItem(Colors.yellow, 'Medium'),
        const SizedBox(width: 16),
        _buildLegendItem(Colors.orange, 'High'),
        const SizedBox(width: 16),
        _buildLegendItem(Colors.red, 'Very High'),
      ],
    );
  }
  
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }
  
  Widget _buildTopAreasSection() {
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
            'Top Active Areas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF36599F),
            ),
          ),
          const SizedBox(height: 16),
          if (_topAreas.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'No active areas found',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ..._topAreas.asMap().entries.map((entry) {
              final index = entry.key;
              final area = entry.value;
              final name = area['name'] ?? 'Unknown';
              final count = area['count'] ?? 0;
              final trend = area['trend'] ?? 'stable';
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF36599F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '$count ${count == 1 ? 'report' : 'reports'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      trend == 'up'
                          ? Icons.trending_up
                          : trend == 'down'
                          ? Icons.trending_down
                          : Icons.trending_flat,
                      color: trend == 'up'
                          ? Colors.red
                          : trend == 'down'
                          ? Colors.green
                          : Colors.grey,
                      size: 20,
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

class HeatMapPoint {
  final double latitude;
  final double longitude;
  final double weight;
  final int count;
  
  HeatMapPoint({
    required this.latitude,
    required this.longitude,
    required this.weight,
    required this.count,
  });
}
