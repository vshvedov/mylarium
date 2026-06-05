import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_icons.dart';
import '../../../app/widgets/app_button.dart';
import '../../../app/widgets/app_text_field.dart';
import 'comic_vine_providers.dart';

/// Settings for the optional Comic Vine integration: paste (or clear) the API
/// key. The key is stored in the device Keychain/Keystore. Comic Vine stays off
/// until a key is set.
class ComicVineSettingsScreen extends ConsumerStatefulWidget {
  const ComicVineSettingsScreen({super.key});

  @override
  ConsumerState<ComicVineSettingsScreen> createState() =>
      _ComicVineSettingsScreenState();
}

class _ComicVineSettingsScreenState
    extends ConsumerState<ComicVineSettingsScreen> {
  final _controller = TextEditingController();
  bool _loaded = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final key = _controller.text.trim();
    if (key.isEmpty) return;
    await ref.read(comicVineKeyControllerProvider).save(key);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Comic Vine connected')));
    Navigator.maybePop(context);
  }

  Future<void> _clear() async {
    await ref.read(comicVineKeyControllerProvider).clear();
    _controller.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Comic Vine disconnected')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Prefill once with any existing key so the user can see/replace it.
    final existing = ref.watch(comicVineApiKeyProvider).valueOrNull;
    if (!_loaded && existing != null) {
      _controller.text = existing;
      _loaded = true;
    }
    final connected = existing != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Comic Vine')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Optional. Comic Vine adds rich details (descriptions, characters, '
              'creators and more) to series and issues. It is off until you add '
              'a key, and only then are titles sent to Comic Vine to look them '
              'up. Your key is stored in the device keychain.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Get a free key at comicvine.gamespot.com/api',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _controller,
              label: 'API key',
              hint: 'Paste your Comic Vine API key',
              prefixIcon: AppIcons.lock,
              obscureText: true,
              autofocus: !connected,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 20),
            AppButton(label: 'Save', icon: AppIcons.check, onPressed: _save),
            if (connected) ...[
              const SizedBox(height: 8),
              AppButton(
                kind: AppButtonKind.text,
                label: 'Disconnect',
                icon: AppIcons.delete,
                onPressed: _clear,
              ),
            ],
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show on detail pages'),
              subtitle: const Text(
                'Turn off to hide the Comic Vine section everywhere.',
              ),
              value:
                  !(ref.watch(comicVineDismissedProvider).valueOrNull ?? false),
              onChanged: (show) => ref
                  .read(comicVineKeyControllerProvider)
                  .setDismissed(!show),
            ),
          ],
        ),
      ),
    );
  }
}
