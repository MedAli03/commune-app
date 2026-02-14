import 'package:flutter/widgets.dart';
import '../l10n/app_localizations.dart' as gen;

/// Compatibility wrapper while screens migrate to generated l10n API.
class AppLocalizations {
  AppLocalizations._(this._l10n);

  final gen.AppLocalizations _l10n;

  static AppLocalizations of(BuildContext context) {
    final l10n = gen.AppLocalizations.of(context);
    assert(l10n != null, 'AppLocalizations not found in widget tree.');
    return AppLocalizations._(l10n!);
  }

  String get appTitle => _l10n.appName;
  String get newReport => _l10n.createReportTitle;
  String get titleLabel => _l10n.reportTitleLabel;
  String get descriptionLabel => _l10n.reportDescriptionLabel;
  String get pickFromGallery => _l10n.pickFromGallery;
  String get openCamera => _l10n.openCamera;
  String get removeImage => _l10n.removeImage;
  String get getLocation => _l10n.getLocation;
  String get saveReport => _l10n.submit;
  String get confirmSubmit => _l10n.confirmSubmit;
  String get confirmSubmitMessage => _l10n.confirmSubmitMessage;
  String get cancel => _l10n.cancel;
  String get confirm => _l10n.ok;
  String get noReports => _l10n.noReports;
  String get noReportsHint => _l10n.noReportsHint;
  String get reportSaved => _l10n.savedSuccess;
  String get saveFailed => _l10n.saveFailed;
  String get permissionDenied => _l10n.permissionDenied;
  String get locationServicesDisabled => _l10n.locationServicesDisabled;
  String get detailsTitle => _l10n.reportDetailsTitle;
  String get createdAt => _l10n.createdAt;
  String get photoLabel => _l10n.photoLabel;
  String get photoMissing => _l10n.photoMissing;
  String get locationLabel => _l10n.locationLabel;
  String get noLocation => _l10n.noLocation;
  String get photoStatusPresent => _l10n.photoStatusPresent;
  String get photoStatusMissing => _l10n.photoStatusMissing;
  String get locationStatusPresent => _l10n.locationStatusPresent;
  String get locationStatusMissing => _l10n.locationStatusMissing;

  String locationCaptured({required String lat, required String lng}) {
    return _l10n.locationCaptured(lat, lng);
  }
}
