import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dashboard_screen.dart';

class EmergencyModeScreen extends StatelessWidget {
  const EmergencyModeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFB3221),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                _buildSOSIcon(),
                const SizedBox(height: 24),
                const Text(
                  'Emergency Mode',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Help is on the way.\nYour location is being shared with emergency services.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Police ETA', style: TextStyle(color: Colors.white, fontSize: 16)),
                    SizedBox(width: 16),
                    Text('4-6 minutes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: 0.7,
                  backgroundColor: Colors.white24,
                  color: Colors.white,
                  minHeight: 6,
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showEmergencyCallDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'CALL NOW',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Cancel Emergency',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Your emergency contacts have been notified',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSOSIcon() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'SOS',
          style: TextStyle(
            color: Colors.red.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 36,
          ),
        ),
      ),
    );
  }

  void _showEmergencyCallDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Select Emergency Service',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF36599F),
                ),
              ),
            ),
            const Divider(height: 1),
            _buildEmergencyOption(
              context: context,
              icon: Icons.local_police,
              title: 'Police Emergency',
              subtitle: '911',
              phoneNumber: '911',
              color: const Color(0xFF36599F),
            ),
            _buildEmergencyOption(
              context: context,
              icon: Icons.fire_truck,
              title: 'Fire Department',
              subtitle: '911',
              phoneNumber: '911',
              color: const Color(0xFFEF4444),
            ),
            _buildEmergencyOption(
              context: context,
              icon: Icons.local_hospital,
              title: 'Ambulance',
              subtitle: '911',
              phoneNumber: '911',
              color: const Color(0xFF10B981),
            ),
            _buildEmergencyOption(
              context: context,
              icon: Icons.phone,
              title: 'Non-Emergency Police',
              subtitle: '311',
              phoneNumber: '311',
              color: Colors.grey[700]!,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String phoneNumber,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.phone,
            color: Colors.white,
            size: 20,
          ),
        ),
        onPressed: () async {
          Navigator.pop(context); // Close dialog
          await _makePhoneCall(phoneNumber);
        },
      ),
      onTap: () async {
        Navigator.pop(context); // Close dialog
        await _makePhoneCall(phoneNumber);
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        // Fallback: show error message
        if (phoneNumber == '911' || phoneNumber == '311') {
          // For emergency numbers, we still try to launch
          // Some devices may not support canLaunchUrl for emergency numbers
          await launchUrl(phoneUri);
        }
      }
    } catch (e) {
      // Handle error - in a real app, you might want to show a snackbar
      debugPrint('Error making phone call: $e');
    }
  }
}