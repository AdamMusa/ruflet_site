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

## Available extensions

| Key | Ruby API provided | Kind |
|---|---|---|
| [`audio`](/docs/extension-audio) | `audio(...)` | Media control |
| [`audio_recorder`](/docs/service-audio-recorder) | `page.audio_recorder(...)` | Device service; documented under Services |
| [`camera`](/docs/service-camera) | `page.camera(...)` | Device service; documented under Services |
| [`charts`](/docs/extension-charts) | Bar, line, pie, scatter, candlestick, and radar chart helpers | Control family |
| [`code_editor`](/docs/extension-code-editor) | `code_editor(...)` | Editing control |
| [`color_pickers`](/docs/extension-color-pickers) | `control("ColorPicker", ...)` and related wire controls | Control family |
| [`datatable2`](/docs/extension-datatable2) | `control("DataTable2", ...)` | Data control |
| [`flashlight`](/docs/service-flashlight) | `page.flashlight` | Device service; documented under Services |
| [`geolocator`](/docs/service-geolocator) | `page.geolocator(...)` | Device service; documented under Services |
| [`lottie`](/docs/extension-lottie) | `control("Lottie", ...)` | Animation control |
| [`map`](/docs/extension-map) | `map(...)` and map-layer helpers | Control family |
| [`permission_handler`](/docs/service-permission-handler) | `page.permission_handler(...)` | Device service; documented under Services |
| [`qrcode_scanner`](/docs/qrcode-scanner) | `qrcode_scanner(...)` | Scanner control |
| [`rive`](/docs/extension-rive) | `rive(...)` | Animation control |
| [`secure_storage`](/docs/service-secure-storage) | `page.secure_storage` | Storage service; documented under Services |
| [`video`](/docs/extension-video) | `video(...)` | Media control |
| [`webview`](/docs/extension-webview) | `web_view(...)` | Web content control |

Controls and widgets remain documented under
[Controls](/docs/component-reference), even when an extension supplies their
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
required packages. `qrcode_scanner` also adds its camera declarations when it
is selected directly. Request access only when the user starts the related
action.

## First-party QR scanner

The first Ruflet-owned extension is
[`ruflet_qrcode_scanner`](/docs/qrcode-scanner). It follows Flet's extension
contract and uses the normal Ruby DSL:

```ruby
scanner = qrcode_scanner(
  formats: [:qr_code],
  on_detect: ->(event) {
    page.update(result, value: event.value.to_s)
  }
)
```

To build an extension package, see
[Extension Authoring](/docs/extension-authoring).
