# Build and Release

Ruflet builds the managed Flutter client for Android, iOS, web, macOS,
Windows, and Linux.

## Build targets

```bash
ruflet build apk
ruflet build aab
ruflet build ios
ruflet build ipa
ruflet build web
ruflet build macos
ruflet build windows
ruflet build linux
```

`android` is an alias for an Android APK build. `ipa` produces the iOS archive
you upload to App Store Connect, where `ios` produces an app for a device.

## Naming the app

The identity every build uses comes from `ruflet.yaml`:

```yaml
app:
  name: My App
  package_name: my_app
  organization: com.example
  version: 1.0.0+1
  description: A new Ruflet app.
```

From these Ruflet derives the display name, the bundle identifier
(`com.example.my_app`), and the version and build number written into each
platform. A mobile build stops if the name, package name, or organization is
missing.

## Server-driven builds

Server-driven is the default build mode. The installed client connects to a
deployed Ruby or Rails server, so configure a reachable HTTPS URL:

```yaml
app:
  backend_url: https://app.example.com
```

Do not use `localhost` in a build intended for another device.

`backend_url` may be omitted for web and desktop clients, which learn their
server at launch: a web client from the origin it is served from, a desktop
client from the URL its launcher passes.

## Self-contained builds

Use `--self` to package the Ruby project with the client:

```bash
ruflet build android --self
ruflet build ios --self
```

Choose this mode when the app should run without a remote Ruflet server.

## Extensions and permissions

Optional client packages belong in `ruflet.yaml`:

```yaml
extensions:
  - charts
  - map
  - webview
```

Protected device access belongs in `services.yaml`:

```yaml
services:
  - camera:
      description: Allows users to capture photos.
```

Rebuild after changing either file.

## Assets

```yaml
assets:
  dir: assets
  splash_screen: assets/splash.png
  icon_launcher: assets/icon.png

build:
  splash_color: "#FFFFFF"
  splash_dark_color: "#0B0B0B"
  icon_background: "#FFFFFF"
  theme_color: "#FFFFFF"
```

## Install a build

```bash
ruflet install
ruflet install --device DEVICE_ID
```

Run the intended platform build early. Native signing, permissions, and store
requirements are platform-specific and should not be left until release day.
