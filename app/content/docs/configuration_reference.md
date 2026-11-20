# Configuration Reference

Ruflet reads project settings from `ruflet.yaml` in the project root. Set
`RUFLET_CONFIG` to read a different file. If `ruflet.yaml` is absent, Ruflet
also checks `ruflet.yml`. A `services.yaml` next to that file is read too; see
[`services.yaml`](#services-yaml).

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

- `name` is the app name. The display name and the package name fall back to it.
- `display_name` is the user-facing name. `app_name` is another spelling that outranks it: the display name is the first of `app_name`, `display_name` and `name` that is set. `ruflet new` writes `app_name` into `services.yaml`.
- `package_name` is the package-safe name, used for the Flutter package and the default identifiers. Without it, Ruflet derives one from `app_name`, `display_name` or `name`.
- `organization` sets the reverse-domain organization. `org` is an accepted alias.
- `version` is the release version and build number, for example `1.0.0+1`.
- `description` is the package description. `company_name` appears in the macOS copyright and the Windows company and copyright fields, and defaults to the organization.
- `bundle_identifier` is the identifier every platform uses, by default `organization.package_name`. The platform-specific `android_application_id`, `ios_bundle_identifier`, `macos_bundle_identifier`, and `linux_application_id` override it.
- `short_name` is the web manifest's short name and the web app title on iOS home screens. It defaults to the display name.
- `backend_url` is required for server-driven builds and must be reachable from the installed client.
- `ios_team_id` and `team_id` are fallbacks for the Apple signing team; see [`ios`](#ios).

An `apk`, `android`, `aab` or `ios` build stops unless `name` (or `app_name`
or `display_name`), `package_name` and `organization` (or `org`) are set
under `app`, in `ruflet.yaml` or in `services.yaml`.

For compatibility, Ruflet also accepts `backend_url`, `server_url`, or
`ruflet_client_url` at the document root or under `app`. Prefer
`app.backend_url` in new projects.

Older projects may state the identity at the document root instead: `name`,
`display_name`, `package_name`, `organization`, `org`, `bundle_identifier`,
`description`, `version`, `company_name`, `android_application_id`,
`ios_bundle_identifier`, `macos_bundle_identifier`, `linux_application_id`
and `short_name`. A key under `app` wins over its root spelling. The root
spellings name the app on every platform, but they do not satisfy the mobile
check above, so a mobile build still needs the three keys under `app`.

## `extensions`

Extensions add optional client packages. Supported keys are:

```yaml
extensions:
  - ads
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
  - qrcode_scanner
  - rive
  - secure_storage
  - spinkit
  - video
  - webview
```

`local_auth` adds the [Local Authentication service](/docs/service-local-authentication). **Requires the next Ruflet release** (on `main`, not in 0.0.23).

Some extensions need device access. Selecting one writes the platform
permissions and usage descriptions of a [`services.yaml`](#services-yaml)
declaration, but it does not select that declaration's other extensions:

- `audio_recorder` writes the `microphone` permissions.
- `camera` writes the `camera` permissions.
- `flashlight` writes the `camera` permissions.
- `geolocator` writes the `location` permissions.
- `qrcode_scanner` writes the `camera` permissions.
- `local_auth` writes the `biometrics` usage description. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

These permissions get a generic usage description. To supply your own text,
declare the service in `services.yaml` as well. The declaration also selects
its extensions, such as the `permission_handler` that `page.permission_handler`
needs. Rebuild after changing extensions. Protected service declarations can
add required extensions automatically, so applications normally declare device
permissions in `services.yaml` instead of duplicating them here.

## `assets`

```yaml
assets:
  splash_screen: assets/splash.png
  splash_dark: assets/splash-dark.png
  icon_launcher: assets/icon.png
  icon_android: assets/icon-android.png
  icon_ios: assets/icon-ios.png
  icon_web: assets/icon-web.png
  icon_windows: assets/icon-windows.png
  icon_macos: assets/icon-macos.png
```

`assets` holds the splash screen and launcher icon settings every platform
shares. Ruflet passes them to the client's
[flutter_native_splash](https://pub.dev/packages/flutter_native_splash) and
[flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)
configuration on every build, then runs both generators. Image paths are
relative to `ruflet.yaml`; in a Rails app Ruflet also looks under `app/`.

The splash generator writes Android, iOS and web splash screens. The icon
generator writes Android, iOS, web, macOS and Windows icons. Desktop builds
therefore have no generated splash screen, and Linux builds have no generated
icon: Ruflet ignores those settings and prints a build note.

When a shared `splash_screen` or `icon_launcher` file does not exist, the
build notes it and keeps the client's default image. A missing platform
`splash_screen` or `icon_launcher` is noted and skipped, and any other missing
image is skipped.

`dir`, `build.assets_dir` and a root-level `assets_dir` are read but change
nothing in 0.0.23 or on `main`: `ruflet run` serves the `assets` directory
next to the script, and the image paths here are relative to `ruflet.yaml`.

### Shared splash and icon keys

Each of these may sit under `assets` or under `build`. A `build` value is read
first. `splash_screen` and `icon_launcher` are also read at the document root,
last.

| Key | Value | What it sets |
| --- | --- | --- |
| `splash_screen` | image path | The splash image. |
| `splash_dark` | image path | The dark-mode splash image. `build.splash_dark_image` is an alias. |
| `splash_color` | hex color | The splash background color. |
| `splash_dark_color` | hex color | The dark-mode splash background color. `splash_color_dark` is an alias. |
| `splash_background_image` | image path | An image drawn behind the splash. `build.background_image` is an alias. |
| `splash_background_image_dark` | image path | The dark-mode background image. |
| `splash_branding` | image path | A branding image shown with the splash, for example a logo near the bottom. |
| `splash_branding_dark` | image path | The dark-mode branding image. |
| `splash_branding_mode` | `bottom`, `bottomLeft` or `bottomRight` | Where the branding image sits (flutter_native_splash `branding_mode`). `branding_mode` is an alias. |
| `splash_branding_bottom_padding` | integer | Space between the branding image and the bottom of the screen. `branding_bottom_padding` is an alias. |
| `icon_launcher` | image path | The launcher icon for every platform that has no icon of its own. |
| `icon_background` | hex color | The launcher icon background: the Android adaptive icon background and the web icon background, unless their own keys are set. |
| `theme_color` | hex color | The web manifest and web icon theme color. |

The client template starts with `fullscreen: true` for the splash and a
white splash and icon background. Ruflet changes only what you configure.

### Per-platform image keys

These shorthands in the shared sections give one platform its own image:

- `splash_<platform>` under `assets` or `build` is that platform's splash image.
- `splash_<platform>_dark` under `assets` is its dark-mode splash image.
- `icon_<platform>` under `assets` or `build` is its launcher icon.
- `splash_background_<platform>` under `assets` is its splash background image.

`<platform>` is `android`, `ios`, `web`, `macos`, `windows` or `linux`. A
[platform section](#platform-sections) value wins over the shorthand. Only
`android`, `ios` and `web` use the splash keys, and `icon_linux` is ignored.

### Android keys in the shared sections

`assets` also accepts these fallbacks for the [`android`](#android) section:

- `splash_android_12` and `splash_android_12_dark`: the Android 12+ splash images.
- `icon_adaptive_foreground` (alias `icon_foreground`): the adaptive icon foreground.
- `icon_adaptive_background_image`: the adaptive icon background image.
- `icon_adaptive_monochrome`: the themed (monochrome) adaptive icon.

`build.min_sdk_android` is the fallback for `android.min_sdk`.

## `build`

```yaml
build:
  splash_screen: assets/splash.png
  splash_dark: assets/splash-dark.png
  splash_dark_image: assets/splash-dark.png
  icon_launcher: assets/icon.png
  splash_color: "#FFFFFF"
  splash_dark_color: "#0B0B0B"
  icon_background: "#FFFFFF"
  theme_color: "#FFFFFF"
```

Build-level asset keys override their counterparts under `assets`; every
[shared key](#shared-splash-and-icon-keys) works here.
`splash_color_dark` is accepted as a compatibility alias for
`splash_dark_color`.

`full_runtime_path` points `--full` builds at a CRuby runtime distribution.
See [Self-contained builds](/docs/build-and-release#self-contained-builds).

## Platform sections

A section named after a platform overrides the shared values for that
platform: `android`, `ios`, `web`, `macos`, `windows` or `linux`. Write it at
the document root, or as `build.<platform>` or `assets.<platform>`. Ruflet
merges the three key by key, and a later one wins: the root section, then
`build.<platform>`, then `assets.<platform>`.

```yaml
assets:
  splash_screen: assets/splash.png
  icon_launcher: assets/icon.png

android:
  adaptive_icon_foreground: assets/icon-foreground.png
  adaptive_icon_background: "#0F172A"
  splash_android_12: assets/splash-android-12.png

ios:
  team_id: ABCDE12345
  splash_color: "#0F172A"

web:
  icon_launcher: assets/icon-web.png
  theme_color: "#0F172A"
```

Every platform section accepts these keys:

- `splash_screen` (alias `splash_image`) and `splash_dark` (alias `splash_dark_image`): the splash images.
- `splash_color` and `splash_dark_color` (alias `splash_color_dark`): the splash background colors. A value equal to the shared one is not repeated.
- `splash_background_image` (alias `background_image`) and `splash_background_image_dark` (alias `background_image_dark`): the background images.
- `splash_branding` (alias `branding`) and `splash_branding_dark` (alias `branding_dark`): the branding images.
- `icon_launcher` (alias `icon`): the launcher icon. A Windows icon may be an `.ico` file.
- `icon_background` and `theme_color`: read by the `web` section for the web icons and manifest. The `android` section's values are used only when the shared keys are unset.

As with the shorthands, only `android`, `ios` and `web` draw a splash, and
Linux has no icon generator.

### `android`

- `splash_android_12` (alias `android_12_image`) and `splash_android_12_dark` (alias `android_12_image_dark`): the image Android 12 and later show on the system splash. Without one, Ruflet uses the Android splash image, then the shared one.
- `splash_android_12_icon_background_color` (alias `icon_background_color`) and `splash_android_12_icon_background_color_dark` (alias `icon_background_color_dark`): the circle behind that image. They default to the Android splash colors.
- `splash_android_12_color` (alias `android_12_color`) and `splash_android_12_color_dark` (alias `android_12_color_dark`): the Android 12+ splash background.
- `splash_android_12_branding` (alias `android_12_branding`): the Android 12+ branding image.
- `adaptive_icon_foreground` (alias `icon_foreground`): the adaptive icon foreground. It defaults to the Android icon, then the shared icon.
- `adaptive_icon_background`: the adaptive icon background color. It defaults to the shared `icon_background`.
- `adaptive_icon_background_image`: a background image, used instead of the color.
- `adaptive_icon_monochrome` (alias `icon_monochrome`): the monochrome image Android uses for themed icons.
- `min_sdk` (alias `min_sdk_android`): the minimum Android API level flutter_launcher_icons assumes when it generates the icons. The template sets 21. It does not change the app's `minSdkVersion`.
- `splash_fullscreen` (alias `fullscreen`): `true` hides the status bar while the splash shows, `false` keeps it. The template sets `true`.
- `splash_gravity` (alias `android_gravity`): how the splash image is placed, as an Android gravity such as `center` or `fill`.

### `ios`

- `team_id`: the Apple development team written into the iOS Xcode project. Without it Ruflet falls back to `app.ios_team_id`, then `app.team_id`, then the `RUFLET_IOS_TEAM_ID` environment variable, and otherwise leaves the team empty for Xcode to choose. `ruflet build macos` writes this team into the iOS project as well; Ruflet sets no team in the macOS project. See [iOS signing](/docs/publishing-ios#signing).
- `local_network`: `true` declares local-network access. See [Local network access](#local-network-access).
- `local_network_usage_description`: the text of the local-network prompt.
- `content_mode` (alias `ios_content_mode`): how the splash image fills the iOS launch screen, as a `UIView.ContentMode` name such as `center` or `scaleAspectFit`.
- `remove_alpha` (alias `remove_alpha_ios`): the template already strips the alpha channel from the iOS icon, as the App Store requires. `remove_alpha: false` does not turn that off in 0.0.23 or on `main`: Ruflet writes the setting only when it is `true`.

### `web`

- `image_mode` (alias `web_image_mode`): how the splash image is drawn on the web page: `center`, `contain`, `stretch` or `cover`.
- `icon_background` and `theme_color`: the web icon background and the manifest theme color.

### `macos`

- `local_network` and `local_network_usage_description`: as for `ios`.

The macOS signing team is not read from `ruflet.yaml`. Set it in Xcode.

### `windows`

- `icon_size`: the size in pixels of the generated Windows icon. The template sets 48.

### `linux`

The `linux` section accepts the keys every section does, but Linux builds
generate neither a splash screen nor an icon.

### Local network access

Set `local_network: true` in the `ios` or `macos` section when the app talks to
devices or services on the local network:

```yaml
ios:
  local_network: true
  local_network_usage_description: Finds the printers on your network.
```

The build writes `NSLocalNetworkUsageDescription`, with your text or "Connect
to Ruflet applications and services on your local network.", and sets
`NSAllowsLocalNetworking` under `NSAppTransportSecurity`. Only the YAML value
`true` counts; the string `"true"` does not. The `ios` section covers `ios` and
`ipa` builds, and `macos` covers `macos` builds.

Without `local_network`, a self-contained build removes both keys. A
server-driven build leaves them as the client template has them: the iOS
template declares local-network access so a development build can reach a
server on your computer, and the macOS template does not.

## `services.yaml`

Keep protected device access in the `services` list of `services.yaml`. When
both configuration files contain `services`, the one in `services.yaml` takes
precedence.

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

The supported declarations are `camera`, `microphone`, `location`, `motion`,
and `photo_library`. A `biometrics` declaration is supported too. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
A declaration can be a string or a mapping with a
user-facing `description`. Ruflet uses these entries to add client extensions, Android
permissions, iOS usage-description keys, and related platform configuration.
Each declaration selects the extensions it needs:

- `camera` adds `camera` and `permission_handler`.
- `microphone` adds `audio_recorder` and `permission_handler`.
- `location` adds `geolocator` and `permission_handler`.
- `motion` adds `permission_handler`.
- `photo_library` adds no extension. It only writes the iOS photo-library usage description.
- `biometrics` adds `local_auth`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

See [Android Builds](/docs/publishing-android#permissions) and
[iOS Builds](/docs/publishing-ios#permissions-and-usage-descriptions) for the
platform keys each declaration writes.

Request access only in response to the related user action, and write a
description that explains the benefit rather than restating the permission
name.

### App identity in `services.yaml`

`services.yaml` may also carry an `app` section. `ruflet new` writes the
project's identity there:

```yaml
app:
  app_name: My App
  package_name: my_app
  organization: com.example
  version: 1.0.0+1
  description: A new Ruflet app.
```

It takes every [`app`](#app) key, including `backend_url` and the signing
team. Its values fill the keys that `ruflet.yaml`'s `app` leaves out; a key
set in `ruflet.yaml` wins.

`app_name` outranks `display_name` wherever it is set. So when `ruflet.yaml`
sets only `display_name`, the `app_name` that `ruflet new` wrote into
`services.yaml` still names the app. Set `app_name` in `ruflet.yaml` instead,
or remove it from `services.yaml`.
A `display_name` or `app_name` in `ruflet.yaml` replaces both of
`services.yaml`'s, so the name you set in `ruflet.yaml` wins. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Environment variables

### Project and server

- `RUFLET_CONFIG` selects a project configuration file.
- `RUFLET_PORT` supplies the server port when code or the CLI does not override it.
- `RUFLET_HOST` supplies the host the server binds, `0.0.0.0` by default, for `Ruflet::App` and the DSL `app`.
- `RUFLET_STRICT_PORT`: `1` makes the Ruflet server fail with `Errno::EADDRINUSE` when its port is taken. Otherwise it tries the next 99 ports and warns which one it bound. `ruflet run` picks a free port before it starts the server either way.

### Builds

- `RUFLET_CLIENT_DIR` selects an existing managed Flutter client directory for build and debug commands.
- `RUFLET_FLUTTER_VERSION` selects the managed Flutter SDK version before Ruflet falls back to the project's `.fvmrc` and then its built-in default.
- `RUFLET_FULL_RUNTIME_PATH` selects the CRuby runtime distribution for `--full` builds and overrides `build.full_runtime_path`.
- `RUFLET_IOS_TEAM_ID` is the last fallback for the Apple signing team, after `ios.team_id`, `app.ios_team_id` and `app.team_id`.
- `RUFLET_RUBY_RUNTIME_PATH` points at a local `ruby_runtime` Flutter package, a directory with a `pubspec.yaml`. Self-contained builds then depend on it instead of the published package, and `--full` and `mrbc` lookups check it too. Without it, a build run from a Ruflet source checkout uses that checkout's `ruby_runtime`.
- `RUFLET_MRBC` is the path of an executable `mrbc`. A `--lite` build uses it to precompile the project's Ruby files to bytecode; without it Ruflet looks in the runtime package, and without any `mrbc` the build packages the Ruby source.
- `RUFLET_ANDROID_KEYSTORE`, `RUFLET_ANDROID_KEYSTORE_PASSWORD`, `RUFLET_ANDROID_KEY_ALIAS` and `RUFLET_ANDROID_KEY_PASSWORD` supply the Android upload key; see [Release signing](/docs/publishing-android#release-signing).

### Client template and caches

- `RUFLET_TEMPLATE_ROOT` is a local client template, either the `ruflet_flutter_template` directory or a checkout that contains `templates/ruflet_flutter_template`. `ruflet new` and `ruflet build` copy the client from it instead of the downloaded template, and `ruflet doctor` reports it. `ruflet build` still refreshes the downloaded copy.
- `RUFLET_TEMPLATE_REPO_URL` and `RUFLET_TEMPLATE_REPO_REF` select the Git repository and branch the template is downloaded from, by default `https://github.com/AdamMusa/ruflet-template.git` and `main`.
- `RUFLET_CACHE_DIR` is where the downloaded template is kept, under `templates/`. It defaults to `~/.ruflet`. The prebuilt development clients and the managed Flutter SDK stay under `~/.ruflet`.
- `RUFLET_RUNTIME_REPO_URL` is read when the CLI loads, but no command uses it in 0.0.23 or on `main`.

### Development clients

`ruflet run --web` and `ruflet run --desktop` use prebuilt clients cached
under `~/.ruflet/client`. Ruflet checks for a newer one at most every six
hours.

- `RUFLET_CLIENT_AUTO_UPDATE`: `0`, `false`, `no` or `off` turns the check off, for `ruflet update` too. `ruflet update --force` still downloads the clients.
- `RUFLET_CLIENT_UPDATE_INTERVAL` is the time between checks in seconds, from `0` to `604800` (one week). It defaults to `21600`.
- `RUFLET_CLIENT_CHANNEL` is the release the clients come from. The default, `prebuild-main`, is the rolling build of Ruflet's main branch, used once it is complete. Any other value names another release tag, and `stable` skips the rolling release. Ruflet then falls back to the release of the installed Ruflet version, then the latest release.

### Diagnostics

- `RUFLET_PROTOCOL_TRACE` prints every WebSocket frame between the Ruby server and the client to standard output, prefixed `[RUFLET_PROTOCOL]`. `summary` prints a compact line per frame, and `1` or `full` also prints the bytes and the decoded value. The default, `0`, prints nothing.
- `RUFLET_DEBUG`: `1` makes the Ruflet server log the action of every incoming message and the full backtrace of an error raised while handling one.
- `RUFLET_RAILS_DEBUG_EVENTS`: `true` makes `ruflet_rails` log every event it receives, with its target, name and data.
- `RUFLET_BACKEND_URL` is read by the initializer the Rails generator writes; see [Rails Assets and URLs](/docs/rails-assets#backend-url).

Rails applications normally configure build metadata in
`config/initializers/ruflet.rb`; see [Rails API Reference](/docs/rails-api-reference).
