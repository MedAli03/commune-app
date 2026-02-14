// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Signaleur de problèmes municipaux';

  @override
  String get homeTitleMunicipality => 'Municipalité de Ville-en-Montagne';

  @override
  String get homeSubtitle => 'Signaler un problème dans votre quartier';

  @override
  String get actionReportProblem => 'Signaler un problème';

  @override
  String get actionAdminLogin => 'Connexion Admin';

  @override
  String get hintPhotoDescriptionLocation => 'Photo, description, localisation';

  @override
  String get hintAdminDashboardAccess => 'Accès tableau de bord';

  @override
  String get tipTitle => 'Conseil :';

  @override
  String get tipText =>
      'Ajoutez une photo pour accélérer le traitement de votre demande.';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get serviceFooter => 'SERVICE MUNICIPAL • VERSION 2.4.0';

  @override
  String get loginTitle => 'Connexion Admin';

  @override
  String get usernameLabel => 'Nom d\'utilisateur';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get loginButton => 'Connexion';

  @override
  String get logoutButton => 'Déconnexion';

  @override
  String get reportsTitle => 'Tableau de bord admin';

  @override
  String get filterAll => 'Tous';

  @override
  String get filterNew => 'Nouveau';

  @override
  String get filterInProgress => 'En cours';

  @override
  String get filterResolved => 'Résolu';

  @override
  String get statusNew => 'Nouveau';

  @override
  String get statusInProgress => 'En cours';

  @override
  String get statusResolved => 'Résolu';

  @override
  String get delete => 'Supprimer';

  @override
  String get confirmDeleteTitle => 'Confirmer la suppression';

  @override
  String get confirmDeleteBody =>
      'Voulez-vous vraiment supprimer cet élément ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get ok => 'OK';

  @override
  String get createReportTitle => 'Créer un signalement';

  @override
  String get reportTitleLabel => 'Titre';

  @override
  String get reportDescriptionLabel => 'Description';

  @override
  String get submit => 'Envoyer';

  @override
  String get uploading => 'Téléversement...';

  @override
  String get savedSuccess => 'Enregistré avec succès';

  @override
  String get errorGeneric => 'Une erreur est survenue.';

  @override
  String get pickFromGallery => 'Choisir depuis la galerie';

  @override
  String get openCamera => 'Ouvrir l\'appareil photo';

  @override
  String get removeImage => 'Supprimer l\'image';

  @override
  String get getLocation => 'Obtenir ma position';

  @override
  String get confirmSubmit => 'Confirmer l\'envoi';

  @override
  String get confirmSubmitMessage => 'Voulez-vous envoyer ce signalement ?';

  @override
  String get noReports => 'Aucun signalement pour le moment';

  @override
  String get noReportsHint => 'Créez un signalement pour commencer.';

  @override
  String get saveFailed => 'Impossible d\'enregistrer le signalement.';

  @override
  String get permissionDenied =>
      'Permission refusée. Veuillez l\'activer dans les paramètres.';

  @override
  String get locationServicesDisabled =>
      'Les services de localisation sont désactivés.';

  @override
  String get reportDetailsTitle => 'Détails du signalement';

  @override
  String get createdAt => 'Créé le';

  @override
  String get photoLabel => 'Photo';

  @override
  String get photoMissing => 'Aucune photo disponible';

  @override
  String get locationLabel => 'Localisation';

  @override
  String get noLocation => 'Aucune localisation capturée.';

  @override
  String get photoStatusPresent => 'Photo disponible';

  @override
  String get photoStatusMissing => 'Pas de photo';

  @override
  String get locationStatusPresent => 'Localisation disponible';

  @override
  String get locationStatusMissing => 'Pas de localisation';

  @override
  String locationCaptured(String lat, String lng) {
    return 'Lat : $lat, Lng : $lng';
  }

  @override
  String get adminLoginRequired => 'Connexion admin requise';

  @override
  String get searchReports => 'Rechercher des signalements';

  @override
  String get unableToLoadReports => 'Impossible de charger les signalements';

  @override
  String get retry => 'Réessayer';

  @override
  String get markAsNew => 'Marquer comme nouveau';

  @override
  String get markAsInProgress => 'Marquer en cours';

  @override
  String get markAsResolved => 'Marquer comme résolu';

  @override
  String get changeStatus => 'Changer le statut';

  @override
  String get loadMore => 'Charger plus';

  @override
  String statusUpdatedTo(String status) {
    return 'Statut mis à jour : $status';
  }

  @override
  String get reportDeleted => 'Signalement supprimé';

  @override
  String get deleteReport => 'Supprimer le signalement';

  @override
  String get deleteReportButton => 'Supprimer le signalement';

  @override
  String get deleteReportConfirmTitle => 'Supprimer le signalement';

  @override
  String deleteReportConfirmBody(String title) {
    return 'Voulez-vous vraiment supprimer \"$title\" ?';
  }

  @override
  String get deleteImageTitle => 'Supprimer l\'image';

  @override
  String get deleteImageBody => 'Retirer cette image du signalement ?';

  @override
  String get imageUploaded => 'Image téléversée';

  @override
  String get imageDeleted => 'Image supprimée';

  @override
  String get addImage => 'Ajouter une image';

  @override
  String get deleteImage => 'Supprimer l\'image';

  @override
  String get onlyUploadedImagesCanBeDeleted =>
      'Seules les images téléversées peuvent être supprimées.';

  @override
  String get noImages => 'Aucune image';

  @override
  String get noImagesMessage =>
      'Ajoutez une image pour donner plus de contexte à ce signalement.';

  @override
  String get mapPreview => 'Aperçu de la carte';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get signInAsAdmin => 'Se connecter en tant qu\'admin';

  @override
  String get usernameRequired => 'Le nom d\'utilisateur est requis';

  @override
  String get passwordRequired => 'Le mot de passe est requis';

  @override
  String uploadingProgress(String progress) {
    return 'Téléversement $progress%';
  }

  @override
  String get statusLabel => 'Statut';
}
