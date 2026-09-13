# Store artwork — September 2026

## Upload files

- `screenshots/01-home.jpg` — 1080 × 1920
- `screenshots/02-academics.jpg` — 1080 × 1920
- `screenshots/03-cgpa.jpg` — 1080 × 1920
- `screenshots/04-sgpa.jpg` — 1080 × 1920
- `screenshots/05-absolute.jpg` — 1080 × 1920
- `screenshots/06-downloads.jpg` — 1080 × 1920
- `feature-1024x500.jpg` — Google Play feature graphic
- `social/product-1920x1080.jpg` — LinkedIn/product catalog

JPEG exports are opaque. Original generated artwork is under `source/`.
Six page captures were taken directly from the connected Pixel; private captures
are NOT included in this public directory. Names, GPA values, course histories,
attendance values and filenames in published artwork use sample data.
No portal credentials, account identifiers or real grades belong in this folder.
The running account and its planner were not edited to produce promotional data.

Artwork was created with the built-in image-generation tool, then deterministically
resized/exported using macOS `sips`. These are promotional mockups, not unedited
screen captures. Review text and UI accuracy before publishing. Branding rights
and store approval are separate from image sizing; these assets retain the current
name/logo and do not resolve the earlier Apple authorization concern.

## Campaign prompt set

Common direction: ONE finished portrait 9:16 Google Play artwork; insert the
corresponding real app screenshot inside a realistic Android Pixel phone. Preserve
existing UI and controls; use sample data only. Pale ice-blue/lavender softly
textured backdrop with subtle geometric curves, navy editorial typography, large
readable phone below the headline, restrained shadows. Normalize the status bar
to 9:41 with no notifications. Footer: “My NUST · Independent student companion”.
No invented features, ratings, endorsements, awards or grade-improvement promises.
The first finished Home artwork serves as campaign style reference for the others.

1. Home: “Your semester. At a glance.” / “GPA, portals and academic tools in one
   place”. Greeting “Hey, Hamza!”, Official CGPA 3.80, Fall 2026 SGPA 3.90.
2. Academics: “Your academic day. Clearly organised.” / “Timetable, deadlines and
   attendance”. Preserve empty timetable/deadline states. Sample Programming
   Fundamentals, CS-101, Fall 2026, 3 credits, attendance 92%, 17% above minimum 75%.
3. CGPA: “Plan every semester. See the bigger picture.” / “Import results and
   explore your CGPA”. Three sample terms with 18 credits each and GPAs 3.75,
   3.80, 3.85; overall 3.80 and 54 completed credits. Follow-up correction removes
   an unnecessary fourth zero-GPA term without changing the surrounding artwork.
4. SGPA: “Small changes. Clear GPA impact.” / “Adjust grades and compare your
   projection”. Semester 3 (fall-2026), SGPA 3.90, current CGPA 3.80, projection
   3.83, +0.03; sample Programming Fundamentals and Discrete Mathematics courses.
5. Absolute: “Weighted marks. Made simple.” / “Calculate lecture and lab
   assessments”. Keep actual Lecture/Lab/Both flow and controls; Practice Quiz,
   weight 10%, total marks 10, sample marks 9. No invented result display.
6. Downloads: “Your documents. Within easy reach.” / “Find, open and manage saved
   files”. Two neutral sample filenames: Semester_Timetable.pdf and
   Hostel_Application_Form.pdf. Preserve existing browse/open/delete layout.
7. Feature: wide 1024 × 500, sanitized Home and SGPA phones on the right; left
   “My NUST”, “Your semester, simplified.”, “GPA planning · Academic summaries ·
   Downloads”, “Independent student companion”. Match campaign styling and safe
   margins; opaque background, no badges or additional claims.
8. Social: landscape 16:9, three sanitized Home/SGPA/Downloads Pixel phones on the
   right. Left “My NUST”, “Your semester, simplified.” and “GPA planning.
   Academic summaries. Saved documents.” Same campaign style and privacy limits.

## Splash regeneration

Source: `assets/images/transparent.png` (unchanged).
`tool/export_raster.swift` pads the logo without redrawing it. Android 12 inputs
are 1152 × 1152 with 720px artwork, inside the documented 768px safe circle.
Dark variants add a light circular backing for readable blue-logo contrast.
Backgrounds: light #F8F9FF, dark #101418. Legacy bottom branding is replaced by
theme-aware “Powered by Hexagone” artwork using the updated company logo variants.
Unused legacy source branding assets were removed from the app.

Regenerate with `dart run flutter_native_splash:create` after configuring inputs
in `pubspec.yaml`. Both native splash themes were checked on the Pixel. iOS
resources were regenerated too, but not device-tested or archive-validated here.

References:

- https://pub.dev/packages/flutter_native_splash
- https://support.google.com/googleplay/android-developer/answer/9866151
