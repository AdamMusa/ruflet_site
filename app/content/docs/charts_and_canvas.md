# Charts and Canvas

Ruflet provides chart controls and a low-level drawing canvas. Charts are built
from a parent chart and data controls such as groups, rods, sections, and
spots. The canvas paints shapes described by `paint(...)` and can receive
pointer input through a gesture detector.

Every helper below is a normal Ruflet control — compose them inside `column`,
`row`, `container`, etc. like any other widget, and change them later with
`page.update(control, ...)`.

Charts come from the `charts` client extension, drawn with fl_chart. Enable it
in `ruflet.yaml` and rebuild the client:

```yaml
extensions:
  - charts
```

The canvas is part of the core client and needs no extension. Charts and the
canvas look the same on every platform.

---

## How charts work

- **Size.** A chart fills the width it gets. In a parent with unbounded height,
  such as a `column` in a scrolling page, it is at most 300 pixels tall: set
  `height` (or `expand`) to change that.
- **Ranges.** `min_x` / `max_x` / `min_y` / `max_y` fix the axis ranges; unset,
  the chart fits the data.
- **Axes.** A side shows labels only when you give it a
  [`chart_axis`](/docs/control-chart-axis). Custom labels from
  [`chart_axis_label`](/docs/control-chart-axis-label) appear only at tick
  values, so set the axis's `label_spacing` (for example `1`) when you label
  every whole number.
- **Grid.** `horizontal_grid_lines` / `vertical_grid_lines` take
  `{ interval:, color:, width:, dash_pattern: }`; no grid is drawn when both
  are unset.
- **Touch.** Charts highlight the touched point and send `on_event` with the
  touch phase in `event.data[:type]` (`"tapDown"`, `"tapUp"`, `"panUpdate"`,
  `"pointerHover"`, …) and the indexes of what was touched. With
  `interactive: false` they ignore touches and highlight the parts you mark
  `selected: true` instead. `event.data` is a hash with symbol keys, such as
  `event.data[:group_index]`.
- **Tooltips.** Leave the chart's `tooltip` unset to get the default bubble with
  the touched value. On 0.0.23 a chart with `tooltip` set shows no bubble at
  all, and a debug client (`ruflet debug`) on Android, web, Windows or Linux
  fails to draw it; scatter and candlestick charts never show a bubble. Show
  the touched value from `on_event` instead. With the next release a chart
  `tooltip` styles the bubble, a bar or line point shows its own `tooltip:`
  text (or its value) in it, and a scatter spot or candle with its own
  `tooltip:` text shows it in a bubble. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- **Colors.** Colors are names, `"#rrggbb"`, `"#aarrggbb"` (alpha first) or a
  color with an opacity after a comma, such as `"#2563eb,0.25"`. Gradients are
  hashes with `_type`, for example
  `{ _type: "linear", begin: { x: 0, y: 1 }, end: { x: 0, y: -1 }, colors: ["#93c5fd", "#1d4ed8"] }`.

## Bar chart

```ruby
bar_chart(
  width: 320,
  height: 180,
  max_y: 110,
  border: { width: 1, color: "#cad5e5" },
  horizontal_grid_lines: { color: "#cad5e5", width: 1, dash_pattern: [3, 3] },
  left_axis: chart_axis(title: text(value: "Fruit supply"), title_size: 40, label_size: 40),
  right_axis: chart_axis(show_labels: false),
  bottom_axis: chart_axis(
    label_size: 40,
    labels: [
      chart_axis_label(value: 0, label: text(value: "Apple")),
      chart_axis_label(value: 1, label: text(value: "Cherry"))
    ]
  ),
  groups: [
    bar_chart_group(x: 0, rods: [bar_chart_rod(from_y: 0, to_y: 40, width: 40, color: "#69db7c")]),
    bar_chart_group(x: 1, rods: [bar_chart_rod(from_y: 0, to_y: 30, width: 40, color: "#ff6b6b")])
  ],
  on_event: ->(e) { puts "bar event: #{e.data}" }
)
```

- [`bar_chart`](/docs/control-bar-chart) — `groups`, the axes, ranges, grid,
  `border`, `spacing` between groups and `group_alignment`. `on_event` data has
  `type`, `group_index`, `rod_index` and `stack_item_index`. With the next
  release `group_spacing` also sets the space between groups, and wins over
  `spacing`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- [`bar_chart_group`](/docs/control-bar-chart-group) — one x position: `x`,
  `rods`, `spacing` between its rods, and `group_vertically` to stack them.
- [`bar_chart_rod`](/docs/control-bar-chart-rod) — one bar: `from_y` / `to_y`,
  `width`, `color` or `gradient`, `border_radius`, `border_side`, a track
  behind it (`bg_from_y`, `bg_to_y`, `bgcolor`) and `stack_items`.
- [`bar_chart_rod_stack_item`](/docs/control-bar-chart-rod-stack-item) — a
  segment of a stacked bar: `from_y`, `to_y` and `color` (all three required)
  and `border_side`. In Rails HTML markup, `<bar-chart-rod-stack-item>` tags
  nested in a `<bar-chart-rod>` fill the rod's `rod_stack_items`, which only
  the next release draws. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

---

## Line chart

```ruby
line_chart(
  width: 320,
  height: 180,
  min_x: 0, max_x: 14, min_y: 0, max_y: 4,
  interactive: true,
  data_series: [
    line_chart_data(
      color: "#51cf66",
      stroke_width: 4,
      curved: true,
      rounded_stroke_cap: true,
      points: [
        line_chart_data_point(x: 1, y: 1),
        line_chart_data_point(x: 3, y: 1.5),
        line_chart_data_point(x: 7, y: 3.4)
      ]
    )
  ],
  on_event: ->(e) { puts "line event: #{e.data}" }
)
```

- [`line_chart`](/docs/control-line-chart) — `data_series`, the axes, ranges and
  grid. `on_event` data has `type` and `spots`. With the next release `spots` is
  a list of `{ bar_index:, spot_index: }` hashes for the touched points; on
  0.0.23 each of its entries is an empty String. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- [`line_chart_data`](/docs/control-line-chart-data) — one line: `points`,
  `color` or `gradient`, `stroke_width`, `curved`, `dash_pattern`, dots with
  `point: true`, and an area fill with `below_line_bgcolor` or
  `below_line_gradient`.
- [`line_chart_data_point`](/docs/control-line-chart-data-point) — `x` / `y` of
  one point, and `selected` to highlight it.

---

## Pie chart

```ruby
pie_chart(
  width: 220,
  height: 220,
  sections_space: 0,
  center_space_radius: 0,
  sections: [
    pie_chart_section(value: 40, title: "40%", color: "#4dabf7", radius: 100),
    pie_chart_section(value: 30, title: "30%", color: "#ffd43b", radius: 100),
    pie_chart_section(value: 30, title: "30%", color: "#51cf66", radius: 100)
  ],
  on_event: ->(e) { puts "pie event: #{e.data}" }
)
```

- [`pie_chart`](/docs/control-pie-chart) — `sections`, `sections_space`,
  `start_degree_offset` and the hole in the middle: `center_space_radius` (unset,
  the hole takes the room the slices leave; `0` for a full pie) and
  `center_space_color`. `on_event` data has `type`, `section_index`, `local_x`
  and `local_y`; a pie always reacts to touches.
- [`pie_chart_section`](/docs/control-pie-chart-section) — one slice: `value`,
  `color` or `gradient`, `radius`, `title` with `title_style` and
  `title_position`, a `badge` control with `badge_position` (both positions
  from 0, the inner edge, to 1, the outer edge), and `border_side`.

---

## Candlestick chart

```ruby
candlestick_chart(
  width: 320,
  height: 180,
  min_x: -0.5, max_x: 6.5, min_y: 22, max_y: 36,
  spots: [
    candlestick_chart_spot(x: 0, open: 24.8, high: 28.6, low: 23.9, close: 27.2),
    candlestick_chart_spot(x: 1, open: 27.2, high: 30.1, low: 25.8, close: 28.4)
  ],
  on_event: ->(e) { puts "candlestick event: #{e.data}" }
)
```

- [`candlestick_chart`](/docs/control-candlestick-chart) — `spots`, the axes,
  ranges and grid, `touch_spot_threshold`, `long_press_duration` and
  `rotation_quarter_turns`. `on_event` data has `type` and `spot_index`.
- [`candlestick_chart_spot`](/docs/control-candlestick-chart-spot) — `x` and the
  `open` / `high` / `low` / `close` prices of one candle; it is green when it
  closes above its open and red otherwise. With the next release `selected`
  keeps the bubble of a candle with its own `tooltip:` text shown. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

---

## Radar chart

```ruby
radar_chart(
  width: 300,
  height: 180,
  titles: [
    radar_chart_title(text: "macOS"),
    radar_chart_title(text: "Linux"),
    radar_chart_title(text: "Windows")
  ],
  data_sets: [
    radar_data_set(
      border_color: "#4dabf7",
      fill_color: "#4dabf7,0.2",
      entries: [
        radar_data_set_entry(value: 300),
        radar_data_set_entry(value: 50),
        radar_data_set_entry(value: 250)
      ]
    )
  ],
  on_event: ->(e) { puts "radar event: #{e.data}" }
)
```

- [`radar_chart`](/docs/control-radar-chart) — `titles`, `data_sets`,
  `radar_shape` (`"polygon"` or `"circle"`), `tick_count`, and the border, grid
  and tick lines. `on_event` data has `type`, `data_set_index`, `entry_index`
  and `entry_value`.
- [`radar_chart_title`](/docs/control-radar-chart-title) — the label of one
  spoke: `text`, `angle` in degrees and `position_percentage_offset`.
- [`radar_data_set`](/docs/control-radar-data-set) — one shape: `entries` (one
  per spoke), `fill_color` or `fill_gradient`, `border_color`, `border_width`
  and `entry_radius`.
- [`radar_data_set_entry`](/docs/control-radar-data-set-entry) — the `value` on
  one spoke.

---

## Scatter chart

```ruby
scatter_chart(
  width: 300,
  height: 180,
  min_x: 0, max_x: 50, min_y: 0, max_y: 50,
  left_axis: chart_axis(show_labels: false),
  bottom_axis: chart_axis(show_labels: false),
  spots: [
    scatter_chart_spot(x: 10, y: 10, radius: 6, color: "#339af0"),
    scatter_chart_spot(x: 35, y: 40, radius: 8, color: "#51cf66")
  ],
  on_event: ->(e) { puts "scatter event: #{e.data}" }
)
```

- [`scatter_chart`](/docs/control-scatter-chart) — `spots`, the axes, ranges
  and grid. `on_event` data has `type` and `spot_index`.
- [`scatter_chart_spot`](/docs/control-scatter-chart-spot) — `x` / `y`,
  `radius`, `color` (unset, one of 18 series colors), `label_text`,
  `render_priority`, or a custom dot with `point`.

---

## Axes

Every cartesian chart (bar, line, candlestick, scatter) takes a `chart_axis` for
each side. Build labels with `chart_axis_label`.

- [`chart_axis`](/docs/control-chart-axis) — `title` (a control such as
  `text(value: "Sales")`) and `title_size`; `show_labels`, `label_size` (the
  space reserved for labels, default 22), `label_spacing` (the distance between
  ticks), `show_min` / `show_max`, and custom `labels`.
- [`chart_axis_label`](/docs/control-chart-axis-label) — `value`, a tick value,
  and `label`, a string or any control drawn there.

---

## Canvas and drawing

[`canvas`](/docs/control-canvas) paints a list of shapes and can host an
interactive child in `content`. Each shape's stroke or fill is described by
`paint(...)`. Positions are logical pixels from the canvas's top-left corner,
and anything outside the canvas is clipped.

```ruby
shapes = [
  rect(x: 18, y: 18, width: 72, height: 44, border_radius: 8,
       paint: paint(color: "#4dabf7", stroke_width: 3, style: "stroke")),
  circle(x: 170, y: 40, radius: 22,
         paint: paint(color: "#ffd43b", style: "fill")),
  path(
    elements: [
      path_move_to(42, 156),
      path_line_to(92, 112),
      path_line_to(142, 156),
      path_close
    ],
    paint: paint(color: "#69db7c", stroke_width: 4, style: "stroke", stroke_join: "round")
  )
]

canvas(shapes, width: 420, height: 260)
```

### `paint`

Describes how a shape is stroked or filled. Passed to every shape via `paint:`.

- `color` — stroke/fill color (default black).
- `style` — `"fill"` (solid, the default) or `"stroke"` (outline).
- `stroke_width` — line thickness when `style: "stroke"` (default 0, a
  hairline).
- `stroke_cap` — line end shape: `"butt"` (the default), `"round"`, `"square"`.
- `stroke_join` — corner shape: `"miter"` (the default), `"round"`, `"bevel"`.
- `stroke_dash_pattern` — dash and gap lengths, for example `[8, 4]`.
- `gradient` — gradient paint instead of a flat color, with positions in canvas
  pixels: `{ _type: "linear", begin: [0, 0], end: [0, 120], colors: [...] }`,
  `{ _type: "radial", center:, radius:, colors: }` or
  `{ _type: "sweep", center:, start_angle:, end_angle:, colors: }`, each with
  optional `color_stops` and `tile_mode`.
- `blend_mode` — how the shape composites with what's behind it.
- `blur_image` — blurs what the shape paints.
- `anti_alias` — smooth edges (default true).

### `canvas`

- `shapes` — array of shapes to paint (first positional argument, or `shapes:`).
- `content` — a child control painted over the shapes — wrap it in
  `gesture_detector` to draw interactively.
- `width` / `height` — canvas size.
- `resize_interval` / `on_resize` — `on_resize` reports the painted size as
  `event.data[:w]` and `event.data[:h]`, at most once every
  `resize_interval` milliseconds (default 10).
- Standard layout props: `expand`, `padding`, `margin`, `offset`, `opacity`,
  `rotate`, `scale`, `visible`, `tooltip`.

### Shapes

- [`line(x1:, y1:, x2:, y2:, paint:)`](/docs/control-line) — a straight segment, always stroked.
- [`rect(x:, y:, width:, height:, border_radius:, paint:)`](/docs/control-rect) — a rectangle.
- [`circle(x:, y:, radius:, paint:)`](/docs/control-circle) — a circle centered at `(x, y)`.
- [`oval(x:, y:, width:, height:, paint:)`](/docs/control-oval) — an ellipse in the given box.
- [`arc(x:, y:, width:, height:, start_angle:, sweep_angle:, use_center:, paint:)`](/docs/control-arc) — an arc of an ellipse (angles in radians, clockwise from 3 o'clock).
- [`points(points:, point_mode:, paint:)`](/docs/control-points) — discrete points or lines; `point_mode` is `"points"`, `"lines"`, or `"polygon"`.
- [`path(elements:, paint:)`](/docs/control-path) — a free-form path built from path elements (below).
- [`shadow(path:, color:, elevation:, transparent_occluder:)`](/docs/control-shadow) — drop a shadow under a path; `path` is a list of path elements.
- [`fill(paint:)`](/docs/control-fill) — fill the whole canvas with a paint, such as a gradient.
- [`canvas_color(color:, blend_mode:)`](/docs/control-color) — fill the whole canvas with a color.
- `text(value:, x:, y:)` and `image(src:, x:, y:, width:, height:)` — text and
  pictures painted at a position.

### Path elements

Pass these in `path(elements: [...])` or `shadow(path: [...])`:

- `path_move_to(x, y)` — lift the pen and move to a point.
- `path_line_to(x, y)` — draw a line to a point.
- `path_quadratic_to(cp1x:, cp1y:, x:, y:, w: 1)` — a quadratic Bézier curve
  through the control point `cp1x`, `cp1y`. Pass `w: 1`: it is the curve's
  weight, and without it the curve is drawn as a straight line.
- `path_cubic_to(cp1x:, cp1y:, cp2x:, cp2y:, x:, y:)` — a cubic Bézier curve.
- `path_arc(x:, y:, width:, height:, start_angle:, sweep_angle:)` — add an arc
  of the ellipse in that box.
- `path_arc_to(x:, y:, radius:, rotation:, large_arc:, clockwise:)` — draw an
  arc from the current point to `x`, `y`.
- `path_oval(x:, y:, width:, height:)` / `path_rect(x:, y:, width:, height:, border_radius:)`
  — add an oval or rectangle sub-shape.
- `path_sub_path(elements:, x:, y:)` — embed another path, shifted by `x`, `y`.
- `path_close` — close the current contour back to its start.

### Interactive drawing

Host a `gesture_detector` in the canvas `content` and append `line` shapes as the
pointer moves, then `page.update` the canvas with the new shape list.
`event.local_position` is the pointer position inside the canvas:

```ruby
strokes = []
last = nil
stroke_paint = paint(color: "#ff6b6b", stroke_width: 3, style: "stroke", stroke_cap: "round")
base_shapes = [rect(x: 0, y: 0, width: 420, height: 260, paint: paint(color: "#f8fafc"))]

drawing = canvas(
  base_shapes,
  width: 420, height: 260,
  content: gesture_detector(
    drag_interval: 10,
    on_pan_start:  ->(e) { last = e.local_position },
    on_pan_update: ->(e) {
      pos = e.local_position
      if last && pos
        strokes << line(x1: last.x, y1: last.y, x2: pos.x, y2: pos.y, paint: stroke_paint)
        page.update(drawing, shapes: base_shapes + strokes)
      end
      last = pos
    },
    on_pan_end: ->(_e) { last = nil }
  )
)
page.add(drawing)
```

### Saving a drawing

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). On 0.0.23 the canvas has no `capture` method.

`capture` paints the current shapes into a picture the canvas keeps and draws
under its shapes, so a long drawing can drop its old strokes. `get_capture`
returns that picture as PNG bytes and `clear_capture` drops it:

```ruby
board = canvas(
  [circle(x: 60, y: 60, radius: 40, paint: paint(color: "#2563eb"))],
  width: 120,
  height: 120
)
status = text(value: "Nothing captured")
page.add(column(children: [board, status]))
page.add(
  button("Save drawing", on_click: ->(_event) {
    board.capture(on_result: ->(_result, error) {
      next page.update(status, value: error.to_s) if error

      board.get_capture(on_result: ->(png, read_error) {
        page.update(status, value: read_error ? read_error.to_s : "Captured #{png.to_s.bytesize} bytes of PNG")
      })
    })
  })
)
```

### `shader_mask`

Wraps a child and masks it with a gradient/shader — useful for fades and
gradient-tinted images.

- `content` — the control to mask.
- `shader` — the shader/gradient applied as the mask.
- `blend_mode` — how the shader combines with the child.
- `border_radius` — clip the masked area to rounded corners.
- Standard layout props: `expand`, `width`, `height`, `opacity`, `visible`.
