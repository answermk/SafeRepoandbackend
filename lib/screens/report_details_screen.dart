import 'package:flutter/material.dart';

class ReportDetailsScreen extends StatelessWidget {
  const ReportDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildStatusRow(),
              const SizedBox(height: 12),
              _buildIncidentInfo(),
              const SizedBox(height: 12),
              _buildEvidenceSection(),
              const SizedBox(height: 12),
              _buildStatusUpdates(),
              const SizedBox(height: 16),
              _buildAnonymousBadge(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: const Color(0xFF36599F),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
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
                'Report Details',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                'Report #SP-2025-0001',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF6CA6F7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'UNDER REVIEW',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const Spacer(),
          const Text(
            'Updated 30 mins ago',
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade100, width: 1.2),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Incident Information',
              style: TextStyle(
                color: Color(0xFF36599F),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Type: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Suspicious Person'),
                ],
              ),
              style: TextStyle(fontSize: 14),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Location: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '123 Main Street, Downtown'),
                ],
              ),
              style: TextStyle(fontSize: 14),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Time: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Today, 2:30 PM'),
                ],
              ),
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              'Individual loitering around school entrance for extended period, taking photos of building and observing student dismissal patterns.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade100, width: 1.2),
        ),
        child: Row(
          children: const [
            Icon(Icons.camera_alt, color: Color(0xFF36599F), size: 28),
            SizedBox(width: 16),
            Icon(Icons.videocam, color: Color(0xFF36599F), size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusUpdates() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade100, width: 1.2),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Updates',
              style: TextStyle(
                color: Color(0xFF36599F),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Report Under Review\n', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '30 minutes ago\n'),
                  TextSpan(text: 'Officer Martinez has been assigned to investigate'),
                ],
              ),
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Report Received\n', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '2 hours ago\n'),
                  TextSpan(text: 'Your report has been logged and prioritized'),
                ],
              ),
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnonymousBadge() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade100, width: 1.2),
        ),
        child: Row(
          children: const [
            Text(
              'Anonymous Report',
              style: TextStyle(
                color: Color(0xFF36599F),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Spacer(),
            Icon(Icons.verified_user, color: Color(0xFF10B981), size: 20),
            SizedBox(width: 4),
            Text(
              'Protected',
              style: TextStyle(
                color: Color(0xFF10B981),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}