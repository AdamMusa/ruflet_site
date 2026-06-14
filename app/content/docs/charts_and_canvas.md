# Charts and Canvas

Ruflet provides chart controls and a low-level drawing canvas. Charts are built
from a parent chart and data controls such as groups, rods, sections, and
spots. The canvas paints shapes described by `paint(...)` and can receive
pointer input through a gesture detector.

Every helper below is a normal Ruflet control — compose them inside `column`,
`row`, `container`, etc. like any other widget.

---

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

### `bar_chart`

- `width` / `height` — chart size in logical pixels.
- `min_y` / `max_y` / `min_x` / `max_x` — value range of the axes.
- `groups` — array of `bar_chart_group` controls, one per x position.
- `left_axis` / `right_axis` / `top_axis` / `bottom_axis` — a `chart_axis` for each side.
- `horizontal_grid_lines` / `vertical_grid_lines` — grid line style: `{ color:, width:, dash_pattern: }`.
- `border` — outer border: `{ width:, color: }`.
- `tooltip` — tooltip configuration, or `nil` to disable.
- `on_event` — fired on touch/hover; the block receives the touched bar's data.

### `bar_chart_group`

- `x` — the x position this group sits at.
- `rods` — array of `bar_chart_rod` (the bars drawn at this x).
- `bars_space` — spacing between rods in the group.
- `showing_tooltip_indicators` — indices of rods that show a tooltip.

### `bar_chart_rod`

- `from_y` / `to_y` — bottom and top values of the bar.
- `width` — bar thickness.
- `color` — fill color (or use `gradient`).
- `gradient` — gradient fill instead of a flat color.
- `border_radius` — rounded bar corners.
- `rod_stack_items` — array of `bar_chart_rod_stack_item` to stack segments inside one rod.

### `bar_chart_rod_stack_item`

- `from_y` / `to_y` — value range of this stacked segment.
- `color` — segment color.
- `border_side` — segment border: `{ width:, color: }`.

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

### `line_chart`

- `width` / `height` — chart size.
- `min_y` / `max_y` / `min_x` / `max_x` — axis ranges.
- `data_series` — array of `line_chart_data` (one entry per line).
- `left_axis` / `right_axis` / `top_axis` / `bottom_axis` — `chart_axis` per side.
- `interactive` — enable touch tracking and tooltips.
- `tooltip` — tooltip configuration, or `nil` to disable.
- `on_event` — fired on touch; the block receives the touched spot's data.

### `line_chart_data`

- `points` — array of `line_chart_data_point`.
- `color` — line color (or use `gradient`).
- `gradient` — gradient stroke.
- `stroke_width` — line thickness.
- `curved` — draw a smooth curve through the points instead of straight segments.
- `rounded_stroke_cap` — round the line ends.

### `line_chart_data_point`

- `x` / `y` — the coordinate of one point on the line.

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

### `pie_chart`

- `width` / `height` — chart size.
- `sections` — array of `pie_chart_section`.
- `sections_space` — gap between sections.
- `center_space_radius` — radius of the empty hole in the middle (0 = full pie).
- `tooltip` — tooltip configuration, or `nil`.
- `on_event` — fired on touch; the block receives the touched section's data.

### `pie_chart_section`

- `value` — the slice's magnitude (slices are sized relative to the total).
- `title` — label drawn on the slice.
- `color` — slice color.
- `radius` — slice radius (length from the center).
- `title_style` — text style for the title: `{ size:, color:, weight: }`.
- `badge_widget` — a control drawn as a badge on the slice.
- `badge_position_percentage_offset` — where along the radius the badge sits (0–1).

---

## Candlestick chart

```ruby
candlestick_chart(
  width: 320,
  height: 180,
  min_x: -0.5, max_x: 6.5, min_y: 22, max_y: 36,
  spots: [
    candlestick_chart_spot(x: 0, open: 24.8, high: 28.6, low: 23.9, close: 27.2, selected: true),
    candlestick_chart_spot(x: 1, open: 27.2, high: 30.1, low: 25.8, close: 28.4)
  ],
  on_event: ->(e) { puts "candlestick event: #{e.data}" }
)
```

### `candlestick_chart`

- `width` / `height` — chart size.
- `min_x` / `max_x` / `min_y` / `max_y` — axis ranges.
- `spots` — array of `candlestick_chart_spot`.
- `left_axis` / `right_axis` / `top_axis` / `bottom_axis` — `chart_axis` per side.
- `tooltip` — tooltip configuration, or `nil`.
- `on_event` — fired on touch; the block receives the touched candle's data.

### `candlestick_chart_spot`

- `x` — the candle's x position.
- `open` / `high` / `low` / `close` — the OHLC values of the candle.
- `selected` — draw this candle in its selected state.

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
      fill_color: "#4dabf733",
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

### `radar_chart`

- `width` / `height` — chart size.
- `titles` — array of `radar_chart_title`, one per axis spoke.
- `data_sets` — array of `radar_data_set` (overlaid polygons).
- `on_event` — fired on touch; the block receives the touched entry's data.

### `radar_chart_title`

- `text` — the spoke label.
- `angle` — rotation of the label.
- `position_percentage_offset` — distance of the label from the chart edge (0–1).

### `radar_data_set`

- `entries` — array of `radar_data_set_entry`, one value per spoke (in spoke order).
- `border_color` — outline color of the polygon.
- `fill_color` — fill color (use an alpha suffix like `#4dabf733` for translucency).
- `border_width` — outline thickness.

### `radar_data_set_entry`

- `value` — the magnitude along one spoke.

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

### `scatter_chart`

- `width` / `height` — chart size.
- `min_x` / `max_x` / `min_y` / `max_y` — axis ranges.
- `spots` — array of `scatter_chart_spot`.
- `left_axis` / `right_axis` / `top_axis` / `bottom_axis` — `chart_axis` per side.
- `on_event` — fired on touch; the block receives the touched spot's data.

### `scatter_chart_spot`

- `x` / `y` — the point's coordinate.
- `radius` — dot size.
- `color` — dot color.

---

## Axes

Every cartesian chart (bar, line, candlestick, scatter) takes a `chart_axis` for
each side. Build labels with `chart_axis_label`.

### `chart_axis`

- `title` — a control drawn as the axis title (e.g. `text(value: "Sales")`).
- `title_size` — space reserved for the title.
- `labels` — array of `chart_axis_label` placed at specific values.
- `label_size` — space reserved for the tick labels.
- `show_labels` — set to `false` to hide this axis's labels entirely.

### `chart_axis_label`

- `value` — the axis position the label sits at.
- `label` — a control to render at that position (text, container, icon…).

---

## Canvas and drawing

`canvas` paints a list of shapes and can host an interactive child via `content`.
Each shape's stroke/fill is described by `paint(...)`.

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

- `color` — stroke/fill color.
- `style` — `"stroke"` (outline) or `"fill"` (solid).
- `stroke_width` — line thickness when `style: "stroke"`.
- `stroke_cap` — line end shape: `"round"`, `"square"`, `"butt"`.
- `stroke_join` — corner shape: `"round"`, `"bevel"`, `"miter"`.
- `gradient` — gradient paint instead of a flat color.
- `blend_mode` — how the shape composites with what's behind it.

### `canvas`

- `shapes` — array of shapes to paint (first positional argument, or `shapes:`).
- `content` — a child control painted over the shapes — wrap it in
  `gesture_detector` to draw interactively.
- `width` / `height` — canvas size.
- `resize_interval` / `on_resize` — throttle and handle canvas resize events.
- Standard layout props: `expand`, `padding`, `margin`, `offset`, `opacity`,
  `rotate`, `scale`, `visible`, `tooltip`.

### Shapes

- `line(x1:, y1:, x2:, y2:, paint:)` — a straight segment.
- `rect(x:, y:, width:, height:, border_radius:, paint:)` — a rectangle.
- `circle(x:, y:, radius:, paint:)` — a circle centered at `(x, y)`.
- `oval(x:, y:, width:, height:, paint:)` — an ellipse in the given box.
- `arc(x:, y:, width:, height:, start_angle:, sweep_angle:, use_center:, paint:)` — an arc of an ellipse (angles in radians).
- `points(points:, point_mode:, paint:)` — discrete points/lines; `point_mode` is `"points"`, `"lines"`, or `"polygon"`.
- `path(elements:, paint:)` — a free-form path built from path elements (below).
- `shadow(path:, color:, elevation:, transparent_occluder:)` — drop a shadow under a path.

### Path elements

Pass these in `path(elements: [...])`:

- `path_move_to(x, y)` — lift the pen and move to a point.
- `path_line_to(x, y)` — draw a line to a point.
- `path_arc(...)` / `path_arc_to(...)` — add an arc.
- `path_oval(...)` / `path_rect(...)` — add an oval/rectangle sub-shape.
- `path_quadratic_to(...)` — a quadratic Bézier curve.
- `path_cubic_to(...)` — a cubic Bézier curve.
- `path_sub_path(...)` — embed another path.
- `path_close` — close the current contour back to its start.

### Interactive drawing

Host a `gesture_detector` in the canvas `content` and append `line` shapes as the
pointer moves, then `page.update` the canvas with the new shape list:

```ruby
strokes = []
last = nil
stroke_paint = paint(color: "#ff6b6b", stroke_width: 3, style: "stroke", stroke_cap: "round")

drawing = canvas(
  base_shapes,
  width: 420, height: 260,
  content: gesture_detector(
    drag_interval: 10,
    on_pan_start:  ->(e) { last = extract_pos(e) },
    on_pan_update: ->(e) {
      pos = extract_pos(e)
      if last && pos
        strokes << line(x1: last[:x], y1: last[:y], x2: pos[:x], y2: pos[:y], paint: stroke_paint)
        page.update(drawing, shapes: base_shapes + strokes)
      end
      last = pos
    },
    on_pan_end: ->(_e) { last = nil }
  )
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
