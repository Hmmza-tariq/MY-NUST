# Changelog

## Unreleased

- Refined the Material 3 interface across authentication, portals, calculators, settings, help, and downloads.
- Added native portal downloads, a downloaded-files library, review prompts, domain services, regression tests, documentation, and release tooling.
- Updated Android and iOS configuration for the current release and improved portal recovery, GPA, CGPA, absolute-score, and campus-selection flows.
- Removed obsolete visual assets, generated files, and unused asset constants.

## 3.0.0+32

- Rebuilt Qalam/LMS loading around a non-blocking portal state model.
- Added authenticated native document downloads and browser fallback for generated challans.
- Removed startup cache deletion, stale user-agent overrides, and production WebView debugging.
- Restored live SGPA-to-CGPA projections with exact credit weighting.
- Introduced a low-cost layered surface system with consistent spacing, radii, interaction states, and accessible contrast.
- Added pure domain services, regression tests, architecture notes, and a device release runbook.
- Added an NUST authorization request, letter template, and App Review response pack.
- Replaced retired LMS routing with the current login and made Qalam follow its server-managed login redirect.
- Applied the solid premium design system across home, calculators, portal chrome, settings, help, about, and authentication; removed the glass shader dependency.
- Rebuilt the GPA and absolute-score flows with guided inputs, editable examples, clearer empty states, and live academic projections.
- Added branded confirmation dialogs and sheets, consistent dropdowns and buttons, and light portal controls for light web content.
- Removed the indefinite hexagon loader in favor of bounded progress, skeletons, and actionable slow/offline states.
- Replaced the previous visual layer with a Material 3 token-based theme: tonal surfaces, Roboto typography, accessible contrast, consistent 12/28 dp shapes, pill actions, and restrained motion.
- Fixed campus selection and refresh progress so both update immediately without requiring a manual reload.
- Fixed GPA editor reactivity so credit and grade changes instantly update the selected controls, SGPA, and projected CGPA.
- Simplified Absolute score onboarding with Lecture-first setup, clearer field labels, and an editable starter example.
- Added an FAQ-ready Help section and removed redundant app-bar actions from Help, Settings, and About.
- Added static Material 3 background shapes and broader primary, secondary, and tertiary tonal accents without GPU-heavy blur effects.
- Made the app theme preference independent from the phone theme and kept modal sheets on the selected app theme.
- Added searchable, boxed campus selection and guided bottom-sheet creation flows for semesters, courses, and assessments.
- Replaced the course-grade dropdown with faster plus/minus grade controls and added restrained progress/achievement feedback to calculators.
- Added a quota-aware native in-app review prompt after repeated successful calculator outcomes.
- Added six support-derived FAQ answers plus a redacting Gmail-to-Drive support export script.
- Replaced semester GPA sliders with exact 0.00–4.00 decimal entry, including values such as 3.39, and compacted semester/course controls.
- Redesigned CGPA/SGPA selection and result breakdowns with clearer Material 3 fields and comparable score bars.
- Added pinned Sliver headers to Home, GPA Planner, and Absolute Score for steadier navigation while scrolling.
- Added an in-app Downloaded Files library for refreshing, opening, and safely deleting files saved from portal pages.
- Unified the CGPA/SGPA semester selectors and exact GPA/credit controls with equal-height Material 3 selection tiles.
- Fixed Android public-download discovery, including MediaStore duplicate names such as `(1)`, while excluding unrelated files.
- Forced portal loading and recovery overlays to use a readable light color scheme over light web content.
