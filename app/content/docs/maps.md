# Maps

Ruflet maps combine tile layers, markers, circles, polylines, and polygons for
features such as store locators, delivery tracking, and geographic dashboards.

A map is a `map` control holding an ordered list of **layers**. The first layer is
almost always a `tile_layer` that supplies the base imagery; further layers draw
markers and shapes on top. Coordinates are everywhere expressed as
`{ latitude:, longitude: }`.

## Example

```ruby
map(
  expand: true,
  initial_center: { latitude: 48.8566, longitude: 2.3522 },
  initial_zoom: 12,
  layers: [
    tile_layer(
      url_template: "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
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
  on_tap: ->(event) { add_pin(event) }
)
```

## `map`

- `layers` — the ordered list of layers (tiles first, overlays after).
- `initial_center` — `{ latitude:, longitude: }` the map opens centered on.
- `initial_zoom` — zoom level at first render.
- `min_zoom` / `max_zoom` — clamp how far the user can zoom.
- `interaction_configuration` — which gestures are enabled (pan, pinch-zoom, rotate, double-tap).
- `keep_alive` — keep the map state alive when it scrolls offscreen.
- `bgcolor` — color shown behind tiles while they load.
- `expand` / `width` / `height` — layout sizing.
- `visible` — show/hide the map.

### Map events

- `on_tap` — a tap on the map (data includes the tapped coordinate).
- `on_long_press` — a long press on the map.
- `on_secondary_tap` — a secondary (right-click) tap.
- `on_position_change` — the camera moved (data includes center and zoom).
- `on_init` — the map finished initializing.

## Layers

### `tile_layer`

Supplies the base imagery from an XYZ tile server.

- `url_template` — tile URL with `{z}/{x}/{y}` placeholders (and optional `{s}` for subdomains).
- `fallback_url` — URL used when a tile fails to load.
- `subdomains` — array of subdomain tokens for `{s}` (e.g. `["a", "b", "c"]`).
- `additional_options` — extra query params merged into each tile request.
- `attribution` — attribution text required by the provider.
- `min_zoom` / `max_zoom` — zoom range this layer serves tiles for.
- `retina_mode` — request high-DPI (`@2x`) tiles on retina displays.
- `tile_bounds` — restrict tiles to a geographic bounding box.
- `tile_size` — tile pixel size (default 256).
- `user_agent_package_name` — package name sent in the tile request user agent.
- `visible` — show/hide the layer.

### `marker_layer`

Holds `marker` controls.

- `markers` — array of `marker` controls.
- `rotate` — rotate markers to counter map rotation so they stay upright.
- `visible` — show/hide the layer.

### `marker`

- `coordinates` — `{ latitude:, longitude: }` the marker is pinned to.
- `content` — the control drawn at that point (an icon, image, or any widget).
- `width` / `height` — size of the marker's content box.
- `alignment` — how the content is anchored over the coordinate.
- `rotate` — rotate this marker with the map.

### `circle_layer`

Holds `circle_marker`s.

- `circles` — array of `circle_marker` controls.
- `visible` — show/hide the layer.

### `circle_marker`

- `coordinates` — `{ latitude:, longitude: }` of the center.
- `radius` — circle radius (pixels, or meters when `use_radius_in_meter` is true).
- `color` — fill color (use an alpha suffix like `#3b82f633` for translucency).
- `border_color` — outline color.
- `border_stroke_width` — outline thickness.
- `use_radius_in_meter` — interpret `radius` as real-world meters instead of pixels.

### `polyline_layer`

Connected lines — routes, boundaries.

- `polylines` — array of `polyline_marker` controls.
- `visible` — show/hide the layer.

### `polyline_marker`

- `coordinates` — array of `{ latitude:, longitude: }` points.
- `color` — line color.
- `stroke_width` — line thickness.
- `border_color` / `border_stroke_width` — optional outline around the line.
- `gradient_colors` — colors blended along the line.
- `stroke_cap` — line end shape (`"round"`, `"square"`, `"butt"`).
- `stroke_join` — corner shape (`"round"`, `"bevel"`, `"miter"`).

### `polygon_layer`

Filled polygons.

- `polygons` — array of `polygon_marker` controls.
- `visible` — show/hide the layer.

### `polygon_marker`

- `coordinates` — array of `{ latitude:, longitude: }` vertices.
- `color` — fill color.
- `border_color` / `border_stroke_width` — outline.
- `disable_holes_border` — don't draw a border around interior holes.
- `label` — text label drawn on the polygon.

### `simple_attribution`

The attribution badge most tile providers require.

- `text` — the attribution text.
- `alignment` — where the badge sits over the map.
- `bgcolor` — badge background color.
- `text_style` — text style: `{ size:, color:, weight: }`.
- `url` — link opened when the badge is tapped.
- `on_click` — handler fired when the badge is tapped.

## Layering overlays

Compose overlays by stacking layers in order — later layers paint on top:

```ruby
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
        color: "#3b82f633", border_color: "#3b82f6", border_stroke_width: 2
      )
    ]),
    marker_layer(markers: store_pins),
    simple_attribution(text: "© OpenStreetMap", url: "https://openstreetmap.org/copyright")
  ]
)
```

Respect your tile provider's usage policy and attribution requirements.
