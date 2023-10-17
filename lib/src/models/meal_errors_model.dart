class ResponseError implements Exception {
  final int? statusCode;

  String? message;

  ResponseError({
    required this.statusCode,
    this.message = '',
  }) {
    message = "[Error while getting RESPONSE]>> $message";
  }
}

class ConnectionError implements Exception {
  final int? statusCode;
  String? message;

  ConnectionError({
    this.statusCode,
    this.message = '',
  }) {
    message = "[Error while doing REQUEST]>> $message";
  }
}

class MemoryError implements Exception {
  String? message;
  MemoryError({
    this.message = '',
  }) {
    message = "[Error while reading MEMORY]>> $message";
  }
}

class InternalError implements Exception {
  String? message;
  InternalError({
    this.message = '',
  }) {
    message = "[INTERNAL ERROR]>> $message";
  }
}
