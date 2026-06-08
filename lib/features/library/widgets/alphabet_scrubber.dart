import 'package:flutter/material.dart';

/// A thin vertical A-Z (plus `#`) rail pinned to the trailing edge of the browse
/// grid. Tapping or dragging a letter reports it via [onLetter]; the grid then
/// jumps to the first series at that letter. Letters with no series are dimmed
/// and ignore taps. A single gesture handler maps the touch's vertical position
/// to a letter, so both a tap and a drag-scrub work.
class AlphabetScrubber extends StatelessWidget {
  const AlphabetScrubber({
    super.key,
    required this.present,
    required this.onLetter,
  });

  /// The uppercase letters (and `#`) that have at least one series; others are
  /// shown dimmed and are not selectable.
  final Set<String> present;
  final ValueChanged<String> onLetter;

  /// `#` (non-alphabetic) first, then A-Z, top to bottom.
  static const List<String> letters = [
    '#', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', //
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  ];

  void _handle(double dy, double height) {
    if (height <= 0) return;
    final i = (dy / height * letters.length)
        .floor()
        .clamp(0, letters.length - 1);
    final letter = letters[i];
    if (present.contains(letter)) onLetter(letter);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (d) => _handle(d.localPosition.dy, height),
          onVerticalDragStart: (d) => _handle(d.localPosition.dy, height),
          onVerticalDragUpdate: (d) => _handle(d.localPosition.dy, height),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final letter in letters)
                  Expanded(
                    child: Center(
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1,
                          fontWeight: FontWeight.w600,
                          color: present.contains(letter)
                              ? scheme.onSurfaceVariant
                              : scheme.onSurfaceVariant.withValues(alpha: 0.25),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The uppercase first-letter bucket for a series, by its `titleSort`: an A-Z
/// letter, or `#` for anything non-alphabetic (digits, symbols, empty).
String letterBucket(String titleSort) {
  if (titleSort.isEmpty) return '#';
  final c = titleSort[0].toUpperCase();
  return RegExp('[A-Z]').hasMatch(c) ? c : '#';
}
