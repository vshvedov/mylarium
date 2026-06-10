import 'package:flutter/material.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/app_icons.dart';
import '../../../data/comicvine/comic_vine_models.dart';
import '../../library/widgets/detail_header.dart' show DetailPill;

/// Structured Comic Vine details for a matched series volume.
class ComicVineVolumeView extends StatelessWidget {
  const ComicVineVolumeView({super.key, required this.data});

  final ComicVineVolumeData data;

  @override
  Widget build(BuildContext context) {
    return _DetailsCard(
      summary: _strip(data.description) ?? data.deck,
      pills: [
        if (data.publisher != null && data.publisher!.isNotEmpty)
          data.publisher!,
        if (data.startYear != null && data.startYear!.isNotEmpty)
          data.startYear!,
        if (data.issueCount != null)
          data.issueCount == 1 ? '1 issue' : '${data.issueCount} issues',
      ],
      characters: data.characters,
      creators: data.creators,
    );
  }
}

/// Structured Comic Vine details for a matched book issue.
class ComicVineIssueView extends StatelessWidget {
  const ComicVineIssueView({super.key, required this.data});

  final ComicVineIssueData data;

  @override
  Widget build(BuildContext context) {
    return _DetailsCard(
      summary: _strip(data.description) ?? data.deck,
      pills: [
        if (data.coverDate != null && data.coverDate!.isNotEmpty)
          data.coverDate!,
        if (data.issueNumber != null && data.issueNumber!.isNotEmpty)
          'No. ${data.issueNumber}',
      ],
      characters: data.characters,
      creators: data.creators,
      storyArcs: data.storyArcs,
    );
  }
}

String? _strip(String? html) {
  if (html == null || html.isEmpty) return null;
  final s = stripHtml(html);
  return s.isEmpty ? null : s;
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({
    required this.summary,
    required this.pills,
    required this.characters,
    required this.creators,
    this.storyArcs = const [],
  });

  final String? summary;
  final List<String> pills;
  final List<String> characters;
  final List<({String name, String role})> creators;
  final List<String> storyArcs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final roles = groupCreatorsByRole(creators);
    final shownChars = characters.take(12).toList();
    final overflow = characters.length - shownChars.length;

    return _Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COMIC VINE',
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          if (summary != null) ...[
            const SizedBox(height: 10),
            Text(
              summary!,
              maxLines: 14,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ],
          if (pills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final p in pills) DetailPill(p)],
            ),
          ],
          if (shownChars.isNotEmpty) ...[
            const SizedBox(height: 16),
            _Label(context.l10n.comicVineCharacters),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in shownChars) DetailPill(c),
                if (overflow > 0)
                  DetailPill(context.l10n.comicVineMore(overflow),
                      accent: true),
              ],
            ),
          ],
          if (roles.isNotEmpty) ...[
            const SizedBox(height: 16),
            _Label(context.l10n.comicVineCreators),
            const SizedBox(height: 6),
            for (final group in roles) _CreditLine(group: group),
          ],
          if (storyArcs.isNotEmpty) ...[
            const SizedBox(height: 16),
            _Label(context.l10n.comicVineStoryArcs),
            const SizedBox(height: 6),
            Text(
              storyArcs.join(', '),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CreditLine extends StatelessWidget {
  const _CreditLine({required this.group});

  final ({String role, List<String> names}) group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${group.role}: ',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: group.names.join(', '),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(
      context,
    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
  );
}

/// Loading state: the bordered card with a slim progress strip.
class ComicVineLoadingView extends StatelessWidget {
  const ComicVineLoadingView({super.key});

  @override
  Widget build(BuildContext context) => _Container(
    child: Row(
      children: [
        Text(
          'COMIC VINE',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(999)),
            child: LinearProgressIndicator(minHeight: 4),
          ),
        ),
      ],
    ),
  );
}

/// Error state with a retry affordance.
class ComicVineErrorView extends StatelessWidget {
  const ComicVineErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _Container(
      child: Row(
        children: [
          Icon(AppIcons.noSource, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(AppIcons.refresh, size: 18),
            label: Text(context.l10n.retry),
          ),
        ],
      ),
    );
  }
}

/// Shared bordered container matching the Comic Vine panel's other states.
class _Container extends StatelessWidget {
  const _Container({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: double.infinity, child: child);
}
