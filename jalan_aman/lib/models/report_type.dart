import 'package:flutter/material.dart';

enum ReportType {
  accident(
    value: 'accident',
    label: 'Accident',
    color: Color(0xFFD0021B),
    icon: Icons.car_crash_rounded,
    ttlHours: 2,
  ),
  police(
    value: 'police',
    label: 'Police',
    color: Color(0xFF1D4ED8),
    icon: Icons.local_police_rounded,
    ttlHours: 2,
  ),
  hazard(
    value: 'hazard',
    label: 'Hazard',
    color: Color(0xFFD97706),
    icon: Icons.warning_rounded,
    ttlHours: 2,
  ),
  crime(
    value: 'crime',
    label: 'Crime',
    color: Color(0xFF991B1B),
    icon: Icons.gavel_rounded,
    ttlHours: 2,
  ),
  flood(
    value: 'flood',
    label: 'Flood',
    color: Color(0xFF0E7490),
    icon: Icons.water_damage_rounded,
    ttlHours: 12,
  ),
  pothole(
    value: 'pothole',
    label: 'Pothole',
    color: Color(0xFFB45309),
    icon: Icons.add_road_rounded,
    ttlHours: 12,
  ),
  closure(
    value: 'closure',
    label: 'Road Closure',
    color: Color(0xFF4B5563),
    icon: Icons.block_rounded,
    ttlHours: 24,
  ),
  construction(
    value: 'construction',
    label: 'Construction',
    color: Color(0xFFD97706),
    icon: Icons.engineering_rounded,
    ttlHours: 24,
  ),
  brokenTrafficLight(
    value: 'broken_traffic_light',
    label: 'Traffic Light',
    color: Color(0xFFB91C1C),
    icon: Icons.traffic_rounded,
    ttlHours: 24,
  ),
  other(
    value: 'other',
    label: 'Other',
    color: Color(0xFF6B7280),
    icon: Icons.more_horiz_rounded,
    ttlHours: 6,
  );

  const ReportType({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
    required this.ttlHours,
  });

  final String value;
  final String label;
  final Color color;
  final IconData icon;
  final int ttlHours;

  static ReportType fromString(String raw) {
    final lower = raw.toLowerCase().trim();
    for (final type in values) {
      if (type.value == lower) return type;
    }
    return ReportType.other;
  }
}
