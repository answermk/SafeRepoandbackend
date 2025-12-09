import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../widgets/map_picker_widget.dart';
import '../services/location_service.dart';
import 'review_report_screen.dart';

class LocationScreen extends StatefulWidget {
  final Map<String, dynamic> reportData;

  const LocationScreen({Key? key, required this.reportData}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool isLocationDetected = false;
  bool sendLocationDirectly = true;
  final TextEditingController addressController = TextEditingController();
  bool _isLoadingLocation = false;
  bool _isLoadingAddress = false;

  // Location data
  String detectedLocation = "";
  String locationAccuracy = "±5 meters";
  double? selectedLatitude;
  double? selectedLongitude;
  String _locationSource = "none"; // "map", "manual", "gps"

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Request location permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          selectedLatitude = -1.9441; // Default to Kigali coordinates
          selectedLongitude = 30.0619;
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            selectedLatitude = -1.9441; // Default to Kigali coordinates
            selectedLongitude = 30.0619;
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          selectedLatitude = -1.9441; // Default to Kigali coordinates
          selectedLongitude = 30.0619;
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        selectedLatitude = position.latitude;
        selectedLongitude = position.longitude;
        locationAccuracy = "±${position.accuracy.toInt()} meters";
        _isLoadingLocation = false;
      });

      // Reverse geocode to get address
      await _reverseGeocode(selectedLatitude!, selectedLongitude!);
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        selectedLatitude = -1.9441; // Default to Kigali coordinates
        selectedLongitude = 30.0619;
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      // Use geocoding package for reverse geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        final address = _formatAddress(place, lat, lng);
        
        setState(() {
          detectedLocation = address;
          isLocationDetected = true;
          _isLoadingAddress = false;
        });
      } else {
        setState(() {
          detectedLocation = "$lat, $lng";
          isLocationDetected = true;
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
      setState(() {
        detectedLocation = "$lat, $lng";
        isLocationDetected = true;
        _isLoadingAddress = false;
      });
    }
  }

  String _formatAddress(Placemark place, double lat, double lng) {
    final parts = <String>[];
    if (place.street != null && place.street!.isNotEmpty) {
      parts.add(place.street!);
    }
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      parts.add(place.subLocality!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      parts.add(place.locality!);
    }
    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
      parts.add(place.administrativeArea!);
    }
    if (place.country != null && place.country!.isNotEmpty) {
      parts.add(place.country!);
    }
    
    // If no address parts found, return coordinates as fallback
    return parts.isNotEmpty ? parts.join(', ') : "$lat, $lng";
  }

  void _onMapLocationSelected(double lat, double lng) {
    setState(() {
      selectedLatitude = lat;
      selectedLongitude = lng;
      _locationSource = "map";
      addressController.clear(); // Clear manual input when map is used
    });
    
    // Reverse geocode the selected location
    _reverseGeocode(lat, lng);
  }

  void _onManualAddressChanged(String value) {
    if (value.trim().isNotEmpty) {
      setState(() {
        _locationSource = "manual";
        detectedLocation = value;
        isLocationDetected = true;
        // Clear map coordinates when manual input is used
        selectedLatitude = null;
        selectedLongitude = null;
      });
    } else {
      setState(() {
        if (_locationSource == "manual") {
          isLocationDetected = false;
          _locationSource = "none";
        }
      });
    }
  }

  Future<Map<String, dynamic>> _saveLocationData() async {
    // Validate that at least one location method is used
    final hasMapLocation = _locationSource == "map" && selectedLatitude != null && selectedLongitude != null;
    final hasManualLocation = _locationSource == "manual" && addressController.text.trim().isNotEmpty;
    
    if (!hasMapLocation && !hasManualLocation) {
      throw Exception('Please select a location on the map or enter an address manually');
    }

    // Prepare location data for backend
    final locationData = {
      'detectedLocation': detectedLocation,
      'manualAddress': addressController.text.trim(),
      'sendLocationDirectly': sendLocationDirectly,
      'latitude': selectedLatitude,
      'longitude': selectedLongitude,
      'accuracy': locationAccuracy,
      'locationSource': _locationSource,
      'timestamp': DateTime.now().toIso8601String(),
    };

    print('Saving location data to backend: $locationData');

    // Merge location data with report data
    final completeReportData = {
      ...widget.reportData,
      ...locationData,
    };

    return completeReportData;
  }

  Future<void> _handleReviewSubmit() async {
    // Validate location
    final hasMapLocation = _locationSource == "map" && selectedLatitude != null && selectedLongitude != null;
    final hasManualLocation = _locationSource == "manual" && addressController.text.trim().isNotEmpty;
    
    if (!hasMapLocation && !hasManualLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location on the map or enter an address manually'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      final completeReportData = await _saveLocationData();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewReportScreen(
            reportData: completeReportData,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25),
                    _buildMapContainer(),
                    const SizedBox(height: 20),
                    _buildInteractiveMapInfo(),
                    const SizedBox(height: 25),
                    _buildLocationDetectedCard(),
                    const SizedBox(height: 25),
                    _buildManualAddressSection(),
                    const SizedBox(height: 25),
                    _buildSendLocationCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildReviewButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              children: [
                Text(
                  'Location',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Where did this incident occur?',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapContainer() {
    if (_isLoadingLocation) {
      return Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.grey[100],
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF36599F),
          ),
        ),
      );
    }

    return MapPickerWidget(
      initialLatitude: selectedLatitude,
      initialLongitude: selectedLongitude,
      onLocationSelected: _onMapLocationSelected,
      height: 400, // Increased height for better visibility
    );
  }

  Widget _buildInteractiveMapInfo() {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFFEF4444),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Interactive Map View',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _locationSource == "map" 
                    ? 'Location selected on map' 
                    : 'Tap on map to select location',
                style: TextStyle(
                  fontSize: 14,
                  color: _locationSource == "map" ? const Color(0xFF10B981) : Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDetectedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isLocationDetected ? const Color(0xFF10B981) : Colors.grey[300]!,
          width: 1.5,
        ),
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
          Icon(
            Icons.check_circle,
            color: isLocationDetected ? const Color(0xFF10B981) : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location Detected',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isLocationDetected ? const Color(0xFF36599F) : Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                _isLoadingAddress
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF36599F),
                        ),
                      )
                    : Text(
                        // Display selected location from map or manual input
                        _locationSource == "manual" && addressController.text.isNotEmpty
                            ? addressController.text
                            : (detectedLocation.isNotEmpty ? detectedLocation : "No location selected"),
                        style: TextStyle(
                          fontSize: 14,
                          color: isLocationDetected ? Colors.black87 : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                const SizedBox(height: 4),
                Text(
                  'Accuracy: $locationAccuracy',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'OR Enter Address Manually',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF36599F),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _locationSource == "manual" ? const Color(0xFF10B981) : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _locationSource == "manual" ? 'Active' : 'Optional',
                style: TextStyle(
                  color: _locationSource == "manual" ? Colors.white : Colors.grey[700],
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'If you prefer, type the address instead of selecting on map',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: addressController,
            decoration: InputDecoration(
              hintText: 'Enter specific address or landmark (e.g., "KG 123 St, Kigali")',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _locationSource == "manual" ? const Color(0xFF10B981) : Colors.grey[200]!,
                  width: _locationSource == "manual" ? 2 : 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _locationSource == "manual" ? const Color(0xFF10B981) : Colors.grey[200]!,
                  width: _locationSource == "manual" ? 2 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF36599F), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: const Icon(Icons.edit_location_alt, color: Color(0xFF36599F)),
            ),
            onChanged: _onManualAddressChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSendLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Send My Location Directly',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF36599F),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Share precise GPS coordinates with police',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Switch(
            value: sendLocationDirectly,
            onChanged: (value) {
              setState(() {
                sendLocationDirectly = value;
              });
            },
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF36599F),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewButton() {
    return Container(
      padding: const EdgeInsets.all(30),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _handleReviewSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF36599F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Review & Submit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
