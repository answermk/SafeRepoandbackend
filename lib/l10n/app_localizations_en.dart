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
  String get usernameMustBeAtLeast3Characters =>
      'Username must be at least 3 characters';

  @override
  String get usernameMustBeLessThan50Characters =>
      'Username must be less than 50 characters';

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
  String goodAfternoon(String userName) {
    return 'Good Afternoon, $userName';
  }

  @override
  String goodEvening(String userName) {
    return 'Good Evening, $userName';
  }

  @override
  String get accessibilitySettingsTitle => 'Accessibility Settings';

  @override
  String get accessibilityCustomize =>
      'Customize the app to make it easier to use';

  @override
  String get fontSizeLabel => 'Font Size';

  @override
  String get fontSizeSmall => 'Small (12px)';

  @override
  String get fontSizeLarge => 'Large (28px)';

  @override
  String get fontSizePreview => 'Preview: This is how text will appear';

  @override
  String get darkModeTitle => 'Dark Mode';

  @override
  String get darkModeSubtitle =>
      'Switch to dark theme for better visibility in low light';

  @override
  String get ttsTitle => 'Enable Text-to-Speech';

  @override
  String get ttsSubtitle => 'Reads text aloud when enabled';

  @override
  String get ttsEnabledToast => 'Text-to-speech enabled';

  @override
  String get settingsSavedAutomatically => 'Settings are saved automatically';

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
    return '$hours hours ago';
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

  @override
  String activeAlertsInYourArea(int count) {
    return '$count active alerts in your area';
  }

  @override
  String get viewGroups => 'View Groups';

  @override
  String get callForHelp => 'Call for help';

  @override
  String get submitIncident => 'Submit Incident';

  @override
  String get viewContributions => 'View contributions';

  @override
  String get safetyTips => 'Safety tips';

  @override
  String get home => 'Home';

  @override
  String get managePreferencesSubtitle => 'Manage your preferences';

  @override
  String get quickAccess => 'Quick Access';

  @override
  String get pendingReports => 'Pending reports';

  @override
  String get viewStats => 'View stats';

  @override
  String get accessibilityCardTitle => 'Accessibility';

  @override
  String get fontDisplay => 'Font & display';

  @override
  String get securitySettingsTitle => 'Security Settings';

  @override
  String lastChangedDaysAgo(int days) {
    return 'Last changed $days days ago';
  }

  @override
  String get neverChanged => 'Never changed';

  @override
  String get twoFactorAuth => 'Two-Factor Authentication';

  @override
  String get addExtraSecurity => 'Add extra security to your account';

  @override
  String get useFingerprint => 'Use fingerprint or face ID';

  @override
  String get notificationsPreferencesTitle => 'Notifications Preferences';

  @override
  String get pushNotificationsLabel => 'Push Notifications';

  @override
  String get pushNotificationsSubtitle => 'Report updates and alerts';

  @override
  String get emailUpdatesLabel => 'Email Updates';

  @override
  String get emailUpdatesSubtitle => 'Weekly community summary';

  @override
  String get watchGroupAlertsLabel => 'Watch Group Alerts';

  @override
  String get watchGroupAlertsSubtitle => 'Messages from your groups';

  @override
  String get privacySettingsTitle => 'Privacy Settings';

  @override
  String get defaultAnonymousModeLabel => 'Default Anonymous Mode';

  @override
  String get defaultAnonymousModeSubtitle =>
      'Always submit reports anonymously';

  @override
  String get locationSharingLabel => 'Location Sharing';

  @override
  String get locationSharingSubtitle =>
      'Share precise location with reports (Always enabled)';

  @override
  String get anonymousGuideTitle => 'Anonymous Reporting Guide';

  @override
  String get anonymousGuideSubtitle => 'Learn about privacy protections';

  @override
  String get languagePreferencesTitle => 'Language Preferences';

  @override
  String languageChangedTo(String language) {
    return 'Language changed to $language';
  }

  @override
  String get accessibilitySettingsLinkTitle => 'Accessibility Settings';

  @override
  String get accessibilitySettingsLinkSubtitle =>
      'Adjust font size, contrast, and text-to-speech';

  @override
  String get saveAllSettings => 'Save All Settings';

  @override
  String get settingsSavedSuccess => 'Settings saved successfully';

  @override
  String get anonymousReportingTitle => 'Anonymous Reporting';

  @override
  String get reportSafely => 'Report Safely';

  @override
  String get identityProtected => 'Your identity is fully protected';

  @override
  String get whatsHiddenTitle => 'What\'s Hidden';

  @override
  String get hiddenName => 'Your name and identity';

  @override
  String get hiddenEmail => 'Email address';

  @override
  String get hiddenPhone => 'Phone number';

  @override
  String get hiddenAccountId => 'Account ID';

  @override
  String get hiddenPersonalIdentifiers => 'Personal identifiers';

  @override
  String get whatsSharedTitle => 'What\'s Still Shared';

  @override
  String get sharedLocation => 'Incident location only';

  @override
  String get sharedTime => 'Time of report';

  @override
  String get sharedDescription => 'Report description';

  @override
  String get sharedEvidence => 'Evidence (if provided)';

  @override
  String get helpsPolice =>
      'This information helps police respond effectively without revealing who you are';

  @override
  String get benefitsAnonymousTitle => 'Benefits of Anonymous Reporting';

  @override
  String get benefit1 => 'Report without fear of retaliation';

  @override
  String get benefit2 => 'Protect your personal safety';

  @override
  String get benefit3 => 'Help your community without exposure';

  @override
  String get benefit4 => 'No follow-up contact unless you choose';

  @override
  String get legalProtectionTitle => 'Legal Protection';

  @override
  String get legalProtectionText =>
      'Anonymous reports are protected by law. Your identity cannot be disclosed without your explicit consent, even under legal proceedings.';

  @override
  String get faqTitle => 'Frequently Asked Questions';

  @override
  String get faqQ1 => 'Can police trace my report back to me?';

  @override
  String get faqA1 =>
      'No. Anonymous reports are encrypted and stored without any identifying information.';

  @override
  String get faqQ2 => 'Can I switch between anonymous and non-anonymous?';

  @override
  String get faqA2 =>
      'Yes, you can choose for each report whether to submit anonymously or with your information.';

  @override
  String get faqQ3 => 'Will my report be taken less seriously?';

  @override
  String get faqA3 =>
      'No. All reports are investigated equally regardless of anonymity status.';

  @override
  String get orText => 'or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get usernameOptionalLabel => 'Username (Optional)';

  @override
  String get usernameOptionalHint => 'Leave empty to auto-generate from email';

  @override
  String get phoneNumberLabel => 'Phone Number';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get createAccount => 'Create an Account';

  @override
  String get alreadyHaveAccount => 'Already have an Account?';

  @override
  String get signUpTitle => 'Sign Up';

  @override
  String get easyReporting => 'Easy Reporting';

  @override
  String get communityWatch => 'Community Watch';

  @override
  String get anonymousSecure => 'Anonymous & Secure';

  @override
  String get emergencyReady => 'Emergency Ready';

  @override
  String get onboardingDescCommon =>
      'Report suspicious activities instantly with\njust a few taps. Your safety is our priority';

  @override
  String get skipTutorial => 'Skip Tutorial';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileSubtitle => 'Manage your personal information';

  @override
  String get usernameLabel => 'Username';

  @override
  String get locationLabel => 'Location';

  @override
  String get emergencyContactTitle => 'Emergency Contact';

  @override
  String get emergencyContactNameHint => 'Jane Doe';

  @override
  String get emergencyContactPhoneHint => '+250 7............';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get unableToLoadProfile => 'Unable to Load Profile';

  @override
  String get retry => 'Retry';

  @override
  String get goBack => 'Go Back';

  @override
  String get memberSinceUnknown => 'Member since unknown';

  @override
  String get usingAvailableData =>
      'Unable to load full profile. Using available data.';

  @override
  String get userIdNotFound => 'User ID not found. Please login again.';

  @override
  String get loadProfileError =>
      'An error occurred while loading your profile. Please try again.';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully';

  @override
  String get failedToUpdateProfile => 'Failed to update profile';

  @override
  String get logoutConfirmTitle => 'Logout';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to logout?';

  @override
  String get learnReportProtect => 'Learn. Report. Protect.';

  @override
  String get empowerWithKnowledge =>
      'Empower yourself with knowledge on responsible reporting';

  @override
  String get featuredArticles => 'Featured Articles';

  @override
  String get howToReportTitle => 'How to Report';

  @override
  String get whatToReportTitle => 'What to Report';

  @override
  String get videoTutorialsTitle => 'Video Tutorials';

  @override
  String get quickSafetyTipsTitle => 'Quick Safety Tips';

  @override
  String get emergencyStepsTitle => 'Emergency Steps';

  @override
  String get closeText => 'Close';

  @override
  String get searchFaqHint => 'Search FAQs...';

  @override
  String get noFaqsFound => 'No FAQs found';

  @override
  String get tryDifferentSearchTerms => 'Try different search terms';

  @override
  String get browseByCategory => 'Browse by Category';

  @override
  String resultsFound(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count result$_temp0 found';
  }

  @override
  String get tutorialFaqTitle => 'Tutorial & FAQ';

  @override
  String get fullNameRequired => 'Full Name is required';

  @override
  String get onboardingDesc1 =>
      'Report suspicious activities instantly with just a few taps. Your safety is our priority.';

  @override
  String get myReportStatusTitle => 'My Report Status';

  @override
  String get suspiciousActivityLabel => 'Suspicious Activity';

  @override
  String get vandalismLabel => 'Vandalism';

  @override
  String get theftLabel => 'Theft';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusInReview => 'In Review';

  @override
  String get statusResolved => 'Resolved';

  @override
  String get dateLabel => 'Date';

  @override
  String get detailsCta => 'Details';

  @override
  String get reportSubmittedTitle => 'Report Submitted!';

  @override
  String get reportSubmittedSubtitle =>
      'Thank you for helping keep your community safe. Law enforcement has been notified.';

  @override
  String get reportIdLabel => 'Report ID:';

  @override
  String get saveIdForReference => 'Save this ID for reference';

  @override
  String get viewMyReportsCta => 'View My Reports';

  @override
  String get returnToHomeCta => 'Return to Home';

  @override
  String get estimatedResponseTime => 'Estimated response time: 5-10 minutes';

  @override
  String get reportDetailsTitle => 'Report Details';

  @override
  String get unableToLoadReportDetails => 'Unable to load report details';

  @override
  String get notAvailable => 'N/A';

  @override
  String updatedTimeAgo(Object timeAgo) {
    return 'Updated $timeAgo';
  }

  @override
  String get updatedUnknown => 'Updated: Unknown';

  @override
  String get untitledReport => 'Untitled Report';

  @override
  String get noDescriptionProvided => 'No description provided';

  @override
  String get locationNotSpecified => 'Location not specified';

  @override
  String get incidentInformation => 'Incident Information';

  @override
  String get typeLabel => 'Type';

  @override
  String get timeLabel => 'Time';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get statusUpdates => 'Status Updates';

  @override
  String get reportUnderReview => 'Report Under Review';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes minutes ago';
  }

  @override
  String get officerAssigned => 'An officer has been assigned to investigate';

  @override
  String get reportReceived => 'Report Received';

  @override
  String get reportLogged => 'Your report has been logged and prioritized';

  @override
  String get anonymousReportLabel => 'Anonymous Report';

  @override
  String get protectedLabel => 'Protected';

  @override
  String get reviewReportTitle => 'Review Report';

  @override
  String get confirmSubmission => 'Confirm your submission';

  @override
  String get reportSummaryTitle => 'Report Summary';

  @override
  String get evidenceLabel => 'Evidence';

  @override
  String get noEvidenceAttached => 'No evidence attached';

  @override
  String get yesLabel => 'Yes';

  @override
  String get noLabel => 'No';

  @override
  String get emergencyPrompt => 'Emergency ?';

  @override
  String get call911Prompt => 'Call 911 for immediate danger';

  @override
  String get submitReportCta => 'Submit Report';

  @override
  String get saveAsDraftCta => 'Save as Draft';

  @override
  String get reportSubmitFailed => 'Failed to submit report';

  @override
  String get draftSavedSuccess => 'Report saved as draft successfully';

  @override
  String get draftSaveFailed => 'Failed to save draft';

  @override
  String get reportCrimeTitle => 'Report Crime';

  @override
  String get reportCrimeSubtitle => 'Help keep your community safe';

  @override
  String get selectIncidentTypeTitle => 'Select Incident Type';

  @override
  String get provideDetailsHint => 'Provide details about what you observed';

  @override
  String get addEvidenceTitle => 'Add Evidence';

  @override
  String get optionalLabel => '(Optional)';

  @override
  String get evidenceHelperText => 'Photos, videos, or audio recordings';

  @override
  String filesAttachedCount(Object count) {
    return '$count file(s) attached';
  }

  @override
  String get savingLabel => 'Saving...';

  @override
  String get restoreDraftTitle => 'Restore Draft?';

  @override
  String restoreDraftMessage(Object timeAgo) {
    return 'You have an unsaved draft from $timeAgo.';
  }

  @override
  String get incidentLabel => 'Incident';

  @override
  String get descriptionPlaceholder =>
      'Describe what you observed in detail...';

  @override
  String get pleaseSelectIncidentType => 'Please select an incident type';

  @override
  String get pleaseProvideDescription => 'Please provide a description';

  @override
  String filesAddedCount(Object count, Object type) {
    return '$count $type(s) added';
  }

  @override
  String get submitAnonymouslyTitle => 'Submit Anonymously';

  @override
  String get identityProtectedSubtitle => 'Your identity will be protected';

  @override
  String get anonymousToggleYes => 'Yes';

  @override
  String get anonymousToggleNo => 'No';

  @override
  String get photoLabel => 'Photo';

  @override
  String get videoLabel => 'Video';

  @override
  String get audioLabel => 'Audio';

  @override
  String get suspiciousPersonLabel => 'Suspicious Person';

  @override
  String get vehicleActivityLabel => 'Vehicle Activity';

  @override
  String get abandonedItemLabel => 'Abandoned Item';

  @override
  String get theftBurglaryLabel => 'Theft/Burglary';

  @override
  String get vandalismLabelFull => 'Vandalism';

  @override
  String get drugActivityLabel => 'Drug Activity';

  @override
  String get assaultLabel => 'Assault/Violence';

  @override
  String get noiseDisturbanceLabel => 'Noise Disturbance';

  @override
  String get trespassingLabel => 'Trespassing';

  @override
  String get otherIncidentLabel => 'Other';

  @override
  String get incidentSubtitleDefault => 'Select the incident type';

  @override
  String get changePasswordTitle => 'Change Your Password';

  @override
  String get changePasswordResetDesc => 'Enter your new password below.';

  @override
  String get changePasswordSettingsDesc =>
      'Enter your current password and new password below.';

  @override
  String get currentPasswordLabel => 'Current Password';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get passwordChangedSuccess => 'Password changed successfully!';

  @override
  String get enterCurrentPassword => 'Please enter your current password';

  @override
  String passwordChange30DayRule(Object days, Object remaining) {
    return 'Password can only be changed once every 30 days. Last changed $days days ago. Please wait $remaining more days.';
  }

  @override
  String get failedToChangePassword => 'Failed to change password';

  @override
  String get userNotFoundLogin => 'User not found. Please login again.';

  @override
  String get backToSignIn => 'Back to Sign In';

  @override
  String get cancelCta => 'Cancel';

  @override
  String get changePasswordCta => 'Change Password';

  @override
  String get verifyEmailTitle => 'Check Your Email';

  @override
  String get verifyEmailSubtitle => 'We\'ve sent a verification code to';

  @override
  String get verifyEmailCta => 'Verify Email';

  @override
  String get didNotReceiveCode => 'Didn\'t receive code?';

  @override
  String get sendNewCode => 'Send new code';

  @override
  String get verificationCodeLabel => 'Verification Code';

  @override
  String get enter6Digits => 'Enter 6 Digits';

  @override
  String get enter6DigitCode => 'Please enter the 6-digit code';

  @override
  String get invalidOrExpiredCode => 'Invalid or expired code';

  @override
  String get newCodeSent => 'New verification code sent to your email.';

  @override
  String get failedToSendCode => 'Failed to send new code';

  @override
  String get forgotPasswordTitle => 'Forgot Your Password?';

  @override
  String get forgotPasswordDesc =>
      'Enter your email address and we\'ll send you instructions to reset your password.';

  @override
  String get emailLabel => 'Email';

  @override
  String get enterEmailAddress => 'Please enter your email address';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get failedToSendReset => 'Failed to send reset code';

  @override
  String get emergencyModeTitle => 'Emergency Mode';

  @override
  String get emergencyModeSubtitle =>
      'Help is on the way.\nYour location is being shared with emergency services.';

  @override
  String get policeEtaLabel => 'Police ETA';

  @override
  String etaMinutes(Object max, Object min) {
    return '$min-$max minutes';
  }

  @override
  String get emergencyContactsNotified =>
      'Your emergency contacts have been notified';
}
