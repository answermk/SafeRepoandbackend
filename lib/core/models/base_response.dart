/// Standard response structure for all API calls
class BaseResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? message;
  final int? statusCode;

  BaseResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
    this.statusCode,
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return BaseResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : json['data'] as T?,
      error: json['error'],
      message: json['message'],
      statusCode: json['statusCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'error': error,
      'message': message,
      'statusCode': statusCode,
    };
  }
}

/// Paginated Response Model
class PaginatedResponse<T> {
  final List<T> content;
  final int totalPages;
  final int totalElements;
  final int currentPage;
  final int size;
  final bool hasNext;
  final bool hasPrevious;

  PaginatedResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.currentPage,
    required this.size,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      content: (json['content'] as List<dynamic>?)
              ?.map((item) => fromJsonT(item))
              .toList() ??
          [],
      totalPages: json['totalPages'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      currentPage: json['number'] ?? 0,
      size: json['size'] ?? 0,
      hasNext: json['number'] != null && json['totalPages'] != null
          ? (json['number'] as int) < (json['totalPages'] as int) - 1
          : false,
      hasPrevious: json['number'] != null && (json['number'] as int) > 0,
    );
  }
}

