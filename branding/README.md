# Branding source art

Source artwork for the Mylarium app icon and launch/splash screen. Identity: a glowing
"M" monogram on a dark, cover-forward background with the violet brand accent (`#6B4EFF`).
Platform assets under `ios/` and `android/` are generated from these files, not edited by hand.

## Files

| File | Purpose |
| --- | --- |
| `icon.svg` / `icon.png` | Full-bleed app icon (iOS, legacy Android). 1024x1024, opaque. |
| `icon-fg.svg` / `icon-fg.png` | Android adaptive icon foreground (the M, transparent, inside the safe zone). Also the Android 12+ splash icon. |
| `icon-bg.svg` / `icon-bg.png` | Android adaptive icon background (dark gradient + violet glow). |
| `splash-logo.svg` / `splash-logo.png` | Centered logo for the launch/splash screen. |
| `concept-a-monogram.svg` | The chosen direction (A). `concept-b-book.svg` / `concept-c-panels.svg` are the rejected alternatives, kept for reference. |
| `final-showcase.png` | Preview of the generated iOS icon, Android adaptive icon, and splash. |

## Regenerating

The PNGs are rasterized from the SVGs with `rsvg-convert`, e.g.:

```
rsvg-convert -w 1024 -h 1024 icon.svg -o icon.png
```

Config lives in `pubspec.yaml` (`flutter_launcher_icons:` and `flutter_native_splash:`).
After editing the art, regenerate the platform assets:

```
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

The splash uses the dark brand background (`#0B0B0E`) in both light and dark mode.
