import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../api/app_exception.dart';
import '../localization/app_localizations.dart';
import '../models/report.dart';
import '../repositories/reports_repository.dart';
import '../services/location_service.dart';
import '../services/photo_service.dart';
import '../theme/app_theme.dart';
import '../utils/platform_image.dart';
import '../utils/validators.dart';
import '../widgets/section_card.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationService = LocationService();
  final _photoService = PhotoService();
  final _reportsRepository = ReportsRepository();
  final _uuid = const Uuid();

  String? _photoPath;
  double? _latitude;
  double? _longitude;
  bool _saving = false;
  bool _loadingLocation = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.newReport),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.titleLabel,
                    style: theme.textTheme.labelSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: localizations.titleLabel,
                    ),
                    validator: (value) => validateRequired(
                      value,
                      fieldName: localizations.titleLabel,
                      minLength: 5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    localizations.descriptionLabel,
                    style: theme.textTheme.labelSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: localizations.descriptionLabel,
                    ),
                    validator: (value) => validateRequired(
                      value,
                      fieldName: localizations.descriptionLabel,
                      minLength: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.photoLabel,
                    style: theme.textTheme.labelSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildPhotoPreview(context),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickFromGallery,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: Text(localizations.pickFromGallery),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openCamera,
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: Text(localizations.openCamera),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.locationLabel,
                    style: theme.textTheme.labelSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: AppRadii.md,
                    ),
                    child: Text(
                      _latitude != null && _longitude != null
                          ? localizations.locationCaptured(
                              lat: _latitude!.toStringAsFixed(6),
                              lng: _longitude!.toStringAsFixed(6),
                            )
                          : localizations.noLocation,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton.tonalIcon(
                    onPressed: _loadingLocation ? null : _getLocation,
                    icon: _loadingLocation
                        ? SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          )
                        : const Icon(Icons.my_location),
                    label: Text(localizations.getLocation),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _saving ? null : _confirmSaveReport,
              child: _saving
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : Text(localizations.saveReport),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPreview(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (_photoPath == null) {
      return Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: AppRadii.md,
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        child: Center(
          child: Text(
            localizations.photoStatusMissing,
            style: theme.textTheme.bodySmall,
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.topRight,
      children: [
        ClipRRect(
          borderRadius: AppRadii.md,
          child: buildPlatformImage(
                _photoPath!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ) ??
              Container(
                height: 180,
                width: double.infinity,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(child: Text(localizations.photoMissing)),
              ),
        ),
        IconButton.filledTonal(
          onPressed: () {
            setState(() {
              _photoPath = null;
            });
          },
          icon: const Icon(Icons.close),
          tooltip: localizations.removeImage,
        ),
      ],
    );
  }

  Future<void> _pickFromGallery() async {
    final path = await _photoService.pickFromGallery();
    if (path != null && mounted) {
      setState(() {
        _photoPath = path;
      });
    }
  }

  Future<void> _openCamera() async {
    final path = await _photoService.pickFromCamera();
    if (path != null && mounted) {
      setState(() {
        _photoPath = path;
      });
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      _loadingLocation = true;
    });
    try {
      final position =
          await _locationService.getCurrentPositionWithPermission();
      if (position != null && mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      final localizations = AppLocalizations.of(context);
      final message = error.toString().contains('permission')
          ? localizations.permissionDenied
          : error.toString().contains('services')
              ? localizations.locationServicesDisabled
              : error.toString();
      _showSnackBar(message);
    } finally {
      if (mounted) {
        setState(() {
          _loadingLocation = false;
        });
      }
    }
  }

  Future<void> _confirmSaveReport() async {
    final localizations = AppLocalizations.of(context);
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.confirmSubmit),
        content: Text(localizations.confirmSubmitMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(localizations.confirm),
          ),
        ],
      ),
    );

    if (shouldSave != true) {
      return;
    }

    await _saveReport();
  }

  Future<void> _saveReport() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final report = Report(
        id: _uuid.v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        photoPath: _photoPath,
        latitude: _latitude,
        longitude: _longitude,
        createdAt: DateTime.now().toUtc(),
      );

      await _reportsRepository.createReportAndSync(report);

      if (!mounted) {
        return;
      }

      final localizations = AppLocalizations.of(context);
      _showSnackBar(localizations.reportSaved);
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      final localizations = AppLocalizations.of(context);
      final message = _readableError(error);
      _showSnackBar('${localizations.saveFailed} $message');
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  String _readableError(Object error) {
    if (error is AppException) {
      final details = error.details;
      if (details == null || details.isEmpty) {
        return error.message;
      }
      return '${error.message}: $details';
    }
    return error.toString();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
