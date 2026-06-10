import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.comicVineConnected)));
    Navigator.maybePop(context);
  }

  Future<void> _clear() async {
    await ref.read(comicVineKeyControllerProvider).clear();
    _controller.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.comicVineDisconnected)));
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
              context.l10n.comicVineDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.comicVineGetKey,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _controller,
              label: context.l10n.connectApiKeyLabel,
              hint: context.l10n.comicVineKeyHint,
              prefixIcon: AppIcons.lock,
              obscureText: true,
              autofocus: !connected,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 20),
            AppButton(
                label: context.l10n.save,
                icon: AppIcons.check,
                onPressed: _save),
            if (connected) ...[
              const SizedBox(height: 8),
              AppButton(
                kind: AppButtonKind.text,
                label: context.l10n.comicVineDisconnect,
                icon: AppIcons.delete,
                onPressed: _clear,
              ),
            ],
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.comicVineShowOnDetail),
              subtitle: Text(context.l10n.comicVineShowOnDetailSubtitle),
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
