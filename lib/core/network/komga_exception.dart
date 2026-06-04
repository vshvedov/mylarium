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

/// A short, human-friendly hint for an error, for display in the UI. Never
/// surfaces raw exception text or secrets.
String friendlyError(Object error) {
  if (error is KomgaException) {
    return switch (error.kind) {
      KomgaErrorKind.notFound =>
        'The server could not find this item. It may have been removed.',
      KomgaErrorKind.unauthorized ||
      KomgaErrorKind.forbidden =>
        'Your session may have expired. Reconnect the source in Settings.',
      KomgaErrorKind.unreachable =>
        'Can not reach the server. Check your connection and try again.',
      KomgaErrorKind.tls => 'The secure connection to the server failed.',
      _ => 'Something went wrong talking to the server.',
    };
  }
  return 'Something went wrong. Please try again.';
}
