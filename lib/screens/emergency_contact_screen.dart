import 'package:flutter/material.dart';

class EmergencyContactScreen extends StatelessWidget {
  const EmergencyContactScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildDangerAlert(),
                      const SizedBox(height: 16),
                      _buildSectionTitle(
                        icon: Icons.emergency,
                        title: 'Emergency Services',
                      ),
                      const SizedBox(height: 8),
                      _buildEmergencyServicesGrid(),
                      const SizedBox(height: 24),
                      _buildSectionTitle(
                        icon: Icons.account_balance,
                        title: 'Local Authorities',
                      ),
                      const SizedBox(height: 8),
                      _buildLocalAuthorities(),
                      const SizedBox(height: 24),
                      _buildSectionTitle(
                        icon: Icons.groups,
                        title: 'Personal Contacts',
                      ),
                      const SizedBox(height: 8),
                      _buildPersonalContacts(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: const Color(0xFF36599F),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Emergency Contact',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                'Quick access to help',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDangerAlert() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE5E5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'For immediate danger, call 911',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Use these contacts for non-emergency situations',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF36599F)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF36599F),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyServicesGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildServiceCard(
          icon: Icons.local_police,
          label: 'Police',
          number: '112',
        ),
        _buildServiceCard(
          icon: Icons.fire_truck,
          label: 'Fire Dept',
          number: '113',
        ),
        _buildServiceCard(
          icon: Icons.medical_services,
          label: 'Medical',
          number: '911',
        ),
        _buildServiceCard(
          icon: Icons.phone_in_talk,
          label: 'Poison Control',
          number: '1-800-222-1222',
        ),
      ],
    );
  }

  Widget _buildServiceCard({required IconData icon, required String label, required String number}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade100, width: 1.5),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: const Color(0xFFFF1400)),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF36599F),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            number,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalAuthorities() {
    return Column(
      children: [
        _buildAuthorityTile(
          title: 'Police Station',
          subtitle: 'Downtown Precinct',
        ),
        const SizedBox(height: 12),
        _buildAuthorityTile(
          title: 'City Hall',
          subtitle: 'Non-emergency reporting',
        ),
      ],
    );
  }

  Widget _buildAuthorityTile({required String title, required String subtitle}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100, width: 1.2),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF36599F),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 13),
        ),
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF36599F), // Blue background
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          ),
          child: const Text(
            'Call',
            style: TextStyle(color: Colors.white), // White text
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalContacts() {
    return _buildAuthorityTile(
      title: 'Jan Dkak',
      subtitle: 'Emergency Contact',
    );
  }
}