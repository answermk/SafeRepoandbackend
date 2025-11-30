import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class PrivacyDataScreen extends StatefulWidget {
  const PrivacyDataScreen({super.key});

  @override
  State<PrivacyDataScreen> createState() => _PrivacyDataScreenState();
}

class _PrivacyDataScreenState extends State<PrivacyDataScreen> {
  bool _dataCollection = true;
  bool _anonymousReporting = true;
  bool _communication = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Main content
            Expanded(
              child: _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 100,
      decoration: const BoxDecoration(
        color: Color(0xFF36599F),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Privacy & Data',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Balance the back button
              ],
            ),
            const SizedBox(height: 5),
            const Text(
              'Your privacy is our priority',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Database Icon with Shield
            _buildDatabaseIcon(),

            const SizedBox(height: 40),

            // Information Cards
            _buildInfoCard(
              title: 'Data Collection',
              description: 'We collect only necessary information to provide safety services',
              checkboxText: 'I agree to data collection',
              value: _dataCollection,
              onChanged: (value) {
                setState(() {
                  _dataCollection = value ?? false;
                });
              },
            ),

            const SizedBox(height: 15),

            _buildInfoCard(
              title: 'Anonymous Reporting',
              description: 'You can report incidents without revealing your identity',
              checkboxText: 'I understand anonymous options',
              value: _anonymousReporting,
              onChanged: (value) {
                setState(() {
                  _anonymousReporting = value ?? false;
                });
              },
            ),

            const SizedBox(height: 15),

            _buildInfoCard(
              title: 'Communication',
              description: 'We may contact you regarding your reports for follow-up',
              checkboxText: 'I consent to safety communications',
              value: _communication,
              onChanged: (value) {
                setState(() {
                  _communication = value ?? false;
                });
              },
            ),

            const SizedBox(height: 40),

            // Accept & Continue Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF36599F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Accept & Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Policy Links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    // Handle privacy policy
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Privacy Policy',
                    style: TextStyle(
                      color: Color(0xFF36599F),
                      decoration: TextDecoration.underline,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const Text(
                  ' • ',
                  style: TextStyle(
                    color: Color(0xFF36599F),
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Handle terms of service
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Terms of Service',
                    style: TextStyle(
                      color: Color(0xFF36599F),
                      decoration: TextDecoration.underline,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDatabaseIcon() {
    return Container(
      width: 100,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Database stack
          Container(
            width: 70,
            height: 60,
            child: Stack(
              children: [
                // Database cylinder
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: 70,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color(0xFF36599F),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Top section
                        Container(
                          height: 15,
                          margin: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Color(0xFFE8F4FD),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        // Middle section
                        Container(
                          height: 15,
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: Color(0xFFE8F4FD),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        // Bottom section
                        Container(
                          height: 15,
                          margin: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Color(0xFFE8F4FD),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Database base
                Positioned(
                  bottom: 0,
                  left: 5,
                  right: 5,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(0xFF36599F),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Shield overlay
          Positioned(
            bottom: -5,
            right: -5,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Color(0xFF36599F),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.shield,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String description,
    required String checkboxText,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 15),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: value,
                  onChanged: onChanged,
                  activeColor: const Color(0xFF36599F),
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  checkboxText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}