class MapBoundsModel {
  const MapBoundsModel({
    required this.swLat,
    required this.swLng,
    required this.neLat,
    required this.neLng,
    this.reportTypes = const <String>[],
  });

  final double swLat;
  final double swLng;
  final double neLat;
  final double neLng;
  final List<String> reportTypes;

  Map<String, String> toQueryParameters() {
    return {
      'swLat': swLat.toString(),
      'swLng': swLng.toString(),
      'neLat': neLat.toString(),
      'neLng': neLng.toString(),
      if (reportTypes.isNotEmpty) 'reportType': reportTypes.join(','),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is MapBoundsModel &&
        other.swLat == swLat &&
        other.swLng == swLng &&
        other.neLat == neLat &&
        other.neLng == neLng &&
        other.reportTypes.join(',') == reportTypes.join(',');
  }

  @override
  int get hashCode => Object.hash(
        swLat,
        swLng,
        neLat,
        neLng,
        reportTypes.join(','),
      );
}
