class VoteSummary {
  const VoteSummary({
    required this.confirms,
    required this.resolves,
    required this.userVoted,
  });

  final int confirms;
  final int resolves;
  final String? userVoted;

  factory VoteSummary.fromJson(Map<String, dynamic> json) {
    return VoteSummary(
      confirms: (json['confirms'] as num?)?.toInt() ?? 0,
      resolves: (json['resolves'] as num?)?.toInt() ?? 0,
      userVoted: json['userVoted'] as String?,
    );
  }
}

class ReportAttachment {
  const ReportAttachment({
    required this.id,
    required this.s3Key,
    required this.mimeType,
    required this.fileSize,
    required this.createdAt,
  });

  final String id;
  final String s3Key;
  final String mimeType;
  final int fileSize;
  final DateTime createdAt;

  factory ReportAttachment.fromJson(Map<String, dynamic> json) {
    return ReportAttachment(
      id: json['id']?.toString() ?? '',
      s3Key: json['s3Key']?.toString() ?? '',
      mimeType: json['mimeType']?.toString() ?? '',
      fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class ReportSummary {
  const ReportSummary({
    required this.id,
    required this.reportType,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.expiresAt,
    required this.reportedBy,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.zipCode,
    required this.voteSummary,
  });

  final String id;
  final String reportType;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime expiresAt;
  final String reportedBy;
  final double latitude;
  final double longitude;
  final String address;
  final String? zipCode;
  final VoteSummary voteSummary;

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      id: json['id']?.toString() ?? '',
      reportType: json['reportType']?.toString() ?? 'other',
      description: json['description']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? '') ??
          DateTime.now(),
      reportedBy: json['reportedBy']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      address: json['address']?.toString() ?? '',
      zipCode: json['zipCode']?.toString(),
      voteSummary: VoteSummary.fromJson(
        (json['voteSummary'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      ),
    );
  }
}

class ReportDetail extends ReportSummary {
  const ReportDetail({
    required super.id,
    required super.reportType,
    required super.description,
    required super.createdAt,
    required super.updatedAt,
    required super.expiresAt,
    required super.reportedBy,
    required super.latitude,
    required super.longitude,
    required super.address,
    required super.zipCode,
    required super.voteSummary,
    required this.commentCount,
    required this.attachments,
  });

  final int commentCount;
  final List<ReportAttachment> attachments;

  factory ReportDetail.fromJson(Map<String, dynamic> json) {
    final attachments = (json['attachments'] as List?)
            ?.whereType<Map>()
            .map((item) =>
                ReportAttachment.fromJson(item.cast<String, dynamic>()))
            .toList() ??
        const <ReportAttachment>[];

    return ReportDetail(
      id: json['id']?.toString() ?? '',
      reportType: json['reportType']?.toString() ?? 'other',
      description: json['description']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? '') ??
          DateTime.now(),
      reportedBy: json['reportedBy']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      address: json['address']?.toString() ?? '',
      zipCode: json['zipCode']?.toString(),
      voteSummary: VoteSummary.fromJson(
        (json['voteSummary'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      ),
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      attachments: attachments,
    );
  }
}

class MapPinModel {
  const MapPinModel({
    required this.id,
    required this.reportType,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String reportType;
  final double latitude;
  final double longitude;

  factory MapPinModel.fromJson(Map<String, dynamic> json) {
    return MapPinModel(
      id: json['id']?.toString() ?? '',
      reportType: json['reportType']?.toString() ?? 'other',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ReportComment {
  const ReportComment({
    required this.id,
    required this.reportId,
    required this.userId,
    required this.userName,
    required this.details,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String reportId;
  final String userId;
  final String userName;
  final String details;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ReportComment.fromJson(Map<String, dynamic> json) {
    return ReportComment(
      id: json['id']?.toString() ?? '',
      reportId: json['reportId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      details: json['details']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class CursorPage<T> {
  const CursorPage({
    required this.items,
    required this.nextCursor,
  });

  final List<T> items;
  final String? nextCursor;
}

class NearbyReportItem {
  const NearbyReportItem({
    required this.report,
    required this.distanceKm,
  });

  final ReportSummary report;
  final double distanceKm;
}
