import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_icons.dart';
import '../../app/widgets/app_button.dart';
import '../../app/widgets/app_text_field.dart';
import 'connection_result.dart';
import 'kavita_connect_controller.dart';
import '../../app/widgets/brand_mark.dart';

/// Enter a Kavita server URL and API key, validate against the live server, and
/// persist the connection. Reached from the onboarding picker, or deep-linked
/// for re-auth (with [initialUrl] prefilled). On success it routes to the
/// library home.
class KavitaConnectScreen extends ConsumerStatefulWidget {
  const KavitaConnectScreen({super.key, this.initialUrl});

  /// Prefilled when re-authenticating a source whose secret went missing.
  final String? initialUrl;

  @override
  ConsumerState<KavitaConnectScreen> createState() =>
      _KavitaConnectScreenState();
}

class _KavitaConnectScreenState extends ConsumerState<KavitaConnectScreen> {
  late final TextEditingController _url =
      TextEditingController(text: widget.initialUrl ?? '');
  final TextEditingController _apiKey = TextEditingController();

  @override
  void dispose() {
    _url.dispose();
    _apiKey.dispose();
    super.dispose();
  }

  void _connect() {
    ref.read(kavitaConnectControllerProvider.notifier).connect(
          url: _url.text,
          apiKey: _apiKey.text,
        );
  }

  String _errorFor(ConnectionResult r) => switch (r) {
        ConnInvalidUrl() =>
          'Enter a valid server URL (for example https://kavita.example.com).',
        ConnUnreachable() =>
          'Could not reach the server. Check the URL and your network.',
        ConnUnauthorized() => 'That API key was not accepted.',
        ConnMissingRoles(:final missing) =>
          'Your Kavita account is missing the ${missing.join(' and ')} '
              'role. Ask your server admin to enable it.',
        ConnVersionTooOldForApiKey(:final version) =>
          'This server${version == null ? '' : ' (v$version)'} is not '
              'supported.',
        ConnTlsError() =>
          'The server security certificate could not be verified.',
        ConnUnknown(:final message) => message,
        ConnSuccess() => '',
      };

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kavitaConnectControllerProvider);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    ref.listen(kavitaConnectControllerProvider, (_, next) {
      if (next.valueOrNull is ConnSuccess) {
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
                  'Connect to Kavita',
                  textAlign: TextAlign.center,
                  style: text.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Point Mylarium at your server and paste your API key.',
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),
                AppTextField(
                  label: 'Server URL',
                  controller: _url,
                  enabled: !busy,
                  keyboardType: TextInputType.url,
                  hint: 'https://kavita.example.com',
                  prefixIcon: AppIcons.sourceKavita,
                ),
                const SizedBox(height: 18),
                AppTextField(
                  label: 'API key',
                  controller: _apiKey,
                  enabled: !busy,
                  obscureText: true,
                  prefixIcon: AppIcons.lock,
                ),
                const SizedBox(height: 8),
                Text(
                  'Find your API key in Kavita under '
                  'Settings, Account, 3rd Party Clients.',
                  style: text.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
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
