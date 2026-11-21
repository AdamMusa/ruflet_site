# CupertinoSlider

`cupertino_slider` builds the same `Slider` control as
[`slider`](/docs/control-slider) and sends `min: 0.0` and `max: 1.0` unless
you set them. The client draws an iOS-style slider on iOS and macOS and a
Material slider on Android, Windows and Linux. A web app follows the device: in a browser on an iPhone, iPad or Mac it gets the iOS design.

## Example

```ruby
volume = text(value: "Volume: 50%")
page.add(
  column(
    children: [
      cupertino_slider(
        value: 0.5,
        divisions: 10,
        active_color: "#34c759",
        on_change: ->(event) {
          level = (event.control.props["value"].to_f * 100).round
          page.update(volume, value: "Volume: #{level}%")
        }
      ),
      volume
    ]
  )
)
```

## Common properties

- `value` — between `min` and `max`
- `min` / `max` — the range (default 0.0 to 1.0)
- `divisions` — snap to discrete steps
- `active_color` — the track up to the thumb
- `thumb_color`
- `on_change` / `on_change_start` / `on_change_end`

## Usage

The client writes the value to the control before it sends `on_change`, so
read it from `event.control.props["value"]`, as above. On iOS and macOS
`on_change` carries no data; `on_change_start` and `on_change_end` send the
value in `event.data` on every platform. `on_change` fires continuously while
the user drags; handle `on_change_end` to react once, when they let go.

`event.control.value` returns the same value as `event.control.props["value"]`;
with 0.0.23 it raises NoMethodError. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

`cupertino_slider` accepts only the properties both designs share. For a value
label, an inactive color and the other Material-only properties, build the
slider with [`slider`](/docs/control-slider).

On iOS and macOS, the 0.0.23 client never sends `on_focus` or `on_blur`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
