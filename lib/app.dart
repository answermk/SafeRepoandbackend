import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:safereport_mobo/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'services/api_client.dart';
import 'utils/language_controller.dart';
import 'controllers/language_controller_state.dart';
import 'providers/app_settings_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/onboarding_screen_1.dart';
import 'screens/onboarding_screen_2.dart';
import 'screens/onboarding_screen_3.dart';
import 'screens/onboarding_screen_4.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/privacy_data_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/check_email_screen.dart';
import 'screens/location_services_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/report_success_screen.dart';
import 'screens/location_screen.dart';
import 'screens/review_report_screen.dart';
import 'screens/emergency_contact_screen.dart';
import 'screens/report_crime_screen.dart';
import 'screens/my_reports_screen.dart';
import 'screens/report_details_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/emergency_mode_screen.dart';
import 'screens/my_watch_groups_screen.dart';
import 'screens/watch_group_details_screen.dart';
import 'screens/group_chat_screen.dart';
import 'screens/profile_edit_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/account_settings_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/community_forum_screen.dart';
import 'screens/forum_post_screen.dart';
import 'screens/report_status_tracking_screen.dart';
import 'screens/media_gallery_screen.dart';
import 'screens/feedback_rating_screen.dart';
import 'screens/multi_language_screen.dart';
import 'screens/accessibility_settings_screen.dart';
import 'screens/tutorial_faq_screen.dart';
import 'screens/incident_map_view_screen.dart';
import 'screens/create_post_screen.dart';

// NEW SCREENS - Add these imports
import 'screens/media_capture_screen.dart';
import 'screens/community_statistics_screen.dart';
import 'screens/my_impact_screen.dart';
import 'screens/nearby_incidents_screen.dart';
import 'screens/safety_education_screen.dart';
import 'screens/offline_reports_queue_screen.dart';
import 'screens/anonymous_reporting_info_screen.dart';

class SafeReportApp extends StatefulWidget {
  const SafeReportApp({super.key});

  @override
  State<SafeReportApp> createState() => _SafeReportAppState();
}

class _SafeReportAppState extends State<SafeReportApp> {
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final locale = await LanguageController.initializeLanguage();
    if (mounted) {
      setState(() {
        _locale = locale;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // API client is initialized lazily when first accessed via ApiClient.dio
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageControllerState()),
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
      ],
      child: Consumer2<LanguageControllerState, AppSettingsProvider>(
        builder: (context, languageState, appSettings, _) {
          // Update locale when language state changes
          if (languageState.currentLocale != _locale) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _locale = languageState.currentLocale;
                });
              }
            });
          }

          // Use app settings for locale and theme
          final currentLocale = appSettings.locale;
          final themeData = appSettings.getThemeData();

          return MaterialApp(
            title: 'SafeReport',
            debugShowCheckedModeBanner: false,
            // Localization support
            locale: currentLocale,
            localizationsDelegates: LanguageController.getLocalizationDelegates(),
            supportedLocales: LanguageController.getSupportedLocales(),
            theme: themeData,
            darkTheme: appSettings.isDarkMode ? themeData : null,
            themeMode: appSettings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            builder: (context, child) {
              // Apply font scaling globally
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(appSettings.fontScale),
                ),
                child: child!,
              );
            },
      // Start with Welcome Screen instead of OnboardingFlow
      home: const WelcomeScreen(),

      // Define named routes for better navigation management
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/onboarding1': (context) => const OnboardingScreen1(),
        '/onboarding2': (context) => const OnboardingScreen2(),
        '/onboarding3': (context) => const OnboardingScreen3(),
        '/onboarding4': (context) => const OnboardingScreen4(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        // Note: /check-email route is not used directly - email is passed via navigation
        // '/check-email': (context) => const CheckEmailScreen(email: ''),
        '/notifications': (context) => const NotificationsScreen(),
        '/location-services': (context) => const LocationServicesScreen(),
        '/privacy-data': (context) => const PrivacyDataScreen(),
        '/dashboard': (context) => const DashboardScreen(),

        // Main App Screens
        '/report-crime': (context) => const ReportCrimeScreen(),
        '/my-reports': (context) => const MyReportsScreen(),
        '/messages': (context) => const MessagesScreen(),
        '/profile': (context) => const ProfileScreen(),

        // Settings & Profile
        '/account-settings': (context) => const AccountSettingsScreen(),
        '/profile-edit': (context) => const ProfileEditScreen(),
        '/accessibility': (context) => const AccessibilitySettingsScreen(),
        '/multi-language': (context) => const MultiLanguageScreen(),

        // Community Features
        '/community-forum': (context) => const CommunityForumScreen(),
        '/my-watch-groups': (context) => const MyWatchGroupsScreen(),

        // Support & Help
        '/help-support': (context) => const HelpSupportScreen(),
        '/tutorial-faq': (context) => const TutorialFaqScreen(),
        '/feedback-rating': (context) => const FeedbackRatingScreen(),

        // Emergency
        '/emergency-mode': (context) => const EmergencyModeScreen(),
        '/emergency-contact': (context) => const EmergencyContactScreen(),

        // NEW SCREENS
        '/community-statistics': (context) => const CommunityStatisticsScreen(),
        '/my-impact': (context) => const MyImpactScreen(),
        '/nearby-incidents': (context) => const NearbyIncidentsScreen(),
        '/safety-education': (context) => const SafetyEducationScreen(),
        '/offline-queue': (context) => const OfflineReportsQueueScreen(),
        '/anonymous-info': (context) => const AnonymousReportingInfoScreen(),
            },
          );
        },
      ),
    );
  }
}