import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Interactive Google Maps Picker Widget
/// Allows users to tap on a real map to select a location
class MapPickerWidget extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final Function(double latitude, double longitude) onLocationSelected;
  final double height;

  const MapPickerWidget({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
    required this.onLocationSelected,
    this.height = 300,
  }) : super(key: key);

  @override
  State<MapPickerWidget> createState() => _MapPickerWidgetState();
}

class _MapPickerWidgetState extends State<MapPickerWidget> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  Marker? _marker;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    // Set initial location (default to Kigali if not provided)
    _selectedLocation = LatLng(
      widget.initialLatitude ?? -1.9441,
      widget.initialLongitude ?? 30.0619,
    );
    _createMarker(_selectedLocation!);
  }

  void _createMarker(LatLng position) {
    setState(() {
      _marker = Marker(
        markerId: const MarkerId('selected_location'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        draggable: true,
        infoWindow: const InfoWindow(
          title: 'Selected Location',
          snippet: 'Drag to adjust or tap map to change',
        ),
      );
    });
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _createMarker(location);
    });
    
    // Show confirmation dialog
    _showLocationConfirmation(location);
  }

  void _onMarkerDragEnd(LatLng newPosition) {
    setState(() {
      _selectedLocation = newPosition;
      _createMarker(newPosition);
    });
    
    // Show confirmation dialog
    _showLocationConfirmation(newPosition);
  }

  void _showLocationConfirmation(LatLng location) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.location_on, color: Color(0xFFEF4444), size: 28),
              SizedBox(width: 10),
              Text(
                'Confirm Location',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF36599F),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Is this the correct location?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.my_location, 'Latitude', '${location.latitude.toStringAsFixed(6)}'),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.explore, 'Longitude', '${location.longitude.toStringAsFixed(6)}'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onLocationSelected(location.latitude, location.longitude);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Location confirmed!'),
                      ],
                    ),
                    backgroundColor: Color(0xFF10B981),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF36599F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF36599F)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _isMapReady = true;
    });
  }

  Future<void> _moveToCurrentLocation() async {
    if (_selectedLocation != null && _mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLocation!, 15.0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _selectedLocation!,
                zoom: 15.0,
              ),
              markers: _marker != null ? {_marker!} : {},
              onTap: _onMapTap,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              mapType: MapType.normal,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              scrollGesturesEnabled: true,
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: true,
              compassEnabled: true,
              mapToolbarEnabled: false,
            ),
            // Instructions overlay
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Tap on map to select location or drag the marker',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Center crosshair indicator
            const Center(
              child: Icon(
                Icons.add_location,
                color: Color(0xFF36599F),
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
