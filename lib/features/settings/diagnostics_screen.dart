import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n.dart';
import '../../app/theme/app_icons.dart';
import '../../core/platform/render_capabilities.dart';

/// Read-only diagnostics: what the app detected about this device and how the
/// reader is sizing its decodes. Opened from Settings. The GPU max texture size
/// is the per-device probe result that raises the reader's focused-page cap.
class DiagnosticsScreen extends ConsumerWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final maxTex = ref.watch(renderCapabilitiesProvider);
    final probed = maxTex != kFallbackMaxTextureDim;
    final size = media.size;
    final dpr = media.devicePixelRatio;

    final l10n = context.l10n;
    final rows = <(String, String)>[
      (l10n.diagGpuMaxTexture, '$maxTex px'),
      (
        l10n.diagProbeStatus,
        probed ? 'probed' : 'fallback (probing or unsupported)'
      ),
      (l10n.diagFocusedPageCap, '${focusTextureCap(maxTex)} px'),
      (l10n.diagReaderSampling, 'FilterQuality.high'),
      (l10n.diagPlatform, Platform.operatingSystem),
      (l10n.diagLogicalScreen,
          '${size.width.round()} x ${size.height.round()} pt'),
      (l10n.diagDevicePixelRatio, dpr.toStringAsFixed(2)),
      (
        l10n.diagScreenPixels,
        '${(size.width * dpr).round()} x ${(size.height * dpr).round()} px'
      ),
      (l10n.diagLogicalCpus, '${Platform.numberOfProcessors}'),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(AppIcons.back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(context.l10n.settingsDiagnostics),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(label, style: theme.textTheme.bodyMedium),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    value,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
