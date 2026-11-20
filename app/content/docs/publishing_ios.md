# iOS Builds

Build the iOS client with:

```bash
ruflet build ios
ruflet build ios --self
```

For an archive you can upload to App Store Connect, build an IPA:

```bash
ruflet build ipa --self
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

## Signing

Name the Apple team that signs the app in `ruflet.yaml`:

```yaml
ios:
  team_id: ABCDE12345
```

Ruflet writes it into the Xcode project during the build. Signing itself is
automatic: Xcode issues and renews the distribution certificate, so sign in to
that team under Xcode → Settings → Accounts once and no certificate has to be
created by hand.

Without `team_id` the field is left empty and Xcode chooses, which is usually
what you want while developing.

## Store listing

The version and build number come from `app.version` in `ruflet.yaml`:

```yaml
app:
  name: My App
  package_name: my_app
  organization: com.example
  version: 1.0.0+1
```

The number after `+` is the build number. App Store Connect rejects an upload
that reuses one for the same version, so raise it for every upload.

## Release requirements

Test permission flows and physical-device behaviour before preparing a release
build. App Store Connect submission and review stay a normal Apple release
responsibility.
