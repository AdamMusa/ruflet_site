# iOS Builds

Build the iOS client with:

```bash
ruflet build ios
ruflet build ios --self
```

Server-driven builds require a device-reachable `app.backend_url` in
`ruflet.yaml`.

## Permissions and usage descriptions

Declare protected access in `services.yaml`:

```yaml
services:
  - camera:
      description: Allows users to capture photos.
  - microphone:
      description: Allows users to record voice notes.
```

Ruflet uses these declarations to configure the required iOS permission
definitions and usage descriptions.

## Release requirements

iOS device installation and distribution require the normal Apple signing,
provisioning, bundle identifier, and App Store Connect setup. Test permission
flows and physical-device behavior before preparing a release build.
