import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n.dart';
import '../../app/theme/app_icons.dart';
import '../../app/widgets/app_button.dart';
import '../../app/widgets/app_segmented_toggle.dart';
import '../../app/widgets/app_text_field.dart';
import 'connection_result.dart';
import 'onboarding_controller.dart';
import '../../app/widgets/brand_mark.dart';

/// Enter a Komga server URL and credentials, validate, and persist the
/// connection. Reached from the onboarding picker, or deep-linked for re-auth
/// (with [initialUrl] prefilled). On success it routes to the library home.
///
/// Built from the shared app inputs ([AppTextField], [AppSegmentedToggle]) so it
/// reads as the same app on iOS and Android, not a stock platform form.
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

  String _errorFor(BuildContext context, ConnectionResult r) {
    final l10n = context.l10n;
    return switch (r) {
      ConnInvalidUrl() => l10n.komgaConnectInvalidUrl,
      ConnUnreachable() => l10n.connectUnreachable,
      ConnUnauthorized() => l10n.komgaConnectUnauthorized,
      ConnMissingRoles(:final missing) =>
        l10n.komgaConnectMissingRoles(missing.join(' and ')),
      ConnVersionTooOldForApiKey(:final version) => l10n
          .komgaConnectVersionTooOld(version == null ? '' : ' (v$version)'),
      ConnTlsError() => l10n.connectTlsError,
      ConnUnknown(:final message) => message,
      ConnSuccess() => '',
    };
  }

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
    final error = (result == null || result is ConnSuccess)
        ? null
        : _errorFor(context, result);

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
                  context.l10n.komgaConnectTitle,
                  textAlign: TextAlign.center,
                  style: text.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.komgaConnectSubtitle,
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),
                AppTextField(
                  label: context.l10n.connectServerUrlLabel,
                  controller: _url,
                  enabled: !busy,
                  keyboardType: TextInputType.url,
                  hint: 'https://komga.example.com',
                  prefixIcon: AppIcons.sourceKomga,
                ),
                const SizedBox(height: 18),
                AppSegmentedToggle<AuthMethod>(
                  segments: [
                    AppSegment(AuthMethod.apiKey, context.l10n.connectApiKeyLabel),
                    AppSegment(AuthMethod.basic, context.l10n.connectPasswordLabel),
                  ],
                  selected: _method,
                  enabled: !busy,
                  onChanged: (m) => setState(() => _method = m),
                ),
                const SizedBox(height: 18),
                if (_method == AuthMethod.apiKey)
                  AppTextField(
                    label: context.l10n.connectApiKeyLabel,
                    controller: _apiKey,
                    enabled: !busy,
                    obscureText: true,
                    prefixIcon: AppIcons.lock,
                  )
                else ...[
                  AppTextField(
                    label: context.l10n.connectUsernameLabel,
                    controller: _username,
                    enabled: !busy,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: context.l10n.connectPasswordLabel,
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
                    label: busy
                        ? context.l10n.connectBusy
                        : context.l10n.connectAction,
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
