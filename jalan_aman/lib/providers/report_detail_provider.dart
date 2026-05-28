import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_aman/models/report_models.dart';
import 'package:jalan_aman/services/api/api_client.dart';
import 'package:jalan_aman/services/report_service.dart';

/// Holds the report detail together with auth headers and the resolved
/// image URL so that the UI can render the image without an extra
/// FutureBuilder or network round-trip for a presigned URL.
class ReportDetailState {
  const ReportDetailState({
    required this.report,
    required this.imageUrl,
    required this.authHeaders,
  });

  final ReportDetail report;

  /// Direct proxy URL for the first attachment, or `null` if none.
  final String? imageUrl;

  /// Auth headers to pass to [Image.network] so the proxy endpoint
  /// can verify the caller.
  final Map<String, String> authHeaders;
}

final reportDetailProvider = FutureProvider.autoDispose
    .family<ReportDetailState, String>((ref, reportId) async {
  final report = await ReportService.getById(reportId);
  final authHeaders = await ApiClient.getAuthHeaders();

  String? imageUrl;
  if (report.attachments.isNotEmpty) {
    final attachment = report.attachments.first;
    imageUrl =
        '${ApiClient.baseUrl}/reports/${report.id}/attachments/${attachment.id}';
  }

  return ReportDetailState(
    report: report,
    imageUrl: imageUrl,
    authHeaders: authHeaders,
  );
});
