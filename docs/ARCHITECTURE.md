# My NUST v3 architecture

The refactor is intentionally incremental so existing routes and locally saved academic data remain compatible.

## Dependency direction

New feature code follows the Flutter-base boundary:

`view -> controller/state -> domain service -> platform/data adapter`

- `lib/app/domain/` contains pure, testable business rules and no GetX or platform APIs.
- feature controllers coordinate state and platform adapters.
- views render state and provide accessible actions; they do not calculate GPA or parse portal URLs.
- Android/iOS adapters expose only functionality Flutter cannot obtain safely, such as HttpOnly WebView cookies.

Legacy features can migrate behind these boundaries one module at a time without changing persisted data keys or public routes.

## Portal state model

The portal has one canonical state: `initializing`, `loading`, `ready`, `slow`, `offline`, or `failed`. A slow page remains visible and usable. Subresource errors never replace the main page with an error screen.

The app uses the platform WebView user agent and persistent cache. It does not delete portal storage at startup. Production WebView debugging is disabled. Direct documents receive native cookies and a referer header; generated `blob:` documents fall back to the system browser because they only exist inside the portal process.

## UI performance

The interface uses opaque, layered surfaces instead of blur or shader-based glass. A small surface hierarchy, an 8-point spacing rhythm, consistent 16-24 px radii, and theme-level interaction states keep the app visually coherent while remaining inexpensive on low-end devices. Entrance motion completes in under 400 ms, respects the system animation setting, and loading never depends on a continuous decorative animation.
