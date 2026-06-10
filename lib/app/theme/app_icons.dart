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
  static const _fillFamily = 'PhosphorFill';
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
  static const info =
      IconData(0xe2ce, fontFamily: _family, fontPackage: _package); // info
  static const warning = IconData(0xe4e0,
      fontFamily: _family, fontPackage: _package); // warning

  // Source kinds (onboarding picker)
  static const sourceKomga =
      IconData(0xe1aa, fontFamily: _family, fontPackage: _package); // cloud
  static const sourceKavita =
      IconData(0xe1de, fontFamily: _family, fontPackage: _package); // database
  static const sourceLocal = IconData(0xe2a0,
      fontFamily: _family, fontPackage: _package); // hardDrives
  static const sourceFolder =
      IconData(0xe24a, fontFamily: _family, fontPackage: _package); // folder
  static const sdCard =
      IconData(0xe664, fontFamily: _family, fontPackage: _package); // simCard

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
  static const lockFill =
      IconData(0xe2fa, fontFamily: _fillFamily, fontPackage: _package); // lock
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

  // Ratings (T3): an outline star and its filled counterpart (same glyph,
  // different Phosphor weight font).
  static const star =
      IconData(0xe46a, fontFamily: _family, fontPackage: _package); // star
  static const starFill =
      IconData(0xe46a, fontFamily: _fillFamily, fontPackage: _package); // star

  // Read-state actions (T3).
  static const markRead = IconData(0xe184,
      fontFamily: _family, fontPackage: _package); // checkCircle
  static const markUnread = IconData(0xe18a,
      fontFamily: _family, fontPackage: _package); // circle

  // Preview (open a chapter without marking it read/in-progress).
  static const preview =
      IconData(0xe220, fontFamily: _family, fontPackage: _package); // eye

  // Home pins (curation): an outline pin, its filled counterpart (same glyph,
  // fill weight), and the slashed glyph used for the "Unpin" action.
  static const pin =
      IconData(0xe3e2, fontFamily: _family, fontPackage: _package); // pushPin
  static const pinFill = IconData(0xe3e2,
      fontFamily: _fillFamily, fontPackage: _package); // pushPin
  static const unpin = IconData(0xe3e4,
      fontFamily: _family, fontPackage: _package); // pushPinSlash

  // Home rail headers (one per category).
  static const recentlyAdded =
      IconData(0xe6a2, fontFamily: _family, fontPackage: _package); // sparkle
  static const series =
      IconData(0xe466, fontFamily: _family, fontPackage: _package); // stack
  static const recentlyRead = IconData(0xe1a0,
      fontFamily: _family, fontPackage: _package); // clockCounterClockwise

  // Drag handle for reorderable lists.
  static const dragHandle = IconData(0xeae2,
      fontFamily: _family, fontPackage: _package); // dotsSixVertical

  // Reader
  static const read =
      IconData(0xe0e6, fontFamily: _family, fontPackage: _package); // bookOpen
  static const readingMode =
      IconData(0xe0e6, fontFamily: _family, fontPackage: _package); // bookOpen
  static const fit =
      IconData(0xe0a2, fontFamily: _family, fontPackage: _package); // arrowsOut
  static const options = IconData(0xe434,
      fontFamily: _family, fontPackage: _package); // slidersHorizontal
  static const colorCorrection =
      IconData(0xe18c, fontFamily: _family, fontPackage: _package); // circleHalf
  static const nudge =
      IconData(0xe83c, fontFamily: _family, fontPackage: _package); // swap
  static const prevChapter =
      IconData(0xe5a4, fontFamily: _family, fontPackage: _package); // skipBack
  static const nextChapter = IconData(0xe5a6,
      fontFamily: _family, fontPackage: _package); // skipForward
  static const readingDirection = IconData(0xe0a0,
      fontFamily: _family, fontPackage: _package); // arrowsLeftRight
  static const close =
      IconData(0xe4f6, fontFamily: _family, fontPackage: _package); // x

  // Page capture (reader) + the personal gallery destination.
  static const capture = IconData(0xe69a,
      fontFamily: _family, fontPackage: _package); // selection
  static const gallery =
      IconData(0xe836, fontFamily: _family, fontPackage: _package); // images

  // Offline / downloads
  static const download = IconData(0xe20c,
      fontFamily: _family, fontPackage: _package); // downloadSimple
  // "Downloaded" reads as a filled down-arrow (NOT a check) so it never
  // collides with the green read-check. See DownloadBadge.
  static const downloaded = IconData(0xe20c,
      fontFamily: _fillFamily, fontPackage: _package); // downloadSimple (fill)
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
  static const export = IconData(0xeaf0,
      fontFamily: _family, fontPackage: _package); // export

  // Local files / import
  static const importComics =
      IconData(0xe236, fontFamily: _family, fontPackage: _package); // filePlus
  static const localBook =
      IconData(0xeb2a, fontFamily: _family, fontPackage: _package); // fileArchive
  static const link =
      IconData(0xe2e2, fontFamily: _family, fontPackage: _package); // link

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
