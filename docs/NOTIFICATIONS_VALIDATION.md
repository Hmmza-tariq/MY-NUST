# Notification validation — 13 September 2026

## Implemented fixes

- Google Services Gradle plugin enabled for native Firebase config generation.
- JSON Android package and Firebase project match the Dart configuration.
- Plugin/channel initialization is awaited before foreground display.
- Stable high-importance `default_channel_id` matches manifest metadata.
- A monochrome notification small icon replaces legacy colored logo bitmaps.
- Message handling no longer assumes notification/Android metadata exists.
- Startup initialization covers quick-action launches, not only Home.
- Notification route payloads are preserved for local notification taps.
- Token refresh is handled without logging tokens or message/account contents.
- Manual duplicate Android FCM service removed; plugin/SDK services remain.
- iOS Firebase AppDelegate swizzling enabled as required by FlutterFire.

## Observed proof

- Flutter analyzer clean; 52 tests pass including notification routing.
- Debug APK built and installed on the connected Pixel without clearing user data.
- Notification permission granted on Pixel.
- Device log: `FCM ready: authorized; token registered; topic all.`
- OS channel exists with importance 4 (high), sound and badge enabled.
- Release AAB built; image/video media permissions remain absent.
- Native powered-by splash checked in both system light and dark mode.

## Still required before claiming end-to-end delivery

A Firebase Console HTTP-v1 test push must be sent to this single Pixel's token,
then verified in foreground, background, and normal terminated state (not Android
force-stop), including tap navigation. No Firebase sender credentials or working
authenticated Console browser were available in this session. Token registration
and a successful build do NOT prove a remote notification was received.

Do not send a test message to the `all` topic; that could notify production users.
Retrieve the token privately for the single-device Console test; never commit it.

iOS additionally needs confirmed Push Notifications capability, signed APNs
entitlements, an APNs key uploaded to the correct Firebase project, and testing
on a signed physical iPhone. No entitlements file was found in the source audit.
An Android Pixel test does not establish iOS delivery.

References:

- https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages
- https://firebase.google.com/docs/cloud-messaging/flutter/get-started
- https://firebase.google.com/docs/android/setup
