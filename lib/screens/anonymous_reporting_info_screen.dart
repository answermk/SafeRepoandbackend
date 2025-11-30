import 'package:flutter/material.dart';

class AnonymousReportingInfoScreen extends StatelessWidget {
  const AnonymousReportingInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Anonymous Reporting', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF36599F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            _buildWhatIsHiddenSection(),
            _buildWhatIsSharedSection(),
            _buildBenefitsSection(),
            _buildLegalProtectionSection(),
            _buildFAQSection(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.privacy_tip, color: Color(0xFF8B5CF6), size: 32),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report Safely',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your identity is fully protected',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatIsHiddenSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          Row(
            children: [
              Icon(Icons.visibility_off, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                'What\'s Hidden',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoItem(Icons.person_off, 'Your name and identity', Colors.green),
          _buildInfoItem(Icons.email_outlined, 'Email address', Colors.green),
          _buildInfoItem(Icons.phone_disabled, 'Phone number', Colors.green),
          _buildInfoItem(Icons.account_circle_outlined, 'Account ID', Colors.green),
          _buildInfoItem(Icons.fingerprint, 'Personal identifiers', Colors.green),
        ],
      ),
    );
  }

  Widget _buildWhatIsSharedSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
          Row(
            children: [
              Icon(Icons.visibility, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Text(
                'What\'s Still Shared',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoItem(Icons.location_on, 'Incident location only', Colors.orange),
          _buildInfoItem(Icons.access_time, 'Time of report', Colors.orange),
          _buildInfoItem(Icons.description, 'Report description', Colors.orange),
          _buildInfoItem(Icons.camera_alt, 'Evidence (if provided)', Colors.orange),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.orange[700]),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'This information helps police respond effectively without revealing who you are',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
          const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF36599F)),
              SizedBox(width: 8),
              Text(
                'Benefits of Anonymous Reporting',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF36599F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBenefitItem('Report without fear of retaliation'),
          _buildBenefitItem('Protect your personal safety'),
          _buildBenefitItem('Help your community without exposure'),
          _buildBenefitItem('No follow-up contact unless you choose'),
        ],
      ),
    );
  }

  Widget _buildLegalProtectionSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF36599F).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.gavel, color: Color(0xFF36599F)),
              SizedBox(width: 8),
              Text(
                'Legal Protection',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF36599F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Anonymous reports are protected by law. Your identity cannot be disclosed without your explicit consent, even under legal proceedings.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
          const Row(
            children: [
              Icon(Icons.help_outline, color: Color(0xFF36599F)),
              SizedBox(width: 8),
              Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF36599F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFAQItem(
            'Can police trace my report back to me?',
            'No. Anonymous reports are encrypted and stored without any identifying information.',
          ),
          _buildFAQItem(
            'Can I switch between anonymous and non-anonymous?',
            'Yes, you can choose for each report whether to submit anonymously or with your information.',
          ),
          _buildFAQItem(
            'Will my report be taken less seriously?',
            'No. All reports are investigated equally regardless of anonymity status.',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, size: 20, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}