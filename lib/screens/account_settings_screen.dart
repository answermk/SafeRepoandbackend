import 'package:flutter/material.dart';
import 'package:safereport_mobo/screens/offline_reports_queue_screen.dart';
import 'anonymous_reporting_info_screen.dart';
//import 'offline_reports_queue_screen.dart';
import 'my_impact_screen.dart';
import 'change_password_screen.dart';
import 'accessibility_settings_screen.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool twoFactorEnabled = false;
  bool biometricLogin = true;
  bool pushNotifications = true;
  bool emailUpdates = true;
  bool watchGroupAlerts = true;
  bool anonymousMode = false;
  bool locationSharing = false;
  String appLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Account Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF36599F),
        foregroundColor: Colors.white,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(24),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Manage your preferences', style: TextStyle(fontSize: 14, color: Colors.white70)),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Quick Access Cards Section
            _buildQuickAccessSection(),
            const SizedBox(height: 24),

            // Security Settings
            _buildSection(
              icon: Icons.security,
              title: 'Security Settings',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('Last changed 30 days ago', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChangePasswordScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(70, 36),
                          backgroundColor: const Color(0xFF36599F),
                        ),
                        child: const Text('Update', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Two-Factor Authentication', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Add extra security to your account'),
                    value: twoFactorEnabled,
                    activeColor: const Color(0xFF36599F),
                    onChanged: (val) => setState(() => twoFactorEnabled = val),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Biometric Login', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Use fingerprint or face ID'),
                    value: biometricLogin,
                    activeColor: const Color(0xFF36599F),
                    onChanged: (val) => setState(() => biometricLogin = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notifications Settings
            _buildSection(
              icon: Icons.notifications,
              title: 'Notifications Preferences',
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Report updates and alerts'),
                    value: pushNotifications,
                    activeColor: const Color(0xFF36599F),
                    onChanged: (val) => setState(() => pushNotifications = val),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Email Updates', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Weekly community summary'),
                    value: emailUpdates,
                    activeColor: const Color(0xFF36599F),
                    onChanged: (val) => setState(() => emailUpdates = val),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Watch Group Alerts', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Messages from your groups'),
                    value: watchGroupAlerts,
                    activeColor: const Color(0xFF36599F),
                    onChanged: (val) => setState(() => watchGroupAlerts = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Privacy Settings with Anonymous Reporting Link
            _buildSection(
              icon: Icons.privacy_tip,
              title: 'Privacy Settings',
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Default Anonymous Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Always submit reports anonymously'),
                    value: anonymousMode,
                    activeColor: const Color(0xFF36599F),
                    onChanged: (val) => setState(() => anonymousMode = val),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Location Sharing', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Share precise location with reports'),
                    value: locationSharing,
                    activeColor: const Color(0xFF36599F),
                    onChanged: (val) => setState(() => locationSharing = val),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.info_outline, color: Color(0xFF36599F)),
                    title: const Text('Anonymous Reporting Guide', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Learn about privacy protections'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AnonymousReportingInfoScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Language Settings
            _buildSection(
              icon: Icons.language,
              title: 'Language Preferences',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('App Language', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: appLanguage,
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'English', child: Text('English')),
                      DropdownMenuItem(value: 'Spanish', child: Text('Spanish')),
                      DropdownMenuItem(value: 'French', child: Text('French')),
                      DropdownMenuItem(value: 'Kinyarwanda', child: Text('Kinyarwanda')),
                    ],
                    onChanged: (val) => setState(() => appLanguage = val ?? 'English'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Accessibility Settings
            _buildSection(
              icon: Icons.accessibility_new,
              title: 'Accessibility Settings',
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.text_fields, color: Color(0xFF36599F)),
                    title: const Text('Font Size & Display', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Adjust font size, contrast, and text-to-speech'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccessibilitySettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: () {
                _saveSettings();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                backgroundColor: const Color(0xFF36599F),
              ),
              child: const Text('Save All Settings', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF36599F),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                icon: Icons.cloud_queue,
                title: 'Offline Queue',
                subtitle: 'Pending reports',
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OfflineReportsQueueScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickAccessCard(
                icon: Icons.emoji_events,
                title: 'My Impact',
                subtitle: 'View stats',
                color: Colors.amber,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyImpactScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                icon: Icons.accessibility_new,
                title: 'Accessibility',
                subtitle: 'Font & display',
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccessibilitySettingsScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(), // Empty space for future card
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
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
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF36599F)),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF36599F))),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }


  void _saveSettings() {
    // TODO: Implement backend save logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}