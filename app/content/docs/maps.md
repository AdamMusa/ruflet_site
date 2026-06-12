# Maps

Ruflet ships an interactive map control backed by tile layers, so you can render
slippy maps with markers, circles, and shapes — useful for store locators,
delivery tracking, and geo dashboards.

A map is a `map` control holding an ordered list of **layers**. The first layer
is almost always a `tile_layer` that supplies the base imagery; further layers
draw markers and shapes on top.

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
    )
  ],
  on_tap: ->(event) { add_pin(event) }
)
```

## Map properties

- `layers` — the ordered list of layers (tiles first, overlays after)
- `initial_center` — `{ latitude:, longitude: }`
- `initial_zoom` / `min_zoom` / `max_zoom`
- `interaction_configuration` — pan/zoom/rotate behavior
- `keep_alive` — keep the map state when scrolled offscreen
- `bgcolor`
- Events: `on_tap`, `on_long_press`, `on_secondary_tap`, `on_position_change`,
  `on_init`

## Layers

- `tile_layer` — base imagery from an XYZ tile server (`url_template` with
  `{z}/{x}/{y}`).
- `marker_layer` — holds `marker` controls. Each `marker` has `coordinates` and
  a `content` control (an icon, image, or any widget).
- `circle_layer` — holds `circle_marker`s (a center, radius, fill, and border).
- `polygon_layer` — filled polygons from a list of coordinates.
- `polyline_layer` — connected lines (routes, boundaries).
- `simple_attribution` — the attribution badge required by most tile providers.

## Usage

Compose overlays by stacking layers in order:

```ruby
map(
  expand: true,
  initial_center: { latitude: 37.7749, longitude: -122.4194 },
  initial_zoom: 11,
  layers: [
    tile_layer(url_template: "https://tile.openstreetmap.org/{z}/{x}/{y}.png"),
    circle_layer(circles: [
      circle_marker(coordinates: { latitude: 37.7749, longitude: -122.4194 },
                    radius: 500, color: "#3b82f633", border_color: "#3b82f6")
    ]),
    marker_layer(markers: store_pins),
    simple_attribution(text: "© OpenStreetMap")
  ]
)
```

Respect your tile provider's usage policy and attribution requirements.
