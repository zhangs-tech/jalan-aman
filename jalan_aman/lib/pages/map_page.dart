import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_aman/components/report_type_badge.dart';
import 'package:jalan_aman/components/report_type_filter_row.dart';
import 'package:jalan_aman/components/vote_chip.dart';
import 'package:jalan_aman/models/map_bounds.dart';
import 'package:jalan_aman/models/report_models.dart';
import 'package:jalan_aman/models/report_type.dart';
import 'package:jalan_aman/pages/create_report_page.dart';
import 'package:jalan_aman/pages/report_detail_page.dart';
import 'package:jalan_aman/providers/map_pins_provider.dart';
import 'package:jalan_aman/providers/profile_providers.dart';
import 'package:jalan_aman/services/location_service.dart';
import 'package:jalan_aman/services/report_service.dart';
import 'package:jalan_aman/theme/theme.dart';
import 'package:jalan_aman/utils/report_refresh.dart';
import 'package:jalan_aman/utils/time_label.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  final MapController _mapController = MapController();
  StreamSubscription? _locationSubs;
  Timer? _boundsDebounce;

  LatLng _currentPosition = const LatLng(-6.2088, 106.8456);
  MapBoundsModel? _bounds;
  ReportType? _selectedType;
  bool _hasCenteredOnUser = false;
  bool _locationResolved = false;
  bool _isMapReady = false;
  LatLng? _pendingCenter;

  @override
  void initState() {
    super.initState();
    _initLiveLocation();
  }

  @override
  void dispose() {
    _locationSubs?.cancel();
    _boundsDebounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initLiveLocation() async {
    final current = await LocationService.getCurrentLocation();
    if (!mounted) return;

    if (current == null) {
      setState(() => _locationResolved = true);
      return;
    }

    final point = LatLng(current.latitude, current.longitude);
    setState(() {
      _currentPosition = point;
      _locationResolved = true;
    });
    _moveMapTo(point);
    _hasCenteredOnUser = true;

    _locationSubs = LocationService.getLivePosition()?.listen((position) {
      if (!mounted) return;
      final point = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentPosition = point;
      });
      if (!_hasCenteredOnUser) {
        _moveMapTo(point);
        _hasCenteredOnUser = true;
      }
    });
  }

  void _centerOnUser() {
    _moveMapTo(_currentPosition);
  }

  void _onMapReady() {
    if (!mounted) return;
    _isMapReady = true;
    final pendingCenter = _pendingCenter;
    if (pendingCenter != null) {
      _pendingCenter = null;
      _mapController.move(pendingCenter, 15);
    }
    _refreshBoundsNow();
  }

  void _moveMapTo(LatLng point) {
    if (!_isMapReady) {
      _pendingCenter = point;
      return;
    }
    _mapController.move(point, 15);
    _refreshBoundsNow();
  }

  void _scheduleBoundsRefresh() {
    if (!_isMapReady) return;
    _boundsDebounce?.cancel();
    _boundsDebounce = Timer(
      const Duration(milliseconds: 500),
      _refreshBoundsNow,
    );
  }

  void _refreshBoundsNow() {
    if (!_isMapReady || !mounted) return;
    final visibleBounds = _mapController.camera.visibleBounds;
    final sw = visibleBounds.southWest;
    final ne = visibleBounds.northEast;
    setState(() {
      _bounds = MapBoundsModel(
        swLat: sw.latitude,
        swLng: sw.longitude,
        neLat: ne.latitude,
        neLng: ne.longitude,
        reportTypes: _selectedType == null ? const [] : [_selectedType!.value],
      );
    });
  }

  Future<void> _openPinPreview(String reportId) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      builder: (_) => _PinPreviewSheet(reportId: reportId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final username = profileAsync.valueOrNull?['name'] ?? 'User';
    final pinsAsync = _bounds == null
        ? const AsyncValue<List<MapPinModel>>.loading()
        : ref.watch(mapPinsProvider(_bounds!));

    if (!_locationResolved) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          _Map(
            mapController: _mapController,
            currentPosition: _currentPosition,
            pinsAsync: pinsAsync,
            onPinTap: _openPinPreview,
            onMapEvent: (_) => _scheduleBoundsRefresh(),
            onMapReady: _onMapReady,
          ),
          SafeArea(
            child: Column(
              children: [
                _GreetingBar(userName: username),
                ReportTypeFilterRow.compact(
                  selectedType: _selectedType,
                  onSelected: (type) {
                    setState(() => _selectedType = type);
                    _refreshBoundsNow();
                  },
                ),
              ],
            ),
          ),
          Positioned(
            right: AppSpacing.base,
            bottom: AppSpacing.base,
            child: _FloatingActionButtons(
              onLocationTap: _centerOnUser,
              onAddTap: () async {
                final created = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateReportPage()),
                );
                if (created == true && context.mounted) {
                  await refreshReportFeeds(ref, mapBounds: _bounds);
                  _refreshBoundsNow();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Map extends StatelessWidget {
  const _Map({
    required this.mapController,
    required this.currentPosition,
    required this.pinsAsync,
    required this.onPinTap,
    required this.onMapEvent,
    required this.onMapReady,
  });

  final MapController mapController;
  final LatLng currentPosition;
  final AsyncValue<List<MapPinModel>> pinsAsync;
  final ValueChanged<String> onPinTap;
  final void Function(MapEvent event) onMapEvent;
  final VoidCallback onMapReady;

  @override
  Widget build(BuildContext context) {
    final pins = pinsAsync.valueOrNull ?? const <MapPinModel>[];

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: currentPosition,
        initialZoom: 13,
        onMapEvent: onMapEvent,
        onMapReady: onMapReady,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.jalan_aman',
        ),
        MarkerLayer(
          markers: pins
              .map(
                (pin) => Marker(
                  point: LatLng(pin.latitude, pin.longitude),
                  width: 36,
                  height: 36,
                  child: GestureDetector(
                    onTap: () => onPinTap(pin.id),
                    child: _ReportPin(
                      reportType: ReportType.fromString(pin.reportType),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: currentPosition,
              width: 20,
              height: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.info,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                  boxShadow: [
                    const BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                    BoxShadow(
                      color: AppColors.info.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (pinsAsync.isLoading)
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 100),
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}

class _PinPreviewSheet extends StatefulWidget {
  const _PinPreviewSheet({required this.reportId});
  final String reportId;

  @override
  State<_PinPreviewSheet> createState() => _PinPreviewSheetState();
}

class _PinPreviewSheetState extends State<_PinPreviewSheet> {
  late final Future<ReportDetail> _future = ReportService.getById(
    widget.reportId,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        AppSpacing.base,
      ),
      child: FutureBuilder<ReportDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 180,
              child: Center(child: Text('Unable to load report')),
            );
          }
          final report = snapshot.data!;
          final type = ReportType.fromString(report.reportType);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReportTypeBadge(reportType: type),
              const SizedBox(height: AppSpacing.sm),
              Text(
                report.address,
                style: AppTextStyles.h3,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                report.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                timeAgoLabel(report.createdAt),
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  VoteChip(
                    icon: Icons.thumb_up_alt_outlined,
                    label: 'Confirm',
                    count: report.voteSummary.confirms,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  VoteChip(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Resolve',
                    count: report.voteSummary.resolves,
                    color: AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportDetailPage(reportId: report.id),
                      ),
                    );
                  },
                  child: const Text('Lihat Detail'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReportPin extends StatelessWidget {
  const _ReportPin({required this.reportType});

  final ReportType reportType;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: reportType.color,
        shape: BoxShape.circle,
        boxShadow: AppShadows.card,
      ),
      child: Icon(reportType.icon, color: Colors.white, size: 18),
    );
  }
}

class _GreetingBar extends StatelessWidget {
  const _GreetingBar({required this.userName});

  final String userName;

  ({String greeting, String subtitle, IconData icon}) get _timeContext {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return (
        greeting: 'Good Morning',
        subtitle: 'Any issues to report today?',
        icon: Icons.wb_sunny_outlined,
      );
    }
    if (hour < 15) {
      return (
        greeting: 'Good Afternoon',
        subtitle: 'Spotted something on the road?',
        icon: Icons.wb_cloudy_outlined,
      );
    }
    if (hour < 19) {
      return (
        greeting: 'Good Evening',
        subtitle: 'Spotted something on the road?',
        icon: Icons.wb_twilight_outlined,
      );
    }
    return (
      greeting: 'Good Night',
      subtitle: 'Stay safe out there.',
      icon: Icons.nightlight_outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeContext = _timeContext;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.overlay,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyMedium,
                    children: [
                      TextSpan(
                        text: '${timeContext.greeting}, ',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      TextSpan(
                        text: userName,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(timeContext.subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          Icon(timeContext.icon, color: AppColors.textTertiary, size: 20),
        ],
      ),
    );
  }
}

class _FloatingActionButtons extends StatelessWidget {
  const _FloatingActionButtons({
    required this.onLocationTap,
    required this.onAddTap,
  });

  final VoidCallback onLocationTap;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onLocationTap,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.cardRadius,
              boxShadow: AppShadows.elevated,
            ),
            child: const Icon(
              Icons.my_location_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        GestureDetector(
          onTap: onAddTap,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppRadius.cardRadius,
              boxShadow: AppShadows.elevated,
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }
}
