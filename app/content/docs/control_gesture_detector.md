# GestureDetector

Adds touch and mouse handling to any control: taps, double taps, long presses,
drags, pinches, hover and scrolling. Put the control in `content` and handle
the gestures you need.

## Example

```ruby
position = text(value: "Tap or drag the square")
page.add(
  column(
    children: [
      gesture_detector(
        content: container(width: 200, height: 200, bgcolor: "#dbeafe", border_radius: 12),
        drag_interval: 50,
        on_tap: ->(event) {
          point = event.local_position
          page.update(position, value: point ? "Tapped at #{point.x.round}, #{point.y.round}" : "Tapped")
        },
        on_double_tap: ->(_event) { page.update(position, value: "Double tap") },
        on_pan_update: ->(event) {
          delta = event.local_delta
          page.update(position, value: "Dragged by #{delta.x.round}, #{delta.y.round}") if delta
        }
      ),
      position
    ]
  )
)
```

## Common properties

- `content` — the control that receives the gestures
- `on_tap` / `on_tap_down` / `on_tap_up` — `event.local_position` and `event.global_position` give the point
- `on_secondary_tap` — a right-click, with no position; use `on_secondary_tap_down` or `on_secondary_tap_up` for the point
- `on_double_tap` / `on_long_press`
- `on_pan_start` / `on_pan_update` / `on_pan_end` — drags in any direction; `event.local_delta` is the movement since the last update
- `on_horizontal_drag_*` / `on_vertical_drag_*` — drags along one axis
- `on_scale_start` / `on_scale_update` / `on_scale_end` — pinch and rotate
- `on_enter` / `on_exit` / `on_hover` / `on_scroll` — mouse and trackpad
- `drag_interval` / `hover_interval` — minimum milliseconds between update events
- `mouse_cursor` — for example `"click"`

## Usage

Each gesture event is a round trip to Ruby, so set `drag_interval` to throttle
`on_pan_update` and the other drag updates. The
[Charts and Canvas](/docs/charts-and-canvas) guide uses a gesture detector to
draw on a canvas.
