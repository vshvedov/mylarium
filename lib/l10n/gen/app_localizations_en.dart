// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get storageUnavailableTitle => 'Storage unavailable';

  @override
  String get storageUnavailableBody =>
      'Mylarium could not open its local storage and is running in memory only. Anything you connect or read will be lost when the app closes. Try restarting; if this keeps happening, check that the device has free space.';

  @override
  String routeNotFound(String uri) {
    return 'Route not found: $uri';
  }

  @override
  String get onboardingTagline => 'Your comics and manga, beautifully offline.';

  @override
  String get onboardingChooseSource => 'Choose a source';

  @override
  String get onboardingKomgaSubtitle => 'Connect to your self-hosted server';

  @override
  String get onboardingKavitaSubtitle => 'Another self-hosted library server';

  @override
  String get onboardingLocalTitle => 'Local files';

  @override
  String get onboardingLocalSubtitle => 'Read comics stored on this device';

  @override
  String get onboardingMoreSourcesHint =>
      'More sources are on the way. You can add or switch sources anytime in Settings.';

  @override
  String sourceComingSoonSemantic(String title) {
    return '$title, coming soon';
  }

  @override
  String get sourceSoonChip => 'Soon';

  @override
  String get connectServerUrlLabel => 'Server URL';

  @override
  String get connectApiKeyLabel => 'API key';

  @override
  String get connectPasswordLabel => 'Password';

  @override
  String get connectUsernameLabel => 'Username';

  @override
  String get connectAction => 'Connect';

  @override
  String get connectBusy => 'Connecting...';

  @override
  String get connectUnreachable =>
      'Could not reach the server. Check the URL and your network.';

  @override
  String get connectTlsError =>
      'The server security certificate could not be verified.';

  @override
  String get komgaConnectTitle => 'Connect to Komga';

  @override
  String get komgaConnectSubtitle =>
      'Point Mylarium at your server and sign in.';

  @override
  String get komgaConnectInvalidUrl =>
      'Enter a valid server URL (for example https://komga.example.com).';

  @override
  String get komgaConnectUnauthorized => 'Incorrect credentials.';

  @override
  String komgaConnectMissingRoles(String roles) {
    return 'Your Komga account is missing the $roles role. Ask your server admin to enable it.';
  }

  @override
  String komgaConnectVersionTooOld(String version) {
    return 'This server$version is too old for API keys. Use a username and password instead.';
  }

  @override
  String get kavitaConnectTitle => 'Connect to Kavita';

  @override
  String get kavitaConnectSubtitle =>
      'Point Mylarium at your server and paste your API key.';

  @override
  String get kavitaConnectApiKeyHint =>
      'Find your API key in Kavita under Settings, Account, 3rd Party Clients.';

  @override
  String get kavitaConnectInvalidUrl =>
      'Enter a valid server URL (for example https://kavita.example.com).';

  @override
  String get kavitaConnectUnauthorized => 'That API key was not accepted.';

  @override
  String kavitaConnectMissingRoles(String roles) {
    return 'Your Kavita account is missing the $roles role. Ask your server admin to enable it.';
  }

  @override
  String kavitaConnectVersionUnsupported(String version) {
    return 'This server$version is not supported.';
  }

  @override
  String get sourcesTitle => 'Sources';

  @override
  String get galleryTitle => 'Gallery';

  @override
  String get statsTitle => 'Reading stats';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get storageTitle => 'Storage';

  @override
  String get librariesTitle => 'Libraries';

  @override
  String get collectionsAndReadListsTitle => 'Collections & read lists';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeAuto => 'Auto';

  @override
  String get themeEink => 'E-ink';

  @override
  String get homeBrowseAll => 'Browse all';

  @override
  String get homeSettingsSubtitle => 'Home rows and more';

  @override
  String get homeSourcesSubtitle => 'Switch, add, or remove servers';

  @override
  String get homeNoSource => 'No source connected.';

  @override
  String get homeConnectServer => 'Connect a server';

  @override
  String get homeEmpty => 'Nothing to show yet. Pull to refresh.';

  @override
  String get railPinned => 'Pinned';

  @override
  String get railKeepReading => 'Keep reading';

  @override
  String get railRecentlyAddedChapters => 'Recently added chapters';

  @override
  String get railRecentlyAddedSeries => 'Recently added series';

  @override
  String get railRecentlyUpdatedSeries => 'Recently updated series';

  @override
  String get railDownloaded => 'Downloaded';

  @override
  String get railRecentlyRead => 'Recently read';

  @override
  String get cancel => 'Cancel';

  @override
  String get remove => 'Remove';

  @override
  String get close => 'Close';

  @override
  String get refresh => 'Refresh';

  @override
  String get sourcesEmpty => 'No sources connected yet.';

  @override
  String get sourceKindFolderLibrary => 'Folder library';

  @override
  String get sourceSubtitleOnDevice => 'On this device';

  @override
  String get sourceSubtitleFolderInPlace => 'Folder library - in place';

  @override
  String get sourceRemoveTooltip => 'Remove source';

  @override
  String sourceRemoveTitle(String label) {
    return 'Remove $label?';
  }

  @override
  String get sourceRemoveFolderBody =>
      'This forgets the folder library. The files on the card or folder are untouched, and reading history is kept.';

  @override
  String get sourceRemoveServerBody =>
      'This disconnects the source and deletes its stored credentials. Downloaded files for this source are removed by storage cleanup.';

  @override
  String get sourceLocalImportSubtitle => 'Import comics from this device';

  @override
  String get sourceAddFolder => 'Add folder library';

  @override
  String get sourceAddFolderSubtitle =>
      'Read comics from a folder or SD card, in place';

  @override
  String get sourceAddSource => 'Add a source';

  @override
  String get serverOnlineTooltip => 'Server online - tap for details';

  @override
  String get serverUnreachableTooltip => 'Server unreachable - tap for details';

  @override
  String get serverCheckingTooltip => 'Checking server...';

  @override
  String get serverDetailsLoadError => 'Could not load server details.';

  @override
  String get serverUnreachableBody =>
      'Server unreachable. Check your connection and try Refresh.';

  @override
  String get serverSectionConnection => 'Connection';

  @override
  String get serverSectionServer => 'Server';

  @override
  String get serverSectionAccount => 'Account';

  @override
  String get serverSectionContent => 'Content';

  @override
  String get serverRowUrl => 'URL';

  @override
  String get serverRowVersion => 'Version';

  @override
  String get serverRowUser => 'User';

  @override
  String get serverRowRoles => 'Roles';

  @override
  String get serverRowLibraries => 'Libraries';

  @override
  String get serverRowSeries => 'Series';

  @override
  String get serverRowBooks => 'Books';

  @override
  String get statusOnline => 'Online';

  @override
  String get statusOffline => 'Offline';

  @override
  String get syncSectionTitle => 'SYNC';

  @override
  String syncUpdatesWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count updates waiting to sync',
      one: '1 update waiting to sync',
    );
    return '$_temp0';
  }

  @override
  String syncFailedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count failed',
      one: '1 failed',
    );
    return '$_temp0';
  }

  @override
  String get syncRetryNow => 'Retry now';

  @override
  String bookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books',
      one: '1 book',
    );
    return '$_temp0';
  }

  @override
  String get read => 'Read';

  @override
  String get readAgain => 'Read again';

  @override
  String get continueReading => 'Continue reading';

  @override
  String get selectSeries => 'Select a series';

  @override
  String get importComics => 'Import comics';

  @override
  String get importBusy => 'Importing...';

  @override
  String importImportedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count imported',
      one: '1 imported',
    );
    return '$_temp0';
  }

  @override
  String get importSkipped => 'Skipped';

  @override
  String importReasonOversize(String mb) {
    return 'File is larger than $mb MB';
  }

  @override
  String get importReasonHttpsOnly => 'Only https URLs are supported';

  @override
  String get importReasonUrlUnreachable => 'Could not reach the URL';

  @override
  String get importReasonNotArchiveUrl => 'Not a comic archive URL';

  @override
  String get importReasonDownloadFailed => 'Download failed';

  @override
  String get importReasonFileNotFound => 'File not found';

  @override
  String get importReasonNotArchive => 'Not a comic archive';

  @override
  String get importReasonAlreadyImported => 'Already imported';

  @override
  String get urlImportTitle => 'Import from URL';

  @override
  String get urlImportInvalid => 'Enter a valid URL';

  @override
  String get urlImportBusy => 'Importing...';

  @override
  String get urlImportAction => 'Import';

  @override
  String get localRailRecentlyImported => 'Recently imported';

  @override
  String get railRecentlyAddedShort => 'Recently added';

  @override
  String get localEmptyTitle => 'No comics yet';

  @override
  String get localEmptyBody =>
      'Import CBZ or CBR files from this device. Imported comics are copied in and always readable.';

  @override
  String get localNoSeries => 'No series here yet.';

  @override
  String get localComicRemoved => 'This comic was removed.';

  @override
  String get localRemoveFromLibrary => 'Remove from library';

  @override
  String get localRemoveTitle => 'Remove this comic?';

  @override
  String get localRemoveBody =>
      'The imported copy is deleted from this device. Reading history is kept.';

  @override
  String get factNumber => 'Number';

  @override
  String get factPages => 'Pages';

  @override
  String get factSize => 'Size';

  @override
  String get factReadingDirection => 'Reading direction';

  @override
  String get factImported => 'Imported';

  @override
  String get readingDirectionRtl => 'Right to left';

  @override
  String get readingDirectionLtr => 'Left to right';

  @override
  String get folderScanning => 'Scanning...';

  @override
  String get folderRescan => 'Rescan folder';

  @override
  String get folderScanAction => 'Scan folder';

  @override
  String folderScanProgress(int scanned, int added) {
    return '$scanned scanned, $added added';
  }

  @override
  String get folderOfflineBody =>
      'This folder is not reachable. The card may be ejected or access was revoked. Reading from cached pages still works.';

  @override
  String get folderReconnect => 'Reconnect';

  @override
  String get folderEmptyTitle => 'Nothing scanned yet';

  @override
  String get folderEmptyBody =>
      'Scan this folder to find CBZ and CBR comics. Files stay where they are; nothing is copied in.';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get save => 'Save';

  @override
  String get reset => 'Reset';

  @override
  String get tryAgain => 'Try again';

  @override
  String get errorNotFound =>
      'The server could not find this item. It may have been removed.';

  @override
  String get errorSessionExpired =>
      'Your session may have expired. Reconnect the source in Settings.';

  @override
  String get errorUnreachable =>
      'Can not reach the server. Check your connection and try again.';

  @override
  String get errorTls => 'The secure connection to the server failed.';

  @override
  String get errorServerGeneric =>
      'Something went wrong talking to the server.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get readerPageLoadError => 'Could not load this page';

  @override
  String get readerOpenError => 'Could not open this book';

  @override
  String get readerNoPages => 'This book has no pages';

  @override
  String get readerPreviousBook => 'Previous book';

  @override
  String get readerNextBook => 'Next book';

  @override
  String get readerGoToPage => 'Go to page';

  @override
  String get readerGo => 'Go';

  @override
  String readerPageRangeHint(int count) {
    return '1 - $count';
  }

  @override
  String readerPageOfCount(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String get readerReadingOffline => 'Reading offline';

  @override
  String get readerStreaming => 'Streaming';

  @override
  String get readerCapturePage => 'Capture page';

  @override
  String get readerToggleDirection => 'Toggle reading direction';

  @override
  String get readerShiftSpread => 'Shift spread by one page';

  @override
  String get readerInvertTaps => 'Invert taps';

  @override
  String get readerDoubleTapZoom => 'Double-tap zoom';

  @override
  String get readerAnimatePageTurn => 'Animate page turn';

  @override
  String get readerImageQuality => 'Image quality';

  @override
  String get readerColorCorrection => 'Color correction';

  @override
  String get readerModePagedLtr => 'Paged (LTR)';

  @override
  String get readerModePagedRtl => 'Paged (RTL)';

  @override
  String get readerModeWebtoon => 'Webtoon';

  @override
  String get readerModeWebtoonGaps => 'Webtoon (gaps)';

  @override
  String get readerModeDoublePage => 'Double page';

  @override
  String get readerFitWidth => 'Fit width';

  @override
  String get readerFitHeight => 'Fit height';

  @override
  String get readerFitScreen => 'Fit screen';

  @override
  String get readerFitOriginal => 'Original';

  @override
  String get readerCaptureFailed => 'Could not capture this page.';

  @override
  String get readerCaptureSaveFailed => 'Could not save capture.';

  @override
  String get readerCaptureSaved => 'Saved to Gallery';

  @override
  String get readerCaptureView => 'View';

  @override
  String get captureHint =>
      'Drag to select an area, or capture the whole page.';

  @override
  String get captureWholePage => 'Whole page';

  @override
  String get nudgeMangaPrompt => 'Reading manga? Try right-to-left';

  @override
  String get nudgeRightToLeft => 'Right-to-left';

  @override
  String get seamFinished => 'Finished';

  @override
  String get seamLastInSeries => 'Last in this series';

  @override
  String seamUpNext(String title) {
    return 'Up next: $title';
  }

  @override
  String get seamReadNow => 'Read now';

  @override
  String get seamCancelAutoAdvance => 'Cancel auto-advance';

  @override
  String seamNext(String title) {
    return 'Next: $title';
  }

  @override
  String get colorCorrectionUnavailable => 'Color correction unavailable';

  @override
  String get colorBrightness => 'Brightness';

  @override
  String get colorContrast => 'Contrast';

  @override
  String get colorGamma => 'Gamma';

  @override
  String get colorTone => 'Tone';

  @override
  String get colorAutoWhitePoint => 'Auto (white point)';

  @override
  String get colorScopeChapter => 'Chapter';

  @override
  String get colorScopeSeries => 'Series';

  @override
  String get colorScopeGlobal => 'Global';

  @override
  String get colorModeNone => 'None';

  @override
  String get colorModeGray => 'Gray';

  @override
  String get colorModeSepia => 'Sepia';

  @override
  String get colorModeInvert => 'Invert';

  @override
  String get qualitySmart => 'Smart';

  @override
  String get qualitySmartSubtitle =>
      'Mylarium picks the sharpest quality your device can handle';

  @override
  String get qualitySmoother => 'Smoother';

  @override
  String get qualitySharper => 'Sharper';

  @override
  String get qualitySharperHint =>
      'Sharper looks crisper but uses more memory.';

  @override
  String get settingsLibraryAccess => 'Library access';

  @override
  String get settingsLibraryLocks => 'Library locks';

  @override
  String get settingsLibraryLocksSubtitle =>
      'Hide libraries behind Face ID / passcode';

  @override
  String get settingsReading => 'Reading';

  @override
  String get settingsAutoAdvance => 'Auto-advance';

  @override
  String get settingsAutoAdvanceSubtitle =>
      'Load the next chapter automatically at the end of a book';

  @override
  String get settingsHomeRows => 'Home screen rows';

  @override
  String get settingsHomeRowsHint =>
      'Drag to reorder. Toggle to show or hide a row.';

  @override
  String get settingsResetToDefault => 'Reset to default';

  @override
  String get settingsDiagnostics => 'Diagnostics';

  @override
  String get settingsDiagnosticsSubtitle => 'GPU and rendering info';

  @override
  String libraryLockLoadError(String error) {
    return 'Could not load libraries: $error';
  }

  @override
  String get libraryLockNoLibraries => 'No libraries.';

  @override
  String get libraryLockSubtitle =>
      'Hide this library until unlocked with biometric/PIN';

  @override
  String get libraryFallbackName => 'Library';

  @override
  String get libraryLockedMessage => 'This library is locked';

  @override
  String get unlock => 'Unlock';

  @override
  String unlockLibraryReason(String name) {
    return 'Unlock \"$name\"';
  }

  @override
  String get diagGpuMaxTexture => 'GPU max texture size';

  @override
  String get diagProbeStatus => 'Probe status';

  @override
  String get diagFocusedPageCap => 'Focused page cap';

  @override
  String get diagReaderSampling => 'Reader sampling';

  @override
  String get diagPlatform => 'Platform';

  @override
  String get diagLogicalScreen => 'Logical screen';

  @override
  String get diagDevicePixelRatio => 'Device pixel ratio';

  @override
  String get diagScreenPixels => 'Screen pixels';

  @override
  String get diagLogicalCpus => 'Logical CPUs';

  @override
  String get storageAutoDownload => 'Auto-download on open';

  @override
  String get storageAutoDownloadSubtitle =>
      'Cache chapters you open (within the size limit)';

  @override
  String get storageAutoDownloadWifi => 'Auto-download on Wi-Fi only';

  @override
  String get storageDeleteOnRead => 'Delete on read';

  @override
  String get storageDeleteOnReadSubtitle =>
      'Remove a downloaded chapter once you finish it (manual downloads are kept)';

  @override
  String get storageAutoCacheLimit => 'Auto-cache limit';

  @override
  String get storagePerBookLimit => 'Per-book limit';

  @override
  String get storagePerBookLimitSubtitle =>
      'Skip auto-downloading chapters larger than this. Manual downloads are not limited.';

  @override
  String get storageNoLimit => 'No limit';

  @override
  String get storageAutoCache => 'Auto-cache';

  @override
  String get storageNoAutoCache => 'No auto-cached chapters.';

  @override
  String get storageKeepTooltip => 'Keep (move to Downloads)';

  @override
  String get storageDownloads => 'Downloads';

  @override
  String get storageDownloadsSubtitle =>
      'Kept until you remove them (no limit)';

  @override
  String get storageNoDownloads => 'No downloaded chapters.';

  @override
  String get create => 'Create';

  @override
  String get pin => 'Pin';

  @override
  String get unpin => 'Unpin';

  @override
  String get preview => 'Preview';

  @override
  String get markRead => 'Mark read';

  @override
  String get markUnread => 'Mark unread';

  @override
  String get markAsNotRead => 'Mark as not read';

  @override
  String get markSeriesRead => 'Mark series read';

  @override
  String get markSeriesUnread => 'Mark series unread';

  @override
  String get download => 'Download';

  @override
  String get downloading => 'Downloading...';

  @override
  String get retryDownload => 'Retry download';

  @override
  String get downloaded => 'Downloaded';

  @override
  String get savedOffline => 'Saved offline';

  @override
  String get keep => 'Keep';

  @override
  String get downloadSeries => 'Download series';

  @override
  String downloadRemaining(int downloaded, int total) {
    return 'Download remaining ($downloaded/$total)';
  }

  @override
  String stopDownloading(int downloaded, int total) {
    return 'Stop downloading ($downloaded/$total)';
  }

  @override
  String get removeDownloads => 'Remove downloads';

  @override
  String get addToCollection => 'Add to collection';

  @override
  String get addToReadList => 'Add to read list';

  @override
  String get bookFallbackName => 'Book';

  @override
  String get seriesFallbackName => 'Series';

  @override
  String bookNumberPill(String number) {
    return 'No. $number';
  }

  @override
  String pagesPill(int count) {
    return '$count pages';
  }

  @override
  String get readPill => 'Read';

  @override
  String percentReadPill(int percent) {
    return '$percent% read';
  }

  @override
  String pageProgress(int page, int total) {
    return 'p. $page of $total';
  }

  @override
  String seriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count series',
      one: '1 series',
    );
    return '$_temp0';
  }

  @override
  String get sortTooltip => 'Sort';

  @override
  String get sortTitleAsc => 'Title A-Z';

  @override
  String get sortTitleDesc => 'Title Z-A';

  @override
  String get sortMostBooks => 'Most books';

  @override
  String get allSeries => 'All series';

  @override
  String get searchHint => 'Search series';

  @override
  String get searchPrompt => 'Search series by title.';

  @override
  String get searchNoResults => 'No results.';

  @override
  String searchFailed(String error) {
    return 'Search failed: $error';
  }

  @override
  String get searchSortRelevance => 'Relevance';

  @override
  String get searchSortRecentlyAdded => 'Recently added';

  @override
  String get searchSortRecentlyUpdated => 'Recently updated';

  @override
  String get statusOngoing => 'Ongoing';

  @override
  String get statusEnded => 'Ended';

  @override
  String get statusHiatus => 'Hiatus';

  @override
  String get statusAbandoned => 'Abandoned';

  @override
  String get readStatusUnread => 'Unread';

  @override
  String get readStatusInProgress => 'In progress';

  @override
  String get readStatusRead => 'Read';

  @override
  String get metaBy => 'By';

  @override
  String get metaReleased => 'Released';

  @override
  String get metaLastRead => 'Last read';

  @override
  String get metaPublisher => 'Publisher';

  @override
  String get metaAgeRating => 'Age rating';

  @override
  String get metaLanguage => 'Language';

  @override
  String get metaLinks => 'Links';

  @override
  String get collectionsNew => 'New';

  @override
  String get collectionsNewCollection => 'New collection';

  @override
  String get collectionsNewReadList => 'New read list';

  @override
  String get collectionsHeader => 'Collections';

  @override
  String get collectionsEmpty => 'No collections.';

  @override
  String get collectionsLoadError => 'Could not load collections.';

  @override
  String get readListsHeader => 'Read lists';

  @override
  String get readListsEmpty => 'No read lists.';

  @override
  String get readListsLoadError => 'Could not load read lists.';

  @override
  String get collectionFallbackName => 'Collection';

  @override
  String get collectionEmpty => 'Empty collection.';

  @override
  String get readListFallbackName => 'Read list';

  @override
  String get readListEmpty => 'Empty read list.';

  @override
  String collectionLoadError(String error) {
    return 'Could not load: $error';
  }

  @override
  String get removeFromCollectionTitle => 'Remove from collection?';

  @override
  String get removeFromReadListTitle => 'Remove from read list?';

  @override
  String collectionCreateError(String name) {
    return 'Could not create $name.';
  }

  @override
  String get collectionRemoveError => 'Could not remove.';

  @override
  String get collectionAddError => 'Could not add.';

  @override
  String get noCollectionsYet => 'No collections yet.';

  @override
  String get noReadListsYet => 'No read lists yet.';

  @override
  String get nameHint => 'Name';

  @override
  String get delete => 'Delete';

  @override
  String get statsYearInReview => 'Year in review';

  @override
  String get statsLoadError => 'Could not load your stats.';

  @override
  String get statsPeriodMonth => 'Month';

  @override
  String get statsPeriodYear => 'Year';

  @override
  String get statsPeriodAllTime => 'All time';

  @override
  String get statsPagesOverTime => 'Pages over time';

  @override
  String get statsDailyActivity => 'Daily activity';

  @override
  String statsDayStreak(int count) {
    return '$count day streak';
  }

  @override
  String get statsBySeries => 'By series';

  @override
  String get statsByGenre => 'By genre';

  @override
  String get statsByGenreFootnote =>
      'Genres overlap, so these can total more than 100%.';

  @override
  String get statsByPublisher => 'By publisher';

  @override
  String get statsByFormat => 'By format';

  @override
  String get statsMilestones => 'Milestones';

  @override
  String get statsNoData => 'No data yet.';

  @override
  String statsTotalReadingTime(String duration, int sessions) {
    return 'Total reading time $duration across $sessions sessions.';
  }

  @override
  String get statsUnknownSeries => 'Unknown series';

  @override
  String get statsUnknown => 'Unknown';

  @override
  String get statsOther => 'Other';

  @override
  String get statsEmptyTitle => 'No reading yet in this period.';

  @override
  String get statsEmptyBody => 'Open a book and your stats will appear here.';

  @override
  String get kpiPages => 'Pages';

  @override
  String get kpiTime => 'Time';

  @override
  String get kpiBooks => 'Books';

  @override
  String get kpiStreak => 'Streak';

  @override
  String get badgeFirstBook => 'First book';

  @override
  String get badgeTenBooks => '10 books';

  @override
  String get badgeFiftyBooks => '50 books';

  @override
  String get badgeHundredBooks => '100 books';

  @override
  String get badgeWeekStreak => '7 day streak';

  @override
  String get badgeMonthStreak => '30 day streak';

  @override
  String get badgeThousandPages => '1,000 pages';

  @override
  String get badgeTenThousandPages => '10,000 pages';

  @override
  String wrapYearInReview(String year) {
    return '$year in review';
  }

  @override
  String get wrapPagesRead => 'pages read';

  @override
  String get wrapTimeReading => 'time reading';

  @override
  String get wrapBooksFinished => 'books finished';

  @override
  String get wrapTopGenre => 'top genre';

  @override
  String get galleryLoadError => 'Could not load the gallery.';

  @override
  String get galleryEmpty => 'No captures yet.';

  @override
  String get galleryUntitled => 'Untitled';

  @override
  String get galleryDeleteTitle => 'Delete capture?';

  @override
  String get captureUnavailable => 'This capture is no longer available.';

  @override
  String get captureImageMissing => 'This snippet image is missing.';

  @override
  String get captureDeleteTooltip => 'Delete capture';

  @override
  String get captureExport => 'Export';

  @override
  String get captureGoToPage => 'Go to page';

  @override
  String get captureSavedToPhotos => 'Saved to Photos';

  @override
  String get captureSavedToFile => 'Saved';

  @override
  String get capturePermissionDenied =>
      'Photos access denied. Enable it in Settings.';

  @override
  String get captureExportFailed => 'Could not export capture.';

  @override
  String get retry => 'Retry';

  @override
  String get comicVineConnected => 'Comic Vine connected';

  @override
  String get comicVineDisconnected => 'Comic Vine disconnected';

  @override
  String get comicVineDescription =>
      'Optional. Comic Vine adds rich details (descriptions, characters, creators and more) to series and issues. It is off until you add a key, and only then are titles sent to Comic Vine to look them up. Your key is stored in the device keychain.';

  @override
  String get comicVineGetKey => 'Get a free key at comicvine.gamespot.com/api';

  @override
  String get comicVineKeyHint => 'Paste your Comic Vine API key';

  @override
  String get comicVineDisconnect => 'Disconnect';

  @override
  String get comicVineShowOnDetail => 'Show on detail pages';

  @override
  String get comicVineShowOnDetailSubtitle =>
      'Turn off to hide the Comic Vine section everywhere.';

  @override
  String get comicVineInvalidKey =>
      'Comic Vine rejected the API key. Check it in settings.';

  @override
  String get comicVineRateLimited =>
      'Comic Vine rate limit reached. Try again later.';

  @override
  String get comicVineLoadError => 'Could not load Comic Vine details.';

  @override
  String get comicVineDetailsTitle => 'Comic Vine details';

  @override
  String get comicVineConnectBody =>
      'Connect Comic Vine to pull in descriptions, characters, creators and more for this title.';

  @override
  String get comicVineAddApiKey => 'Add API key';

  @override
  String get comicVineNeverShow => 'Never show again';

  @override
  String get comicVineCharacters => 'Characters';

  @override
  String get comicVineCreators => 'Creators';

  @override
  String get comicVineStoryArcs => 'Story arcs';

  @override
  String comicVineMore(int count) {
    return '+$count more';
  }
}
