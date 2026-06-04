import 'package:dio/dio.dart';

/// Strategy that injects authentication onto an outgoing Komga request.
///
/// Implementations MUST NOT leak the secret through [toString] (it can land in
/// logs and error reports). See CLAUDE.md: secrets never logged.
abstract class KomgaAuth {
  void apply(RequestOptions options);

  /// The auth header(s) as a plain map, for transports that do not go through
  /// Dio (e.g. the background download service). Same secret as [apply];
  /// callers MUST NOT log the result.
  Map<String, String> headers();
}
