import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_icons.dart';
import '../../app/theme/app_theme.dart' show AppHaptics;
import '../../app/theme/design_tokens.dart';
import '../../app/widgets/app_button.dart';
import 'connection_result.dart';
import 'onboarding_controller.dart';
import 'widgets/brand_mark.dart';

/// Enter a Komga server URL and credentials, validate, and persist the
/// connection. Reached from the onboarding picker, or deep-linked for re-auth
/// (with [initialUrl] prefilled). On success it routes to the library home.
///
/// The form is deliberately bespoke (labels above filled fields, a custom pill
/// auth toggle) so it reads as the same app on iOS and Android, not a stock
/// platform form.
class KomgaConnectScreen extends ConsumerStatefulWidget {
  const KomgaConnectScreen({super.key, this.initialUrl});

  /// Prefilled when re-authenticating a source whose secret went missing.
  final String? initialUrl;

  @override
  ConsumerState<KomgaConnectScreen> createState() => _KomgaConnectScreenState();
}

class _KomgaConnectScreenState extends ConsumerState<KomgaConnectScreen> {
  late final TextEditingController _url =
      TextEditingController(text: widget.initialUrl ?? '');
  final TextEditingController _apiKey = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  AuthMethod _method = AuthMethod.apiKey;

  @override
  void dispose() {
    _url.dispose();
    _apiKey.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _connect() {
    ref.read(onboardingControllerProvider.notifier).connect(
          url: _url.text,
          method: _method,
          apiKey: _apiKey.text,
          username: _username.text,
          password: _password.text,
        );
  }

  String _errorFor(ConnectionResult r) => switch (r) {
        ConnInvalidUrl() =>
          'Enter a valid server URL (for example https://komga.example.com).',
        ConnUnreachable() =>
          'Could not reach the server. Check the URL and your network.',
        ConnUnauthorized() => 'Incorrect credentials.',
        ConnMissingRoles(:final missing) =>
          'Your Komga account is missing the ${missing.join(' and ')} '
              'role. Ask your server admin to enable it.',
        ConnVersionTooOldForApiKey(:final version) =>
          'This server${version == null ? '' : ' (v$version)'} is too old for '
              'API keys. Use a username and password instead.',
        ConnTlsError() =>
          'The server security certificate could not be verified.',
        ConnUnknown(:final message) => message,
        ConnSuccess() => '',
      };

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    ref.listen(onboardingControllerProvider, (_, next) {
      if (next.valueOrNull is ConnSuccess) {
        // Leave onboarding entirely and land on the library home.
        context.go('/');
      }
    });

    final busy = state.isLoading;
    final result = state.valueOrNull;
    final error =
        (result == null || result is ConnSuccess) ? null : _errorFor(result);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(AppIcons.back),
          onPressed: busy ? null : () => _back(context),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              children: [
                const Center(child: BrandMark(size: 56)),
                const SizedBox(height: 18),
                Text(
                  'Connect to Komga',
                  textAlign: TextAlign.center,
                  style: text.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Point Mylarium at your server and sign in.',
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),
                _LabeledField(
                  label: 'Server URL',
                  controller: _url,
                  enabled: !busy,
                  keyboardType: TextInputType.url,
                  hint: 'https://komga.example.com',
                  prefixIcon: AppIcons.sourceKomga,
                ),
                const SizedBox(height: 18),
                _AuthToggle(
                  method: _method,
                  enabled: !busy,
                  onChanged: (m) => setState(() => _method = m),
                ),
                const SizedBox(height: 18),
                if (_method == AuthMethod.apiKey)
                  _LabeledField(
                    label: 'API key',
                    controller: _apiKey,
                    enabled: !busy,
                    obscureText: true,
                    prefixIcon: AppIcons.lock,
                  )
                else ...[
                  _LabeledField(
                    label: 'Username',
                    controller: _username,
                    enabled: !busy,
                  ),
                  const SizedBox(height: 14),
                  _LabeledField(
                    label: 'Password',
                    controller: _password,
                    enabled: !busy,
                    obscureText: true,
                    prefixIcon: AppIcons.lock,
                  ),
                ],
                if (error != null) ...[
                  const SizedBox(height: 18),
                  _ErrorBanner(message: error),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: busy ? 'Connecting...' : 'Connect',
                    onPressed: busy ? null : _connect,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      // Deep-linked here (re-auth) with nothing to pop: fall back to the picker.
      context.go('/onboarding');
    }
  }
}

/// A label rendered above a filled, rounded, borderless field. Avoids the stock
/// floating-label + underline look so the form is identical across platforms.
class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.enabled,
    this.obscureText = false,
    this.keyboardType,
    this.hint,
    this.prefixIcon,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? hint;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(14);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            filled: true,
            fillColor: scheme.surfaceContainerHighest,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: 20, color: scheme.onSurfaceVariant),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: scheme.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

/// A custom two-segment pill toggle for the auth method (replaces the very
/// Material-looking [SegmentedButton]).
class _AuthToggle extends StatelessWidget {
  const _AuthToggle({
    required this.method,
    required this.enabled,
    required this.onChanged,
  });

  final AuthMethod method;
  final bool enabled;
  final ValueChanged<AuthMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          _seg(context, 'API key', AuthMethod.apiKey),
          _seg(context, 'Password', AuthMethod.basic),
        ],
      ),
    );
  }

  Widget _seg(BuildContext context, String label, AuthMethod value) {
    final scheme = Theme.of(context).colorScheme;
    final selected = method == value;
    final tokens = Theme.of(context).extension<DesignTokens>();
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled
            ? () {
                if (!selected) {
                  AppHaptics.selection();
                  onChanged(value);
                }
              }
            : null,
        child: AnimatedContainer(
          duration: tokens?.motion.short ?? const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? scheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onErrorContainer,
            ),
      ),
    );
  }
}
