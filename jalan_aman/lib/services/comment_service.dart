import 'package:jalan_aman/models/report_models.dart';
import 'package:jalan_aman/services/api/api_client.dart';

class CommentService {
  static Future<CursorPage<ReportComment>> getByReportId({
    required String reportId,
    String? cursor,
    int limit = 20,
  }) async {
    final query = <String>[
      'limit=$limit',
      if (cursor != null && cursor.isNotEmpty)
        'cursor=${Uri.encodeQueryComponent(cursor)}',
    ].join('&');

    final result = await ApiClient.get('/reports/$reportId/comments?$query');
    final data = (result['data'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    if (result['statusCode'] != 200) {
      throw CommentServiceException(
        statusCode: result['statusCode'] as int?,
        message: data['message']?.toString() ?? 'Failed to load comments',
      );
    }

    final rows = (data['comments'] as List?)
            ?.whereType<Map>()
            .map((item) => ReportComment.fromJson(item.cast<String, dynamic>()))
            .toList() ??
        const <ReportComment>[];
    return CursorPage<ReportComment>(
      items: rows,
      nextCursor: data['nextCursor']?.toString(),
    );
  }

  static Future<ReportComment> create({
    required String reportId,
    required String details,
  }) async {
    final result = await ApiClient.post(
      '/reports/$reportId/comments',
      {'details': details},
      auth: true,
    );
    final data = (result['data'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final comment = (data['comment'] as Map?)?.cast<String, dynamic>();
    if (result['statusCode'] != 201 || comment == null) {
      throw CommentServiceException(
        statusCode: result['statusCode'] as int?,
        message: data['message']?.toString() ?? 'Failed to add comment',
      );
    }
    return ReportComment.fromJson(comment);
  }

  static Future<ReportComment> update({
    required String reportId,
    required String commentId,
    required String details,
  }) async {
    final result = await ApiClient.patch(
      '/reports/$reportId/comments/$commentId',
      {'details': details},
      auth: true,
    );
    final data = (result['data'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final comment = (data['comment'] as Map?)?.cast<String, dynamic>();
    if (result['statusCode'] != 200 || comment == null) {
      throw CommentServiceException(
        statusCode: result['statusCode'] as int?,
        message: data['message']?.toString() ?? 'Failed to update comment',
      );
    }
    return ReportComment.fromJson(comment);
  }

  static Future<void> delete({
    required String reportId,
    required String commentId,
  }) async {
    final result = await ApiClient.delete(
      '/reports/$reportId/comments/$commentId',
      auth: true,
    );
    final data = (result['data'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    if (result['statusCode'] != 200) {
      throw CommentServiceException(
        statusCode: result['statusCode'] as int?,
        message: data['message']?.toString() ?? 'Failed to delete comment',
      );
    }
  }
}

class CommentServiceException implements Exception {
  const CommentServiceException({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;
}
