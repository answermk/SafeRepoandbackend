import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_rw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('rw'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Safe Report'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @reportCrime.
  ///
  /// In en, this message translates to:
  /// **'Report Crime'**
  String get reportCrime;

  /// No description provided for @myReports.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get myReports;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @communityForum.
  ///
  /// In en, this message translates to:
  /// **'Community Forum'**
  String get communityForum;

  /// No description provided for @watchGroups.
  ///
  /// In en, this message translates to:
  /// **'Watch Groups'**
  String get watchGroups;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// No description provided for @submitAnonymously.
  ///
  /// In en, this message translates to:
  /// **'Submit Anonymously'**
  String get submitAnonymously;

  /// No description provided for @addEvidence.
  ///
  /// In en, this message translates to:
  /// **'Add Evidence'**
  String get addEvidence;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @logIntoYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Log Into your account'**
  String get logIntoYourAccount;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me?'**
  String get rememberMe;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'No Account?'**
  String get noAccount;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get createAnAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @registerAnonymously.
  ///
  /// In en, this message translates to:
  /// **'Register Anonymously'**
  String get registerAnonymously;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter Full Name'**
  String get enterFullName;

  /// No description provided for @youremailGmailCom.
  ///
  /// In en, this message translates to:
  /// **'youremail@gmail.com'**
  String get youremailGmailCom;

  /// No description provided for @testCredentials.
  ///
  /// In en, this message translates to:
  /// **'Test Credentials'**
  String get testCredentials;

  /// No description provided for @emailTestSafereportCom.
  ///
  /// In en, this message translates to:
  /// **'Email: test@safereport.com'**
  String get emailTestSafereportCom;

  /// No description provided for @passwordSafeReport123.
  ///
  /// In en, this message translates to:
  /// **'Password: SafeReport123'**
  String get passwordSafeReport123;

  /// Greeting with user name
  ///
  /// In en, this message translates to:
  /// **'Good Morning, {userName}'**
  String goodMorning(String userName);

  /// No description provided for @reportNow.
  ///
  /// In en, this message translates to:
  /// **'Report Now'**
  String get reportNow;

  /// No description provided for @yourCommunitySafetyHub.
  ///
  /// In en, this message translates to:
  /// **'Your Community\nSafety Hub'**
  String get yourCommunitySafetyHub;

  /// No description provided for @communityStatus.
  ///
  /// In en, this message translates to:
  /// **'Community Status'**
  String get communityStatus;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @avgResponse.
  ///
  /// In en, this message translates to:
  /// **'Avg Response'**
  String get avgResponse;

  /// No description provided for @safetyLevel.
  ///
  /// In en, this message translates to:
  /// **'Safety Level'**
  String get safetyLevel;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @nearbyIncidents.
  ///
  /// In en, this message translates to:
  /// **'Nearby Incidents'**
  String get nearbyIncidents;

  /// Nearby incidents count
  ///
  /// In en, this message translates to:
  /// **'{count} nearby'**
  String nearbyIncidentsCount(int count);

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @watchGroupInfo.
  ///
  /// In en, this message translates to:
  /// **'Watch Group'**
  String get watchGroupInfo;

  /// New alerts count
  ///
  /// In en, this message translates to:
  /// **'{count} new alerts'**
  String newAlerts(int count);

  /// No description provided for @safetyEducation.
  ///
  /// In en, this message translates to:
  /// **'Safety Education'**
  String get safetyEducation;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get learnMore;

  /// No description provided for @selectIncidentType.
  ///
  /// In en, this message translates to:
  /// **'Select Incident Type'**
  String get selectIncidentType;

  /// No description provided for @pleaseSelectAnIncidentType.
  ///
  /// In en, this message translates to:
  /// **'Please select an incident type'**
  String get pleaseSelectAnIncidentType;

  /// No description provided for @pleaseProvideADescription.
  ///
  /// In en, this message translates to:
  /// **'Please provide a description'**
  String get pleaseProvideADescription;

  /// No description provided for @suspiciousPerson.
  ///
  /// In en, this message translates to:
  /// **'Suspicious Person'**
  String get suspiciousPerson;

  /// No description provided for @individualActingSuspiciously.
  ///
  /// In en, this message translates to:
  /// **'Individual acting suspiciously'**
  String get individualActingSuspiciously;

  /// No description provided for @vehicleActivity.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Activity'**
  String get vehicleActivity;

  /// No description provided for @suspiciousVehicleBehavior.
  ///
  /// In en, this message translates to:
  /// **'Suspicious vehicle behavior'**
  String get suspiciousVehicleBehavior;

  /// No description provided for @abandonedItem.
  ///
  /// In en, this message translates to:
  /// **'Abandoned Item'**
  String get abandonedItem;

  /// No description provided for @unattendedSuspiciousItems.
  ///
  /// In en, this message translates to:
  /// **'Unattended suspicious items'**
  String get unattendedSuspiciousItems;

  /// No description provided for @theftBurglary.
  ///
  /// In en, this message translates to:
  /// **'Theft/Burglary'**
  String get theftBurglary;

  /// No description provided for @propertyTheftOrBreakIn.
  ///
  /// In en, this message translates to:
  /// **'Property theft or break-in'**
  String get propertyTheftOrBreakIn;

  /// No description provided for @vandalism.
  ///
  /// In en, this message translates to:
  /// **'Vandalism'**
  String get vandalism;

  /// No description provided for @propertyDamageOrGraffiti.
  ///
  /// In en, this message translates to:
  /// **'Property damage or graffiti'**
  String get propertyDamageOrGraffiti;

  /// No description provided for @drugActivity.
  ///
  /// In en, this message translates to:
  /// **'Drug Activity'**
  String get drugActivity;

  /// No description provided for @suspectedDrugRelatedBehavior.
  ///
  /// In en, this message translates to:
  /// **'Suspected drug-related behavior'**
  String get suspectedDrugRelatedBehavior;

  /// No description provided for @assaultViolence.
  ///
  /// In en, this message translates to:
  /// **'Assault/Violence'**
  String get assaultViolence;

  /// No description provided for @physicalAltercationOrThreat.
  ///
  /// In en, this message translates to:
  /// **'Physical altercation or threat'**
  String get physicalAltercationOrThreat;

  /// No description provided for @noiseDisturbance.
  ///
  /// In en, this message translates to:
  /// **'Noise Disturbance'**
  String get noiseDisturbance;

  /// No description provided for @excessiveNoiseComplaint.
  ///
  /// In en, this message translates to:
  /// **'Excessive noise complaint'**
  String get excessiveNoiseComplaint;

  /// No description provided for @trespassing.
  ///
  /// In en, this message translates to:
  /// **'Trespassing'**
  String get trespassing;

  /// No description provided for @unauthorizedEntry.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized entry'**
  String get unauthorizedEntry;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @otherIncidentType.
  ///
  /// In en, this message translates to:
  /// **'Other incident type'**
  String get otherIncidentType;

  /// No description provided for @describeTheIncident.
  ///
  /// In en, this message translates to:
  /// **'Describe the incident'**
  String get describeTheIncident;

  /// No description provided for @addPhotosVideosOrAudio.
  ///
  /// In en, this message translates to:
  /// **'Add Photos, Videos, or Audio'**
  String get addPhotosVideosOrAudio;

  /// No description provided for @draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved'**
  String get draftSaved;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// Draft saved time
  ///
  /// In en, this message translates to:
  /// **'Saved {minutes} minutes ago'**
  String savedXMinutesAgo(int minutes);

  /// No description provided for @restoreDraft.
  ///
  /// In en, this message translates to:
  /// **'Restore Draft'**
  String get restoreDraft;

  /// No description provided for @youHaveAnUnsavedDraft.
  ///
  /// In en, this message translates to:
  /// **'You have an unsaved draft. Would you like to restore it?'**
  String get youHaveAnUnsavedDraft;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @continueToLocation.
  ///
  /// In en, this message translates to:
  /// **'Continue to Location'**
  String get continueToLocation;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @submitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submitted;

  /// No description provided for @reviewing.
  ///
  /// In en, this message translates to:
  /// **'Reviewing'**
  String get reviewing;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @deleteReports.
  ///
  /// In en, this message translates to:
  /// **'Delete Reports'**
  String get deleteReports;

  /// Delete confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} report(s)?'**
  String areYouSureYouWantToDelete(int count);

  /// No description provided for @reportsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Reports deleted'**
  String get reportsDeleted;

  /// No description provided for @noReportsSelected.
  ///
  /// In en, this message translates to:
  /// **'No reports selected'**
  String get noReportsSelected;

  /// No description provided for @exportToPDF.
  ///
  /// In en, this message translates to:
  /// **'Export to PDF'**
  String get exportToPDF;

  /// No description provided for @shareReports.
  ///
  /// In en, this message translates to:
  /// **'Share Reports'**
  String get shareReports;

  /// No description provided for @mySafetyReports.
  ///
  /// In en, this message translates to:
  /// **'My Safety Reports'**
  String get mySafetyReports;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Member since date
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String memberSince(String date);

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @myImpact.
  ///
  /// In en, this message translates to:
  /// **'My Impact'**
  String get myImpact;

  /// No description provided for @offlineQueue.
  ///
  /// In en, this message translates to:
  /// **'Offline Queue'**
  String get offlineQueue;

  /// No description provided for @accessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @accountSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettingsTitle;

  /// No description provided for @manageYourPreferences.
  ///
  /// In en, this message translates to:
  /// **'Manage your preferences'**
  String get manageYourPreferences;

  /// No description provided for @securitySettings.
  ///
  /// In en, this message translates to:
  /// **'Security Settings'**
  String get securitySettings;

  /// Password last changed
  ///
  /// In en, this message translates to:
  /// **'Last changed {days} days ago'**
  String lastChangedXDaysAgo(int days);

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @twoFactorAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactorAuthentication;

  /// No description provided for @addExtraSecurityToYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Add extra security to your account'**
  String get addExtraSecurityToYourAccount;

  /// No description provided for @biometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get biometricLogin;

  /// No description provided for @useFingerprintOrFaceId.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face ID'**
  String get useFingerprintOrFaceId;

  /// No description provided for @notificationsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Notifications Preferences'**
  String get notificationsPreferences;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @reportUpdatesAndAlerts.
  ///
  /// In en, this message translates to:
  /// **'Report updates and alerts'**
  String get reportUpdatesAndAlerts;

  /// No description provided for @emailUpdates.
  ///
  /// In en, this message translates to:
  /// **'Email Updates'**
  String get emailUpdates;

  /// No description provided for @weeklyCommunitySummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly community summary'**
  String get weeklyCommunitySummary;

  /// No description provided for @watchGroupAlerts.
  ///
  /// In en, this message translates to:
  /// **'Watch Group Alerts'**
  String get watchGroupAlerts;

  /// No description provided for @messagesFromYourGroups.
  ///
  /// In en, this message translates to:
  /// **'Messages from your groups'**
  String get messagesFromYourGroups;

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy Settings'**
  String get privacySettings;

  /// No description provided for @defaultAnonymousMode.
  ///
  /// In en, this message translates to:
  /// **'Default Anonymous Mode'**
  String get defaultAnonymousMode;

  /// No description provided for @alwaysSubmitReportsAnonymously.
  ///
  /// In en, this message translates to:
  /// **'Always submit reports anonymously'**
  String get alwaysSubmitReportsAnonymously;

  /// No description provided for @locationSharing.
  ///
  /// In en, this message translates to:
  /// **'Location Sharing'**
  String get locationSharing;

  /// No description provided for @sharePreciseLocationWithReports.
  ///
  /// In en, this message translates to:
  /// **'Share precise location with reports'**
  String get sharePreciseLocationWithReports;

  /// No description provided for @anonymousReportingGuide.
  ///
  /// In en, this message translates to:
  /// **'Anonymous Reporting Guide'**
  String get anonymousReportingGuide;

  /// No description provided for @learnAboutPrivacyProtections.
  ///
  /// In en, this message translates to:
  /// **'Learn about privacy protections'**
  String get learnAboutPrivacyProtections;

  /// No description provided for @languagePreferences.
  ///
  /// In en, this message translates to:
  /// **'Language Preferences'**
  String get languagePreferences;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @kinyarwanda.
  ///
  /// In en, this message translates to:
  /// **'Kinyarwanda'**
  String get kinyarwanda;

  /// No description provided for @swahili.
  ///
  /// In en, this message translates to:
  /// **'Swahili'**
  String get swahili;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @offlineReports.
  ///
  /// In en, this message translates to:
  /// **'Offline Reports'**
  String get offlineReports;

  /// No description provided for @manageReportsWhenOffline.
  ///
  /// In en, this message translates to:
  /// **'Manage reports when offline'**
  String get manageReportsWhenOffline;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @passwordStrength.
  ///
  /// In en, this message translates to:
  /// **'Password Strength'**
  String get passwordStrength;

  /// No description provided for @weak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get weak;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @strong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strong;

  /// No description provided for @veryStrong.
  ///
  /// In en, this message translates to:
  /// **'Very Strong'**
  String get veryStrong;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password Requirements'**
  String get passwordRequirements;

  /// No description provided for @atLeast8Characters.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get atLeast8Characters;

  /// No description provided for @oneUppercaseLetter.
  ///
  /// In en, this message translates to:
  /// **'One uppercase letter'**
  String get oneUppercaseLetter;

  /// No description provided for @oneLowercaseLetter.
  ///
  /// In en, this message translates to:
  /// **'One lowercase letter'**
  String get oneLowercaseLetter;

  /// No description provided for @oneNumber.
  ///
  /// In en, this message translates to:
  /// **'One number'**
  String get oneNumber;

  /// No description provided for @oneSpecialCharacter.
  ///
  /// In en, this message translates to:
  /// **'One special character'**
  String get oneSpecialCharacter;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully!'**
  String get passwordChangedSuccessfully;

  /// No description provided for @accessibilitySettings.
  ///
  /// In en, this message translates to:
  /// **'Accessibility Settings'**
  String get accessibilitySettings;

  /// No description provided for @customizeTheAppToMakeItEasierToUse.
  ///
  /// In en, this message translates to:
  /// **'Customize the app to make it easier to use'**
  String get customizeTheAppToMakeItEasierToUse;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @adjustTextSize.
  ///
  /// In en, this message translates to:
  /// **'Adjust text size for better readability'**
  String get adjustTextSize;

  /// No description provided for @highContrastMode.
  ///
  /// In en, this message translates to:
  /// **'High Contrast Mode'**
  String get highContrastMode;

  /// No description provided for @improveVisibilityWithHighContrast.
  ///
  /// In en, this message translates to:
  /// **'Improve visibility with high contrast colors'**
  String get improveVisibilityWithHighContrast;

  /// No description provided for @textToSpeech.
  ///
  /// In en, this message translates to:
  /// **'Text-to-Speech'**
  String get textToSpeech;

  /// No description provided for @readContentAloud.
  ///
  /// In en, this message translates to:
  /// **'Read content aloud'**
  String get readContentAloud;

  /// No description provided for @accessibilitySettingsSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Accessibility settings saved successfully!'**
  String get accessibilitySettingsSavedSuccessfully;

  /// Error saving settings
  ///
  /// In en, this message translates to:
  /// **'Error saving settings: {error}'**
  String errorSavingSettings(String error);

  /// No description provided for @helpSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupportTitle;

  /// No description provided for @getAssistanceAndAnswers.
  ///
  /// In en, this message translates to:
  /// **'Get assistance and answers'**
  String get getAssistanceAndAnswers;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get needHelp;

  /// No description provided for @wereHereToAssistYou247.
  ///
  /// In en, this message translates to:
  /// **'We\'re here to assist you 24/7'**
  String get wereHereToAssistYou247;

  /// No description provided for @startLiveChat.
  ///
  /// In en, this message translates to:
  /// **'Start Live Chat'**
  String get startLiveChat;

  /// No description provided for @quickHelp.
  ///
  /// In en, this message translates to:
  /// **'Quick Help'**
  String get quickHelp;

  /// No description provided for @frequentlyAskedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get frequentlyAskedQuestions;

  /// No description provided for @commonQuestionsAndAnswers.
  ///
  /// In en, this message translates to:
  /// **'Common questions and answers'**
  String get commonQuestionsAndAnswers;

  /// No description provided for @reportingGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Reporting Guidelines'**
  String get reportingGuidelines;

  /// No description provided for @bestPracticesForSafetyReporting.
  ///
  /// In en, this message translates to:
  /// **'Best practices for safety reporting'**
  String get bestPracticesForSafetyReporting;

  /// No description provided for @communityGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Community Guidelines'**
  String get communityGuidelines;

  /// No description provided for @rulesAndExpectations.
  ///
  /// In en, this message translates to:
  /// **'Rules and expectations'**
  String get rulesAndExpectations;

  /// No description provided for @contactOptions.
  ///
  /// In en, this message translates to:
  /// **'Contact Options'**
  String get contactOptions;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// No description provided for @supportSafereportCom.
  ///
  /// In en, this message translates to:
  /// **'support@saferreport.com'**
  String get supportSafereportCom;

  /// No description provided for @phoneSupport.
  ///
  /// In en, this message translates to:
  /// **'Phone Support'**
  String get phoneSupport;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @tellUsHowWeCanImprove.
  ///
  /// In en, this message translates to:
  /// **'Tell us how we can improve ......'**
  String get tellUsHowWeCanImprove;

  /// No description provided for @submitFeedback.
  ///
  /// In en, this message translates to:
  /// **'Submit Feedback'**
  String get submitFeedback;

  /// No description provided for @couldNotOpenEmailClient.
  ///
  /// In en, this message translates to:
  /// **'Could not open email client'**
  String get couldNotOpenEmailClient;

  /// Phone call error
  ///
  /// In en, this message translates to:
  /// **'Could not make phone call: {error}'**
  String couldNotMakePhoneCall(String error);

  /// No description provided for @emergencyMode.
  ///
  /// In en, this message translates to:
  /// **'Emergency Mode'**
  String get emergencyMode;

  /// No description provided for @helpIsOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'Help is on the way.\nYour location is being shared with emergency services.'**
  String get helpIsOnTheWay;

  /// No description provided for @policeETA.
  ///
  /// In en, this message translates to:
  /// **'Police ETA'**
  String get policeETA;

  /// ETA range
  ///
  /// In en, this message translates to:
  /// **'{min}-{max} minutes'**
  String xToYMinutes(int min, int max);

  /// No description provided for @callNow.
  ///
  /// In en, this message translates to:
  /// **'CALL NOW'**
  String get callNow;

  /// No description provided for @cancelEmergency.
  ///
  /// In en, this message translates to:
  /// **'Cancel Emergency'**
  String get cancelEmergency;

  /// No description provided for @yourEmergencyContactsHaveBeenNotified.
  ///
  /// In en, this message translates to:
  /// **'Your emergency contacts have been notified'**
  String get yourEmergencyContactsHaveBeenNotified;

  /// No description provided for @selectEmergencyService.
  ///
  /// In en, this message translates to:
  /// **'Select Emergency Service'**
  String get selectEmergencyService;

  /// No description provided for @policeEmergency.
  ///
  /// In en, this message translates to:
  /// **'Police Emergency'**
  String get policeEmergency;

  /// No description provided for @fireDepartment.
  ///
  /// In en, this message translates to:
  /// **'Fire Department'**
  String get fireDepartment;

  /// No description provided for @ambulance.
  ///
  /// In en, this message translates to:
  /// **'Ambulance'**
  String get ambulance;

  /// No description provided for @nonEmergencyPolice.
  ///
  /// In en, this message translates to:
  /// **'Non-Emergency Police'**
  String get nonEmergencyPolice;

  /// No description provided for @communityForumTitle.
  ///
  /// In en, this message translates to:
  /// **'Community Forum'**
  String get communityForumTitle;

  /// No description provided for @discussLocalSafetys.
  ///
  /// In en, this message translates to:
  /// **'Discuss local safetys'**
  String get discussLocalSafetys;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @createNewPost.
  ///
  /// In en, this message translates to:
  /// **'Create New Post'**
  String get createNewPost;

  /// No description provided for @recentPostsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Recent posts coming soon...'**
  String get recentPostsComingSoon;

  /// No description provided for @followingPostsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Following posts coming soon...'**
  String get followingPostsComingSoon;

  /// No description provided for @bestHomeSecurityCameras2023.
  ///
  /// In en, this message translates to:
  /// **'Best home security cameras 2023?'**
  String get bestHomeSecurityCameras2023;

  /// No description provided for @neighborhoodPatrolTips.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood patrol tips'**
  String get neighborhoodPatrolTips;

  /// No description provided for @holidaySafetyAdvisory.
  ///
  /// In en, this message translates to:
  /// **'Holiday Safety Advisory'**
  String get holidaySafetyAdvisory;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @helpful.
  ///
  /// In en, this message translates to:
  /// **'Helpful'**
  String get helpful;

  /// Time ago in hours
  ///
  /// In en, this message translates to:
  /// **'{hours} hrs ago'**
  String hoursAgo(int hours);

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Time ago in days
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// No description provided for @myWatchGroups.
  ///
  /// In en, this message translates to:
  /// **'My Watch Groups'**
  String get myWatchGroups;

  /// No description provided for @communitySafetyPartnerships.
  ///
  /// In en, this message translates to:
  /// **'Community safety partnerships'**
  String get communitySafetyPartnerships;

  /// No description provided for @oakStreetResidential.
  ///
  /// In en, this message translates to:
  /// **'Oak Street Residential'**
  String get oakStreetResidential;

  /// No description provided for @oakStreetNeighborhood.
  ///
  /// In en, this message translates to:
  /// **'Oak Street Neighborhood'**
  String get oakStreetNeighborhood;

  /// No description provided for @downtownBusiness.
  ///
  /// In en, this message translates to:
  /// **'Downtown Business'**
  String get downtownBusiness;

  /// No description provided for @businessDistrict.
  ///
  /// In en, this message translates to:
  /// **'Business District'**
  String get businessDistrict;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @coverage.
  ///
  /// In en, this message translates to:
  /// **'Coverage'**
  String get coverage;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @monFri9AM5PM.
  ///
  /// In en, this message translates to:
  /// **'Mon-Fri 9AM-5PM'**
  String get monFri9AM5PM;

  /// No description provided for @businessHours.
  ///
  /// In en, this message translates to:
  /// **'Business hours'**
  String get businessHours;

  /// No description provided for @viewMessages.
  ///
  /// In en, this message translates to:
  /// **'View Messages'**
  String get viewMessages;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @findMoreGroups.
  ///
  /// In en, this message translates to:
  /// **'Find More Groups'**
  String get findMoreGroups;

  /// No description provided for @discoverAndJoinWatchGroups.
  ///
  /// In en, this message translates to:
  /// **'Discover and join watch groups in your area'**
  String get discoverAndJoinWatchGroups;

  /// No description provided for @browseGroups.
  ///
  /// In en, this message translates to:
  /// **'Browse Groups'**
  String get browseGroups;

  /// No description provided for @yourImpact.
  ///
  /// In en, this message translates to:
  /// **'Your Impact'**
  String get yourImpact;

  /// No description provided for @contributionsToCommunitySafety.
  ///
  /// In en, this message translates to:
  /// **'Your contributions to community safety'**
  String get contributionsToCommunitySafety;

  /// No description provided for @reportsSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Reports Submitted'**
  String get reportsSubmitted;

  /// No description provided for @watchGroupsJoined.
  ///
  /// In en, this message translates to:
  /// **'Watch Groups Joined'**
  String get watchGroupsJoined;

  /// No description provided for @helpfulResponses.
  ///
  /// In en, this message translates to:
  /// **'Helpful Responses'**
  String get helpfulResponses;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @stayInformedAboutImportantUpdates.
  ///
  /// In en, this message translates to:
  /// **'Stay informed about important updates and alerts'**
  String get stayInformedAboutImportantUpdates;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @messagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// No description provided for @yourCommunications.
  ///
  /// In en, this message translates to:
  /// **'Your communications'**
  String get yourCommunications;

  /// No description provided for @reportCommunications.
  ///
  /// In en, this message translates to:
  /// **'Report Communications'**
  String get reportCommunications;

  /// No description provided for @directContact.
  ///
  /// In en, this message translates to:
  /// **'Direct Contact'**
  String get directContact;

  /// No description provided for @officer.
  ///
  /// In en, this message translates to:
  /// **'Officer'**
  String get officer;

  /// No description provided for @newMessage.
  ///
  /// In en, this message translates to:
  /// **'New Message'**
  String get newMessage;

  /// No description provided for @viewAllMessages.
  ///
  /// In en, this message translates to:
  /// **'View All Messages'**
  String get viewAllMessages;

  /// No description provided for @joinDiscussion.
  ///
  /// In en, this message translates to:
  /// **'Join Discussion'**
  String get joinDiscussion;

  /// No description provided for @anonymousReporting.
  ///
  /// In en, this message translates to:
  /// **'Anonymous Reporting'**
  String get anonymousReporting;

  /// No description provided for @whatIsHidden.
  ///
  /// In en, this message translates to:
  /// **'What is Hidden'**
  String get whatIsHidden;

  /// No description provided for @whatIsShared.
  ///
  /// In en, this message translates to:
  /// **'What is Shared'**
  String get whatIsShared;

  /// No description provided for @benefits.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get benefits;

  /// No description provided for @legalProtection.
  ///
  /// In en, this message translates to:
  /// **'Legal Protection'**
  String get legalProtection;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @appLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguageTitle;

  /// No description provided for @selectYourPreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language:'**
  String get selectYourPreferredLanguage;

  /// No description provided for @saveLanguage.
  ///
  /// In en, this message translates to:
  /// **'Save Language'**
  String get saveLanguage;

  /// No description provided for @nearbyIncidentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby Incidents'**
  String get nearbyIncidentsTitle;

  /// No description provided for @mapView.
  ///
  /// In en, this message translates to:
  /// **'Map View'**
  String get mapView;

  /// No description provided for @radius.
  ///
  /// In en, this message translates to:
  /// **'Radius'**
  String get radius;

  /// No description provided for @timeFilter.
  ///
  /// In en, this message translates to:
  /// **'Time Filter'**
  String get timeFilter;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @h.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get h;

  /// Minutes ago
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String minAgo(int minutes);

  /// Hour ago
  ///
  /// In en, this message translates to:
  /// **'{hours} hour ago'**
  String hourAgo(int hours);

  /// Hours ago
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String hoursAgoPlural(int hours);

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @severity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severity;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @safeReport.
  ///
  /// In en, this message translates to:
  /// **'SafeReport'**
  String get safeReport;

  /// No description provided for @aRealTimeCrimePreventionPlatform.
  ///
  /// In en, this message translates to:
  /// **'A Real-Time Crime Prevention Platform uses smart technology to detect and respond to crime instantly, helping keep communities safe through quick alerts and data-driven actions.'**
  String get aRealTimeCrimePreventionPlatform;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful! Welcome to SafeReport'**
  String get loginSuccessful;

  /// No description provided for @invalidEmailOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password. Try sample credentials.'**
  String get invalidEmailOrPassword;

  /// No description provided for @pleaseEnterBothEmailAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter both email and password'**
  String get pleaseEnterBothEmailAndPassword;

  /// Connection error message
  ///
  /// In en, this message translates to:
  /// **'Connection error: {error}'**
  String connectionError(String error);

  /// No description provided for @accountCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully! Please sign in.'**
  String get accountCreatedSuccessfully;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Photos added count
  ///
  /// In en, this message translates to:
  /// **'{count} photo(s) added'**
  String photosAdded(int count);

  /// Videos added count
  ///
  /// In en, this message translates to:
  /// **'{count} video(s) added'**
  String videosAdded(int count);

  /// Audios added count
  ///
  /// In en, this message translates to:
  /// **'{count} audio(s) added'**
  String audiosAdded(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'rw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'rw':
      return AppLocalizationsRw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
