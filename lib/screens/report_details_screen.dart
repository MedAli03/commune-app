import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/app_exception.dart';
import '../localization/app_localizations.dart';
import '../models/report.dart';
import '../repositories/reports_repository.dart';
import '../services/photo_service.dart';
import '../theme/app_theme.dart';
import '../utils/media_url.dart';
import '../utils/platform_image.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_card.dart';

class ReportDetailsScreen extends StatefulWidget {
  const ReportDetailsScreen({
    super.key,
    required this.report,
    this.isAdmin = false,
  });

  final Report report;
  final bool isAdmin;

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  final _reportsRepository = ReportsRepository();
  final _photoService = PhotoService();
  final _pageController = PageController();

  late Report _report;
  late List<_ReportImage> _images;
  bool _loading = false;
  bool _deleting = false;
  bool _uploading = false;
  bool _updatingStatus = false;
  double? _uploadProgress;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _report = widget.report;
    _images = _initialImages(widget.report);
    _refreshDetails();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _refreshDetails() async {
    setState(() {
      _loading = true;
    });
    try {
      final updated = await _reportsRepository.fetchReportById(_report.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _report = updated;
        _images = _mergeImages(existing: _images, report: updated);
      });
    } catch (_) {
      // Keep existing local values if refresh fails.
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _deleteReport() async {
    if (!widget.isAdmin) {
      _showError('Admin login required');
      return;
    }
    if (_deleting) {
      return;
    }
    final localizations = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete report'),
        content: Text(
          'Are you sure you want to delete "${_report.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _deleting = true;
    });
    try {
      await _reportsRepository.deleteReportById(_report.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report deleted')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showError(_readableError(error));
    } finally {
      if (mounted) {
        setState(() {
          _deleting = false;
        });
      }
    }
  }

  Future<void> _uploadImage() async {
    if (!widget.isAdmin) {
      _showError('Admin login required');
      return;
    }
    if (_uploading) {
      return;
    }

    final source = await showModalBottomSheet<_PickerSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pick from gallery'),
              onTap: () => Navigator.of(context).pop(_PickerSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take photo'),
              onTap: () => Navigator.of(context).pop(_PickerSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) {
      return;
    }

    final path = source == _PickerSource.gallery
        ? await _photoService.pickFromGallery()
        : await _photoService.pickFromCamera();

    if (path == null || path.isEmpty || !mounted) {
      return;
    }

    setState(() {
      _uploading = true;
      _uploadProgress = 0;
    });

    try {
      final response = await _reportsRepository.uploadReportImage(
        reportId: _report.id,
        image: XFile(path),
        onProgress: (progress) {
          if (!mounted) {
            return;
          }
          setState(() {
            _uploadProgress = progress;
          });
        },
      );
      final uploaded = _ReportImage.fromUploadResponse(response);
      if (!mounted) {
        return;
      }
      setState(() {
        _images = [..._images, uploaded];
        _currentImageIndex = _images.length - 1;
      });
      _pageController.animateToPage(
        _currentImageIndex,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showError(_readableError(error));
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
          _uploadProgress = null;
        });
      }
    }
  }

  Future<void> _deleteCurrentImage() async {
    if (!widget.isAdmin) {
      _showError('Admin login required');
      return;
    }
    if (_images.isEmpty || _uploading) {
      return;
    }
    final image = _images[_currentImageIndex];
    if (image.id == null) {
      _showError('Only uploaded report images can be deleted.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete image'),
        content: const Text('Remove this image from the report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await _reportsRepository.deleteReportImage(
        reportId: _report.id,
        imageId: image.id!,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _images.removeAt(_currentImageIndex);
        if (_currentImageIndex >= _images.length) {
          _currentImageIndex = _images.isEmpty ? 0 : _images.length - 1;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image deleted')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showError(_readableError(error));
    }
  }

  Future<void> _updateStatus(String status) async {
    if (!widget.isAdmin) {
      _showError('Admin login required');
      return;
    }
    if (_updatingStatus || status == _currentStatusValue) {
      return;
    }

    setState(() {
      _updatingStatus = true;
    });

    try {
      final updated = await _reportsRepository.updateReportStatus(
        reportId: _report.id,
        status: status,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _report = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to ${_statusLabel(status)}')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showError(_readableError(error));
    } finally {
      if (mounted) {
        setState(() {
          _updatingStatus = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.detailsTitle),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDetails,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _buildImageSection(context),
            const SizedBox(height: AppSpacing.md),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.titleLabel,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(_report.title,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    localizations.descriptionLabel,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(_report.description),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (widget.isAdmin)
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _currentStatusValue,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'new', child: Text('New')),
                              DropdownMenuItem(
                                value: 'inProgress',
                                child: Text('In Progress'),
                              ),
                              DropdownMenuItem(
                                value: 'resolved',
                                child: Text('Resolved'),
                              ),
                            ],
                            onChanged: _updatingStatus
                                ? null
                                : (value) {
                                    if (value != null) {
                                      _updateStatus(value);
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        if (_updatingStatus)
                          const SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    )
                  else
                    Text(_statusLabel(_currentStatusValue)),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    localizations.createdAt,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(_report.createdAt.toLocal().toString()),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    localizations.locationLabel,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _LocationSection(report: _report),
                ],
              ),
            ),
            if (widget.isAdmin) const SizedBox(height: AppSpacing.lg),
            if (widget.isAdmin)
              FilledButton.icon(
                onPressed: _uploading ? null : _uploadImage,
                icon: _uploading
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: _uploadProgress,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.add_a_photo_outlined),
                label: Text(
                  _uploading && _uploadProgress != null
                      ? 'Uploading ${(100 * _uploadProgress!).round()}%'
                      : 'Add image',
                ),
              ),
            if (widget.isAdmin) const SizedBox(height: AppSpacing.sm),
            if (widget.isAdmin)
              OutlinedButton.icon(
                onPressed: _deleting ? null : _deleteReport,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                ),
                icon: _deleting
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      )
                    : const Icon(Icons.delete_outline),
                label: const Text('Delete report'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    if (_loading && _images.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_images.isEmpty) {
      return const SectionCard(
        child: SizedBox(
          height: 180,
          child: EmptyState(
            icon: Icons.photo_outlined,
            title: 'No images',
            message: 'Add an image to provide more context for this report.',
          ),
        ),
      );
    }

    final canDelete = widget.isAdmin && _images[_currentImageIndex].id != null;
    return SectionCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _images.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: AppRadii.md,
                      child: _ImageView(pathOrUrl: _images[index].url),
                    );
                  },
                ),
                if (widget.isAdmin)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: FilledButton.tonalIcon(
                      onPressed: canDelete ? _deleteCurrentImage : null,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete image'),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _images.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: _currentImageIndex == index ? 20 : 6,
                decoration: BoxDecoration(
                  color: _currentImageIndex == index
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: AppRadii.xl,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_ReportImage> _initialImages(Report report) {
    if (report.photoPath == null || report.photoPath!.isEmpty) {
      return [];
    }
    return [
      _ReportImage(
        id: null,
        url: _resolveImageUrl(report.photoPath!),
      ),
    ];
  }

  List<_ReportImage> _mergeImages({
    required List<_ReportImage> existing,
    required Report report,
  }) {
    final items = [...existing];
    if (report.photoPath != null && report.photoPath!.isNotEmpty) {
      final resolved = _resolveImageUrl(report.photoPath!);
      final alreadyExists = items.any((image) => image.url == resolved);
      if (!alreadyExists) {
        items.insert(0, _ReportImage(id: null, url: resolved));
      }
    }
    return items;
  }

  String _resolveImageUrl(String value) {
    return resolveMediaUrl(value);
  }

  String get _currentStatusValue {
    switch (_report.status) {
      case 'resolved':
        return 'resolved';
      case 'inProgress':
        return 'inProgress';
      case 'new':
      default:
        return 'new';
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'resolved':
        return 'Resolved';
      case 'inProgress':
        return 'In Progress';
      case 'new':
      default:
        return 'New';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _readableError(Object error) {
    if (error is AppException) {
      final details = error.details;
      if (details == null || details.isEmpty) {
        return error.message;
      }
      if (details['errors'] is List) {
        final messages =
            (details['errors'] as List).map((e) => e.toString()).join(', ');
        return '${error.message}: $messages';
      }
      return '${error.message}: $details';
    }
    return error.toString();
  }
}

class _LocationSection extends StatelessWidget {
  const _LocationSection({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final hasLocation = report.latitude != null && report.longitude != null;
    if (!hasLocation) {
      return Text(localizations.noLocation);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.locationCaptured(
            lat: report.latitude!.toStringAsFixed(6),
            lng: report.longitude!.toStringAsFixed(6),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: AppRadii.md,
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.map_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Map preview',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageView extends StatelessWidget {
  const _ImageView({required this.pathOrUrl});

  final String pathOrUrl;

  @override
  Widget build(BuildContext context) {
    if (isNetworkImageUrl(pathOrUrl)) {
      return Image.network(
        pathOrUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(context),
      );
    }

    final localImage = buildPlatformImage(pathOrUrl, fit: BoxFit.cover);
    if (localImage != null && platformFileExists(pathOrUrl)) {
      return localImage;
    }
    return _fallback(context);
  }

  Widget _fallback(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.broken_image_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _ReportImage {
  const _ReportImage({
    required this.id,
    required this.url,
  });

  final String? id;
  final String url;

  factory _ReportImage.fromUploadResponse(Map<String, dynamic> json) {
    final value = json['url']?.toString() ?? json['path']?.toString() ?? '';
    return _ReportImage(
      id: json['id']?.toString(),
      url: resolveMediaUrl(value),
    );
  }
}

enum _PickerSource {
  gallery,
  camera,
}
