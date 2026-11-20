# Extension Catalog

Extensions are optional Flutter packages compiled into a Ruflet client. They
add controls, widgets, or device integrations that are not part of the core
client. This is separate from a service: a service is the Ruby API used at
runtime, while an extension is client build configuration.

Enable extensions in `ruflet.yaml`, then rebuild the client:

```yaml
extensions:
  - charts
  - code_editor
  - qrcode_scanner
```

## Use an extension Ruflet does not bundle

A client that uses an extension Ruflet does not bundle currently fails to
compile, whether the extension comes from `git:` or `path:`. The build writes
the extension's `Extension(),` line outside the client's `RufletExtension`
list.

To declare a third-party or private extension that is not in the built-in
catalog, use the Dart package name as the extension key and tell Ruflet where
the package lives:

```yaml
extensions:
  - charts
  - acme_widgets:
      git:
        url: git@github.com:acme/acme_widgets.git
        ref: 4f6d93f0b5a8d92d9b7a1af83dd752984e951eb2
```

During the build Ruflet:

1. adds `acme_widgets` to the generated Flutter client's dependencies;
2. imports `package:acme_widgets/acme_widgets.dart`; and
3. writes `acme_widgets.Extension(),` into the client's Dart entrypoints.

The package name must be a valid Dart identifier and match all three places:
the extension key, `name:` in the package's `pubspec.yaml`, and its public
`lib/acme_widgets.dart` library. That library must expose an `Extension` class
that extends `RufletExtension` from `package:ruflet/ruflet.dart`.

`ref:` is preferred for reproducible builds and accepts a commit, branch, or
tag understood by Git. Ruflet also accepts `branch:` or `tag:` as aliases.

### Private Git authentication

Ruflet does not copy or store repository credentials. Flutter's package tool
invokes Git, so the machine running `ruflet build` must already be able to
clone the private repository.

- For SSH URLs, load a read-only deploy key or developer key into the SSH agent and configure the Git host in `known_hosts`.
- For HTTPS URLs, use the operating system's Git credential helper or a CI secret supplied to Git at build time.
- Do not put a personal access token in `ruflet.yaml`, a Rails initializer, or the repository URL. Those values can appear in source control and build logs.
- Give build credentials read-only access and pin production builds to a commit SHA or immutable tag.

Verify authentication before building:

```bash
git ls-remote git@github.com:acme/acme_widgets.git
ruflet build ios --self
```

### Rails configuration

Rails applications declare the same source in
`config/initializers/ruflet.rb`. The Rails build task serializes it to the
extension configuration consumed by the Ruflet CLI:

```ruby
Ruflet::Rails.configure do |config|
  config.extensions = [
    "charts",
    {
      "acme_widgets" => {
        "git" => {
          "url" => "git@github.com:acme/acme_widgets.git",
          "ref" => "4f6d93f0b5a8d92d9b7a1af83dd752984e951eb2"
        }
      }
    }
  ]
end
```

Build normally after the build machine can access the repository:

```bash
rake ruflet:build[ios]
```

In an ERB-to-native view, use the extension's wire type as a normal tag. No
Ruflet catalog entry is required:

```erb
<acme-rating value="4" maximum="5"></acme-rating>
```

The equivalent generic helper is useful when values come from Ruby:

```erb
<%= widget "acme-rating", value: @review.rating, maximum: 5 %>
```

If the private extension also ships a Ruby gem that registers a typed helper,
require that gem and use its helper normally. ERB-to-native rendering does not
require a typed Ruby helper for a plain wire tag.

### Monorepos and local development

Use `path:` inside `git:` when the Dart package is in a repository
subdirectory:

```yaml
extensions:
  - acme_widgets:
      git:
        url: git@github.com:acme/mobile_extensions.git
        ref: v2.1.0
        path: packages/acme_widgets
```

Use a direct path while developing against a local checkout:

```yaml
extensions:
  - acme_widgets:
      path: /Users/developer/code/acme_widgets
```

Absolute local paths are safest because the generated Flutter client lives in
the build directory. Do not use a developer-specific local path in CI or a
release configuration.

## Available extensions

| Key | Ruby API provided | Kind |
|---|---|---|
| [`ads`](/docs/extension-ads) | `banner_ad(...)`, and `interstitial_ad(...)` registered with `page.add_service` | Control family |
| [`audio`](/docs/extension-audio) | `page.audio(...)` | Media service |
| [`audio_recorder`](/docs/service-audio-recorder) | `page.audio_recorder(...)` | Device service; documented under Services |
| [`camera`](/docs/service-camera) | `page.camera(...)` | Device service; documented under Services |
| [`charts`](/docs/extension-charts) | Bar, line, pie, scatter, candlestick, and radar chart helpers | Control family |
| [`code_editor`](/docs/extension-code-editor) | `code_editor(...)` | Editing control |
| [`color_pickers`](/docs/extension-color-pickers) | `color_picker(...)`, `block_picker(...)`, `hue_ring_picker(...)`, `material_picker(...)`, `multiple_choice_block_picker(...)` and `slide_picker(...)` | Control family |
| [`datatable2`](/docs/extension-datatable2) | `data_table2(...)` with `data_column2(...)` and `data_row2(...)` | Data control |
| [`flashlight`](/docs/service-flashlight) | `page.flashlight` | Device service; documented under Services |
| [`geolocator`](/docs/service-geolocator) | `page.geolocator(...)` | Device service; documented under Services |
| [`local_auth`](/docs/service-local-authentication) | `page.local_authentication(...)` | Device service; documented under Services. **Requires the next Ruflet release** (on `main`, not in 0.0.23). |
| [`lottie`](/docs/extension-lottie) | `lottie(...)` | Animation control |
| [`map`](/docs/extension-map) | `map(...)` with layer, marker and attribution helpers | Control family |
| [`permission_handler`](/docs/service-permission-handler) | `page.permission_handler(...)` | Device service; documented under Services |
| [`qrcode_scanner`](/docs/qrcode-scanner) | `qrcode_scanner(...)` | Scanner control |
| [`rive`](/docs/extension-rive) | `rive(...)` | Animation control |
| [`secure_storage`](/docs/service-secure-storage) | `page.secure_storage` | Storage service; documented under Services |
| [`spinkit`](/docs/control-spinkit) | `spinkit(...)` | Animation control |
| [`video`](/docs/extension-video) | `video(...)` | Media control |
| [`webview`](/docs/extension-webview) | `web_view(...)` | Web content control |

Extension controls pass their properties to the client unchanged. Write enum
values in Flutter's spelling, such as `"fitWidth"` or `"spaceBetween"`: the
0.0.23 client does not read `"fit_width"`. With the next release both spellings
work. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

Widgets remain documented under
[Widgets](/docs/component-reference), even when an extension supplies their
Flutter implementation. Runtime service APIs remain under
[Services](/docs/services-and-plugins).

Service-backed extensions do not have duplicate extension reference pages.
Their catalog links open the authoritative service page, which includes both
the complete Ruby API and the required client build setup.

## Permissions

Protected native access belongs in `services.yaml`:

```yaml
services:
  - camera:
      description: Scan product QR codes.
  - microphone:
      description: Record voice notes.
```

Ruflet uses service declarations to configure platform permissions and include
required packages. Selecting `audio_recorder`, `camera`, `flashlight`,
`geolocator`, or `qrcode_scanner` directly writes the platform permissions of
the matching declaration, with a generic usage description, but does not
select that declaration's other packages, such as `permission_handler`; see
[Configuration](/docs/configuration-reference#extensions). Request access only
when the user starts the related action.

## First-party QR scanner

The first Ruflet-owned extension is
[`ruflet_qrcode_scanner`](/docs/qrcode-scanner). Its `Extension` class extends
`RufletExtension`, and it uses the normal Ruby DSL:

```ruby
result = text(value: "Point the camera at a code")
scanner = qrcode_scanner(
  formats: [:qr_code],
  on_detect: ->(event) {
    page.update(result, value: event.value.to_s)
  }
)
page.add(column(children: [scanner, result]))
```

To build an extension package, see
[Extension Authoring](/docs/extension-authoring).
