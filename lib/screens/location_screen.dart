import 'package:flutter/material.dart';
import 'review_report_screen.dart';

class LocationScreen extends StatefulWidget {
  final Map<String, dynamic> reportData;

  const LocationScreen({Key? key, required this.reportData}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool isLocationDetected = true;
  bool sendLocationDirectly = true;
  final TextEditingController addressController = TextEditingController();

  // Location data
  String detectedLocation = "123 Main Street, Downtown";
  String locationAccuracy = "±5 meters";
  double? selectedLatitude;
  double? selectedLongitude;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    // TODO: Implement actual location detection
    print('Getting current location...');

    // Simulate location detection
    // final location = await LocationService.getCurrentLocation();
    // setState(() {
    //   detectedLocation = location.address;
    //   locationAccuracy = "±${location.accuracy.toInt()} meters";
    //   selectedLatitude = location.latitude;
    //   selectedLongitude = location.longitude;
    // });
  }

  Future<Map<String, dynamic>> _saveLocationData() async {
    // Prepare location data for backend
    final locationData = {
      'detectedLocation': detectedLocation,
      'manualAddress': addressController.text.trim(),
      'sendLocationDirectly': sendLocationDirectly,
      'latitude': selectedLatitude,
      'longitude': selectedLongitude,
      'accuracy': locationAccuracy,
      'timestamp': DateTime.now().toIso8601String(),
    };

    print('Saving location data to backend: $locationData');

    // TODO: Save to backend
    // await ReportService.updateReportLocation(widget.reportData['id'], locationData);

    // Merge location data with report data
    final completeReportData = {
      ...widget.reportData,
      ...locationData,
    };

    return completeReportData;
  }

  Future<void> _handleReviewSubmit() async {
    final completeReportData = await _saveLocationData();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewReportScreen(
          reportData: completeReportData,
        ),
      ),
    );
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
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // Map background - using a real map-like design
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E8),
                borderRadius: BorderRadius.circular(15),
              ),
              child: CustomPaint(
                painter: MapPainter(),
                size: const Size(double.infinity, 200),
              ),
            ),
            // Location pin
            const Center(
              child: Icon(
                Icons.location_on,
                color: Color(0xFFEF4444),
                size: 40,
              ),
            ),
          ],
        ),
      ),
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
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interactive Map View',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Tap to place pin',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
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
                Text(
                  // Display selected location from map or manual input
                  addressController.text.isNotEmpty ? addressController.text : detectedLocation,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
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
        const Text(
          'Manual Address (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF36599F),
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
              hintText: 'Enter specific address or landmark',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF36599F)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (value) {
              setState(() {
                // Update location display when manual address is entered
              });
              // TODO: Auto-save to backend as user types
            },
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

class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw roads/streets
    paint.color = const Color(0xFFBDBDBD);

    // Horizontal roads
    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.3),
      paint,
    );

    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.7),
      paint,
    );

    // Vertical roads
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.3, size.height),
      paint,
    );

    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.7, size.height),
      paint,
    );

    // Draw some buildings (green squares)
    final buildingPaint = Paint()
      ..color = const Color(0xFF81C784)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.1, 40, 30),
      buildingPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.6, size.height * 0.15, 35, 25),
      buildingPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.75, 30, 20),
      buildingPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}