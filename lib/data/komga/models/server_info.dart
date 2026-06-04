/// Result of probing a Komga server during onboarding: its build [version]
/// (nullable when the actuator endpoint is unavailable) and the authenticated
/// account's [roles].
class KomgaServerInfo {
  const KomgaServerInfo({this.version, this.roles = const {}});

  final String? version;
  final Set<String> roles;
}
