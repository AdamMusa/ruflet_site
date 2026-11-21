# Maps

Ruflet maps combine tile layers, markers, circles, polylines, and polygons for
features such as store locators, delivery tracking, and geographic dashboards.

A map is a `map` control holding an ordered list of **layers**. The first layer is
almost always a `tile_layer` that supplies the base imagery; further layers draw
markers and shapes on top. Coordinates are `[latitude, longitude]` arrays or
`{ latitude:, longitude: }` hashes.

Maps come from the `map` client extension, drawn with flutter_map. Enable it in
`ruflet.yaml` and rebuild the client:

```yaml
extensions:
  - map
```

Maps work the same on every platform; only the attribution controls are
Cupertino-styled on iOS and macOS.

## Example

```ruby
map(
  expand: true,
  initial_center: { latitude: 48.8566, longitude: 2.3522 },
  initial_zoom: 12,
  layers: [
    tile_layer(
      url_template: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
      user_agent_package_name: "com.example.parisguide"
    ),
    marker_layer(
      markers: [
        marker(
          coordinates: { latitude: 48.8566, longitude: 2.3522 },
          content: icon("location_on", color: "#ef4444")
        )
      ]
    ),
    simple_attribution(text: "© OpenStreetMap")
  ],
  on_tap: ->(event) { puts event.data[:coordinates].inspect }
)
```

The layer helpers also take their list as the first argument:
`map([tile_layer(...), marker_layer([marker(icon("place"), coordinates: [48.85, 2.35])])], ...)`.

## `map`

- `layers` — the ordered list of layers (tiles first, overlays after).
- `initial_center` — the point the map opens centered on (default latitude
  50.5, longitude 30.51).
- `initial_zoom` — zoom level at first render (default 13).
- `min_zoom` / `max_zoom` — clamp how far the user can zoom.
- `initial_rotation` — rotation in degrees at first render.
- `initial_camera_fit` — fit the initial camera to an area:
  `{ bounds: { corner_1:, corner_2: } }` or `{ coordinates: [...] }`, with
  `{ latitude:, longitude: }` hashes, plus optional `padding` and zoom limits.
- `interaction_configuration` — which gestures and keys move the map, as a
  hash such as `{ flags: 1 | 8, pinch_move_threshold: 40 }`. Unset, every
  gesture is on. Always include `pinch_move_threshold`: on 0.0.23 the map fails
  to draw without it. See [Gestures and keyboard](#gestures-and-keyboard) for
  every key.
- `animation_curve` / `animation_duration` — defaults for the animated map
  methods (`"fastOutSlowIn"` and 500 ms).
- `keep_alive` — keep the map state alive when it scrolls offscreen.
- `bgcolor` — color shown behind tiles while they load (default light grey).
- `expand` / `width` / `height` — layout sizing.
- `visible` — show/hide the map.

`initial_*` properties apply when the map first appears. To move the map later,
call its methods once it is on the page:

```ruby
city = map(
  [tile_layer(url_template: "https://tile.openstreetmap.org/{z}/{x}/{y}.png")],
  initial_center: [51.5072, -0.1276],
  initial_zoom: 11,
  expand: true
)
page.add(city)
page.add(
  row(children: [
    button("Zoom in", on_click: ->(_event) { city.zoom_in }),
    button("Paris", on_click: ->(_event) { city.move_to(destination: [48.8566, 2.3522], zoom: 12, animation_duration: 800) }),
    button("North up", on_click: ->(_event) { city.reset_rotation })
  ])
)
```

The methods are `move_to(destination:, zoom:, rotation:, offset:)`,
`center_on(point, zoom:)`, `zoom_in`, `zoom_out`, `zoom_to(zoom)`,
`rotate_from(degrees)` and `reset_rotation`. Each animates and takes
`animation_curve:`, `animation_duration:` (milliseconds),
`cancel_ongoing_animations:`, `timeout:` and `on_result:`.

### Gestures and keyboard

`interaction_configuration` takes a hash. Every key is optional, but always
include `pinch_move_threshold`: a 0.0.23 client fails to draw a map whose hash
lacks it. With the next release a missing `pinch_move_threshold` defaults to
40. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

```ruby
map(
  [tile_layer(url_template: "https://tile.openstreetmap.org/{z}/{x}/{y}.png")],
  initial_center: [52.52, 13.405],
  initial_zoom: 11,
  expand: true,
  interaction_configuration: {
    flags: 1 | 2 | 8 | 16 | 64, # drag, fling, pinch-zoom, double-tap and wheel zoom; no rotation
    pinch_move_threshold: 40,
    scroll_wheel_velocity: 0.01,
    keyboard_configuration: { enable_qe_rotating: false }
  }
)
```

- `flags` — the gestures that move the map, added up: 1 drag, 2 fling (the map
  keeps moving after a quick drag), 4 pinch-move (two fingers pan), 8
  pinch-zoom, 16 double-tap zoom, 32 double-tap-drag zoom, 64 scroll-wheel zoom
  and 128 rotate. The default, 255, turns all of them on; `0` makes the map
  static. The methods such as `move_to` still move it.
- `scroll_wheel_velocity` — how fast the mouse wheel zooms (default 0.005).
- `enable_multi_finger_gesture_race` — let two-finger rotation, pinch-zoom and
  pinch-move compete (default false). The first gesture past its threshold
  wins and turns on the gestures its `*_win_gestures` value lists, added up
  from 1 pinch-move, 2 pinch-zoom and 4 rotate:
  - `pinch_move_threshold` (in logical pixels, flutter_map's default 40) with
    `pinch_move_win_gestures` (default 3, pinch-move and pinch-zoom);
  - `pinch_zoom_threshold` (default 0.5) with `pinch_zoom_win_gestures`
    (default 3);
  - `rotation_threshold` (in degrees, default 20) with `rotation_win_gestures`
    (default 4, rotation only).
- `keyboard_configuration` — how keys move a focused map, on desktop and the
  web. Without it the arrow keys pan the map. Once you send the hash, every
  key set below is on unless you turn it off: `enable_arrow_keys_panning`,
  `enable_wasd_panning` (W, A, S, D pan), `enable_qe_rotating` (Q and E
  rotate) and `enable_rf_zooming` (R zooms in, F out), plus `autofocus`
  (default true, the map takes the keyboard focus when it appears). The speeds
  are `max_zoom_velocity` (zoom levels per frame, default 0.03) and
  `max_rotate_velocity` (degrees per frame, default 3). A quick key press
  "leaps" only when you set `perform_leap_trigger_duration` (milliseconds,
  flutter_map uses 100); `pan_leap_velocity_multiplier` (default 5),
  `zoom_leap_velocity_multiplier` and `rotate_leap_velocity_multiplier`
  (default 3) and `leap_max_of_curve_component` (default 0.6) shape the leap.
  `animation_curve_duration` (milliseconds, default 450) and
  `animation_curve_curve` (default `"easeInOut"`) shape how a held key speeds
  up, and `animation_curve_reverse_duration` how it slows down after the key
  is released (unset, the same as `animation_curve_duration`).
- `cursor_keyboard_rotation_configuration` — on desktop and the web, rotate
  the map by holding a key and moving the mouse. Without this hash any Control
  key does it. On 0.0.23 leave the hash out: with it that client never starts
  the rotation, and every key press raises an error in the client when
  `trigger_keys` is missing or a single name. The hash takes `behaviour`,
  `"offset"` (the default, turn the map by the angle you drag) or `"setNorth"`
  (point north where the cursor is), and `set_north_on_click` (default true: a
  click with the key held and no drag points north at the cursor). With the
  next release
  `trigger_keys` names the keys by label, as one name or a list:
  `"Shift Left"`, `:shift_left` and `"SHIFT_LEFT"` are the same key, `[]`
  turns the rotation off, and without `trigger_keys` the Control keys start
  it. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

### Map events

- `on_tap` — a tap on the map. `event.data[:coordinates]` is the tapped point
  as `{ latitude:, longitude: }`; `gx` / `gy` and `lx` / `ly` are the screen
  and map-relative positions in pixels. Like every map payload, `event.data`
  has symbol keys.
- `on_long_press` — a long press on the map, with the same data.
- `on_secondary_tap` — a secondary (right-click) tap, with the same data.
- `on_position_change` — the camera moved. `event.data` has `coordinates` (the
  new center), `has_gesture` and `camera` (`center`, `zoom`, `min_zoom`,
  `max_zoom`, `rotation`).
- `on_init` — the map is ready for the methods above.
- `on_hover`, `on_pointer_down`, `on_pointer_up`, and `on_pointer_cancel` —
  pointer events: `coordinates` plus the pointer's kind (`k`) and local and
  global positions (`l`, `g`).
- `on_event` — any camera event: `event.data` has `source` (for example
  `"dragStart"` or `"scrollWheel"`) and `camera`.

## Layers

### `tile_layer`

Supplies the base imagery from an XYZ tile server. See
[`tile_layer`](/docs/control-tile-layer) for every property.

- `url_template` — tile URL with `{z}/{x}/{y}` placeholders (and optional `{s}` for subdomains).
- `fallback_url` — URL template tried when a tile fails to load.
- `subdomains` — array of subdomain tokens for `{s}` (default `["a", "b", "c"]`).
- `additional_options` — values for your own `{placeholders}` in `url_template`,
  such as an API key.
- `min_zoom` / `max_zoom` — zoom range this layer shows tiles for.
- `min_native_zoom` / `max_native_zoom` — zoom levels available from the provider (default 0 and 19).
- `enable_retina_mode` — request high-DPI tiles on retina displays.
- `enable_tms` — use TMS Y-axis tile numbering.
- `zoom_reverse` / `zoom_offset` — transform requested zoom levels.
- `keep_buffer` / `pan_buffer` — retain nearby tiles while moving.
- `display_mode` — tile loading/fade behavior: `{ _type: "fadein", duration: }`
  (the default) or `{ _type: "instantaneous", opacity: }`.
- `error_image_src` / `evict_error_tile_strategy` — failed-tile behavior.
- `on_image_error` — fires when a tile image fails to load; `event.data` is the error.
- `tile_bounds` — restrict tiles to a geographic bounding box.
- `tile_size` — tile pixel size (default 256).
- `user_agent_package_name` — your app id, sent in the tile request user agent
  (OpenStreetMap asks for it).

### `marker_layer`

Holds `marker` controls.

- `markers` — array of `marker` controls.
- `rotate` — keep markers upright when the map rotates.
- `alignment` — where markers sit relative to their points, unless a marker sets its own.

### `marker`

- `coordinates` — the point the marker is pinned to.
- `content` — the control drawn at that point (an icon, image, or any widget); required.
- `width` / `height` — size of the marker's content box (default 30).
- `alignment` — how the content is anchored over the coordinate;
  `{ x: 0, y: -1 }` puts it above the point, like a pin.
- `rotate` — keep this marker upright when the map rotates.

### `circle_layer`

Holds `circle_marker`s.

- `circles` — array of `circle_marker` controls.

### `circle_marker`

- `coordinates` — the center.
- `radius` — circle radius (pixels, or meters when `use_radius_in_meter` is true).
- `color` — fill color (use `"#3b82f6,0.2"` for a see-through circle).
- `border_color` — outline color.
- `border_stroke_width` — outline thickness.
- `use_radius_in_meter` — interpret `radius` as real-world meters instead of pixels.

### `polyline_layer`

Connected lines — routes, boundaries.

- `polylines` — array of `polyline_marker` controls.
- `culling_margin`, `min_hittable_radius`, and `simplification_tolerance` —
  rendering and hit-test tuning.

### `polyline_marker`

- `coordinates` — the points of the line, in order.
- `color` — line color.
- `stroke_width` — line thickness.
- `border_color` / `border_stroke_width` — optional outline around the line.
- `gradient_colors` — colors blended along the line.
- `colors_stop` — normalized positions for `gradient_colors`.
- `stroke_pattern` — `{ _type: "solid" }`, `{ _type: "dotted", spacing_factor: }`
  or `{ _type: "dashed", segments: [10, 5] }`.
- `use_stroke_width_in_meter` — interpret line width in map meters.
- `stroke_cap` — line end shape (`"round"`, `"square"`, `"butt"`).
- `stroke_join` — corner shape (`"round"`, `"bevel"`, `"miter"`).

### `polygon_layer`

Filled polygons.

- `polygons` — array of `polygon_marker` controls.
- `polygon_culling`, `polygon_labels`, `draw_labels_last`,
  `simplification_tolerance`, and `use_alternative_rendering` — rendering and
  label controls for the layer.

### `polygon_marker`

- `coordinates` — the corners of the area, in order.
- `color` — fill color.
- `border_color` / `border_stroke_width` — outline.
- `disable_holes_border` — don't draw a border around interior holes.
- `label` — text label drawn on the polygon.
- `label_text_style` — label style as a plain Ruby hash.
- `rotate_label`, `stroke_cap`, and `stroke_join` — label and outline behavior.

### `simple_attribution`

The attribution badge most tile providers require.

- `text` — the attribution text.
- `alignment` — where the badge sits over the map.
- `bgcolor` — badge background color.
- `on_click` — handler fired when the badge is tapped.

### `rich_attribution`

An attribution button that opens a popup listing every source, with logos that
stay visible. List the sources with `text_source_attribution(text)` and
`image_source_attribution(image(...))`; both take `on_click`.

```ruby
map(
  [
    tile_layer(url_template: "https://tile.openstreetmap.org/{z}/{x}/{y}.png"),
    rich_attribution(
      [
        text_source_attribution("OpenStreetMap contributors",
                                on_click: ->(_event) { page.launch_url("https://www.openstreetmap.org/copyright") })
      ],
      popup_initial_display_duration: 3000
    )
  ],
  initial_center: [48.8566, 2.3522],
  expand: true
)
```

## Layering overlays

Compose overlays by stacking layers in order — later layers paint on top:

```ruby
store_pins = [
  marker(icon("storefront"), coordinates: [37.7849, -122.4094]),
  marker(icon("storefront"), coordinates: [37.7649, -122.4294])
]

map(
  expand: true,
  initial_center: { latitude: 37.7749, longitude: -122.4194 },
  initial_zoom: 11,
  layers: [
    tile_layer(url_template: "https://tile.openstreetmap.org/{z}/{x}/{y}.png"),
    circle_layer(circles: [
      circle_marker(
        coordinates: { latitude: 37.7749, longitude: -122.4194 },
        radius: 500, use_radius_in_meter: true,
        color: "#3b82f6,0.2", border_color: "#3b82f6", border_stroke_width: 2
      )
    ]),
    marker_layer(markers: store_pins),
    simple_attribution(
      text: "© OpenStreetMap",
      on_click: ->(_event) { page.launch_url("https://openstreetmap.org/copyright") }
    )
  ]
)
```

Respect your tile provider's usage policy and attribution requirements.
