import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safereport_mobo/screens/offline_reports_queue_screen.dart';
import '../providers/app_settings_provider.dart';
import '../services/language_service.dart';
import '../services/user_service.dart';
import '../services/token_manager.dart';
import '../controllers/language_controller_state.dart';
import 'anonymous_reporting_info_screen.dart';
//import 'offline_reports_queue_screen.dart';
import 'my_impact_screen.dart';
import 'change_password_screen.dart';
import 'accessibility_settings_screen.dart';
import '../l10n/app_localizations.dart';
import '../utils/translation_helper.dart';
import '../utils/theme_helper.dart';

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
  bool locationSharing = true; // Always on by default
  String appLanguage = 'English';
  bool _isLoadingPrivacy = false;
  
  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _loadPrivacySettings();
  }
  
  Future<void> _loadLanguage() async {
    final languageCode = await LanguageService.getSavedLanguage();
    setState(() {
      appLanguage = LanguageService.getLanguageName(languageCode);
    });
  }
  
  Future<void> _loadPrivacySettings() async {
    try {
      final userId = await TokenManager.getUserId();
      if (userId == null) return;
      
      final result = await UserService.getUserProfile(userId);
      if (result['success'] == true && result['data'] != null) {
        final userData = result['data'] as Map<String, dynamic>;
        setState(() {
          anonymousMode = userData['anonymousMode'] ?? false;
          locationSharing = userData['locationSharing'] ?? true; // Default to true
        });
      }
    } catch (e) {
      print('Error loading privacy settings: $e');
    }
  }
  
  Future<void> _savePrivacySettings() async {
    setState(() {
      _isLoadingPrivacy = true;
    });
    
    try {
      final userId = await TokenManager.getUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User ID not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      final result = await UserService.updateUserProfile(
        userId: userId,
        anonymousMode: anonymousMode,
        locationSharing: locationSharing,
      );
      
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Privacy settings saved successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to save privacy settings'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPrivacy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final cardColor = ThemeHelper.getCardColor(context);
    final dividerColor = ThemeHelper.getDividerColor(context);
    final primaryColor = ThemeHelper.getPrimaryColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondaryText = ThemeHelper.getSecondaryTextColor(context);

    return Scaffold(
      backgroundColor: ThemeHelper.getScaffoldBackgroundColor(context),
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(t.accountSettingsTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(t.managePreferencesSubtitle, style: const TextStyle(fontSize: 14, color: Colors.white70)),
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
            _buildQuickAccessSection(t, primaryColor),
            const SizedBox(height: 24),

            // Security Settings
            _buildSection(
              icon: Icons.security,
              title: t.securitySettingsTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FutureBuilder<Map<String, dynamic>>(
                        future: _getPasswordChangeInfo(),
                        builder: (context, snapshot) {
                          final daysSinceChange = snapshot.data?['days'] ?? 0;
                          final lastChanged = snapshot.data?['lastChanged'];
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.changePassword, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(
                                lastChanged != null 
                                    ? t.lastChangedDaysAgo(daysSinceChange)
                                    : t.neverChanged,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: daysSinceChange < 30 ? Colors.orange : Colors.grey,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChangePasswordScreen.forSettings(),
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
                          title: Text(t.twoFactorAuth, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(t.addExtraSecurity),
                    value: twoFactorEnabled,
                    activeColor: const Color(0xFF36599F),
                    onChanged: (val) => setState(() => twoFactorEnabled = val),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                          title: Text(t.biometricLogin, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(t.useFingerprint),
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
              title: t.notificationsPreferencesTitle,
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t.pushNotificationsLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(t.pushNotificationsSubtitle),
                    value: pushNotifications,
                    activeColor: const Color(0xFF36599F),
                    onChanged: (val) => setState(() => pushNotifications = val),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t.emailUpdatesLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(t.emailUpdatesSubtitle),
                    value: emailUpdates,
                    activeColor: const Color(0xFF36599F),
                    onChanged: (val) => setState(() => emailUpdates = val),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t.watchGroupAlertsLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(t.watchGroupAlertsSubtitle),
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
              title: t.privacySettingsTitle,
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t.defaultAnonymousModeLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(t.defaultAnonymousModeSubtitle),
                    value: anonymousMode,
                    activeColor: const Color(0xFF36599F),
                    onChanged: _isLoadingPrivacy ? null : (val) {
                      setState(() => anonymousMode = val);
                      _savePrivacySettings();
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t.locationSharingLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(t.locationSharingSubtitle),
                    value: locationSharing,
                    activeColor: const Color(0xFF36599F),
                    onChanged: null, // Always enabled, cannot be disabled
                    secondary: const Icon(Icons.location_on, color: Color(0xFF36599F)),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.info_outline, color: Color(0xFF36599F)),
                    title: Text(t.anonymousGuideTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(t.anonymousGuideSubtitle),
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
              title: t.languagePreferencesTitle,
              child: Consumer<AppSettingsProvider>(
                builder: (context, appSettings, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.appLanguage, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                        items: LanguageService.getAllLanguages().entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.value,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (val) async {
                          if (val != null) {
                            final languageCode = LanguageService.getLanguageCode(val);
                            if (languageCode != null) {
                              setState(() => appLanguage = val);
                              await appSettings.setLanguage(languageCode);
                              
                              // Also update LanguageControllerState to trigger app rebuild
                              final languageState = Provider.of<LanguageControllerState>(context, listen: false);
                              languageState.changeLanguage(languageCode);
                              
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(t.languageChangedTo(val)),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Accessibility Settings
            _buildSection(
              icon: Icons.accessibility_new,
              title: t.accessibilitySettingsTitle,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.text_fields, color: Color(0xFF36599F)),
                    title: Text(t.accessibilitySettingsLinkTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(t.accessibilitySettingsLinkSubtitle),
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
              child: Text(t.saveAllSettings, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection(AppLocalizations t, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.quickAccess,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                icon: Icons.cloud_queue,
                title: t.offlineQueue,
                subtitle: t.pendingReports,
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
                title: t.myImpact,
                subtitle: t.viewStats,
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
                title: t.accessibilityCardTitle,
                subtitle: t.fontDisplay,
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
          color: ThemeHelper.getCardColor(context),
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
        color: ThemeHelper.getCardColor(context),
        border: Border.all(color: ThemeHelper.getDividerColor(context)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ThemeHelper.getPrimaryColor(context)),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: ThemeHelper.getPrimaryColor(context))),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }


  Future<Map<String, dynamic>> _getPasswordChangeInfo() async {
    try {
      final userId = await TokenManager.getUserId();
      if (userId == null) {
        return {'days': 0, 'canChange': true, 'lastChanged': null};
      }
      
      final result = await UserService.getUserProfile(userId);
      if (result['success'] == true && result['data'] != null) {
        final userData = result['data'] as Map<String, dynamic>;
        final passwordChangedAt = userData['passwordChangedAt'];
        
        if (passwordChangedAt == null) {
          return {'days': 0, 'canChange': true, 'lastChanged': null};
        }
        
        final changedDate = DateTime.parse(passwordChangedAt);
        final now = DateTime.now();
        final difference = now.difference(changedDate);
        final daysSinceChange = difference.inDays;
        final canChange = daysSinceChange >= 30;
        
        return {
          'days': daysSinceChange,
          'canChange': canChange,
          'lastChanged': changedDate,
        };
      }
    } catch (e) {
      print('Error getting password change info: $e');
    }
    
    return {'days': 0, 'canChange': true, 'lastChanged': null};
  }

  void _saveSettings() {
    // Privacy settings are saved automatically when toggled
    // Other settings can be saved here if needed
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}