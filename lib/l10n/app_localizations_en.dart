// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Municipality Issue Reporter';

  @override
  String get homeTitleMunicipality => 'Municipality of Ville-en-Montagne';

  @override
  String get homeSubtitle => 'Report a problem in your neighborhood';

  @override
  String get actionReportProblem => 'Report a problem';

  @override
  String get actionAdminLogin => 'Admin Login';

  @override
  String get hintPhotoDescriptionLocation => 'Photo, description, location';

  @override
  String get hintAdminDashboardAccess => 'Access dashboard';

  @override
  String get tipTitle => 'Tip:';

  @override
  String get tipText => 'Add a photo to speed up handling of your request.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get serviceFooter => 'MUNICIPAL SERVICE • VERSION 2.4.0';

  @override
  String get loginTitle => 'Admin Login';

  @override
  String get usernameLabel => 'Username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get logoutButton => 'Logout';

  @override
  String get reportsTitle => 'Admin Dashboard';

  @override
  String get filterAll => 'All';

  @override
  String get filterNew => 'New';

  @override
  String get filterInProgress => 'In Progress';

  @override
  String get filterResolved => 'Resolved';

  @override
  String get statusNew => 'New';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusResolved => 'Resolved';

  @override
  String get delete => 'Delete';

  @override
  String get confirmDeleteTitle => 'Confirm Deletion';

  @override
  String get confirmDeleteBody => 'Are you sure you want to delete this item?';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get createReportTitle => 'Create Report';

  @override
  String get reportTitleLabel => 'Title';

  @override
  String get reportDescriptionLabel => 'Description';

  @override
  String get submit => 'Submit';

  @override
  String get uploading => 'Uploading...';

  @override
  String get savedSuccess => 'Saved successfully';

  @override
  String get errorGeneric => 'Something went wrong.';

  @override
  String get pickFromGallery => 'Pick from gallery';

  @override
  String get openCamera => 'Open camera';

  @override
  String get removeImage => 'Remove image';

  @override
  String get getLocation => 'Get my location';

  @override
  String get confirmSubmit => 'Confirm submission';

  @override
  String get confirmSubmitMessage => 'Submit this report?';

  @override
  String get noReports => 'No reports yet';

  @override
  String get noReportsHint => 'Create a report to get started.';

  @override
  String get saveFailed => 'Unable to save report.';

  @override
  String get permissionDenied =>
      'Permission denied. Please enable it in settings.';

  @override
  String get locationServicesDisabled => 'Location services are disabled.';

  @override
  String get reportDetailsTitle => 'Report details';

  @override
  String get createdAt => 'Created';

  @override
  String get photoLabel => 'Photo';

  @override
  String get photoMissing => 'No photo available';

  @override
  String get locationLabel => 'Location';

  @override
  String get noLocation => 'No location captured.';

  @override
  String get photoStatusPresent => 'Photo available';

  @override
  String get photoStatusMissing => 'No photo';

  @override
  String get locationStatusPresent => 'Location available';

  @override
  String get locationStatusMissing => 'No location';

  @override
  String locationCaptured(String lat, String lng) {
    return 'Lat: $lat, Lng: $lng';
  }

  @override
  String get adminLoginRequired => 'Admin login required';

  @override
  String get searchReports => 'Search reports';

  @override
  String get unableToLoadReports => 'Unable to load reports';

  @override
  String get retry => 'Retry';

  @override
  String get markAsNew => 'Mark as New';

  @override
  String get markAsInProgress => 'Mark as In Progress';

  @override
  String get markAsResolved => 'Mark as Resolved';

  @override
  String get changeStatus => 'Change status';

  @override
  String get loadMore => 'Load more';

  @override
  String statusUpdatedTo(String status) {
    return 'Status updated to $status';
  }

  @override
  String get reportDeleted => 'Report deleted';

  @override
  String get deleteReport => 'Delete report';

  @override
  String get deleteReportButton => 'Delete report';

  @override
  String get deleteReportConfirmTitle => 'Delete report';

  @override
  String deleteReportConfirmBody(String title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get deleteImageTitle => 'Delete image';

  @override
  String get deleteImageBody => 'Remove this image from the report?';

  @override
  String get imageUploaded => 'Image uploaded';

  @override
  String get imageDeleted => 'Image deleted';

  @override
  String get addImage => 'Add image';

  @override
  String get deleteImage => 'Delete image';

  @override
  String get onlyUploadedImagesCanBeDeleted =>
      'Only uploaded report images can be deleted.';

  @override
  String get noImages => 'No images';

  @override
  String get noImagesMessage =>
      'Add an image to provide more context for this report.';

  @override
  String get mapPreview => 'Map preview';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get signInAsAdmin => 'Sign in as admin';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String uploadingProgress(String progress) {
    return 'Uploading $progress%';
  }

  @override
  String get statusLabel => 'Status';
}
