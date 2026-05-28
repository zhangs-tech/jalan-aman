import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:jalan_aman/models/map_bounds.dart';
import 'package:jalan_aman/models/report_models.dart';
import 'package:jalan_aman/services/api/api_client.dart';

class ReportService {
  static Future<Map<String, dynamic>> create({
    required String reportType,
    required String description,
    required double latitude,
    required double longitude,
    required String address,
    String? zipCode,
    String? mimeType,
    int? fileSize,
  }) async {
    final body = <String, dynamic>{
      'reportType': reportType,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
    if (zipCode != null && zipCode.isNotEmpty) {
      body['zipCode'] = zipCode;
    }
    if (mimeType != null && fileSize != null) {
      body['attachment'] = {'mimeType': mimeType, 'fileSize': fileSize};
    }
    return ApiClient.post('/reports', body, auth: true);
  }

  static Future<void> uploadAttachment({
    required String uploadUrl,
    required File file,
    required String mimeType,
  }) async {
    final signedUri = Uri.parse(uploadUrl);
    final uploadUri = _androidReachableUri(signedUri);
    final bytes = await file.readAsBytes();
    final response = await http.put(
      uploadUri,
      headers: _uploadHeaders(
        signedUri: signedUri,
        uploadUri: uploadUri,
        mimeType: mimeType,
      ),
      body: bytes,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ReportServiceException(
        statusCode: response.statusCode,
        message: response.body.trim().isEmpty
            ? 'Attachment upload failed'
            : 'Attachment upload failed: ${response.body}',
      );
    }
  }

  static Uri _androidReachableUri(Uri uri) {
    if (!_isLoopbackHost(uri.host)) return uri;

    final apiHost = _configuredApiHost();
    if (apiHost != null && !_isLoopbackHost(apiHost)) {
      return uri.replace(host: apiHost);
    }

    if (Platform.isAndroid) {
      return uri.replace(host: '10.0.2.2');
    }

    return uri;
  }

  static String? _configuredApiHost() {
    final apiBaseUrl = dotenv.env['API_BASE_URL'];
    if (apiBaseUrl == null || apiBaseUrl.isEmpty) return null;
    return Uri.tryParse(apiBaseUrl)?.host;
  }

  static bool _isLoopbackHost(String host) {
    final normalized = host.toLowerCase();
    return normalized == 'localhost' ||
        normalized == '127.0.0.1' ||
        normalized == '0.0.0.0';
  }

  static Map<String, String> _uploadHeaders({
    required Uri signedUri,
    required Uri uploadUri,
    required String mimeType,
  }) {
    final headers = <String, String>{HttpHeaders.contentTypeHeader: mimeType};
    if (uploadUri.host != signedUri.host) {
      headers[HttpHeaders.hostHeader] = signedUri.hasPort
          ? '${signedUri.host}:${signedUri.port}'
          : signedUri.host;
    }
    return headers;
  }

  static int? _statusCode(Map<String, dynamic> result) {
    final statusCode = result['statusCode'];
    return statusCode is int ? statusCode : null;
  }

  static Map<String, dynamic> _dataMap(Map<String, dynamic> result) {
    return (result['data'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
  }

  static Map<String, dynamic> _expectOkData(
    Map<String, dynamic> result, {
    required String failureMessage,
  }) {
    final data = _dataMap(result);
    final statusCode = _statusCode(result);
    if (statusCode != 200) {
      throw ReportServiceException(
        statusCode: statusCode,
        message: data['message']?.toString() ?? failureMessage,
      );
    }
    return data;
  }

  static Future<CursorPage<ReportSummary>> getMyReports({
    String? cursor,
    int limit = 20,
    String? reportType,
  }) async {
    final query = <String>[
      'limit=$limit',
      if (cursor != null && cursor.isNotEmpty)
        'cursor=${Uri.encodeQueryComponent(cursor)}',
      if (reportType != null && reportType.isNotEmpty)
        'reportType=${Uri.encodeQueryComponent(reportType)}',
    ].join('&');

    final result = await ApiClient.get('/reports/user/me?$query', auth: true);
    final data = _expectOkData(
      result,
      failureMessage: 'Failed to load your reports',
    );
    final rows =
        (data['reports'] as List?)
            ?.whereType<Map>()
            .map((item) => ReportSummary.fromJson(item.cast<String, dynamic>()))
            .toList() ??
        const <ReportSummary>[];

    return CursorPage<ReportSummary>(
      items: rows,
      nextCursor: data['nextCursor']?.toString(),
    );
  }

  static Future<CursorPage<ReportSummary>> getPublicReports({
    String? cursor,
    int limit = 20,
    String? reportType,
  }) async {
    final query = <String>[
      'limit=$limit',
      if (cursor != null && cursor.isNotEmpty)
        'cursor=${Uri.encodeQueryComponent(cursor)}',
      if (reportType != null && reportType.isNotEmpty)
        'reportType=${Uri.encodeQueryComponent(reportType)}',
      'sort=createdAt',
      'order=desc',
    ].join('&');

    final result = await ApiClient.get('/reports?$query', auth: true);
    final data = _expectOkData(
      result,
      failureMessage: 'Failed to load public reports',
    );
    final rows =
        (data['reports'] as List?)
            ?.whereType<Map>()
            .map((item) => ReportSummary.fromJson(item.cast<String, dynamic>()))
            .toList() ??
        const <ReportSummary>[];

    return CursorPage<ReportSummary>(
      items: rows,
      nextCursor: data['nextCursor']?.toString(),
    );
  }

  static Future<List<MapPinModel>> getMapPins(MapBoundsModel bounds) async {
    final queryString = bounds
        .toQueryParameters()
        .entries
        .map((entry) => '${entry.key}=${Uri.encodeQueryComponent(entry.value)}')
        .join('&');
    final result = await ApiClient.get('/reports/map?$queryString');
    final data = _expectOkData(
      result,
      failureMessage: 'Failed to load map pins',
    );
    return (data['pins'] as List?)
            ?.whereType<Map>()
            .map((item) => MapPinModel.fromJson(item.cast<String, dynamic>()))
            .toList() ??
        const <MapPinModel>[];
  }

  static Future<ReportDetail> getById(String reportId) async {
    final result = await ApiClient.get('/reports/$reportId', auth: true);
    final data = _expectOkData(
      result,
      failureMessage: 'Failed to load report',
    );
    final report = (data['report'] as Map?)?.cast<String, dynamic>();
    if (report == null) {
      throw StateError('Invalid report detail response');
    }
    return ReportDetail.fromJson(report);
  }

  static Future<ReportDetail> confirm(String reportId) async {
    final result = await ApiClient.post(
      '/reports/$reportId/confirm',
      const {},
      auth: true,
    );
    final data = _expectOkData(
      result,
      failureMessage: 'Failed to confirm report',
    );
    final report = (data['report'] as Map?)?.cast<String, dynamic>();
    if (report == null) {
      throw StateError('Invalid confirm report response');
    }
    return ReportDetail.fromJson(report);
  }

  static Future<ReportDetail> resolve(String reportId) async {
    final result = await ApiClient.post(
      '/reports/$reportId/resolve',
      const {},
      auth: true,
    );
    final data = _expectOkData(
      result,
      failureMessage: 'Failed to resolve report',
    );
    final report = (data['report'] as Map?)?.cast<String, dynamic>();
    if (report == null) {
      throw StateError('Invalid resolve report response');
    }
    return ReportDetail.fromJson(report);
  }

  static Future<void> edit({
    required String reportId,
    required String description,
    required String address,
    required double userLat,
    required double userLng,
  }) async {
    final result = await ApiClient.put('/reports/$reportId', {
      'description': description,
      'address': address,
      'userLat': userLat,
      'userLng': userLng,
    }, auth: true);
    _expectOkData(result, failureMessage: 'Failed to edit report');
  }

  static Future<void> delete(String reportId) async {
    final result = await ApiClient.delete('/reports/$reportId', auth: true);
    _expectOkData(result, failureMessage: 'Failed to delete report');
  }
}

class ReportServiceException implements Exception {
  const ReportServiceException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ReportServiceException($statusCode): $message';
}
