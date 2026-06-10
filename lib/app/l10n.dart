import 'package:flutter/widgets.dart';
import 'package:mylarium/l10n/gen/app_localizations.dart';

/// Convenience access to the generated [AppLocalizations] from any
/// [BuildContext] via `context.l10n`.
///
/// The generated getter is nullable (`nullable-getter: true` in `l10n.yaml`),
/// which it returns null when no [AppLocalizations] delegate is present in the
/// widget tree. That happens in the large existing widget-test suite, where
/// most tests pump a bare `MaterialApp(home: ...)` without the localization
/// delegates. To keep those tests green without editing them, fall back to the
/// English lookup (`lookupAppLocalizations(const Locale('en'))`) when the
/// delegate is absent. In the real app the delegates are always registered, so
/// the fallback never fires at runtime.
extension L10nX on BuildContext {
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ?? lookupAppLocalizations(const Locale('en'));
}
