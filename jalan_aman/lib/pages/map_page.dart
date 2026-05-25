import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_aman/providers/profile_providers.dart';
import 'package:jalan_aman/services/location_service.dart';
import 'package:jalan_aman/theme/theme.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  final MapController _mapController = MapController();
  StreamSubscription? _locationSubs;

  //default location -Jakarta
  LatLng _currentPosition = const LatLng(-6.2088, 106.8456);

  Map<String, dynamic>? _selectedReport;

  final List<Map<String, dynamic>> _reports = [
    {
      'id': '1',
      'status': 'Pending',
      'title': 'Jalan Sudirman, Dekat Halte',
      'description':
          'Lubang besar di lajur kiri, bahaya untuk pengendara motor.',
      'address': 'Jl. Sudirman, Jakarta Pusat',
      'timeAgo': '2 jam lalu',
      'lat': -6.2088,
      'lng': 106.8456,
    },
    {
      'id': '2',
      'status': 'In Progress',
      'title': 'Lampu Jalan Mati',
      'description': 'Lampu jalan tidak menyala sejak 3 hari lalu.',
      'address': 'Jl. Thamrin, Jakarta Pusat',
      'timeAgo': '5 jam lalu',
      'lat': -6.1944,
      'lng': 106.8229,
    },
    {
      'id': '3',
      'status': 'Resolved',
      'title': 'Drainase Tersumbat',
      'description': 'Got terasa sudah diperbaiki.',
      'address': 'Jl. Gatot Subroto, Jakarta',
      'timeAgo': '1 hari lalu',
      'lat': -6.2297,
      'lng': 106.8197,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initLiveLocation();
  }

  @override
  void dispose() {
    _locationSubs?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initLiveLocation() async {
    final permission = await LocationService.checkLocationService();
    if (permission == null) return;

    _locationSubs = LocationService.getLivePosition()?.listen((position) {
      if (!mounted) return;
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    });
  }

  void _centerOnUser() {
    _mapController.move(_currentPosition, 15);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final username = profileAsync.valueOrNull?['name'] ?? 'User';

    return Scaffold(
      body: Stack(
        children: [
          _Map(
            mapController: _mapController,
            currentPosition: _currentPosition,
            reports: _reports,
            onPinTap: (report) => setState(() {
              _selectedReport = report;
            }),
          ),

          _GreetingBar(userName: username),

          Positioned(
            right: AppSpacing.base,
            bottom: _selectedReport != null ? 220 : AppSpacing.base,
            child: _FloatingActionButtons(
              onLocationTap: _centerOnUser,
              onAddTap: () {
                // TODO: Navigator.pushNamed(context, '/reports/new');
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
    required this.reports,
    required this.onPinTap,
  });

  final MapController mapController;
  final LatLng currentPosition;
  final List<Map<String, dynamic>> reports;
  final ValueChanged<Map<String, dynamic>> onPinTap;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: currentPosition,
        initialZoom: 13,
        onTap: (_, _) {},
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.jalan_aman',
        ),

        MarkerLayer(
          markers: [
            ...reports.map(
              (report) => Marker(
                point: LatLng(report['lat'], report['lng']),
                width: 36,
                height: 36,
                child: GestureDetector(
                  onTap: () => onPinTap(report),
                  child: _ReportPin(status: report['status']),
                ),
              ),
            ),

            //user current location pin
            Marker(
              point: currentPosition,
              width: 18,
              height: 18,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.info,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 2),
                  boxShadow: [
                    // A standard drop shadow for depth
                    const BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                    // A colored "glow" shadow that spreads out
                    BoxShadow(
                      color: AppColors.info.withValues(alpha: 153),
                      blurRadius: 12,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReportPin extends StatelessWidget {
  const _ReportPin({required this.status});

  final String status;

  IconData get _icon {
    switch (status) {
      case 'Pending':
        return Icons.warning_rounded;
      case 'In Progress':
        return Icons.settings_rounded;
      case 'Resolved':
        return Icons.check_rounded;
      case 'Rejected':
        return Icons.close_rounded;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pinColor(status),
        shape: BoxShape.circle,
        boxShadow: AppShadows.card,
      ),
      child: Icon(_icon, color: Colors.white, size: 18),
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

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
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
          ),
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
