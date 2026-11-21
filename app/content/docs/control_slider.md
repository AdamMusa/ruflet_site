# Slider

A track with a thumb for picking a value from a continuous or discrete range.
The client draws an iOS-style slider on iOS and macOS and a Material slider on
Android, Windows and Linux;
[`cupertino_slider`](/docs/control-cupertino-slider) builds the same control. A web app follows the device: in a browser on an iPhone, iPad or Mac it gets the iOS design.

## Example

```ruby
preview = container(width: 120, height: 60, bgcolor: "#2563eb", opacity: 0.4)
page.add(
  column(
    children: [
      slider(
        value: 40,
        min: 0,
        max: 100,
        divisions: 10,
        label: "{value}%",
        on_change: ->(event) { page.update(preview, opacity: event.control.props["value"] / 100.0) }
      ),
      preview
    ]
  )
)
```

## Common properties

- `value` — between `min` and `max`
- `min` / `max` — the range (default 0.0 to 1.0)
- `divisions` — snap to discrete steps
- `label` — text shown above the thumb while dragging (`"{value}"` interpolates)
- `active_color` / `inactive_color`
- `thumb_color`
- `round` — decimal places for the displayed value

## Range slider

For two-handle selection, use `range_slider` with `start_value` / `end_value`:

```ruby
range_slider(start_value: 20, end_value: 80, min: 0, max: 100, divisions: 10)
```

## Usage

`on_change` fires continuously while dragging; use `on_change_end` to react only
when the user releases. Read the current value from
`event.control.props["value"]`; the client writes it to the control before
`on_change` fires. On iOS and macOS `on_change` carries no data, so do not read
`event.data` there. `on_change_start` and `on_change_end` send the value as
`event.data` on every platform.

`event.control.value` returns the same value as `event.control.props["value"]`;
with 0.0.23 it raises NoMethodError. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Platform differences

The iOS slider has no value label, ink or secondary track: `label`, `round`,
`inactive_color`, `overlay_color`, `mouse_cursor`, `interaction`,
`secondary_track_value`, `secondary_active_color`, `padding` and `year_2023`
apply on Android, Windows and Linux only. `value`, `min`, `max`,
`divisions`, `active_color` and `thumb_color` work everywhere.
