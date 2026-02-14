import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Municipality Issue Reporter'**
  String get appName;

  /// No description provided for @homeTitleMunicipality.
  ///
  /// In en, this message translates to:
  /// **'Municipality of Ville-en-Montagne'**
  String get homeTitleMunicipality;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Report a problem in your neighborhood'**
  String get homeSubtitle;

  /// No description provided for @actionReportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get actionReportProblem;

  /// No description provided for @actionAdminLogin.
  ///
  /// In en, this message translates to:
  /// **'Admin Login'**
  String get actionAdminLogin;

  /// No description provided for @hintPhotoDescriptionLocation.
  ///
  /// In en, this message translates to:
  /// **'Photo, description, location'**
  String get hintPhotoDescriptionLocation;

  /// No description provided for @hintAdminDashboardAccess.
  ///
  /// In en, this message translates to:
  /// **'Access dashboard'**
  String get hintAdminDashboardAccess;

  /// No description provided for @tipTitle.
  ///
  /// In en, this message translates to:
  /// **'Tip:'**
  String get tipTitle;

  /// No description provided for @tipText.
  ///
  /// In en, this message translates to:
  /// **'Add a photo to speed up handling of your request.'**
  String get tipText;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @serviceFooter.
  ///
  /// In en, this message translates to:
  /// **'MUNICIPAL SERVICE • VERSION 2.4.0'**
  String get serviceFooter;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Login'**
  String get loginTitle;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButton;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get reportsTitle;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get filterNew;

  /// No description provided for @filterInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get filterInProgress;

  /// No description provided for @filterResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get filterResolved;

  /// No description provided for @statusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get statusNew;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @statusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get statusResolved;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get confirmDeleteBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @createReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Report'**
  String get createReportTitle;

  /// No description provided for @reportTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get reportTitleLabel;

  /// No description provided for @reportDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get reportDescriptionLabel;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @savedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get savedSuccess;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorGeneric;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from gallery'**
  String get pickFromGallery;

  /// No description provided for @openCamera.
  ///
  /// In en, this message translates to:
  /// **'Open camera'**
  String get openCamera;

  /// No description provided for @removeImage.
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get removeImage;

  /// No description provided for @getLocation.
  ///
  /// In en, this message translates to:
  /// **'Get my location'**
  String get getLocation;

  /// No description provided for @confirmSubmit.
  ///
  /// In en, this message translates to:
  /// **'Confirm submission'**
  String get confirmSubmit;

  /// No description provided for @confirmSubmitMessage.
  ///
  /// In en, this message translates to:
  /// **'Submit this report?'**
  String get confirmSubmitMessage;

  /// No description provided for @noReports.
  ///
  /// In en, this message translates to:
  /// **'No reports yet'**
  String get noReports;

  /// No description provided for @noReportsHint.
  ///
  /// In en, this message translates to:
  /// **'Create a report to get started.'**
  String get noReportsHint;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to save report.'**
  String get saveFailed;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Please enable it in settings.'**
  String get permissionDenied;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled.'**
  String get locationServicesDisabled;

  /// No description provided for @reportDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Report details'**
  String get reportDetailsTitle;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdAt;

  /// No description provided for @photoLabel.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photoLabel;

  /// No description provided for @photoMissing.
  ///
  /// In en, this message translates to:
  /// **'No photo available'**
  String get photoMissing;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @noLocation.
  ///
  /// In en, this message translates to:
  /// **'No location captured.'**
  String get noLocation;

  /// No description provided for @photoStatusPresent.
  ///
  /// In en, this message translates to:
  /// **'Photo available'**
  String get photoStatusPresent;

  /// No description provided for @photoStatusMissing.
  ///
  /// In en, this message translates to:
  /// **'No photo'**
  String get photoStatusMissing;

  /// No description provided for @locationStatusPresent.
  ///
  /// In en, this message translates to:
  /// **'Location available'**
  String get locationStatusPresent;

  /// No description provided for @locationStatusMissing.
  ///
  /// In en, this message translates to:
  /// **'No location'**
  String get locationStatusMissing;

  /// No description provided for @locationCaptured.
  ///
  /// In en, this message translates to:
  /// **'Lat: {lat}, Lng: {lng}'**
  String locationCaptured(String lat, String lng);

  /// No description provided for @adminLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Admin login required'**
  String get adminLoginRequired;

  /// No description provided for @searchReports.
  ///
  /// In en, this message translates to:
  /// **'Search reports'**
  String get searchReports;

  /// No description provided for @unableToLoadReports.
  ///
  /// In en, this message translates to:
  /// **'Unable to load reports'**
  String get unableToLoadReports;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @markAsNew.
  ///
  /// In en, this message translates to:
  /// **'Mark as New'**
  String get markAsNew;

  /// No description provided for @markAsInProgress.
  ///
  /// In en, this message translates to:
  /// **'Mark as In Progress'**
  String get markAsInProgress;

  /// No description provided for @markAsResolved.
  ///
  /// In en, this message translates to:
  /// **'Mark as Resolved'**
  String get markAsResolved;

  /// No description provided for @changeStatus.
  ///
  /// In en, this message translates to:
  /// **'Change status'**
  String get changeStatus;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @statusUpdatedTo.
  ///
  /// In en, this message translates to:
  /// **'Status updated to {status}'**
  String statusUpdatedTo(String status);

  /// No description provided for @reportDeleted.
  ///
  /// In en, this message translates to:
  /// **'Report deleted'**
  String get reportDeleted;

  /// No description provided for @deleteReport.
  ///
  /// In en, this message translates to:
  /// **'Delete report'**
  String get deleteReport;

  /// No description provided for @deleteReportButton.
  ///
  /// In en, this message translates to:
  /// **'Delete report'**
  String get deleteReportButton;

  /// No description provided for @deleteReportConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete report'**
  String get deleteReportConfirmTitle;

  /// No description provided for @deleteReportConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String deleteReportConfirmBody(String title);

  /// No description provided for @deleteImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete image'**
  String get deleteImageTitle;

  /// No description provided for @deleteImageBody.
  ///
  /// In en, this message translates to:
  /// **'Remove this image from the report?'**
  String get deleteImageBody;

  /// No description provided for @imageUploaded.
  ///
  /// In en, this message translates to:
  /// **'Image uploaded'**
  String get imageUploaded;

  /// No description provided for @imageDeleted.
  ///
  /// In en, this message translates to:
  /// **'Image deleted'**
  String get imageDeleted;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add image'**
  String get addImage;

  /// No description provided for @deleteImage.
  ///
  /// In en, this message translates to:
  /// **'Delete image'**
  String get deleteImage;

  /// No description provided for @onlyUploadedImagesCanBeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Only uploaded report images can be deleted.'**
  String get onlyUploadedImagesCanBeDeleted;

  /// No description provided for @noImages.
  ///
  /// In en, this message translates to:
  /// **'No images'**
  String get noImages;

  /// No description provided for @noImagesMessage.
  ///
  /// In en, this message translates to:
  /// **'Add an image to provide more context for this report.'**
  String get noImagesMessage;

  /// No description provided for @mapPreview.
  ///
  /// In en, this message translates to:
  /// **'Map preview'**
  String get mapPreview;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @signInAsAdmin.
  ///
  /// In en, this message translates to:
  /// **'Sign in as admin'**
  String get signInAsAdmin;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @uploadingProgress.
  ///
  /// In en, this message translates to:
  /// **'Uploading {progress}%'**
  String uploadingProgress(String progress);

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;
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
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
