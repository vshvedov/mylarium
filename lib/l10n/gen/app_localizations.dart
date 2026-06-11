import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Title of the banner shown when the on-disk database could not be opened and the app fell back to in-memory storage.
  ///
  /// In en, this message translates to:
  /// **'Storage unavailable'**
  String get storageUnavailableTitle;

  /// Body text of the ephemeral-storage warning banner.
  ///
  /// In en, this message translates to:
  /// **'Mylarium could not open its local storage and is running in memory only. Anything you connect or read will be lost when the app closes. Try restarting; if this keeps happening, check that the device has free space.'**
  String get storageUnavailableBody;

  /// Fallback shown by the router when no route matches.
  ///
  /// In en, this message translates to:
  /// **'Route not found: {uri}'**
  String routeNotFound(String uri);

  /// Subtitle on the first-run welcome screen.
  ///
  /// In en, this message translates to:
  /// **'Your comics and manga, beautifully offline.'**
  String get onboardingTagline;

  /// Section header above the source picker on onboarding.
  ///
  /// In en, this message translates to:
  /// **'Choose a source'**
  String get onboardingChooseSource;

  /// Subtitle of the Komga source option card.
  ///
  /// In en, this message translates to:
  /// **'Connect to your self-hosted server'**
  String get onboardingKomgaSubtitle;

  /// Subtitle of the Kavita source option card.
  ///
  /// In en, this message translates to:
  /// **'Another self-hosted library server'**
  String get onboardingKavitaSubtitle;

  /// Title of the local-files source option card.
  ///
  /// In en, this message translates to:
  /// **'Local files'**
  String get onboardingLocalTitle;

  /// Subtitle of the local-files source option card.
  ///
  /// In en, this message translates to:
  /// **'Read comics stored on this device'**
  String get onboardingLocalSubtitle;

  /// Footer note below the source picker on onboarding.
  ///
  /// In en, this message translates to:
  /// **'More sources are on the way. You can add or switch sources anytime in Settings.'**
  String get onboardingMoreSourcesHint;

  /// Screen-reader label for a disabled coming-soon source card.
  ///
  /// In en, this message translates to:
  /// **'{title}, coming soon'**
  String sourceComingSoonSemantic(String title);

  /// Chip shown on a coming-soon source card.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get sourceSoonChip;

  /// Text field label for a server URL on the connect screens.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get connectServerUrlLabel;

  /// Label for the API key field / auth method on the connect screens.
  ///
  /// In en, this message translates to:
  /// **'API key'**
  String get connectApiKeyLabel;

  /// Label for the password field / auth method on the connect screens.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get connectPasswordLabel;

  /// Label for the username field on the connect screens.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get connectUsernameLabel;

  /// Primary button label on the connect screens.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connectAction;

  /// Primary button label while a connection attempt is in progress.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connectBusy;

  /// Connect error: the server could not be reached.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server. Check the URL and your network.'**
  String get connectUnreachable;

  /// Connect error: the TLS certificate could not be verified.
  ///
  /// In en, this message translates to:
  /// **'The server security certificate could not be verified.'**
  String get connectTlsError;

  /// Title of the Komga connect screen.
  ///
  /// In en, this message translates to:
  /// **'Connect to Komga'**
  String get komgaConnectTitle;

  /// Subtitle of the Komga connect screen.
  ///
  /// In en, this message translates to:
  /// **'Point Mylarium at your server and sign in.'**
  String get komgaConnectSubtitle;

  /// Komga connect error: the entered URL is invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid server URL (for example https://komga.example.com).'**
  String get komgaConnectInvalidUrl;

  /// Komga connect error: credentials were rejected.
  ///
  /// In en, this message translates to:
  /// **'Incorrect credentials.'**
  String get komgaConnectUnauthorized;

  /// Komga connect error: the account lacks required roles.
  ///
  /// In en, this message translates to:
  /// **'Your Komga account is missing the {roles} role. Ask your server admin to enable it.'**
  String komgaConnectMissingRoles(String roles);

  /// Komga connect error: server too old for API keys. The version placeholder is an already-formatted parenthesised version string or empty.
  ///
  /// In en, this message translates to:
  /// **'This server{version} is too old for API keys. Use a username and password instead.'**
  String komgaConnectVersionTooOld(String version);

  /// Title of the Kavita connect screen.
  ///
  /// In en, this message translates to:
  /// **'Connect to Kavita'**
  String get kavitaConnectTitle;

  /// Subtitle of the Kavita connect screen.
  ///
  /// In en, this message translates to:
  /// **'Point Mylarium at your server and paste your API key.'**
  String get kavitaConnectSubtitle;

  /// Helper text under the Kavita API key field.
  ///
  /// In en, this message translates to:
  /// **'Find your API key in Kavita under Settings, Account, 3rd Party Clients.'**
  String get kavitaConnectApiKeyHint;

  /// Kavita connect error: the entered URL is invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid server URL (for example https://kavita.example.com).'**
  String get kavitaConnectInvalidUrl;

  /// Kavita connect error: the API key was rejected.
  ///
  /// In en, this message translates to:
  /// **'That API key was not accepted.'**
  String get kavitaConnectUnauthorized;

  /// Kavita connect error: the account lacks required roles.
  ///
  /// In en, this message translates to:
  /// **'Your Kavita account is missing the {roles} role. Ask your server admin to enable it.'**
  String kavitaConnectMissingRoles(String roles);

  /// Kavita connect error: server version not supported. The version placeholder is an already-formatted parenthesised version string or empty.
  ///
  /// In en, this message translates to:
  /// **'This server{version} is not supported.'**
  String kavitaConnectVersionUnsupported(String version);

  /// Title used for the Sources sheet, button tooltips, and rows.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get sourcesTitle;

  /// Title of the gallery screen and its home tooltip.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryTitle;

  /// Title of the reading-stats screen and its home tooltip.
  ///
  /// In en, this message translates to:
  /// **'Reading stats'**
  String get statsTitle;

  /// Title of the settings screen and its home row.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Title of the storage screen and its home/settings rows.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storageTitle;

  /// Title of the libraries list.
  ///
  /// In en, this message translates to:
  /// **'Libraries'**
  String get librariesTitle;

  /// Home row title leading to collections and read lists.
  ///
  /// In en, this message translates to:
  /// **'Collections & read lists'**
  String get collectionsAndReadListsTitle;

  /// Header of the appearance/theme section in the home settings sheet.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// Light theme toggle label.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Dark theme toggle label.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// System (auto) theme toggle label.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get themeAuto;

  /// E-ink theme toggle label.
  ///
  /// In en, this message translates to:
  /// **'E-ink'**
  String get themeEink;

  /// Tooltip for the browse-all action on home.
  ///
  /// In en, this message translates to:
  /// **'Browse all'**
  String get homeBrowseAll;

  /// Subtitle of the Settings row in the home settings sheet.
  ///
  /// In en, this message translates to:
  /// **'Home rows and more'**
  String get homeSettingsSubtitle;

  /// Subtitle of the Sources row in the home settings sheet.
  ///
  /// In en, this message translates to:
  /// **'Switch, add, or remove servers'**
  String get homeSourcesSubtitle;

  /// Empty state when no source is connected.
  ///
  /// In en, this message translates to:
  /// **'No source connected.'**
  String get homeNoSource;

  /// Button to start onboarding when no source is connected.
  ///
  /// In en, this message translates to:
  /// **'Connect a server'**
  String get homeConnectServer;

  /// Shown when every home rail resolved empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show yet. Pull to refresh.'**
  String get homeEmpty;

  /// Home rail title: pinned items.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get railPinned;

  /// Home rail title: keep reading / on deck.
  ///
  /// In en, this message translates to:
  /// **'Keep reading'**
  String get railKeepReading;

  /// Home rail title: recently added chapters.
  ///
  /// In en, this message translates to:
  /// **'Recently added chapters'**
  String get railRecentlyAddedChapters;

  /// Home rail title: recently added series.
  ///
  /// In en, this message translates to:
  /// **'Recently added series'**
  String get railRecentlyAddedSeries;

  /// Home rail title: recently updated series.
  ///
  /// In en, this message translates to:
  /// **'Recently updated series'**
  String get railRecentlyUpdatedSeries;

  /// Home rail title: downloaded items.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get railDownloaded;

  /// Home rail title: recently read items.
  ///
  /// In en, this message translates to:
  /// **'Recently read'**
  String get railRecentlyRead;

  /// Generic Cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Generic Remove button.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Generic Close button.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Generic Refresh button.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Empty state in the sources sheet.
  ///
  /// In en, this message translates to:
  /// **'No sources connected yet.'**
  String get sourcesEmpty;

  /// Kind label for a folder (SAF tree) source.
  ///
  /// In en, this message translates to:
  /// **'Folder library'**
  String get sourceKindFolderLibrary;

  /// Subtitle for the local-files source row.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get sourceSubtitleOnDevice;

  /// Subtitle for an in-place folder source row.
  ///
  /// In en, this message translates to:
  /// **'Folder library - in place'**
  String get sourceSubtitleFolderInPlace;

  /// Tooltip on the remove-source icon button.
  ///
  /// In en, this message translates to:
  /// **'Remove source'**
  String get sourceRemoveTooltip;

  /// Title of the remove-source confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Remove {label}?'**
  String sourceRemoveTitle(String label);

  /// Body of the remove-folder confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'This forgets the folder library. The files on the card or folder are untouched, and reading history is kept.'**
  String get sourceRemoveFolderBody;

  /// Body of the remove-server confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'This disconnects the source and deletes its stored credentials. Downloaded files for this source are removed by storage cleanup.'**
  String get sourceRemoveServerBody;

  /// Subtitle of the local-files add row in the sources sheet.
  ///
  /// In en, this message translates to:
  /// **'Import comics from this device'**
  String get sourceLocalImportSubtitle;

  /// Row to add a folder-tree library source.
  ///
  /// In en, this message translates to:
  /// **'Add folder library'**
  String get sourceAddFolder;

  /// Subtitle of the add-folder source row.
  ///
  /// In en, this message translates to:
  /// **'Read comics from a folder or SD card, in place'**
  String get sourceAddFolderSubtitle;

  /// Row to add another source (opens onboarding).
  ///
  /// In en, this message translates to:
  /// **'Add a source'**
  String get sourceAddSource;

  /// Tooltip on the app-bar status dot when the server is online.
  ///
  /// In en, this message translates to:
  /// **'Server online - tap for details'**
  String get serverOnlineTooltip;

  /// Tooltip on the app-bar status dot when the server is unreachable.
  ///
  /// In en, this message translates to:
  /// **'Server unreachable - tap for details'**
  String get serverUnreachableTooltip;

  /// Tooltip on the app-bar status dot while checking reachability.
  ///
  /// In en, this message translates to:
  /// **'Checking server...'**
  String get serverCheckingTooltip;

  /// Error shown when server details fail to load.
  ///
  /// In en, this message translates to:
  /// **'Could not load server details.'**
  String get serverDetailsLoadError;

  /// Body shown in the details dialog when the server is offline.
  ///
  /// In en, this message translates to:
  /// **'Server unreachable. Check your connection and try Refresh.'**
  String get serverUnreachableBody;

  /// Server details section header (rendered uppercased).
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get serverSectionConnection;

  /// Server details section header and fallback server name (rendered uppercased as a header).
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get serverSectionServer;

  /// Server details section header (rendered uppercased).
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get serverSectionAccount;

  /// Server details section header (rendered uppercased).
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get serverSectionContent;

  /// Server details row label: URL.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get serverRowUrl;

  /// Server details row label: Version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get serverRowVersion;

  /// Server details row label: User.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get serverRowUser;

  /// Server details row label: Roles.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get serverRowRoles;

  /// Server details row label: Libraries.
  ///
  /// In en, this message translates to:
  /// **'Libraries'**
  String get serverRowLibraries;

  /// Server details row label: Series.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get serverRowSeries;

  /// Server details row label: Books.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get serverRowBooks;

  /// Status pill text when online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get statusOnline;

  /// Status pill text when offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get statusOffline;

  /// Sync section header in the server details dialog.
  ///
  /// In en, this message translates to:
  /// **'SYNC'**
  String get syncSectionTitle;

  /// Count of pending write-backs waiting to sync.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 update waiting to sync} other{{count} updates waiting to sync}}'**
  String syncUpdatesWaiting(int count);

  /// Count of failed write-backs.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 failed} other{{count} failed}}'**
  String syncFailedCount(int count);

  /// Button to retry failed sync write-backs.
  ///
  /// In en, this message translates to:
  /// **'Retry now'**
  String get syncRetryNow;

  /// Count of books in a series or library.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 book} other{{count} books}}'**
  String bookCount(int count);

  /// Read action for a book that has no progress yet.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get read;

  /// Read action for a completed book (re-read).
  ///
  /// In en, this message translates to:
  /// **'Read again'**
  String get readAgain;

  /// Read action for a book with saved progress.
  ///
  /// In en, this message translates to:
  /// **'Continue reading'**
  String get continueReading;

  /// Placeholder in the two-pane browse detail when nothing is selected.
  ///
  /// In en, this message translates to:
  /// **'Select a series'**
  String get selectSeries;

  /// Action to import comics from this device.
  ///
  /// In en, this message translates to:
  /// **'Import comics'**
  String get importComics;

  /// Import action label while an import runs.
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get importBusy;

  /// Header counting imported files in the results sheet.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 imported} other{{count} imported}}'**
  String importImportedCount(int count);

  /// Header for skipped files in the import results sheet.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get importSkipped;

  /// Import skip reason when a file exceeds the size limit. mb is the configured limit in megabytes.
  ///
  /// In en, this message translates to:
  /// **'File is larger than {mb} MB'**
  String importReasonOversize(String mb);

  /// Import skip reason: only https URLs are accepted.
  ///
  /// In en, this message translates to:
  /// **'Only https URLs are supported'**
  String get importReasonHttpsOnly;

  /// Import skip reason: the URL could not be reached.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the URL'**
  String get importReasonUrlUnreachable;

  /// Import skip reason: the URL is not a comic archive.
  ///
  /// In en, this message translates to:
  /// **'Not a comic archive URL'**
  String get importReasonNotArchiveUrl;

  /// Import skip reason: the download failed.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get importReasonDownloadFailed;

  /// Import skip reason: the file could not be found.
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get importReasonFileNotFound;

  /// Import skip reason: the file is not a comic archive.
  ///
  /// In en, this message translates to:
  /// **'Not a comic archive'**
  String get importReasonNotArchive;

  /// Import skip reason: the file is a duplicate.
  ///
  /// In en, this message translates to:
  /// **'Already imported'**
  String get importReasonAlreadyImported;

  /// Title of the import-from-URL dialog and its tooltip.
  ///
  /// In en, this message translates to:
  /// **'Import from URL'**
  String get urlImportTitle;

  /// Inline error when the entered URL is invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid URL'**
  String get urlImportInvalid;

  /// URL import button label while importing.
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get urlImportBusy;

  /// URL import confirm button.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get urlImportAction;

  /// Local home rail title: recently imported.
  ///
  /// In en, this message translates to:
  /// **'Recently imported'**
  String get localRailRecentlyImported;

  /// Folder home rail title: recently added.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get railRecentlyAddedShort;

  /// Empty-library title on the local home.
  ///
  /// In en, this message translates to:
  /// **'No comics yet'**
  String get localEmptyTitle;

  /// Empty-library body on the local home.
  ///
  /// In en, this message translates to:
  /// **'Import CBZ or CBR files from this device. Imported comics are copied in and always readable.'**
  String get localEmptyBody;

  /// Empty state for the local series grid.
  ///
  /// In en, this message translates to:
  /// **'No series here yet.'**
  String get localNoSeries;

  /// Shown on the local book detail when the comic no longer exists.
  ///
  /// In en, this message translates to:
  /// **'This comic was removed.'**
  String get localComicRemoved;

  /// Button to remove an imported comic.
  ///
  /// In en, this message translates to:
  /// **'Remove from library'**
  String get localRemoveFromLibrary;

  /// Title of the remove-imported-comic dialog.
  ///
  /// In en, this message translates to:
  /// **'Remove this comic?'**
  String get localRemoveTitle;

  /// Body of the remove-imported-comic dialog.
  ///
  /// In en, this message translates to:
  /// **'The imported copy is deleted from this device. Reading history is kept.'**
  String get localRemoveBody;

  /// Book fact label: issue/chapter number.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get factNumber;

  /// Book fact label: page count.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get factPages;

  /// Book fact label: file size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get factSize;

  /// Book fact label: reading direction.
  ///
  /// In en, this message translates to:
  /// **'Reading direction'**
  String get factReadingDirection;

  /// Book fact label: import date.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get factImported;

  /// Reading direction value: right to left.
  ///
  /// In en, this message translates to:
  /// **'Right to left'**
  String get readingDirectionRtl;

  /// Reading direction value: left to right.
  ///
  /// In en, this message translates to:
  /// **'Left to right'**
  String get readingDirectionLtr;

  /// Folder rescan button label while scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get folderScanning;

  /// Folder rescan button label.
  ///
  /// In en, this message translates to:
  /// **'Rescan folder'**
  String get folderRescan;

  /// Empty-folder scan button label.
  ///
  /// In en, this message translates to:
  /// **'Scan folder'**
  String get folderScanAction;

  /// Folder scan progress strip; an optional ' - current file name' suffix is appended outside this string.
  ///
  /// In en, this message translates to:
  /// **'{scanned} scanned, {added} added'**
  String folderScanProgress(int scanned, int added);

  /// Offline banner body on the folder home.
  ///
  /// In en, this message translates to:
  /// **'This folder is not reachable. The card may be ejected or access was revoked. Reading from cached pages still works.'**
  String get folderOfflineBody;

  /// Button to re-pick an unreachable folder tree.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get folderReconnect;

  /// Empty-folder title on the folder home.
  ///
  /// In en, this message translates to:
  /// **'Nothing scanned yet'**
  String get folderEmptyTitle;

  /// Empty-folder body on the folder home.
  ///
  /// In en, this message translates to:
  /// **'Scan this folder to find CBZ and CBR comics. Files stay where they are; nothing is copied in.'**
  String get folderEmptyBody;

  /// Generic dismiss tooltip/action.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// Generic Save button.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Generic Reset button.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Generic retry button.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// Friendly error: item not found.
  ///
  /// In en, this message translates to:
  /// **'The server could not find this item. It may have been removed.'**
  String get errorNotFound;

  /// Friendly error: auth expired / forbidden.
  ///
  /// In en, this message translates to:
  /// **'Your session may have expired. Reconnect the source in Settings.'**
  String get errorSessionExpired;

  /// Friendly error: server unreachable.
  ///
  /// In en, this message translates to:
  /// **'Can not reach the server. Check your connection and try again.'**
  String get errorUnreachable;

  /// Friendly error: TLS failure.
  ///
  /// In en, this message translates to:
  /// **'The secure connection to the server failed.'**
  String get errorTls;

  /// Friendly error: generic server error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong talking to the server.'**
  String get errorServerGeneric;

  /// Friendly error: generic non-transport error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// Shown in place of a page that failed to load.
  ///
  /// In en, this message translates to:
  /// **'Could not load this page'**
  String get readerPageLoadError;

  /// Error title when a book fails to open.
  ///
  /// In en, this message translates to:
  /// **'Could not open this book'**
  String get readerOpenError;

  /// Error title when a book has zero pages.
  ///
  /// In en, this message translates to:
  /// **'This book has no pages'**
  String get readerNoPages;

  /// Tooltip for the previous-chapter button.
  ///
  /// In en, this message translates to:
  /// **'Previous book'**
  String get readerPreviousBook;

  /// Tooltip for the next-chapter button.
  ///
  /// In en, this message translates to:
  /// **'Next book'**
  String get readerNextBook;

  /// Title of the jump-to-page dialog.
  ///
  /// In en, this message translates to:
  /// **'Go to page'**
  String get readerGoToPage;

  /// Confirm button in the jump-to-page dialog.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get readerGo;

  /// Hint showing the valid page range in the jump-to-page field.
  ///
  /// In en, this message translates to:
  /// **'1 - {count}'**
  String readerPageRangeHint(int count);

  /// Fallback reader title when no chapter title is known.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String readerPageOfCount(int page, int total);

  /// Semantic label for the offline indicator in the reader top bar.
  ///
  /// In en, this message translates to:
  /// **'Reading offline'**
  String get readerReadingOffline;

  /// Semantic label for the streaming indicator in the reader top bar.
  ///
  /// In en, this message translates to:
  /// **'Streaming'**
  String get readerStreaming;

  /// Reader options menu: enter page capture mode.
  ///
  /// In en, this message translates to:
  /// **'Capture page'**
  String get readerCapturePage;

  /// Reader options menu: flip reading direction.
  ///
  /// In en, this message translates to:
  /// **'Toggle reading direction'**
  String get readerToggleDirection;

  /// Reader options menu: nudge the double-page spread by one page.
  ///
  /// In en, this message translates to:
  /// **'Shift spread by one page'**
  String get readerShiftSpread;

  /// Reader options menu: invert tap zones.
  ///
  /// In en, this message translates to:
  /// **'Invert taps'**
  String get readerInvertTaps;

  /// Reader options menu: toggle double-tap zoom.
  ///
  /// In en, this message translates to:
  /// **'Double-tap zoom'**
  String get readerDoubleTapZoom;

  /// Reader options menu: toggle page-turn animation.
  ///
  /// In en, this message translates to:
  /// **'Animate page turn'**
  String get readerAnimatePageTurn;

  /// Reader options menu / sheet title for image quality.
  ///
  /// In en, this message translates to:
  /// **'Image quality'**
  String get readerImageQuality;

  /// Reader options menu / sheet title for color correction.
  ///
  /// In en, this message translates to:
  /// **'Color correction'**
  String get readerColorCorrection;

  /// Reading mode: left-to-right paged.
  ///
  /// In en, this message translates to:
  /// **'Paged (LTR)'**
  String get readerModePagedLtr;

  /// Reading mode: right-to-left paged.
  ///
  /// In en, this message translates to:
  /// **'Paged (RTL)'**
  String get readerModePagedRtl;

  /// Reading mode: webtoon (gapless vertical).
  ///
  /// In en, this message translates to:
  /// **'Webtoon'**
  String get readerModeWebtoon;

  /// Reading mode: webtoon with gaps.
  ///
  /// In en, this message translates to:
  /// **'Webtoon (gaps)'**
  String get readerModeWebtoonGaps;

  /// Reading mode: double page spread.
  ///
  /// In en, this message translates to:
  /// **'Double page'**
  String get readerModeDoublePage;

  /// Fit mode: fit to width.
  ///
  /// In en, this message translates to:
  /// **'Fit width'**
  String get readerFitWidth;

  /// Fit mode: fit to height.
  ///
  /// In en, this message translates to:
  /// **'Fit height'**
  String get readerFitHeight;

  /// Fit mode: fit to screen.
  ///
  /// In en, this message translates to:
  /// **'Fit screen'**
  String get readerFitScreen;

  /// Fit mode: original size.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get readerFitOriginal;

  /// Snackbar when capturing a page fails.
  ///
  /// In en, this message translates to:
  /// **'Could not capture this page.'**
  String get readerCaptureFailed;

  /// Snackbar when saving a capture fails.
  ///
  /// In en, this message translates to:
  /// **'Could not save capture.'**
  String get readerCaptureSaveFailed;

  /// Snackbar confirming a capture was saved.
  ///
  /// In en, this message translates to:
  /// **'Saved to Gallery'**
  String get readerCaptureSaved;

  /// Snackbar action to view a saved capture in the gallery.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get readerCaptureView;

  /// Instructional hint in the capture overlay.
  ///
  /// In en, this message translates to:
  /// **'Drag to select an area, or capture the whole page.'**
  String get captureHint;

  /// Capture overlay: capture the whole page.
  ///
  /// In en, this message translates to:
  /// **'Whole page'**
  String get captureWholePage;

  /// First-open reading-direction nudge prompt.
  ///
  /// In en, this message translates to:
  /// **'Reading manga? Try right-to-left'**
  String get nudgeMangaPrompt;

  /// Nudge action to switch to right-to-left reading.
  ///
  /// In en, this message translates to:
  /// **'Right-to-left'**
  String get nudgeRightToLeft;

  /// End-of-book seam: book finished label.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get seamFinished;

  /// End-of-book seam: no next book in the series.
  ///
  /// In en, this message translates to:
  /// **'Last in this series'**
  String get seamLastInSeries;

  /// End-of-book seam: the next book during auto-advance countdown.
  ///
  /// In en, this message translates to:
  /// **'Up next: {title}'**
  String seamUpNext(String title);

  /// End-of-book seam: open the next book immediately.
  ///
  /// In en, this message translates to:
  /// **'Read now'**
  String get seamReadNow;

  /// End-of-book seam: stop the auto-advance countdown.
  ///
  /// In en, this message translates to:
  /// **'Cancel auto-advance'**
  String get seamCancelAutoAdvance;

  /// End-of-book seam: open the next book (no countdown).
  ///
  /// In en, this message translates to:
  /// **'Next: {title}'**
  String seamNext(String title);

  /// Shown when the color-correction settings fail to load.
  ///
  /// In en, this message translates to:
  /// **'Color correction unavailable'**
  String get colorCorrectionUnavailable;

  /// Color correction slider: brightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get colorBrightness;

  /// Color correction slider: contrast.
  ///
  /// In en, this message translates to:
  /// **'Contrast'**
  String get colorContrast;

  /// Color correction slider: gamma.
  ///
  /// In en, this message translates to:
  /// **'Gamma'**
  String get colorGamma;

  /// Color correction: tone-mode section label.
  ///
  /// In en, this message translates to:
  /// **'Tone'**
  String get colorTone;

  /// Color correction: auto white-point toggle.
  ///
  /// In en, this message translates to:
  /// **'Auto (white point)'**
  String get colorAutoWhitePoint;

  /// Color correction scope: this chapter.
  ///
  /// In en, this message translates to:
  /// **'Chapter'**
  String get colorScopeChapter;

  /// Color correction scope: this series.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get colorScopeSeries;

  /// Color correction scope: global.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get colorScopeGlobal;

  /// Color tone mode: none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get colorModeNone;

  /// Color tone mode: grayscale.
  ///
  /// In en, this message translates to:
  /// **'Gray'**
  String get colorModeGray;

  /// Color tone mode: sepia.
  ///
  /// In en, this message translates to:
  /// **'Sepia'**
  String get colorModeSepia;

  /// Color tone mode: invert.
  ///
  /// In en, this message translates to:
  /// **'Invert'**
  String get colorModeInvert;

  /// Image quality: smart auto-ceiling switch.
  ///
  /// In en, this message translates to:
  /// **'Smart'**
  String get qualitySmart;

  /// Subtitle for the smart image-quality switch.
  ///
  /// In en, this message translates to:
  /// **'Mylarium picks the sharpest quality your device can handle'**
  String get qualitySmartSubtitle;

  /// Image quality slider low end label.
  ///
  /// In en, this message translates to:
  /// **'Smoother'**
  String get qualitySmoother;

  /// Image quality slider high end label.
  ///
  /// In en, this message translates to:
  /// **'Sharper'**
  String get qualitySharper;

  /// Hint under the image-quality slider.
  ///
  /// In en, this message translates to:
  /// **'Sharper looks crisper but uses more memory.'**
  String get qualitySharperHint;

  /// Settings section header for library access.
  ///
  /// In en, this message translates to:
  /// **'Library access'**
  String get settingsLibraryAccess;

  /// Settings row / lock screen title for library locks.
  ///
  /// In en, this message translates to:
  /// **'Library locks'**
  String get settingsLibraryLocks;

  /// Subtitle for the library-locks settings row.
  ///
  /// In en, this message translates to:
  /// **'Hide libraries behind Face ID / passcode'**
  String get settingsLibraryLocksSubtitle;

  /// Settings section header for reading options.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get settingsReading;

  /// Auto-advance setting title.
  ///
  /// In en, this message translates to:
  /// **'Auto-advance'**
  String get settingsAutoAdvance;

  /// Subtitle for the auto-advance setting.
  ///
  /// In en, this message translates to:
  /// **'Load the next chapter automatically at the end of a book'**
  String get settingsAutoAdvanceSubtitle;

  /// Settings section header for the home rows editor.
  ///
  /// In en, this message translates to:
  /// **'Home screen rows'**
  String get settingsHomeRows;

  /// Helper text for the home rows editor.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder. Toggle to show or hide a row.'**
  String get settingsHomeRowsHint;

  /// Button to reset the home rows to default.
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get settingsResetToDefault;

  /// Diagnostics screen title and settings row.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get settingsDiagnostics;

  /// Subtitle for the diagnostics settings row.
  ///
  /// In en, this message translates to:
  /// **'GPU and rendering info'**
  String get settingsDiagnosticsSubtitle;

  /// Error when the libraries list fails to load.
  ///
  /// In en, this message translates to:
  /// **'Could not load libraries: {error}'**
  String libraryLockLoadError(String error);

  /// Empty state on the library-lock screen.
  ///
  /// In en, this message translates to:
  /// **'No libraries.'**
  String get libraryLockNoLibraries;

  /// Subtitle of a library row on the lock screen.
  ///
  /// In en, this message translates to:
  /// **'Hide this library until unlocked with biometric/PIN'**
  String get libraryLockSubtitle;

  /// Fallback title when a library has no name.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryFallbackName;

  /// Message on the locked-library gate.
  ///
  /// In en, this message translates to:
  /// **'This library is locked'**
  String get libraryLockedMessage;

  /// Unlock action.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// Reason text shown in the OS biometric/PIN prompt when unlocking a named library.
  ///
  /// In en, this message translates to:
  /// **'Unlock \"{name}\"'**
  String unlockLibraryReason(String name);

  /// Diagnostics label: GPU max texture size.
  ///
  /// In en, this message translates to:
  /// **'GPU max texture size'**
  String get diagGpuMaxTexture;

  /// Diagnostics label: GPU probe status.
  ///
  /// In en, this message translates to:
  /// **'Probe status'**
  String get diagProbeStatus;

  /// Diagnostics label: focused page decode cap.
  ///
  /// In en, this message translates to:
  /// **'Focused page cap'**
  String get diagFocusedPageCap;

  /// Diagnostics label: reader image sampling.
  ///
  /// In en, this message translates to:
  /// **'Reader sampling'**
  String get diagReaderSampling;

  /// Diagnostics label: operating system.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get diagPlatform;

  /// Diagnostics label: logical screen size.
  ///
  /// In en, this message translates to:
  /// **'Logical screen'**
  String get diagLogicalScreen;

  /// Diagnostics label: device pixel ratio.
  ///
  /// In en, this message translates to:
  /// **'Device pixel ratio'**
  String get diagDevicePixelRatio;

  /// Diagnostics label: physical screen pixels.
  ///
  /// In en, this message translates to:
  /// **'Screen pixels'**
  String get diagScreenPixels;

  /// Diagnostics label: logical CPU count.
  ///
  /// In en, this message translates to:
  /// **'Logical CPUs'**
  String get diagLogicalCpus;

  /// Storage setting: auto-download chapters on open.
  ///
  /// In en, this message translates to:
  /// **'Auto-download on open'**
  String get storageAutoDownload;

  /// Subtitle for the auto-download setting.
  ///
  /// In en, this message translates to:
  /// **'Cache chapters you open (within the size limit)'**
  String get storageAutoDownloadSubtitle;

  /// Storage setting: restrict auto-download to Wi-Fi.
  ///
  /// In en, this message translates to:
  /// **'Auto-download on Wi-Fi only'**
  String get storageAutoDownloadWifi;

  /// Storage setting: delete a chapter once finished.
  ///
  /// In en, this message translates to:
  /// **'Delete on read'**
  String get storageDeleteOnRead;

  /// Subtitle for the delete-on-read setting.
  ///
  /// In en, this message translates to:
  /// **'Remove a downloaded chapter once you finish it (manual downloads are kept)'**
  String get storageDeleteOnReadSubtitle;

  /// Storage setting: total auto-cache size limit.
  ///
  /// In en, this message translates to:
  /// **'Auto-cache limit'**
  String get storageAutoCacheLimit;

  /// Storage setting: per-book auto-cache ceiling.
  ///
  /// In en, this message translates to:
  /// **'Per-book limit'**
  String get storagePerBookLimit;

  /// Subtitle for the per-book limit setting.
  ///
  /// In en, this message translates to:
  /// **'Skip auto-downloading chapters larger than this. Manual downloads are not limited.'**
  String get storagePerBookLimitSubtitle;

  /// Per-book limit value: no limit.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get storageNoLimit;

  /// Storage pool header: auto-cached (evictable).
  ///
  /// In en, this message translates to:
  /// **'Auto-cache'**
  String get storageAutoCache;

  /// Empty state for the auto-cache pool.
  ///
  /// In en, this message translates to:
  /// **'No auto-cached chapters.'**
  String get storageNoAutoCache;

  /// Tooltip to promote an auto-cached chapter to a permanent download.
  ///
  /// In en, this message translates to:
  /// **'Keep (move to Downloads)'**
  String get storageKeepTooltip;

  /// Storage pool header: manual downloads (permanent).
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get storageDownloads;

  /// Subtitle for the downloads pool.
  ///
  /// In en, this message translates to:
  /// **'Kept until you remove them (no limit)'**
  String get storageDownloadsSubtitle;

  /// Empty state for the downloads pool.
  ///
  /// In en, this message translates to:
  /// **'No downloaded chapters.'**
  String get storageNoDownloads;

  /// Generic Create button.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Pin action.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pin;

  /// Unpin action.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpin;

  /// Open the reader without recording progress.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// Mark a book as read.
  ///
  /// In en, this message translates to:
  /// **'Mark read'**
  String get markRead;

  /// Mark a book as unread.
  ///
  /// In en, this message translates to:
  /// **'Mark unread'**
  String get markUnread;

  /// Context-menu action to mark an item not read.
  ///
  /// In en, this message translates to:
  /// **'Mark as not read'**
  String get markAsNotRead;

  /// Mark an entire series as read.
  ///
  /// In en, this message translates to:
  /// **'Mark series read'**
  String get markSeriesRead;

  /// Mark an entire series as unread.
  ///
  /// In en, this message translates to:
  /// **'Mark series unread'**
  String get markSeriesUnread;

  /// Download a book for offline.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// Shown while a download is in progress.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get downloading;

  /// Retry a failed download.
  ///
  /// In en, this message translates to:
  /// **'Retry download'**
  String get retryDownload;

  /// Status: a manual download is present.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get downloaded;

  /// Status: the book is auto-cached offline.
  ///
  /// In en, this message translates to:
  /// **'Saved offline'**
  String get savedOffline;

  /// Promote an auto-cached book to a permanent download.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// Download all chapters of a series.
  ///
  /// In en, this message translates to:
  /// **'Download series'**
  String get downloadSeries;

  /// Download the not-yet-cached chapters of a series.
  ///
  /// In en, this message translates to:
  /// **'Download remaining ({downloaded}/{total})'**
  String downloadRemaining(int downloaded, int total);

  /// Cancel an in-flight series download.
  ///
  /// In en, this message translates to:
  /// **'Stop downloading ({downloaded}/{total})'**
  String stopDownloading(int downloaded, int total);

  /// Remove all downloaded chapters of a series.
  ///
  /// In en, this message translates to:
  /// **'Remove downloads'**
  String get removeDownloads;

  /// Add a series to a collection.
  ///
  /// In en, this message translates to:
  /// **'Add to collection'**
  String get addToCollection;

  /// Add a book to a read list.
  ///
  /// In en, this message translates to:
  /// **'Add to read list'**
  String get addToReadList;

  /// Fallback title when a book has no title.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get bookFallbackName;

  /// Fallback title when a series has no title.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get seriesFallbackName;

  /// Detail pill showing a book's issue/chapter number.
  ///
  /// In en, this message translates to:
  /// **'No. {number}'**
  String bookNumberPill(String number);

  /// Detail pill showing a book's page count.
  ///
  /// In en, this message translates to:
  /// **'{count} pages'**
  String pagesPill(int count);

  /// Detail pill marking a book as fully read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get readPill;

  /// Detail pill showing read progress percent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% read'**
  String percentReadPill(int percent);

  /// Page-progress caption under a cover.
  ///
  /// In en, this message translates to:
  /// **'p. {page} of {total}'**
  String pageProgress(int page, int total);

  /// Count of series in a collection.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 series} other{{count} series}}'**
  String seriesCount(int count);

  /// Tooltip for the sort menu button.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortTooltip;

  /// Sort option: title ascending.
  ///
  /// In en, this message translates to:
  /// **'Title A-Z'**
  String get sortTitleAsc;

  /// Sort option: title descending.
  ///
  /// In en, this message translates to:
  /// **'Title Z-A'**
  String get sortTitleDesc;

  /// Sort option: most books first.
  ///
  /// In en, this message translates to:
  /// **'Most books'**
  String get sortMostBooks;

  /// Default browse-shell title.
  ///
  /// In en, this message translates to:
  /// **'All series'**
  String get allSeries;

  /// Search field hint.
  ///
  /// In en, this message translates to:
  /// **'Search series'**
  String get searchHint;

  /// Empty search state before a query is entered.
  ///
  /// In en, this message translates to:
  /// **'Search series by title.'**
  String get searchPrompt;

  /// No results found for a search.
  ///
  /// In en, this message translates to:
  /// **'No results.'**
  String get searchNoResults;

  /// Search error message.
  ///
  /// In en, this message translates to:
  /// **'Search failed: {error}'**
  String searchFailed(String error);

  /// Search sort: relevance.
  ///
  /// In en, this message translates to:
  /// **'Relevance'**
  String get searchSortRelevance;

  /// Search sort: recently added.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get searchSortRecentlyAdded;

  /// Search sort: recently updated.
  ///
  /// In en, this message translates to:
  /// **'Recently updated'**
  String get searchSortRecentlyUpdated;

  /// Series status: ongoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get statusOngoing;

  /// Series status: ended.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get statusEnded;

  /// Series status: hiatus.
  ///
  /// In en, this message translates to:
  /// **'Hiatus'**
  String get statusHiatus;

  /// Series status: abandoned.
  ///
  /// In en, this message translates to:
  /// **'Abandoned'**
  String get statusAbandoned;

  /// Read status filter: unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get readStatusUnread;

  /// Read status filter: in progress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get readStatusInProgress;

  /// Read status filter: read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get readStatusRead;

  /// Metadata label: authors.
  ///
  /// In en, this message translates to:
  /// **'By'**
  String get metaBy;

  /// Metadata label: release date.
  ///
  /// In en, this message translates to:
  /// **'Released'**
  String get metaReleased;

  /// Metadata label: last read date.
  ///
  /// In en, this message translates to:
  /// **'Last read'**
  String get metaLastRead;

  /// Metadata label: publisher.
  ///
  /// In en, this message translates to:
  /// **'Publisher'**
  String get metaPublisher;

  /// Metadata label: age rating.
  ///
  /// In en, this message translates to:
  /// **'Age rating'**
  String get metaAgeRating;

  /// Metadata label: language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get metaLanguage;

  /// Metadata label: external links.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get metaLinks;

  /// Tooltip for the new collection/read-list menu.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get collectionsNew;

  /// Create a new collection.
  ///
  /// In en, this message translates to:
  /// **'New collection'**
  String get collectionsNewCollection;

  /// Create a new read list.
  ///
  /// In en, this message translates to:
  /// **'New read list'**
  String get collectionsNewReadList;

  /// Section header for collections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collectionsHeader;

  /// Empty state for collections.
  ///
  /// In en, this message translates to:
  /// **'No collections.'**
  String get collectionsEmpty;

  /// Error loading collections.
  ///
  /// In en, this message translates to:
  /// **'Could not load collections.'**
  String get collectionsLoadError;

  /// Section header for read lists.
  ///
  /// In en, this message translates to:
  /// **'Read lists'**
  String get readListsHeader;

  /// Empty state for read lists.
  ///
  /// In en, this message translates to:
  /// **'No read lists.'**
  String get readListsEmpty;

  /// Error loading read lists.
  ///
  /// In en, this message translates to:
  /// **'Could not load read lists.'**
  String get readListsLoadError;

  /// Fallback title for a collection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collectionFallbackName;

  /// Empty state for a collection's contents.
  ///
  /// In en, this message translates to:
  /// **'Empty collection.'**
  String get collectionEmpty;

  /// Fallback title for a read list.
  ///
  /// In en, this message translates to:
  /// **'Read list'**
  String get readListFallbackName;

  /// Empty state for a read list's contents.
  ///
  /// In en, this message translates to:
  /// **'Empty read list.'**
  String get readListEmpty;

  /// Error loading a collection or read list's contents.
  ///
  /// In en, this message translates to:
  /// **'Could not load: {error}'**
  String collectionLoadError(String error);

  /// Confirm removing a series from a collection.
  ///
  /// In en, this message translates to:
  /// **'Remove from collection?'**
  String get removeFromCollectionTitle;

  /// Confirm removing a book from a read list.
  ///
  /// In en, this message translates to:
  /// **'Remove from read list?'**
  String get removeFromReadListTitle;

  /// Error creating a collection or read list.
  ///
  /// In en, this message translates to:
  /// **'Could not create {name}.'**
  String collectionCreateError(String name);

  /// Error removing an item or membership.
  ///
  /// In en, this message translates to:
  /// **'Could not remove.'**
  String get collectionRemoveError;

  /// Error adding a membership.
  ///
  /// In en, this message translates to:
  /// **'Could not add.'**
  String get collectionAddError;

  /// Empty state in the add-to-collection sheet.
  ///
  /// In en, this message translates to:
  /// **'No collections yet.'**
  String get noCollectionsYet;

  /// Empty state in the add-to-read-list sheet.
  ///
  /// In en, this message translates to:
  /// **'No read lists yet.'**
  String get noReadListsYet;

  /// Hint for the collection/read-list name field.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameHint;

  /// Generic Delete button.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Tooltip for the year-in-review action on stats.
  ///
  /// In en, this message translates to:
  /// **'Year in review'**
  String get statsYearInReview;

  /// Error when stats fail to load.
  ///
  /// In en, this message translates to:
  /// **'Could not load your stats.'**
  String get statsLoadError;

  /// Stats period: month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get statsPeriodMonth;

  /// Stats period: year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get statsPeriodYear;

  /// Stats period: all time.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get statsPeriodAllTime;

  /// Stats section: pages over time chart.
  ///
  /// In en, this message translates to:
  /// **'Pages over time'**
  String get statsPagesOverTime;

  /// Stats section: daily activity heatmap.
  ///
  /// In en, this message translates to:
  /// **'Daily activity'**
  String get statsDailyActivity;

  /// Trailing label showing the current reading streak.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String statsDayStreak(int count);

  /// Stats section: breakdown by series.
  ///
  /// In en, this message translates to:
  /// **'By series'**
  String get statsBySeries;

  /// Stats section: breakdown by genre.
  ///
  /// In en, this message translates to:
  /// **'By genre'**
  String get statsByGenre;

  /// Footnote for the by-genre breakdown.
  ///
  /// In en, this message translates to:
  /// **'Genres overlap, so these can total more than 100%.'**
  String get statsByGenreFootnote;

  /// Stats section: breakdown by publisher.
  ///
  /// In en, this message translates to:
  /// **'By publisher'**
  String get statsByPublisher;

  /// Stats section: breakdown by format.
  ///
  /// In en, this message translates to:
  /// **'By format'**
  String get statsByFormat;

  /// Stats section: milestone badges.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get statsMilestones;

  /// Empty state for a stats breakdown list.
  ///
  /// In en, this message translates to:
  /// **'No data yet.'**
  String get statsNoData;

  /// Summary line of total reading time and session count. Duration is a pre-formatted string.
  ///
  /// In en, this message translates to:
  /// **'Total reading time {duration} across {sessions} sessions.'**
  String statsTotalReadingTime(String duration, int sessions);

  /// Breakdown bucket: series with no known title.
  ///
  /// In en, this message translates to:
  /// **'Unknown series'**
  String get statsUnknownSeries;

  /// Breakdown bucket: unknown publisher.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get statsUnknown;

  /// Breakdown bucket: other/long-tail grouping.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get statsOther;

  /// Empty-stats title.
  ///
  /// In en, this message translates to:
  /// **'No reading yet in this period.'**
  String get statsEmptyTitle;

  /// Empty-stats body.
  ///
  /// In en, this message translates to:
  /// **'Open a book and your stats will appear here.'**
  String get statsEmptyBody;

  /// KPI label: pages read.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get kpiPages;

  /// KPI label: time spent reading.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get kpiTime;

  /// KPI label: books completed.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get kpiBooks;

  /// KPI label: streak length.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get kpiStreak;

  /// Milestone badge: first book.
  ///
  /// In en, this message translates to:
  /// **'First book'**
  String get badgeFirstBook;

  /// Milestone badge: 10 books.
  ///
  /// In en, this message translates to:
  /// **'10 books'**
  String get badgeTenBooks;

  /// Milestone badge: 50 books.
  ///
  /// In en, this message translates to:
  /// **'50 books'**
  String get badgeFiftyBooks;

  /// Milestone badge: 100 books.
  ///
  /// In en, this message translates to:
  /// **'100 books'**
  String get badgeHundredBooks;

  /// Milestone badge: 7 day streak.
  ///
  /// In en, this message translates to:
  /// **'7 day streak'**
  String get badgeWeekStreak;

  /// Milestone badge: 30 day streak.
  ///
  /// In en, this message translates to:
  /// **'30 day streak'**
  String get badgeMonthStreak;

  /// Milestone badge: 1,000 pages.
  ///
  /// In en, this message translates to:
  /// **'1,000 pages'**
  String get badgeThousandPages;

  /// Milestone badge: 10,000 pages.
  ///
  /// In en, this message translates to:
  /// **'10,000 pages'**
  String get badgeTenThousandPages;

  /// Header of the year-in-review wrap card. Year is a pre-formatted string.
  ///
  /// In en, this message translates to:
  /// **'{year} in review'**
  String wrapYearInReview(String year);

  /// Wrap card stat label: pages read.
  ///
  /// In en, this message translates to:
  /// **'pages read'**
  String get wrapPagesRead;

  /// Wrap card stat label: time reading.
  ///
  /// In en, this message translates to:
  /// **'time reading'**
  String get wrapTimeReading;

  /// Wrap card stat label: books finished.
  ///
  /// In en, this message translates to:
  /// **'books finished'**
  String get wrapBooksFinished;

  /// Wrap card stat label: top genre.
  ///
  /// In en, this message translates to:
  /// **'top genre'**
  String get wrapTopGenre;

  /// Error when the gallery fails to load.
  ///
  /// In en, this message translates to:
  /// **'Could not load the gallery.'**
  String get galleryLoadError;

  /// Empty state for the gallery.
  ///
  /// In en, this message translates to:
  /// **'No captures yet.'**
  String get galleryEmpty;

  /// Fallback caption for a capture with no chapter title.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get galleryUntitled;

  /// Confirm deleting a capture.
  ///
  /// In en, this message translates to:
  /// **'Delete capture?'**
  String get galleryDeleteTitle;

  /// Shown when a capture cannot be loaded.
  ///
  /// In en, this message translates to:
  /// **'This capture is no longer available.'**
  String get captureUnavailable;

  /// Shown when a capture's image file is missing.
  ///
  /// In en, this message translates to:
  /// **'This snippet image is missing.'**
  String get captureImageMissing;

  /// Tooltip for the delete-capture action.
  ///
  /// In en, this message translates to:
  /// **'Delete capture'**
  String get captureDeleteTooltip;

  /// Tooltip for the export-capture action.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get captureExport;

  /// Jump to the page a capture was taken from.
  ///
  /// In en, this message translates to:
  /// **'Go to page'**
  String get captureGoToPage;

  /// Snackbar: capture exported to Photos.
  ///
  /// In en, this message translates to:
  /// **'Saved to Photos'**
  String get captureSavedToPhotos;

  /// Snackbar: capture saved to a file.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get captureSavedToFile;

  /// Snackbar: Photos permission denied on export.
  ///
  /// In en, this message translates to:
  /// **'Photos access denied. Enable it in Settings.'**
  String get capturePermissionDenied;

  /// Snackbar: capture export failed.
  ///
  /// In en, this message translates to:
  /// **'Could not export capture.'**
  String get captureExportFailed;

  /// Generic retry button.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Snackbar after connecting Comic Vine.
  ///
  /// In en, this message translates to:
  /// **'Comic Vine connected'**
  String get comicVineConnected;

  /// Snackbar after disconnecting Comic Vine.
  ///
  /// In en, this message translates to:
  /// **'Comic Vine disconnected'**
  String get comicVineDisconnected;

  /// Explanatory text on the Comic Vine settings screen.
  ///
  /// In en, this message translates to:
  /// **'Optional. Comic Vine adds rich details (descriptions, characters, creators and more) to series and issues. It is off until you add a key, and only then are titles sent to Comic Vine to look them up. Your key is stored in the device keychain.'**
  String get comicVineDescription;

  /// Where to get a Comic Vine API key.
  ///
  /// In en, this message translates to:
  /// **'Get a free key at comicvine.gamespot.com/api'**
  String get comicVineGetKey;

  /// Hint for the Comic Vine API key field.
  ///
  /// In en, this message translates to:
  /// **'Paste your Comic Vine API key'**
  String get comicVineKeyHint;

  /// Disconnect (clear) the Comic Vine key.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get comicVineDisconnect;

  /// Toggle to show the Comic Vine section on detail pages.
  ///
  /// In en, this message translates to:
  /// **'Show on detail pages'**
  String get comicVineShowOnDetail;

  /// Subtitle for the show-on-detail toggle.
  ///
  /// In en, this message translates to:
  /// **'Turn off to hide the Comic Vine section everywhere.'**
  String get comicVineShowOnDetailSubtitle;

  /// Error when the Comic Vine API key is rejected.
  ///
  /// In en, this message translates to:
  /// **'Comic Vine rejected the API key. Check it in settings.'**
  String get comicVineInvalidKey;

  /// Error when the Comic Vine rate limit is hit.
  ///
  /// In en, this message translates to:
  /// **'Comic Vine rate limit reached. Try again later.'**
  String get comicVineRateLimited;

  /// Generic Comic Vine load error.
  ///
  /// In en, this message translates to:
  /// **'Could not load Comic Vine details.'**
  String get comicVineLoadError;

  /// Title of the Comic Vine connect placeholder.
  ///
  /// In en, this message translates to:
  /// **'Comic Vine details'**
  String get comicVineDetailsTitle;

  /// Body of the Comic Vine connect placeholder.
  ///
  /// In en, this message translates to:
  /// **'Connect Comic Vine to pull in descriptions, characters, creators and more for this title.'**
  String get comicVineConnectBody;

  /// Action to add a Comic Vine API key.
  ///
  /// In en, this message translates to:
  /// **'Add API key'**
  String get comicVineAddApiKey;

  /// Dismiss the Comic Vine section permanently.
  ///
  /// In en, this message translates to:
  /// **'Never show again'**
  String get comicVineNeverShow;

  /// Comic Vine section: characters.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get comicVineCharacters;

  /// Comic Vine section: creators.
  ///
  /// In en, this message translates to:
  /// **'Creators'**
  String get comicVineCreators;

  /// Comic Vine section: story arcs.
  ///
  /// In en, this message translates to:
  /// **'Story arcs'**
  String get comicVineStoryArcs;

  /// Overflow chip for additional Comic Vine characters.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String comicVineMore(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
