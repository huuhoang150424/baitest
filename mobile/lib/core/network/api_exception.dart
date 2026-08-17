import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  factory ApiException.fromDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return ApiException(
        message: 'Server phản hồi quá lâu. Vui lòng thử lại.',
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return ApiException(
        message: 'Không thể kết nối đến máy chủ. Hãy kiểm tra lại kết nối mạng hoặc backend.',
      );
    }

    if (error.response != null) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      String message = 'Có lỗi xảy ra. Vui lòng thử lại.';
      dynamic errorsList;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('message') && data['message'] != null) {
          message = data['message'].toString();
        }
        if (data.containsKey('errors')) {
          errorsList = data['errors'];
        }
      }

      switch (statusCode) {
        case 400:
          return ApiException(
            message: message.contains('Validation failed')
                ? 'Thông tin phiếu nhập không hợp lệ'
                : message,
            statusCode: 400,
            errors: errorsList,
          );
        case 404:
          return ApiException(
            message: 'Không tìm thấy dữ liệu yêu cầu',
            statusCode: 404,
          );
        case 409:
          return ApiException(
            message: 'Số phiếu nhập kho đã tồn tại',
            statusCode: 409,
          );
        case 500:
          return ApiException(
            message: 'Có lỗi phía máy chủ. Vui lòng thử lại sau.',
            statusCode: 500,
          );
        case 503:
          return ApiException(
            message: 'Không thể kết nối đến máy chủ',
            statusCode: 503,
          );
        default:
          return ApiException(
            message: message,
            statusCode: statusCode,
          );
      }
    }

    return ApiException(
      message: 'Không thể kết nối đến máy chủ',
    );
  }

  @override
  String toString() => message;
}
