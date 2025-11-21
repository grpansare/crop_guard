import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

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
    Locale('hi'),
    Locale('mr'),
    Locale('ta'),
    Locale('te'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Crop Disease Detection'**
  String get appTitle;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Farmer Dashboard title
  ///
  /// In en, this message translates to:
  /// **'Farmer Dashboard'**
  String get farmerDashboard;

  /// Scan Plant button
  ///
  /// In en, this message translates to:
  /// **'Scan Plant'**
  String get scanPlant;

  /// Scan History button
  ///
  /// In en, this message translates to:
  /// **'Scan History'**
  String get scanHistory;

  /// My Reports button
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get myReports;

  /// Settings button
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Recent Activity section title
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// Quick Stats section title
  ///
  /// In en, this message translates to:
  /// **'Quick Stats'**
  String get quickStats;

  /// Total scans label
  ///
  /// In en, this message translates to:
  /// **'Scans completed'**
  String get totalScans;

  /// Diseases detected label
  ///
  /// In en, this message translates to:
  /// **'Diseases detected'**
  String get diseasesDetected;

  /// Plants scanned label
  ///
  /// In en, this message translates to:
  /// **'Plants scanned'**
  String get plantsScanned;

  /// Profile section title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Notifications section title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// App Preferences section title
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get appPreferences;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Theme setting
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Account section title
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// About section title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Logout button
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Select Language dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Language changed dialog title
  ///
  /// In en, this message translates to:
  /// **'Language Changed'**
  String get languageChanged;

  /// Language changed dialog message
  ///
  /// In en, this message translates to:
  /// **'The app language has been changed. Please restart the app to see the changes.'**
  String get languageChangedMessage;

  /// Restart app button
  ///
  /// In en, this message translates to:
  /// **'Restart App'**
  String get restartApp;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No recent activities message
  ///
  /// In en, this message translates to:
  /// **'No recent activities'**
  String get noRecentActivity;

  /// Start scanning message
  ///
  /// In en, this message translates to:
  /// **'Start scanning plants to see your activity here'**
  String get startScanning;

  /// Plant scanned activity message
  ///
  /// In en, this message translates to:
  /// **'plant scanned'**
  String get plantScanned;

  /// Disease detected message
  ///
  /// In en, this message translates to:
  /// **'detected'**
  String get diseaseDetected;

  /// Severity label
  ///
  /// In en, this message translates to:
  /// **'severity'**
  String get severity;

  /// No diseases detected message
  ///
  /// In en, this message translates to:
  /// **'No diseases detected'**
  String get noDiseasesDetected;

  /// Healthy status
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthy;

  /// Expert Dashboard title
  ///
  /// In en, this message translates to:
  /// **'Expert Dashboard'**
  String get expertDashboard;

  /// Farmer Queries section
  ///
  /// In en, this message translates to:
  /// **'Farmer Queries'**
  String get farmerQueries;

  /// Case Review section
  ///
  /// In en, this message translates to:
  /// **'Case Review'**
  String get caseReview;

  /// Knowledge Base section
  ///
  /// In en, this message translates to:
  /// **'Knowledge Base'**
  String get knowledgeBase;

  /// Disease Trends section
  ///
  /// In en, this message translates to:
  /// **'Disease Trends'**
  String get diseaseTrends;

  /// Expert Settings section
  ///
  /// In en, this message translates to:
  /// **'Expert Settings'**
  String get expertSettings;

  /// Pending Cases count
  ///
  /// In en, this message translates to:
  /// **'Pending Cases'**
  String get pendingCases;

  /// Critical Cases count
  ///
  /// In en, this message translates to:
  /// **'Critical Cases'**
  String get criticalCases;

  /// Total Queries count
  ///
  /// In en, this message translates to:
  /// **'Total Queries'**
  String get totalQueries;

  /// Active Farmers count
  ///
  /// In en, this message translates to:
  /// **'Active Farmers'**
  String get activeFarmers;

  /// Response Time metric
  ///
  /// In en, this message translates to:
  /// **'Response Time'**
  String get responseTime;

  /// Satisfaction Rating metric
  ///
  /// In en, this message translates to:
  /// **'Satisfaction Rating'**
  String get satisfactionRating;

  /// Treatments Provided count
  ///
  /// In en, this message translates to:
  /// **'Treatments Provided'**
  String get treatmentsProvided;

  /// Statistics Overview section
  ///
  /// In en, this message translates to:
  /// **'Statistics Overview'**
  String get statisticsOverview;

  /// Performance Metrics section
  ///
  /// In en, this message translates to:
  /// **'Performance Metrics'**
  String get performanceMetrics;

  /// Expert Tools section
  ///
  /// In en, this message translates to:
  /// **'Expert Tools'**
  String get expertTools;

  /// Disease Analysis tool
  ///
  /// In en, this message translates to:
  /// **'Disease Analysis'**
  String get diseaseAnalysis;

  /// Review Cases tool
  ///
  /// In en, this message translates to:
  /// **'Review Cases'**
  String get reviewCases;

  /// Query Details title
  ///
  /// In en, this message translates to:
  /// **'Query Details'**
  String get queryDetails;

  /// Respond to Query action
  ///
  /// In en, this message translates to:
  /// **'Respond to Query'**
  String get respondToQuery;

  /// Submit Response button
  ///
  /// In en, this message translates to:
  /// **'Submit Response'**
  String get submitResponse;

  /// Your Response field
  ///
  /// In en, this message translates to:
  /// **'Your Response'**
  String get yourResponse;

  /// Response field hint
  ///
  /// In en, this message translates to:
  /// **'Provide detailed advice and recommendations...'**
  String get provideDetailedAdvice;

  /// Response field helper text
  ///
  /// In en, this message translates to:
  /// **'Minimum 10 characters required'**
  String get minimumCharactersRequired;

  /// Response success message
  ///
  /// In en, this message translates to:
  /// **'Response submitted successfully!'**
  String get responseSubmittedSuccessfully;

  /// Response error message
  ///
  /// In en, this message translates to:
  /// **'Failed to submit response'**
  String get failedToSubmitResponse;

  /// Case Details title
  ///
  /// In en, this message translates to:
  /// **'Case Details'**
  String get caseDetails;

  /// Review Case action
  ///
  /// In en, this message translates to:
  /// **'Review Case'**
  String get reviewCase;

  /// Expert Notes field
  ///
  /// In en, this message translates to:
  /// **'Expert Notes'**
  String get expertNotes;

  /// Rating field
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// Expert notes field hint
  ///
  /// In en, this message translates to:
  /// **'Provide your professional assessment and recommendations...'**
  String get provideProfessionalAssessment;

  /// Review success message
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully!'**
  String get reviewSubmittedSuccessfully;

  /// Review error message
  ///
  /// In en, this message translates to:
  /// **'Failed to submit review'**
  String get failedToSubmitReview;

  /// Search field hint
  ///
  /// In en, this message translates to:
  /// **'Search diseases, crops, or symptoms...'**
  String get searchDiseases;

  /// Category label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Total Diseases count
  ///
  /// In en, this message translates to:
  /// **'Total Diseases'**
  String get totalDiseases;

  /// Filtered count
  ///
  /// In en, this message translates to:
  /// **'Filtered'**
  String get filtered;

  /// Critical status
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// Disease Information title
  ///
  /// In en, this message translates to:
  /// **'Disease Information'**
  String get diseaseInformation;

  /// Basic Information section
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// Scientific Name field
  ///
  /// In en, this message translates to:
  /// **'Scientific Name'**
  String get scientificName;

  /// Risk Level field
  ///
  /// In en, this message translates to:
  /// **'Risk Level'**
  String get riskLevel;

  /// Affected Crops field
  ///
  /// In en, this message translates to:
  /// **'Affected Crops'**
  String get affectedCrops;

  /// Description field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Causes section
  ///
  /// In en, this message translates to:
  /// **'Causes'**
  String get causes;

  /// Prevention section
  ///
  /// In en, this message translates to:
  /// **'Prevention'**
  String get prevention;

  /// Treatment section
  ///
  /// In en, this message translates to:
  /// **'Treatment'**
  String get treatment;

  /// Outbreak Risk Assessment title
  ///
  /// In en, this message translates to:
  /// **'Outbreak Risk Assessment'**
  String get outbreakRiskAssessment;

  /// Confidence field
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// Timeframe field
  ///
  /// In en, this message translates to:
  /// **'Timeframe'**
  String get timeframe;

  /// Disease Trends chart title
  ///
  /// In en, this message translates to:
  /// **'Disease Trends Over Time'**
  String get diseaseTrendsOverTime;

  /// Disease Outbreak Predictions title
  ///
  /// In en, this message translates to:
  /// **'Disease Outbreak Predictions'**
  String get diseaseOutbreakPredictions;

  /// Expert Recommendations section
  ///
  /// In en, this message translates to:
  /// **'Expert Recommendations'**
  String get expertRecommendations;

  /// Weather Impact Analysis title
  ///
  /// In en, this message translates to:
  /// **'Weather Impact Analysis'**
  String get weatherImpactAnalysis;

  /// Seasonal Forecast title
  ///
  /// In en, this message translates to:
  /// **'Seasonal Forecast'**
  String get seasonalForecast;

  /// Profile Information section
  ///
  /// In en, this message translates to:
  /// **'Profile Information'**
  String get profileInformation;

  /// Specialization field
  ///
  /// In en, this message translates to:
  /// **'Specialization'**
  String get specialization;

  /// Years of Experience field
  ///
  /// In en, this message translates to:
  /// **'Years of Experience'**
  String get yearsOfExperience;

  /// Save Profile button
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// Notification Settings section
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// Push Notifications setting
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// Email Notifications setting
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// Query Alerts setting
  ///
  /// In en, this message translates to:
  /// **'Query Alerts'**
  String get queryAlerts;

  /// Case Review Alerts setting
  ///
  /// In en, this message translates to:
  /// **'Case Review Alerts'**
  String get caseReviewAlerts;

  /// Trend Alerts setting
  ///
  /// In en, this message translates to:
  /// **'Trend Alerts'**
  String get trendAlerts;

  /// Save Notification Settings button
  ///
  /// In en, this message translates to:
  /// **'Save Notification Settings'**
  String get saveNotificationSettings;

  /// Preferences section
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// Save Preferences button
  ///
  /// In en, this message translates to:
  /// **'Save Preferences'**
  String get savePreferences;

  /// Auto Save setting
  ///
  /// In en, this message translates to:
  /// **'Auto Save'**
  String get autoSave;

  /// Data Sync setting
  ///
  /// In en, this message translates to:
  /// **'Data Sync'**
  String get dataSync;

  /// Security section
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// Change Password action
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Current Password field
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// New Password field
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// Confirm New Password field
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// Biometric Authentication setting
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get biometricAuthentication;

  /// App Version field
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// Privacy Policy link
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Terms of Service link
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Help & Support link
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// Profile update success message
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// Settings save success message
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully!'**
  String get settingsSavedSuccessfully;

  /// Password change success message
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully!'**
  String get passwordChangedSuccessfully;

  /// Profile update error message
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// Settings save error message
  ///
  /// In en, this message translates to:
  /// **'Failed to save settings'**
  String get failedToSaveSettings;

  /// Password change error message
  ///
  /// In en, this message translates to:
  /// **'Failed to change password'**
  String get failedToChangePassword;

  /// Name validation error
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameIsRequired;

  /// Mobile validation error
  ///
  /// In en, this message translates to:
  /// **'Mobile number is required'**
  String get mobileNumberIsRequired;

  /// Review notes validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your review notes'**
  String get pleaseEnterYourReviewNotes;

  /// Rating validation error
  ///
  /// In en, this message translates to:
  /// **'Please provide a rating'**
  String get pleaseProvideARating;

  /// Response validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a response'**
  String get pleaseEnterYourResponse;

  /// Response length validation error
  ///
  /// In en, this message translates to:
  /// **'Response must be at least 10 characters long'**
  String get responseMustBeAtLeast10Characters;

  /// Response length validation error
  ///
  /// In en, this message translates to:
  /// **'Response must be less than 2000 characters'**
  String get responseMustBeLessThan2000Characters;

  /// Password confirmation error
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match'**
  String get newPasswordsDoNotMatch;

  /// Password length validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMustBeAtLeast6Characters;

  /// Offline mode banner message
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Some features may be limited.'**
  String get youreOfflineSomeFeaturesMayBeLimited;

  /// Pending status
  ///
  /// In en, this message translates to:
  /// **'pending'**
  String get pending;

  /// Sync success message
  ///
  /// In en, this message translates to:
  /// **'Data synced successfully!'**
  String get dataSyncedSuccessfully;

  /// Sync error message
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// Sync progress message
  ///
  /// In en, this message translates to:
  /// **'Syncing data...'**
  String get syncingData;

  /// No offline data message
  ///
  /// In en, this message translates to:
  /// **'No offline data available'**
  String get noOfflineDataAvailable;

  /// Offline mode queue message
  ///
  /// In en, this message translates to:
  /// **'Offline mode: Request queued for sync'**
  String get offlineModeRequestQueuedForSync;
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
      <String>['en', 'hi', 'mr', 'ta', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
