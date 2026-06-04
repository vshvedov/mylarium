import 'package:flutter/widgets.dart';

/// Every icon in the app is a Phosphor icon (https://phosphoricons.com),
/// declared once here as a semantic constant. Do NOT use Flutter's Material
/// `Icons.*` anywhere (see CLAUDE.md "Iconography").
///
/// We build [IconData] directly against Phosphor's bundled font rather than the
/// `phosphor_flutter` Dart API: that package's `PhosphorIconData extends
/// IconData`, which no longer compiles now that Flutter made `IconData` a final
/// class. Depending on the package still bundles the font, so the glyphs render.
/// Codepoints are the regular weight from `phosphor_flutter`.
abstract final class AppIcons {
  static const _family = 'PhosphorRegular';
  static const _package = 'phosphor_flutter';

  // Navigation / chrome
  static const back =
      IconData(0xe058, fontFamily: _family, fontPackage: _package); // arrowLeft
  static const search = IconData(0xe30c,
      fontFamily: _family, fontPackage: _package); // magnifyingGlass
  static const sort = IconData(0xe444,
      fontFamily: _family, fontPackage: _package); // sortAscending
  static const browse = IconData(0xe464,
      fontFamily: _family, fontPackage: _package); // squaresFour
  static const settings =
      IconData(0xe272, fontFamily: _family, fontPackage: _package); // gearSix

  // Library areas
  static const libraries =
      IconData(0xe758, fontFamily: _family, fontPackage: _package); // books
  static const collections =
      IconData(0xe0ec, fontFamily: _family, fontPackage: _package); // bookmarks
  static const readList = IconData(0xe2f2,
      fontFamily: _family, fontPackage: _package); // listBullets
  static const storage = IconData(0xe2a0,
      fontFamily: _family, fontPackage: _package); // hardDrives
  static const sources =
      IconData(0xe1de, fontFamily: _family, fontPackage: _package); // database

  // Locks
  static const lock =
      IconData(0xe2fa, fontFamily: _family, fontPackage: _package); // lock
  static const lockOpen =
      IconData(0xe306, fontFamily: _family, fontPackage: _package); // lockOpen

  // Generic actions
  static const refresh = IconData(0xe036,
      fontFamily: _family, fontPackage: _package); // arrowClockwise
  static const delete =
      IconData(0xe4a6, fontFamily: _family, fontPackage: _package); // trash
  static const add =
      IconData(0xe3d4, fontFamily: _family, fontPackage: _package); // plus
  static const check =
      IconData(0xe182, fontFamily: _family, fontPackage: _package); // check
  static const checkboxOn = IconData(0xe186,
      fontFamily: _family, fontPackage: _package); // checkSquare
  static const checkboxOff =
      IconData(0xe45e, fontFamily: _family, fontPackage: _package); // square

  // Reader
  static const read =
      IconData(0xe0e6, fontFamily: _family, fontPackage: _package); // bookOpen
  static const readingMode =
      IconData(0xe0e6, fontFamily: _family, fontPackage: _package); // bookOpen
  static const fit =
      IconData(0xe0a2, fontFamily: _family, fontPackage: _package); // arrowsOut
  static const options = IconData(0xe434,
      fontFamily: _family, fontPackage: _package); // slidersHorizontal
  static const nudge =
      IconData(0xe83c, fontFamily: _family, fontPackage: _package); // swap

  // Offline / downloads
  static const download = IconData(0xe20c,
      fontFamily: _family, fontPackage: _package); // downloadSimple
  static const downloaded = IconData(0xe184,
      fontFamily: _family, fontPackage: _package); // checkCircle
  static const savedOffline =
      IconData(0xe1b0, fontFamily: _family, fontPackage: _package); // cloudCheck
  static const streaming =
      IconData(0xe1aa, fontFamily: _family, fontPackage: _package); // cloud
  static const offline =
      IconData(0xe1b0, fontFamily: _family, fontPackage: _package); // cloudCheck
  static const noSource =
      IconData(0xe1b6, fontFamily: _family, fontPackage: _package); // cloudSlash
  static const brokenImage = IconData(0xe7a8,
      fontFamily: _family, fontPackage: _package); // imageBroken
  static const coverPlaceholder =
      IconData(0xe2ca, fontFamily: _family, fontPackage: _package); // image

  // Stats / reading insights
  static const stats =
      IconData(0xe150, fontFamily: _family, fontPackage: _package); // chartBar
  static const trend = IconData(0xe156,
      fontFamily: _family, fontPackage: _package); // chartLineUp
  static const streak =
      IconData(0xe242, fontFamily: _family, fontPackage: _package); // fire
  static const heatmap = IconData(0xe10a,
      fontFamily: _family, fontPackage: _package); // calendarBlank
  static const clock =
      IconData(0xe19a, fontFamily: _family, fontPackage: _package); // clock
  static const share = IconData(0xe408,
      fontFamily: _family, fontPackage: _package); // shareNetwork

  // Badges (milestones)
  static const badge =
      IconData(0xe320, fontFamily: _family, fontPackage: _package); // medal
  static const trophy =
      IconData(0xe67e, fontFamily: _family, fontPackage: _package); // trophy
  static const flame =
      IconData(0xe624, fontFamily: _family, fontPackage: _package); // flame
  static const pages =
      IconData(0xe758, fontFamily: _family, fontPackage: _package); // books
}
