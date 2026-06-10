# Integration tests (on-device smoke suite)

## How to run

```
flutter devices                          # pick a device id
flutter test integration_test -d <device>
```

Runs on a real device or simulator/emulator (iOS simulator and Android emulator
both work). There is no test_driver harness; `flutter test integration_test`
drives the suite directly through `package:integration_test`.

## What it covers

`reader_smoke_test.dart` boots the REAL app widget (`MylariumApp`, the real
go_router, the real Riverpod provider graph) against an in-memory database
seeded with one Local-files source and one 5-page CBZ fixture written to a
temp directory (via `AppPaths.debugOverrideRoot`). It then drives the app with
real taps:

1. Home shows the seeded import on the "Recently imported" shelf.
2. Tile -> book detail -> Read opens the reader on the local archive
   (real archive-decode isolate, real photo_view gesture arena).
3. Page 1 is shown; a right-zone tap advances to page 2.
4. The overflow menu's "Toggle reading direction" flips the reader to RTL.
5. A left-zone tap ADVANCES (page 3) and a right-zone tap goes BACK (page 2):
   tap zones must stay alive across the direction toggle.
6. Closing and reopening the book resumes at the saved page through the real
   progress-persistence path (SyncEngine -> BookState).

The suite is hermetic: no network, no Komga server, no pre-existing state on
the device. All waiting is explicit `pump(duration)` polling (`pumpUntilFound`
/ `pumpUntil`); `pumpAndSettle` is never used because the app holds live Drift
streams that never settle.

## Why it exists

We shipped a regression this suite would have caught: `PhotoViewGallery`
captures its `PageController` once and never attaches a swapped-in instance.
The reader recreates the controller when the reading direction (or mode)
changes, so after "Toggle reading direction" every tap-zone page turn silently
no-oped (`hasClients == false` made `_step()` return early) while swipes kept
working through the stale controller. Nothing crashed and no unit or widget
test of the tap-zone logic could see it; only tapping the real, composed
reader exposes that class of bug (gesture wiring detached from a live view).
Steps 4-5 above are the direct regression test for it; the rest of the flow
guards the surrounding seams (open, chrome, close, resume) the same way.
