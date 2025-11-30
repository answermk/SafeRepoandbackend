// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Safe Report';

  @override
  String get welcome => 'Welcome';

  @override
  String get reportCrime => 'Report Crime';

  @override
  String get myReports => 'My Reports';

  @override
  String get messages => 'Messages';

  @override
  String get profile => 'Profile';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get emergency => 'Emergency';

  @override
  String get communityForum => 'Community Forum';

  @override
  String get watchGroups => 'Watch Groups';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get login => 'Login';

  @override
  String get signup => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get submit => 'Submit';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get noData => 'No data available';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get description => 'Description';

  @override
  String get location => 'Location';

  @override
  String get anonymous => 'Anonymous';

  @override
  String get submitAnonymously => 'Submit Anonymously';

  @override
  String get addEvidence => 'Add Evidence';

  @override
  String get photo => 'Photo';

  @override
  String get video => 'Video';

  @override
  String get audio => 'Audio';

  @override
  String get continueButton => 'Continue';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get signIn => 'Sign In';

  @override
  String get logIntoYourAccount => 'Log Into your account';

  @override
  String get rememberMe => 'Remember me?';

  @override
  String get noAccount => 'No Account?';

  @override
  String get createAnAccount => 'Create an Account';

  @override
  String get fullName => 'Full Name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get registerAnonymously => 'Register Anonymously';

  @override
  String get enterFullName => 'Enter Full Name';

  @override
  String get youremailGmailCom => 'youremail@gmail.com';

  @override
  String get testCredentials => 'Test Credentials';

  @override
  String get emailTestSafereportCom => 'Email: test@safereport.com';

  @override
  String get passwordSafeReport123 => 'Password: SafeReport123';

  @override
  String goodMorning(String userName) {
    return 'Good Morning, $userName';
  }

  @override
  String get reportNow => 'Report Now';

  @override
  String get yourCommunitySafetyHub => 'Your Community\nSafety Hub';

  @override
  String get communityStatus => 'Community Status';

  @override
  String get thisWeek => 'This Week';

  @override
  String get avgResponse => 'Avg Response';

  @override
  String get safetyLevel => 'Safety Level';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get nearbyIncidents => 'Nearby Incidents';

  @override
  String nearbyIncidentsCount(int count) {
    return '$count nearby';
  }

  @override
  String get viewAll => 'View All';

  @override
  String get watchGroupInfo => 'Watch Group';

  @override
  String newAlerts(int count) {
    return '$count new alerts';
  }

  @override
  String get safetyEducation => 'Safety Education';

  @override
  String get learnMore => 'Learn More';

  @override
  String get selectIncidentType => 'Select Incident Type';

  @override
  String get pleaseSelectAnIncidentType => 'Please select an incident type';

  @override
  String get pleaseProvideADescription => 'Please provide a description';

  @override
  String get suspiciousPerson => 'Suspicious Person';

  @override
  String get individualActingSuspiciously => 'Individual acting suspiciously';

  @override
  String get vehicleActivity => 'Vehicle Activity';

  @override
  String get suspiciousVehicleBehavior => 'Suspicious vehicle behavior';

  @override
  String get abandonedItem => 'Abandoned Item';

  @override
  String get unattendedSuspiciousItems => 'Unattended suspicious items';

  @override
  String get theftBurglary => 'Theft/Burglary';

  @override
  String get propertyTheftOrBreakIn => 'Property theft or break-in';

  @override
  String get vandalism => 'Vandalism';

  @override
  String get propertyDamageOrGraffiti => 'Property damage or graffiti';

  @override
  String get drugActivity => 'Drug Activity';

  @override
  String get suspectedDrugRelatedBehavior => 'Suspected drug-related behavior';

  @override
  String get assaultViolence => 'Assault/Violence';

  @override
  String get physicalAltercationOrThreat => 'Physical altercation or threat';

  @override
  String get noiseDisturbance => 'Noise Disturbance';

  @override
  String get excessiveNoiseComplaint => 'Excessive noise complaint';

  @override
  String get trespassing => 'Trespassing';

  @override
  String get unauthorizedEntry => 'Unauthorized entry';

  @override
  String get other => 'Other';

  @override
  String get otherIncidentType => 'Other incident type';

  @override
  String get describeTheIncident => 'Describe the incident';

  @override
  String get addPhotosVideosOrAudio => 'Add Photos, Videos, or Audio';

  @override
  String get draftSaved => 'Draft saved';

  @override
  String get saving => 'Saving...';

  @override
  String savedXMinutesAgo(int minutes) {
    return 'Saved $minutes minutes ago';
  }

  @override
  String get restoreDraft => 'Restore Draft';

  @override
  String get youHaveAnUnsavedDraft =>
      'You have an unsaved draft. Would you like to restore it?';

  @override
  String get restore => 'Restore';

  @override
  String get discard => 'Discard';

  @override
  String get continueToLocation => 'Continue to Location';

  @override
  String get all => 'All';

  @override
  String get active => 'Active';

  @override
  String get resolved => 'Resolved';

  @override
  String get submitted => 'Submitted';

  @override
  String get reviewing => 'Reviewing';

  @override
  String get sortBy => 'Sort By';

  @override
  String get date => 'Date';

  @override
  String get status => 'Status';

  @override
  String get type => 'Type';

  @override
  String get deleteReports => 'Delete Reports';

  @override
  String areYouSureYouWantToDelete(int count) {
    return 'Are you sure you want to delete $count report(s)?';
  }

  @override
  String get reportsDeleted => 'Reports deleted';

  @override
  String get noReportsSelected => 'No reports selected';

  @override
  String get exportToPDF => 'Export to PDF';

  @override
  String get shareReports => 'Share Reports';

  @override
  String get mySafetyReports => 'My Safety Reports';

  @override
  String get accountInformation => 'Account Information';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String memberSince(String date) {
    return 'Member since $date';
  }

  @override
  String get myProfile => 'My Profile';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get changePassword => 'Change Password';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get myImpact => 'My Impact';

  @override
  String get offlineQueue => 'Offline Queue';

  @override
  String get accessibility => 'Accessibility';

  @override
  String get language => 'Language';

  @override
  String get accountSettingsTitle => 'Account Settings';

  @override
  String get manageYourPreferences => 'Manage your preferences';

  @override
  String get securitySettings => 'Security Settings';

  @override
  String lastChangedXDaysAgo(int days) {
    return 'Last changed $days days ago';
  }

  @override
  String get update => 'Update';

  @override
  String get twoFactorAuthentication => 'Two-Factor Authentication';

  @override
  String get addExtraSecurityToYourAccount =>
      'Add extra security to your account';

  @override
  String get biometricLogin => 'Biometric Login';

  @override
  String get useFingerprintOrFaceId => 'Use fingerprint or face ID';

  @override
  String get notificationsPreferences => 'Notifications Preferences';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get reportUpdatesAndAlerts => 'Report updates and alerts';

  @override
  String get emailUpdates => 'Email Updates';

  @override
  String get weeklyCommunitySummary => 'Weekly community summary';

  @override
  String get watchGroupAlerts => 'Watch Group Alerts';

  @override
  String get messagesFromYourGroups => 'Messages from your groups';

  @override
  String get privacySettings => 'Privacy Settings';

  @override
  String get defaultAnonymousMode => 'Default Anonymous Mode';

  @override
  String get alwaysSubmitReportsAnonymously =>
      'Always submit reports anonymously';

  @override
  String get locationSharing => 'Location Sharing';

  @override
  String get sharePreciseLocationWithReports =>
      'Share precise location with reports';

  @override
  String get anonymousReportingGuide => 'Anonymous Reporting Guide';

  @override
  String get learnAboutPrivacyProtections => 'Learn about privacy protections';

  @override
  String get languagePreferences => 'Language Preferences';

  @override
  String get appLanguage => 'App Language';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get kinyarwanda => 'Kinyarwanda';

  @override
  String get swahili => 'Swahili';

  @override
  String get spanish => 'Spanish';

  @override
  String get offlineReports => 'Offline Reports';

  @override
  String get manageReportsWhenOffline => 'Manage reports when offline';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get passwordStrength => 'Password Strength';

  @override
  String get weak => 'Weak';

  @override
  String get medium => 'Medium';

  @override
  String get strong => 'Strong';

  @override
  String get veryStrong => 'Very Strong';

  @override
  String get passwordRequirements => 'Password Requirements';

  @override
  String get atLeast8Characters => 'At least 8 characters';

  @override
  String get oneUppercaseLetter => 'One uppercase letter';

  @override
  String get oneLowercaseLetter => 'One lowercase letter';

  @override
  String get oneNumber => 'One number';

  @override
  String get oneSpecialCharacter => 'One special character';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully!';

  @override
  String get accessibilitySettings => 'Accessibility Settings';

  @override
  String get customizeTheAppToMakeItEasierToUse =>
      'Customize the app to make it easier to use';

  @override
  String get fontSize => 'Font Size';

  @override
  String get adjustTextSize => 'Adjust text size for better readability';

  @override
  String get highContrastMode => 'High Contrast Mode';

  @override
  String get improveVisibilityWithHighContrast =>
      'Improve visibility with high contrast colors';

  @override
  String get textToSpeech => 'Text-to-Speech';

  @override
  String get readContentAloud => 'Read content aloud';

  @override
  String get accessibilitySettingsSavedSuccessfully =>
      'Accessibility settings saved successfully!';

  @override
  String errorSavingSettings(String error) {
    return 'Error saving settings: $error';
  }

  @override
  String get helpSupportTitle => 'Help & Support';

  @override
  String get getAssistanceAndAnswers => 'Get assistance and answers';

  @override
  String get needHelp => 'Need Help?';

  @override
  String get wereHereToAssistYou247 => 'We\'re here to assist you 24/7';

  @override
  String get startLiveChat => 'Start Live Chat';

  @override
  String get quickHelp => 'Quick Help';

  @override
  String get frequentlyAskedQuestions => 'Frequently Asked Questions';

  @override
  String get commonQuestionsAndAnswers => 'Common questions and answers';

  @override
  String get reportingGuidelines => 'Reporting Guidelines';

  @override
  String get bestPracticesForSafetyReporting =>
      'Best practices for safety reporting';

  @override
  String get communityGuidelines => 'Community Guidelines';

  @override
  String get rulesAndExpectations => 'Rules and expectations';

  @override
  String get contactOptions => 'Contact Options';

  @override
  String get emailSupport => 'Email Support';

  @override
  String get supportSafereportCom => 'support@saferreport.com';

  @override
  String get phoneSupport => 'Phone Support';

  @override
  String get call => 'Call';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get tellUsHowWeCanImprove => 'Tell us how we can improve ......';

  @override
  String get submitFeedback => 'Submit Feedback';

  @override
  String get couldNotOpenEmailClient => 'Could not open email client';

  @override
  String couldNotMakePhoneCall(String error) {
    return 'Could not make phone call: $error';
  }

  @override
  String get emergencyMode => 'Emergency Mode';

  @override
  String get helpIsOnTheWay =>
      'Help is on the way.\nYour location is being shared with emergency services.';

  @override
  String get policeETA => 'Police ETA';

  @override
  String xToYMinutes(int min, int max) {
    return '$min-$max minutes';
  }

  @override
  String get callNow => 'CALL NOW';

  @override
  String get cancelEmergency => 'Cancel Emergency';

  @override
  String get yourEmergencyContactsHaveBeenNotified =>
      'Your emergency contacts have been notified';

  @override
  String get selectEmergencyService => 'Select Emergency Service';

  @override
  String get policeEmergency => 'Police Emergency';

  @override
  String get fireDepartment => 'Fire Department';

  @override
  String get ambulance => 'Ambulance';

  @override
  String get nonEmergencyPolice => 'Non-Emergency Police';

  @override
  String get communityForumTitle => 'Community Forum';

  @override
  String get discussLocalSafetys => 'Discuss local safetys';

  @override
  String get popular => 'Popular';

  @override
  String get recent => 'Recent';

  @override
  String get following => 'Following';

  @override
  String get createNewPost => 'Create New Post';

  @override
  String get recentPostsComingSoon => 'Recent posts coming soon...';

  @override
  String get followingPostsComingSoon => 'Following posts coming soon...';

  @override
  String get bestHomeSecurityCameras2023 => 'Best home security cameras 2023?';

  @override
  String get neighborhoodPatrolTips => 'Neighborhood patrol tips';

  @override
  String get holidaySafetyAdvisory => 'Holiday Safety Advisory';

  @override
  String get comments => 'Comments';

  @override
  String get helpful => 'Helpful';

  @override
  String hoursAgo(int hours) {
    return '$hours hrs ago';
  }

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get myWatchGroups => 'My Watch Groups';

  @override
  String get communitySafetyPartnerships => 'Community safety partnerships';

  @override
  String get oakStreetResidential => 'Oak Street Residential';

  @override
  String get oakStreetNeighborhood => 'Oak Street Neighborhood';

  @override
  String get downtownBusiness => 'Downtown Business';

  @override
  String get businessDistrict => 'Business District';

  @override
  String get members => 'Members';

  @override
  String get alerts => 'Alerts';

  @override
  String get coverage => 'Coverage';

  @override
  String get schedule => 'Schedule';

  @override
  String get monFri9AM5PM => 'Mon-Fri 9AM-5PM';

  @override
  String get businessHours => 'Business hours';

  @override
  String get viewMessages => 'View Messages';

  @override
  String get viewDetails => 'View Details';

  @override
  String get findMoreGroups => 'Find More Groups';

  @override
  String get discoverAndJoinWatchGroups =>
      'Discover and join watch groups in your area';

  @override
  String get browseGroups => 'Browse Groups';

  @override
  String get yourImpact => 'Your Impact';

  @override
  String get contributionsToCommunitySafety =>
      'Your contributions to community safety';

  @override
  String get reportsSubmitted => 'Reports Submitted';

  @override
  String get watchGroupsJoined => 'Watch Groups Joined';

  @override
  String get helpfulResponses => 'Helpful Responses';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get stayInformedAboutImportantUpdates =>
      'Stay informed about important updates and alerts';

  @override
  String get enable => 'Enable';

  @override
  String get skip => 'Skip';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get yourCommunications => 'Your communications';

  @override
  String get reportCommunications => 'Report Communications';

  @override
  String get directContact => 'Direct Contact';

  @override
  String get officer => 'Officer';

  @override
  String get newMessage => 'New Message';

  @override
  String get viewAllMessages => 'View All Messages';

  @override
  String get joinDiscussion => 'Join Discussion';

  @override
  String get anonymousReporting => 'Anonymous Reporting';

  @override
  String get whatIsHidden => 'What is Hidden';

  @override
  String get whatIsShared => 'What is Shared';

  @override
  String get benefits => 'Benefits';

  @override
  String get legalProtection => 'Legal Protection';

  @override
  String get faq => 'FAQ';

  @override
  String get appLanguageTitle => 'App Language';

  @override
  String get selectYourPreferredLanguage => 'Select your preferred language:';

  @override
  String get saveLanguage => 'Save Language';

  @override
  String get nearbyIncidentsTitle => 'Nearby Incidents';

  @override
  String get mapView => 'Map View';

  @override
  String get radius => 'Radius';

  @override
  String get timeFilter => 'Time Filter';

  @override
  String get km => 'km';

  @override
  String get h => 'h';

  @override
  String minAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String hourAgo(int hours) {
    return '$hours hour ago';
  }

  @override
  String hoursAgoPlural(int hours) {
    return '$hours hours ago';
  }

  @override
  String get distance => 'Distance';

  @override
  String get severity => 'Severity';

  @override
  String get low => 'Low';

  @override
  String get high => 'High';

  @override
  String get safeReport => 'SafeReport';

  @override
  String get aRealTimeCrimePreventionPlatform =>
      'A Real-Time Crime Prevention Platform uses smart technology to detect and respond to crime instantly, helping keep communities safe through quick alerts and data-driven actions.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get loginSuccessful => 'Login successful! Welcome to SafeReport';

  @override
  String get invalidEmailOrPassword =>
      'Invalid email or password. Try sample credentials.';

  @override
  String get pleaseEnterBothEmailAndPassword =>
      'Please enter both email and password';

  @override
  String connectionError(String error) {
    return 'Connection error: $error';
  }

  @override
  String get accountCreatedSuccessfully =>
      'Account created successfully! Please sign in.';

  @override
  String get unknown => 'Unknown';

  @override
  String photosAdded(int count) {
    return '$count photo(s) added';
  }

  @override
  String videosAdded(int count) {
    return '$count video(s) added';
  }

  @override
  String audiosAdded(int count) {
    return '$count audio(s) added';
  }
}
