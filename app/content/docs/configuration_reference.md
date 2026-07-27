# Configuration Reference

Ruflet reads project settings from `ruflet.yaml` in the project root. Set
`RUFLET_CONFIG` to read a different file. If `ruflet.yaml` is absent, Ruflet
also checks `ruflet.yml`.

## `app`

```yaml
app:
  name: my_app
  display_name: My App
  package_name: my_app
  organization: com.example
  version: 1.0.0+1
  description: A Ruflet app.
  company_name: Example Company
  bundle_identifier: com.example.my_app
  android_application_id: com.example.my_app
  ios_bundle_identifier: com.example.my_app
  macos_bundle_identifier: com.example.my_app
  linux_application_id: com.example.my_app
  short_name: MyApp
  backend_url: https://app.example.com
```

- `name` is the project and package-safe app name.
- `display_name` is the user-facing name.
- `package_name` is the generated package name.
- `organization` sets the reverse-domain organization. `org` is an accepted
  alias.
- `version` is the release version and build number.
- `description` and `company_name` supply package metadata.
- `bundle_identifier` supplies a shared Apple bundle id. The platform-specific
  `android_application_id`, `ios_bundle_identifier`,
  `macos_bundle_identifier`, and `linux_application_id` override generated ids.
- `short_name` is used by platforms with a shorter display-name field.
- `backend_url` is required for server-driven builds and must be reachable from
  the installed client.

For compatibility, Ruflet also accepts `backend_url`, `server_url`, or
`ruflet_client_url` at the document root or under `app`. Prefer
`app.backend_url` in new projects.

## `extensions`

Extensions add optional client packages. Supported keys are:

```yaml
extensions:
  - audio
  - audio_recorder
  - camera
  - charts
  - code_editor
  - color_pickers
  - datatable2
  - flashlight
  - geolocator
  - lottie
  - map
  - permission_handler
  - rive
  - secure_storage
  - video
  - webview
```

Rebuild after changing extensions. Protected service declarations can add
required extensions automatically, so applications normally declare device
permissions in `services.yaml` instead of duplicating them here.

## `assets`

```yaml
assets:
  dir: assets
  splash_screen: assets/splash.png
  splash_dark: assets/splash-dark.png
  icon_launcher: assets/icon.png
  icon_android: assets/icon-android.png
  icon_ios: assets/icon-ios.png
  icon_web: assets/icon-web.png
  icon_windows: assets/icon-windows.png
  icon_macos: assets/icon-macos.png
```

`dir` is the application asset directory. Shared splash and launcher files are
defaults; platform icon keys override the shared launcher image.

## `build`

```yaml
build:
  assets_dir: assets
  splash_screen: assets/splash.png
  splash_dark: assets/splash-dark.png
  splash_dark_image: assets/splash-dark.png
  icon_launcher: assets/icon.png
  splash_color: "#FFFFFF"
  splash_dark_color: "#0B0B0B"
  icon_background: "#FFFFFF"
  theme_color: "#FFFFFF"
```

Build-level asset keys override their counterparts under `assets`.
`splash_color_dark` is accepted as a compatibility alias for
`splash_dark_color`.

## `services.yaml`

Keep protected device access in `services.yaml`. When both configuration files
contain services, `services.yaml` takes precedence.

```yaml
services:
  - camera:
      description: Allows users to capture profile photos.
  - microphone:
      description: Allows users to record voice notes.
  - location:
      description: Shows nearby places.
  - motion:
      description: Detects device movement.
```

The supported declarations are `camera`, `microphone`, `location`, and
`motion`. A declaration can be a string or a mapping with a user-facing
`description`. Ruflet uses these entries to add client extensions, Android
permissions, iOS usage-description keys, and related platform configuration.

Request access only in response to the related user action, and write a
description that explains the benefit rather than restating the permission
name.

## Environment variables

- `RUFLET_CONFIG` selects a project configuration file.
- `RUFLET_PORT` supplies the server port when code or the CLI does not override
  it.
- `RUFLET_HOST` supplies the host for `Ruflet::App`.
- `RUFLET_CLIENT_DIR` selects an existing managed Flutter client directory for
  build and debug commands.
- `RUFLET_FLUTTER_VERSION` selects the managed Flutter SDK version before
  Ruflet falls back to the project's `.fvmrc` and then its built-in default.

Rails applications normally configure build metadata in
`config/initializers/ruflet.rb`; see [Rails API Reference](/docs/rails-api-reference).
