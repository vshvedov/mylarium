import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/widgets/app_button.dart';
import 'connection_result.dart';
import 'onboarding_controller.dart';

/// First-run screen: enter a Komga server URL and credentials, validate, and
/// persist the connection. On success it routes to the debug source list.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.initialUrl});

  /// Prefilled when re-authenticating a source whose secret went missing.
  final String? initialUrl;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
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

    ref.listen(onboardingControllerProvider, (_, next) {
      final result = next.valueOrNull;
      if (result is ConnSuccess) {
        // Land on the library home after connecting (the debug sources screen
        // is reachable from home -> settings).
        context.go('/');
      }
    });

    final busy = state.isLoading;
    final result = state.valueOrNull;
    final error = (result == null || result is ConnSuccess)
        ? null
        : _errorFor(result);

    return Scaffold(
      appBar: AppBar(title: const Text('Connect to Komga')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _url,
            enabled: !busy,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'Server URL',
              hintText: 'https://komga.example.com',
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<AuthMethod>(
            segments: const [
              ButtonSegment(value: AuthMethod.apiKey, label: Text('API key')),
              ButtonSegment(value: AuthMethod.basic, label: Text('Password')),
            ],
            selected: {_method},
            showSelectedIcon: false,
            onSelectionChanged:
                busy ? null : (s) => setState(() => _method = s.first),
          ),
          const SizedBox(height: 16),
          if (_method == AuthMethod.apiKey)
            TextField(
              controller: _apiKey,
              enabled: !busy,
              obscureText: true,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'API key'),
            )
          else ...[
            TextField(
              controller: _username,
              enabled: !busy,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              enabled: !busy,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
          ],
          if (error != null) ...[
            const SizedBox(height: 16),
            Text(
              error,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          AppButton(
            label: busy ? 'Connecting...' : 'Connect',
            onPressed: busy ? null : _connect,
          ),
        ],
      ),
    );
  }
}
