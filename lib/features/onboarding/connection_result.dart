/// Which credential style the user chose on the onboarding form.
enum AuthMethod { apiKey, basic }

/// Roles a Komga account must have for Mylarium to function (FR2).
const requiredKomgaRoles = {'PAGE_STREAMING', 'FILE_DOWNLOAD'};

/// Outcome of an onboarding connection attempt. One variant per user-visible
/// path so the screen can render a precise message.
sealed class ConnectionResult {
  const ConnectionResult();
}

/// Connected, validated, and persisted. [sourceId] is the new source's id.
class ConnSuccess extends ConnectionResult {
  const ConnSuccess(this.sourceId);
  final String sourceId;
}

class ConnInvalidUrl extends ConnectionResult {
  const ConnInvalidUrl();
}

class ConnUnreachable extends ConnectionResult {
  const ConnUnreachable();
}

class ConnUnauthorized extends ConnectionResult {
  const ConnUnauthorized();
}

class ConnMissingRoles extends ConnectionResult {
  const ConnMissingRoles(this.missing);
  final Set<String> missing;
}

class ConnVersionTooOldForApiKey extends ConnectionResult {
  const ConnVersionTooOldForApiKey(this.version);
  final String? version;
}

class ConnTlsError extends ConnectionResult {
  const ConnTlsError();
}

class ConnUnknown extends ConnectionResult {
  const ConnUnknown(this.message);
  final String message;
}
