# QRCodeScanner

Scan QR codes and other barcodes with the first-party
`ruflet_qrcode_scanner` Flet extension, backed by `mobile_scanner`.

Enable it and rebuild the client:

```yaml
# ruflet.yaml
extensions:
  - qrcode_scanner
```

Ruflet adds camera declarations automatically. To customize the Apple usage
message, declare the camera service:

```yaml
# services.yaml
services:
  - camera:
      description: Scan QR codes and product barcodes.
```

## Example

```ruby
Ruflet.run do |page|
  result = text(value: "Point the camera at a code")

  scanner = qrcode_scanner(
    expand: true,
    formats: %i[qr_code data_matrix],
    detection_speed: :no_duplicates,
    on_detect: ->(event) {
      page.update(result, value: event.value.to_s)
    },
    on_error: ->(event) {
      page.update(result, value: event.data["message"].to_s)
    }
  )

  page.add(column(controls: [scanner, result]))
end
```

## Scanner properties

- `auto_start` — start after mounting (default `true`).
- `auto_zoom` — automatically zoom toward a detected code (default `false`; Android only).
- `camera_facing` — `:back` or `:front` (default `:back`).
- `detection_speed` — `:normal`, `:no_duplicates`, or `:unrestricted` (default `:normal`).
- `detection_timeout` — normal-mode interval in milliseconds (default `250`).
- `fit` — preview box fit (default `:cover`).
- `formats` — formats to detect; an empty array means all supported formats.
- `invert_image` — detect white-on-black codes (default `false`; Android only).
- `return_image` — include a base64 capture in detection events (default `false`; Android, iOS, and macOS).
- `scan_window` — `{ left:, top:, right:, bottom: }` or `{ x:, y:, width:, height: }`.
- `tap_to_focus` — enable focus by tapping the preview (default `false`).
- `torch_enabled` — start with the torch enabled (default `false`).
- `zoom_scale` — initial zoom scale (default `1.0`).

Supported format names are `all`, `unknown`, `aztec`, `codabar`, `code_39`,
`code_93`, `code_128`, `data_bar`, `data_bar_expanded`, `data_bar_limited`,
`data_matrix`, `ean_8`, `ean_13`, `itf_2_of_5`,
`itf_2_of_5_with_checksum`, `itf_14`, `maxi_code`, `micro_qr_code`, `pdf_417`,
`qr_code`, `upc_a`, and `upc_e`.

## Layout properties

`align`, `animate_align`, `animate_margin`, `animate_offset`,
`animate_opacity`, `animate_position`, `animate_rotation`, `animate_scale`,
`animate_size`, `aspect_ratio`, `badge`, `bottom`, `col`, `data`, `disabled`,
`expand`, `expand_loose`, `height`, `key`, `left`, `margin`, `offset`,
`opacity`, `right`, `rotate`, `rtl`, `scale`, `size_change_interval`, `tooltip`,
`top`, `visible`, and `width`.

## Events

- `on_detect` — `event.value` is the first raw value. `event.data["barcodes"]`
  contains all results with `raw_value`, `display_value`, `format`, `type`, and
  optional `corners`. `event.data["image"]` is present when `return_image` is
  enabled and the platform supplies a frame.
- `on_error` — exposes `event.data["message"]`, `event.data["type"]`, and an
  optional `stack_trace`.
- `on_animation_end` and `on_size_change` — inherited layout events.

## Methods

After mounting, call `start`, `stop`, `switch_camera`, `toggle_torch`,
`set_zoom_scale(value)`, or `reset_zoom_scale`. Each accepts `timeout: 10` and
`on_result:`; the callback receives `(result, error)`.

The extension supports Android, iOS, macOS, and web. Linux and Windows are not
supported. Web camera access requires a secure context.
