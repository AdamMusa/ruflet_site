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
- `interaction_configuration` — which gestures move the map:
  `{ flags:, pinch_move_threshold: 40, ... }`, where `flags` adds up 1 drag,
  2 fling, 4 pinch-move, 8 pinch-zoom, 16 double-tap zoom, 32 double-tap-drag
  zoom, 64 scroll-wheel zoom and 128 rotate (default 255, all; `0` for a static
  map). Always include `pinch_move_threshold`: without it the map fails to draw.
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
