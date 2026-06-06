import 'dart:io';

import 'package:dio/dio.dart';

enum ContentErrorKind {
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
class ContentException implements Exception {
  const ContentException(this.kind, this.message, {this.statusCode});

  final ContentErrorKind kind;
  final String message;
  final int? statusCode;

  bool get isUnauthorized => kind == ContentErrorKind.unauthorized;

  factory ContentException.fromDio(DioException e) {
    final status = e.response?.statusCode;
    if (e.type == DioExceptionType.badCertificate ||
        e.error is HandshakeException) {
      return const ContentException(
        ContentErrorKind.tls,
        'The server certificate could not be verified.',
      );
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const ContentException(
          ContentErrorKind.unreachable,
          'Could not reach the server.',
        );
      case DioExceptionType.badResponse:
        switch (status) {
          case 401:
            return ContentException(ContentErrorKind.unauthorized,
                'Authentication failed.', statusCode: status);
          case 403:
            return ContentException(ContentErrorKind.forbidden,
                'Access denied.', statusCode: status);
          case 404:
            return ContentException(ContentErrorKind.notFound,
                'Not found.', statusCode: status);
          default:
            return ContentException(ContentErrorKind.badResponse,
                'Unexpected server response.', statusCode: status);
        }
      default:
        if (e.error is SocketException) {
          return const ContentException(
            ContentErrorKind.unreachable,
            'Could not reach the server.',
          );
        }
        return ContentException(ContentErrorKind.unknown,
            'Unexpected error.', statusCode: status);
    }
  }

  @override
  String toString() => 'ContentException($kind, status=$statusCode): $message';
}

/// A short, human-friendly hint for an error, for display in the UI. Never
/// surfaces raw exception text or secrets.
String friendlyError(Object error) {
  if (error is ContentException) {
    return switch (error.kind) {
      ContentErrorKind.notFound =>
        'The server could not find this item. It may have been removed.',
      ContentErrorKind.unauthorized ||
      ContentErrorKind.forbidden =>
        'Your session may have expired. Reconnect the source in Settings.',
      ContentErrorKind.unreachable =>
        'Can not reach the server. Check your connection and try again.',
      ContentErrorKind.tls => 'The secure connection to the server failed.',
      _ => 'Something went wrong talking to the server.',
    };
  }
  return 'Something went wrong. Please try again.';
}
