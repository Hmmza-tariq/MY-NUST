# Google Play Data Safety review

This is a code-based review guide for Android 3.0.4, not a submitted form or certification. Complete the form against the actual distributed build, enabled SDK/console features and your handling of support data. Review each SDK's guidance after dependency updates.

## Data types to review

| Data type | Current path | Optionality and purpose |
| --- | --- | --- |
| Approximate location | Google Analytics can derive country/city from IP addresses. No location permission is requested. | Optional with analytics consent; Analytics. |
| Name and email address | The feedback form prepares an email to support containing the information the user supplies. | Optional support flow; App functionality / support, according to actual use. These fields are excluded from analytics. |
| User IDs | Student account identifiers are sent directly to official university services for portal login. | Optional portal connection; App functionality. These are distinct from Firebase installation IDs. |
| Emails | User-initiated support correspondence, including the prepared message body. | Optional support flow; App functionality / support, according to actual use. Opening the composer does not prove a message was sent. |
| App interactions | Feature taps, fixed screen names, counts, settings and other allowlisted actions. | Optional with analytics consent; Analytics. |
| Web browsing history | Limited portal categories and public-news destination activity; no unrestricted history or full private URLs are sent to analytics. | Optional with analytics consent; Analytics. |
| Diagnostics | Allowlisted load/sync timings and categorized failure events. | Optional with analytics consent; Analytics. Crashlytics is not included. |
| Device or other IDs | Analytics app-instance ID and Firebase installation/messaging identifiers. | Analytics IDs are optional, but Firebase installations/messaging can operate independently of analytics consent. Do not mark the entire data type optional unless every collection path can be opted out of. Purposes include App functionality, developer notifications and optional Analytics as actually used. |

Academic records, downloaded documents, local planner content and biometric templates are not sent to analytics. Local-only access or downloads to the device do not by themselves establish off-device collection of the corresponding data type. Reassess if a new feature uploads or shares those values.

## Collection, sharing and retention

- Declare off-device collection even when it goes directly to an SDK or portal service rather than your own backend. Controlled WebView behavior, such as credential autofill and sync, needs review separately from general open-web browsing.
- Review whether each transfer qualifies for Google's service-provider or user-initiated-sharing exemption. Firebase client use does not automatically prove that every linked service or data-sharing setting qualifies. Check GA4 Google Signals, Ads links, data-sharing options and exports before selecting “not shared.”
- Retained analytics reports are not ephemeral processing. An IP address being transient does not make retained derived geographic information ephemeral.
- Analytics consent is optional, remembered, and managed in About. The startup prompt has no timeout and analytics stays off until an explicit opt-in. Viewing or closing details does not enable collection. A previous affirmative choice enables collection on subsequent launches until revoked.
- Revocation resets local analytics data/identifier and stops further collection; it does not automatically delete historical server-side reports. Review actual GA4 retention and support-deletion procedures.
- The app offers login to existing university accounts, not creation of a separate developer account. Device biometrics protect local app access rather than creating an account.

## Security and release

Android 3.0.3 disables cleartext traffic, restricts native trust to system certificate authorities, requires HTTPS at portal/download entry points and enables downloader certificate checks. Confirm all active network/SDK paths before making the form's all-data encryption declaration. External browser/email services handle their own traffic. Earlier app versions may differ.

The native manifest/Info.plist contain consent and platform network controls; Data Safety declarations themselves are submitted in Play Console. Publish and verify the matching privacy policy before distribution. Do not claim an independent security-review badge without the qualifying external assessment.

## Primary references

- [Google Play definitions, data types and exemptions](https://support.google.com/googleplay/android-developer/answer/10787469)
- [Google Analytics SDK disclosures](https://support.google.com/analytics/answer/11582702)
- [Firebase Android SDK disclosures](https://firebase.google.com/docs/android/play-data-disclosure)
- [Google Play services SDK disclosures](https://developers.google.com/android/guides/play-data-disclosure)
