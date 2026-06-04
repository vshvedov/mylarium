import 'dart:io';

import 'package:dio/dio.dart';

enum KomgaErrorKind {
  unreachable,
  unauthorized,
  forbidden,
  notFound,
  tls,
  badResponse,
  unknown,
}

/// Transport-level error surfaced to callers. Carries no request headers or
/// bodies, so it is safe to log (CLAUDE.md: secrets never logged).
class KomgaException implements Exception {
  const KomgaException(this.kind, this.message, {this.statusCode});

  final KomgaErrorKind kind;
  final String message;
  final int? statusCode;

  bool get isUnauthorized => kind == KomgaErrorKind.unauthorized;

  factory KomgaException.fromDio(DioException e) {
    final status = e.response?.statusCode;
    if (e.type == DioExceptionType.badCertificate ||
        e.error is HandshakeException) {
      return const KomgaException(
        KomgaErrorKind.tls,
        'The server certificate could not be verified.',
      );
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const KomgaException(
          KomgaErrorKind.unreachable,
          'Could not reach the server.',
        );
      case DioExceptionType.badResponse:
        switch (status) {
          case 401:
            return KomgaException(KomgaErrorKind.unauthorized,
                'Authentication failed.', statusCode: status);
          case 403:
            return KomgaException(KomgaErrorKind.forbidden,
                'Access denied.', statusCode: status);
          case 404:
            return KomgaException(KomgaErrorKind.notFound,
                'Not found.', statusCode: status);
          default:
            return KomgaException(KomgaErrorKind.badResponse,
                'Unexpected server response.', statusCode: status);
        }
      default:
        if (e.error is SocketException) {
          return const KomgaException(
            KomgaErrorKind.unreachable,
            'Could not reach the server.',
          );
        }
        return KomgaException(KomgaErrorKind.unknown,
            'Unexpected error.', statusCode: status);
    }
  }

  @override
  String toString() => 'KomgaException($kind, status=$statusCode): $message';
}
