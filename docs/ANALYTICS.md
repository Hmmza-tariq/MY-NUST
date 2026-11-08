# Optional usage analytics and update reminders

Analytics is disabled by native Android/iOS configuration before Firebase starts. A separate, optional consent prompt appears after biometric access and before other onboarding prompts. It has no countdown or automatic timeout; waiting or backgrounding the app never enables analytics. The About control opens a full details sheet without a timer. Every feature remains available when declined. About can enable it after confirmation or revoke it; revocation stops collection, resets local analytics data and the app instance identifier, and persists the choice. Resetting all app data also revokes analytics. This does not delete historical server-side reports.

`AnalyticsService` owns all SDK calls and an allowlist of events, parameters, values, screen names and user properties. Booleans become strings. Screens are explicitly mapped from routes rather than forwarding raw navigation names, query strings, page titles or URLs. Native automatic screen reporting is disabled to avoid duplicate/native screen names. Advertising consent is always denied and Android advertising permissions are removed.

Never add credentials, student identifiers, names, emails, portal HTML/cookies, academic values, attendance, invoices, precise location, free text or private URLs to analytics. Counts and fixed categories are allowed. News identifiers use a truncated SHA-256 of a public campus-news link; permitted reported domains are restricted to public NUST news hosts. There is no analytics `setUserId`. The SDK can derive approximate country/city from IP addresses; no location permission is requested. Fixed portal categories and opaque public-news destination identifiers are also disclosed in the consent copy and policy.

## Custom event coverage

These hooks are implemented; runtime verification in Firebase DebugView is a separate release check. Trigger wording below describes the intended action, not proof that a real portal was tested.

| ID | Event | Trigger |
| --- | --- | --- |
| E01 | `app_open` | On cold start, after splash, once per launch |
| E02 | `cred_banner_view` | When the banner becomes visible on Home (once per session max) |
| E03 | `cred_banner_click` | On tap of the banner CTA |
| E04 | `cred_banner_menu_open` | On tap of the ⋮ icon |
| E05 | `cred_banner_dismiss` | On tap of 'Don't show again' |
| E06 | `credentials_save` | After credentials are saved & verified |
| E07 | `feature_open` | On tap of any feature entry point, BEFORE navigation |
| E08 | `portal_open` | When the LMS or Qalam page finishes loading |
| E09 | `portal_error` | On WebView error, timeout, or failed auto-login |
| E10 | `gpa_tab_switch` | On tab change (not on initial load) |
| E11 | `cgpa_semester_add` | After a semester row is added |
| E12 | `cgpa_semester_delete` | After a semester is removed |
| E13 | `cgpa_calculate` | On successful calculation |
| E14 | `cgpa_download_image` | After the image is saved successfully |
| E15 | `qalam_sync_start` | On tap of Sync with Qalam |
| E16 | `qalam_sync_complete` | When sync succeeds or fails |
| E17 | `sgpa_course_add_click` | On tap of Add course, when popup opens |
| E18 | `sgpa_course_add` | After course saved from popup |
| E19 | `sgpa_course_add_cancel` | On popup dismiss without save |
| E20 | `sgpa_course_delete` | After a course is removed |
| E21 | `sgpa_calculate` | On successful calculation |
| E22 | `sgpa_add_to_cgpa` | After SGPA is pushed into the CGPA list |
| E23 | `abs_tab_switch` | On tab change |
| E24 | `abs_assessment_add_click` | On tap of Add assessment |
| E25 | `abs_assessment_add` | After assessment is saved |
| E26 | `abs_result_view` | When result screen/sheet opens |
| E27 | `abs_result_done` | On tap of Done |
| E28 | `abs_result_download` | After image saved successfully |
| E29 | `update_click` | On tap, before redirecting to the web page |
| E30 | `setting_toggle` | After toggle state changes |
| E31 | `biometric_auth` | On result of biometric prompt at app open |
| E32 | `help_open` | On tap |
| E33 | `support_contact_click` | On tap of contact/support CTA |
| E34 | `feedback_submit` | After feedback is sent / mail app opened |
| E35 | `share` | On tap of share CTA (Google recommended event) |
| E36 | `play_store_click` | On tap of Play Store CTA |

## Alignment with the current app

- E01 fires once per cold launch after consent; foreground resumes use SDK sessions. Notification launch attribution reads the initial message; quick actions use `deep_link`. Unknown attribution falls back to `direct`.
- Credential saving is not treated as verified login. E06 is emitted after saved credentials are checked through the sync flow; local form/persistence failures report failure. Portal properties reflect local saved state at startup and verified state after checking.
- E02 is capped once per session (reset after a 30-minute background gap), rather than every widget rebuild.
- Help is entered from Home in this UI, so `help_open.source` also accepts `home`; fabricating a side-menu visit would distort reports.
- There is no separate Latest updates route; its screen event is conditional on a future separate screen. News clicks on Home emit E29 with list position. Download and academic-dashboard routes are outside the supplied fixed screen dictionary and are not sent as arbitrary screen strings.
- Assessment names are user-entered. They are never reported or parsed into categories: lab assessments report `lab`, others report `other` until an explicit fixed-category selector exists.
- Existing result buttons save an image to app documents and open the system share sheet. E14/E28 report the actual file-write result, not a public gallery save or completed share. No storage permission is requested for this operation. E35 records share CTA use; E34 records email-client handoff, not confirmation an email was delivered.
- Biometrics that return false are reported as `cancelled`: the plugin cannot reliably distinguish a user cancellation from every unsuccessful authentication. Exceptions report `not_available`. No biometric information is collected.
- `first_open`, `session_start`, `user_engagement`, update/removal telemetry and SDK engagement timing are not manually duplicated. Their availability depends on consent, platform and Google's reporting pipeline.
- Crashlytics is not added: it requires its own collection/disclosure and exception-sanitization implementation. Failures are represented only by the requested fixed analytics categories.

## Update reminders

Android uses Play's update availability API for the package and signed-in user's eligible rollout. A check runs on startup and eligible foreground resumes, at most once every six hours, including after failed lookups. The same available version prompts at most once per 24 hours; a new version may prompt sooner. “Later” and back dismissal are non-blocking. “Update now” opens the official package's Play page. Settings offers a manual check that bypasses the automatic cooldown. Errors never prevent using the app. iOS is not currently published; no fictitious App Store update target is configured.

The Play lookup starts on the first app frame, independently of analytics consent. The reminder waits for the app UI and the analytics prompt to finish; it does not open over another sheet/dialog. A compact Settings card supports manual checks. Notification permission remains separate from analytics consent.

## Release checks outside the bundle

1. Publish the updated `site/privacy/index.html` before distributing the analytics build. A local policy change does not update the live policy.
2. Review Play Data Safety against Firebase's current SDK guidance. Usage events, app interactions, IP-derived approximate location, diagnostics/timings and app instance/device identifiers must be accounted for; review SDK processing, purpose, optional collection, sharing exemptions and deletion accurately. Do not copy a generic form blindly.
3. In Firebase/GA4 register the event-scoped definitions and count/time metrics used by reporting. Mark `first_open`, `credentials_save`, `cgpa_calculate`, `sgpa_calculate`, `abs_result_view` and `share` as key events. Filter failed E06/E13/E21 when building success funnels.
4. Review actual data retention, Firebase/GA4 roles, ad-product links and optional BigQuery export settings. BigQuery export is not enabled by this code change.
5. On a dedicated test device enable DebugView with `adb shell setprop debug.firebase.analytics.app com.hexagone.mynust`; verify representative allowed events, screen names and properties after acceptance. Verify no events before acceptance or after revocation. Reset with `adb shell setprop debug.firebase.analytics.app .none.`. Use test/demo data and never put student data in screenshots.
6. Exercise consent on upgrade and clean install, accept/decline/revoke/relaunch, light/dark mode, offline startup, notification/quick-action entry and biometric lock. Test real portal failures only with an authorized test account.
7. Validate update availability via a Google Play test track and an older Play-installed build owned by the test account. Sideloads, a non-Play install, an ineligible rollout or the newest build cannot prove the update-available path. Confirm the previous upload's highest version code before uploading.
8. Verify the release application ID, version and upload signature. Building or signing an AAB does not publish it to Google Play.

## References

- [Firebase Analytics collection controls](https://firebase.google.com/docs/analytics/android/configure-data-collection)
- [Firebase app consent mode](https://developers.google.com/tag-platform/security/guides/app-consent?consentmode=basic&platform=android)
- [Google Play update availability and requirements](https://developer.android.com/guide/playcore/in-app-updates)
- [Firebase Android SDK disclosure guidance](https://firebase.google.com/docs/android/play-data-disclosure)

## HTTPS enforcement

From Android 3.0.3, native network configuration denies cleartext traffic and trusts system certificate authorities only. FlutterDownloader certificate checks are enabled. Portal routing and download entry points reject HTTP and URLs containing embedded credentials; external browser actions also require HTTPS. Generated blob/data documents retain their browser fallback. iOS source explicitly retains App Transport Security for native and WebView requests; an iOS build/device check remains separate.

Untrusted links can fail when they previously depended on HTTP or invalid certificates. Keep the secure defaults and resolve the upstream endpoint instead of adding release exceptions. The encrypted-preferences key is bundled client configuration, not a substitute for device-bound hardware-backed storage.
