# Lumen Gallery

A Flutter prototype that lets visitors walk down a virtual art-gallery corridor and explore paintings hung on the walls. The app renders a cream-white gallery aisle with a blue-grey carpet. Visitors move through it with swipes, on-screen controls, or by turning their phone. Tapping a painting opens its details.

> The name "Lumen Gallery" is a working title. Rename it to suit your museum or brand.

## Features

- **Walkthrough illusion:** walls, ceiling, carpet and lights share one perspective camera, so the corridor recedes convincingly.
- **Paintings on the wall:** each frame is projected onto the wall plane, so it angles down the aisle as if it were hung there.
- **Smooth walking:** swipe up or down, or use the arrow buttons. Movement is eased, so paintings grow as you approach and slide past as you go by.
- **180° looking range:** look from the left wall (-90°) to the right wall (+90°) by swiping sideways, using the slider, or using the look buttons.
- **Tilt to look:** turn your phone and the view follows. The view drifts back to centre when you stop, so it never gets stuck facing a wall.
- **Artwork details:** tapping a painting opens a bottom sheet with its title, artist, medium and description.
- **Accessibility aids:** every control has a tooltip, and swipe, slider and button controls all work without tilt.

## Controls

| Action | Control |
|---|---|
| Walk forward or back | Swipe up or down, or use the arrow buttons |
| Look left or right | Swipe sideways, use the slider, or use the chevron buttons |
| Look around with the phone | Turn your phone (needs a gyroscope) |
| Turn tilt on or off | Rotate icon in the top bar |
| Reverse tilt direction | Swap icon in the top bar |
| Reset view | Centre-focus button |
| See artwork information | Tap a painting |

## Tech stack

- Flutter and Dart, Material 3
- `CustomPainter` and `Canvas` for the corridor, carpet and paintings
- A small perspective camera and homography mapping written in Dart, with no 3D engine
- [`sensors_plus`](https://pub.dev/packages/sensors_plus) for gyroscope input

## Getting started

### Prerequisites

- Flutter SDK (the `sensors_plus` package needs Flutter 3.19+ and Dart 3.3+)
- Android Studio or VS Code with the Flutter extension
- A physical phone to test tilt. Emulators usually don't supply gyroscope data.

### Install and run

```bash
git clone <your-repo-url>
cd lumen_gallery
flutter pub get
flutter run
```

If you create the project from scratch:

```bash
flutter create lumen_gallery
cd lumen_gallery
flutter pub add sensors_plus
```

Then replace `lib/main.dart` with this project's `main.dart`.

### iOS setup

Add a motion usage description to `ios/Runner/Info.plist`. Without it, the app will crash when it reads motion data.

```xml
<key>NSMotionUsageDescription</key>
<string>Motion access lets you look around the gallery by turning your phone.</string>
```

## Project structure

```text
lib/
└── main.dart
    ├── GalleryApp / GalleryPage   App shell, controls, gestures, gyroscope
    ├── Art + collection           Artwork data (demo content)
    ├── Camera / V3                Perspective projection and near-plane clipping
    ├── CorridorPainter            Walls, ceiling, carpet, lights and paintings
    ├── quadMatrix                 Maps each flat painting onto its wall shape
    └── paintArt / ArtPreview      Placeholder artwork drawing
```

## Customising

### Add your own artworks

Edit the `collection` list. Each entry holds a title, artist, medium, description, position along the aisle (`z`), wall side (`-1` left, `1` right) and placeholder colours.

```dart
Art('Title', 'Artist', 'Medium', 'Description', 8.0, -1,
    [Color(0xFF163C51), Color(0xFF5197A2), Color(0xFFF0D4A1)]),
```

To use real images, load an `ui.Image` for each artwork and draw it inside `paintArt` instead of the gradient.

### Change painting size

In `visibleArt()`, adjust `halfWidth`, `bottomY` and `topY`. The defaults give frames 1.7 m wide and 2.1 m tall, with walls 3.5 m high.

### Change the corridor

In `CorridorPainter.paint()`, change `start`, `end`, `width` and `height` for the corridor size. The wall, ceiling and carpet colours are set in the `surface(...)` calls and the carpet gradient.

### Tune tilt

In `_startTilt()`, change the dead zone (`0.12`) and the gains (`1.3` for turning, `0.08` for pitch). In the ticker, change the return speed (`dt * 0.9`).

## Known limitations

- It is a perspective-rendered walkthrough, not a full 3D engine. Paintings are hidden when they cross the camera's near plane.
- The artwork, artists and descriptions are fictional placeholders.
- Tilt direction depends on the device's gyroscope axes. Use the swap button if it turns the wrong way.
- Tilt is relative, not an absolute compass, so the view drifts back to centre by design.
- Most of the work is redrawn on every frame, which is fine for this scene but worth profiling if you add many more paintings or images.

## Roadmap ideas

- Real artwork images loaded from assets or a CMS (Firebase, Supabase or a REST API)
- Multiple rooms and an exhibition map
- Audio guide playback and artist biographies
- Search, favourites and sharing
- QR or NFC scanning to link physical wall labels to digital entries
- Pinch-to-zoom on the artwork detail view
- Localisation, including Swahili




