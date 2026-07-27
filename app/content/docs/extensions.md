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
| `audio` | `audio(...)` | Media control |
| `audio_recorder` | `page.audio_recorder(...)` | Device service |
| `camera` | `camera(...)` | Camera control |
| `charts` | Bar, line, pie, scatter, candlestick, and radar chart helpers | Control family |
| `code_editor` | `code_editor(...)` | Editing control |
| `color_pickers` | Color picker helpers | Control family |
| `datatable2` | DataTable2 helpers | Control family |
| `flashlight` | `page.flashlight` | Device service |
| `geolocator` | `page.geolocator(...)` | Device service |
| `lottie` | `lottie(...)` | Animation control |
| `map` | `map(...)` and map-layer helpers | Control family |
| `permission_handler` | `page.permission_handler(...)` | Device service |
| `qrcode_scanner` | `qrcode_scanner(...)` | Scanner control |
| `rive` | `rive(...)` | Animation control |
| `secure_storage` | `page.secure_storage` | Storage service |
| `video` | `video(...)` | Media control |
| `webview` | `web_view(...)` | Web content control |

Controls and widgets remain documented under
[Controls](/docs/component-reference), even when an extension supplies their
Flutter implementation. Runtime service APIs remain under
[Services](/docs/services-and-plugins).

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
