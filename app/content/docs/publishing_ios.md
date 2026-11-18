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

Ruflet writes each declaration's `description` into `Info.plist` under the
matching usage-description keys:

- `camera` writes `NSCameraUsageDescription`.
- `microphone` writes `NSMicrophoneUsageDescription`.
- `location` writes `NSLocationWhenInUseUsageDescription` and `NSLocationAlwaysAndWhenInUseUsageDescription`.
- `motion` writes `NSMotionUsageDescription`.
- `photo_library` writes `NSPhotoLibraryUsageDescription`.
- `biometrics` writes `NSFaceIDUsageDescription`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

Without a `description`, Ruflet writes a generic sentence such as "This app
uses camera access for its Ruflet features." Before you submit, replace it
with one that explains why the app needs access. Selecting an extension such
as `camera` or `geolocator` without its declaration also writes these keys
with the generic text, and does not select the declaration's other packages;
see [Configuration](/docs/configuration-reference#extensions). Ruflet rewrites
these keys on every build, so removing a declaration removes its key unless a
selected extension still writes it.

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
