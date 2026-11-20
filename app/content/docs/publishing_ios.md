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

Without `ios.team_id`, Ruflet uses `app.ios_team_id`, then `app.team_id`
(either may also sit in the `app` section of `services.yaml`), then the
`RUFLET_IOS_TEAM_ID` environment variable, which suits CI. The `ios` section
may also be written as `build.ios` or `assets.ios`. With none of them the field
is left empty and Xcode chooses, which is usually what you want while
developing.

`ruflet build macos` writes the same team into the iOS project and leaves the
macOS project's signing to Xcode.

## Local network access

A server-driven build already declares local-network access, so a development
client can reach a Ruflet server on your computer: the client template carries
an `NSLocalNetworkUsageDescription` and `NSAllowsLocalNetworking`. A
self-contained build removes both, because its Ruby runs inside the app.

If the app itself talks to printers, cameras or other services on the local
network, declare it so every build keeps the keys with your own text:

```yaml
ios:
  local_network: true
  local_network_usage_description: Finds the printers on your network.
```

iOS shows the description when the app first reaches the local network. The
same keys under `macos:` apply to macOS builds. See
[Local network access](/docs/configuration-reference#local-network-access).

## Icon and launch screen

The launcher icon and splash come from `assets` in `ruflet.yaml`. An `ios:`
section overrides them for iOS: `icon_launcher`, `splash_screen`, `splash_dark`,
`splash_color` and the background and branding images. `content_mode` sets how
the splash image fills the launch screen, for example `scaleAspectFit`.

The template strips the alpha channel from the generated icon, as App Store
Connect requires. `ios.remove_alpha: false` does not change that.

See [Platform sections](/docs/configuration-reference#platform-sections) for
every key.

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
