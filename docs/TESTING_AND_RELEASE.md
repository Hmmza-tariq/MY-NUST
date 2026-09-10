# Testing and release runbook

## Automated gate

Run before every pull request and store build:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Device matrix

Test at least one low-memory Android device, a current Android device, and a physical iPhone. Repeat with Wi-Fi and mobile data where available.

## Portal acceptance checks

- Qalam and LMS login pages render without a blank overlay.
- Navigate forward/back, background the app, restore it, and reload.
- A slow page shows a non-blocking notice after 12 seconds; the page remains visible.
- Offline mode offers retry, then reloads automatically after reconnection.
- Download invoice and mess challans from both direct links and print icons.
- Verify the OS notification starts only after a task is accepted and opens the completed file.
- Verify generated/unsupported documents open in the system browser with clear guidance.
- Confirm external and custom-scheme links do not execute inside the WebView.

## Calculator acceptance checks

- Create completed semesters, switch to SGPA, and add planned courses.
- Changing one grade or credit updates semester GPA, projected CGPA, and delta immediately.
- Confirm weighted results against a hand calculation.
- Empty data never produces `NaN` or `Infinity`.

## Release evidence

Archive screenshots/video for the four critical flows above, attach `flutter test` and `flutter analyze` output, and record the tested OS/device versions. A successful compile is not proof of portal, download, notification, signing, or App Store behavior.

## Latest physical-device check

Checked on a Pixel 6 on 2026-09-09:

- Home, GPA planner, absolute score, settings, help, and about rendered with the v3 dark theme and solid layered surfaces.
- LMS opened `https://lms.nust.edu.pk/login/index.php` without the retired `/portal/my` 404.
- Qalam opened from `https://qalam.nust.edu.pk/` and followed the server redirect to `/web/login`.
- Cached campus stories remained visible when the upstream news request returned an error.
- Portal challan download code, cookie forwarding, and browser fallback passed source and automated checks. A private invoice or mess challan still requires a logged-in student account for end-to-end device evidence.
