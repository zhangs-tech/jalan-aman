import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jalan_aman/components/card.dart';
import 'package:jalan_aman/models/report_type.dart';
import 'package:jalan_aman/providers/location_providers.dart';
import 'package:jalan_aman/services/address_service.dart';
import 'package:jalan_aman/services/report_service.dart';
import 'package:jalan_aman/theme/theme.dart';
import 'package:latlong2/latlong.dart';

class CreateReportPage extends ConsumerStatefulWidget {
  const CreateReportPage({super.key});

  @override
  ConsumerState<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends ConsumerState<CreateReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _mapController = MapController();

  ReportType? _selectedType;
  LatLng? _position;
  File? _photo;
  String? _photoMimeType;
  bool _isSubmitting = false;
  bool _isAddressLoading = false;
  bool _hasLoadedInitialAddress = false;

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_onFieldChanged);
    _addressController.addListener(_onFieldChanged);
    _zipCodeController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    _zipCodeController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onFieldChanged() => setState(() {});

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null && mounted) {
      setState(() {
        _photo = File(picked.path);
        _photoMimeType = picked.mimeType ?? _mimeTypeFromPath(picked.path);
      });
    }
  }

  void _removePhoto() => setState(() {
    _photo = null;
    _photoMimeType = null;
  });

  Future<void> _refreshAddressFromCurrentPosition() async {
    if (_position == null) return;
    final position = _position!;
    setState(() => _isAddressLoading = true);
    final result = await AddressService.getAddress(
      position.latitude,
      position.longitude,
    );
    if (!mounted) return;
    setState(() {
      if (result != null) {
        _addressController.text = result.address.trim().isEmpty
            ? 'Current location'
            : result.address;
        _zipCodeController.text = result.zipCode;
      } else if (_addressController.text.trim().isEmpty) {
        _addressController.text = 'Current location';
      }
      _isAddressLoading = false;
    });
  }

  Future<void> _onSubmit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a report type')),
      );
      return;
    }
    if (_position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location not available. Please try again.'),
        ),
      );
      return;
    }
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address is still loading. Please retry.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await ReportService.create(
        reportType: _selectedType!.value,
        description: _descriptionController.text.trim(),
        latitude: _position!.latitude,
        longitude: _position!.longitude,
        address: _addressController.text.trim(),
        zipCode: _zipCodeController.text.trim(),
        mimeType: _photo != null ? _mimeType : null,
        fileSize: _photo != null ? await _photo!.length() : null,
      );

      if (!mounted) return;

      if (result['statusCode'] == 201) {
        final data = result['data'];
        final attachment = data is Map ? data['attachment'] : null;
        final uploadUrl = attachment is Map
            ? attachment['uploadUrl'] as String?
            : null;

        if (uploadUrl != null && _photo != null) {
          try {
            await ReportService.uploadAttachment(
              uploadUrl: uploadUrl,
              file: _photo!,
              mimeType: _mimeType,
            );
          } catch (error) {
            if (!mounted) return;
            final message = error is ReportServiceException
                ? 'Report submitted, but image upload failed (${error.statusCode}).'
                : 'Report submitted, but image upload failed.';
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
            Navigator.pop(context, true);
            return;
          }
        }

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Report submitted')));
        Navigator.pop(context, true);
      } else {
        final data = result['data'];
        final message = data is Map ? data['message']?.toString() : null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? 'Failed to submit report')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection error. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String get _mimeType {
    return _photoMimeType ?? _mimeTypeFromPath(_photo?.path ?? '');
  }

  String _mimeTypeFromPath(String path) {
    final ext = path.split('.').last.toLowerCase();
    return switch (ext) {
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }

  @override
  Widget build(BuildContext context) {
    final positionAsync = ref.watch(currentPositionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('New Report')),
      body: positionAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, _) => _LocationError(
          onRetry: () => ref.invalidate(currentPositionProvider),
        ),
        data: (detectedPosition) {
          if (_position == null && detectedPosition != null) {
            _position = detectedPosition;
            _addressController.clear();
            _zipCodeController.clear();
            if (!_hasLoadedInitialAddress) {
              _hasLoadedInitialAddress = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _refreshAddressFromCurrentPosition();
                }
              });
            }
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.base),
              children: [
                const _CreateHeader(),
                const SizedBox(height: AppSpacing.xl),
                _SectionLabel(text: 'Report Type'),
                const SizedBox(height: AppSpacing.sm),
                _ReportTypeGrid(
                  selectedType: _selectedType,
                  onSelected: (type) => setState(() => _selectedType = type),
                ),
                const SizedBox(height: AppSpacing.xl),
                _SectionLabel(text: 'Description'),
                const SizedBox(height: AppSpacing.sm),
                _DescriptionField(controller: _descriptionController),
                const SizedBox(height: AppSpacing.xl),
                _SectionLabel(text: 'Photo'),
                const SizedBox(height: AppSpacing.sm),
                _PhotoSection(
                  photo: _photo,
                  onPick: () => _pickPhoto(ImageSource.gallery),
                  onRemove: _removePhoto,
                ),
                const SizedBox(height: AppSpacing.xl),
                _SectionLabel(text: 'Location'),
                const SizedBox(height: AppSpacing.sm),
                if (_position != null)
                  _MapPicker(
                    key: ValueKey(_position.toString()),
                    mapController: _mapController,
                    position: _position!,
                  ),
                const SizedBox(height: AppSpacing.md),
                _LocationFields(
                  addressController: _addressController,
                  zipCodeController: _zipCodeController,
                  isLoading: _isAddressLoading,
                  onRefresh: _refreshAddressFromCurrentPosition,
                ),
                const SizedBox(height: AppSpacing.xxl),
                _SubmitButton(isLoading: _isSubmitting, onPressed: _onSubmit),
                SizedBox(height: AppSpacing.md),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Location error ──────────────────────────────────────────────
class _LocationError extends StatelessWidget {
  const _LocationError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_rounded,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.base),
          Text('Location unavailable', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Please enable location services to create a report.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ── Section label ────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelLarge.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _CreateHeader extends StatelessWidget {
  const _CreateHeader();

  @override
  Widget build(BuildContext context) {
    return Cards(
      appSpacing: Spacing.base,
      border: Border.all(color: AppColors.border),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_location_alt_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create road report', style: AppTextStyles.h3),
                const SizedBox(height: 2),
                Text(
                  'Your report will use your current GPS location.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Report type grid ─────────────────────────────────────────────
class _ReportTypeGrid extends StatelessWidget {
  const _ReportTypeGrid({required this.selectedType, required this.onSelected});
  final ReportType? selectedType;
  final ValueChanged<ReportType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: ReportType.values
          .map(
            (type) => _TypePill(
              type: type,
              isSelected: type == selectedType,
              onTap: () => onSelected(type),
            ),
          )
          .toList(),
    );
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final ReportType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = type.color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.surface,
          borderRadius: AppRadius.pillRadius,
          border: Border.all(color: isSelected ? color : AppColors.border),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.18),
                    blurRadius: 10,
                  ),
                ]
              : const [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type.icon, color: isSelected ? Colors.white : color, size: 16),
            const SizedBox(width: AppSpacing.xs),
            Text(
              type.label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Description field ────────────────────────────────────────────
class _DescriptionField extends StatefulWidget {
  const _DescriptionField({required this.controller});
  final TextEditingController controller;

  @override
  State<_DescriptionField> createState() => _DescriptionFieldState();
}

class _DescriptionFieldState extends State<_DescriptionField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChanged);
  }

  void _handleControllerChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final length = widget.controller.text.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.inputRadius,
            border: Border.all(color: AppColors.border),
          ),
          child: TextFormField(
            controller: widget.controller,
            maxLines: 4,
            maxLength: 256,
            style: AppTextStyles.bodyMedium,
            buildCounter:
                (_, {required currentLength, required isFocused, maxLength}) =>
                    null,
            decoration: const InputDecoration(
              hintText: 'Describe what you see...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(AppSpacing.base),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Description is required';
              }
              if (value.trim().length > 256) {
                return 'Description must be at most 256 characters';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '$length/256',
          style: AppTextStyles.caption.copyWith(
            color: length > 256 ? AppColors.danger : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }
}

// ── Photo section ────────────────────────────────────────────────
class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.photo,
    required this.onPick,
    required this.onRemove,
  });
  final File? photo;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (photo != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: AppRadius.cardRadius,
            child: Image.file(
              photo!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onPick,
      child: Cards(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.xl,
        ),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [],
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.upload_file_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Upload image',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Choose a photo from your device',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Map picker ───────────────────────────────────────────────────
class _MapPicker extends StatefulWidget {
  const _MapPicker({
    super.key,
    required this.mapController,
    required this.position,
  });
  final MapController mapController;
  final LatLng position;

  @override
  State<_MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<_MapPicker> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.mapController.move(widget.position, 15);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.cardRadius,
      child: SizedBox(
        height: 180,
        child: FlutterMap(
          mapController: widget.mapController,
          options: MapOptions(
            initialCenter: widget.position,
            initialZoom: 15,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.jalan_aman',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: widget.position,
                  width: 36,
                  height: 36,
                  child: Icon(
                    Icons.location_on_rounded,
                    color: AppColors.danger,
                    size: 36,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Location fields ──────────────────────────────────────────────
class _LocationFields extends StatelessWidget {
  const _LocationFields({
    required this.addressController,
    required this.zipCodeController,
    required this.isLoading,
    required this.onRefresh,
  });
  final TextEditingController addressController;
  final TextEditingController zipCodeController;
  final bool isLoading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Cards(
      appSpacing: Spacing.base,
      border: Border.all(color: AppColors.border),
      boxShadow: const [],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  isLoading ? 'Loading address...' : 'Address details',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onRefresh,
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.my_location_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _ReadOnlyRow(
            label: 'Address',
            value: addressController.text.isEmpty
                ? (isLoading ? 'Detecting address...' : '-')
                : addressController.text,
          ),
          const SizedBox(height: AppSpacing.md),
          _ReadOnlyRow(
            label: 'Zip Code',
            value: zipCodeController.text.isEmpty
                ? '-'
                : zipCodeController.text,
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: AppRadius.inputRadius,
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Submit button ────────────────────────────────────────────────
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.isLoading, required this.onPressed});
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.inputRadius),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'Submit Report',
                style: AppTextStyles.button.copyWith(color: Colors.white),
              ),
      ),
    );
  }
}
