import 'package:dio/dio.dart';

/// Strategy that injects authentication onto an outgoing Komga request.
///
/// Implementations MUST NOT leak the secret through [toString] (it can land in
/// logs and error reports). See CLAUDE.md: secrets never logged.
abstract class KomgaAuth {
  void apply(RequestOptions options);
}
