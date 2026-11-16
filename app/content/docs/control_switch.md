# Switch

A material on/off toggle.

## Example

```ruby
switch(
  label: "Email notifications",
  value: true,
  on_change: ->(event) { settings.notify = event.control.value }
)
```

## Common properties

- `value` — `true` / `false`
- `label`
- `label_position` — `"left"` or `"right"`
- `active_color` / `active_track_color`
- `inactive_thumb_color` / `inactive_track_color`
- `thumb_color` / `thumb_icon`
- `track_color`

## Usage

The latest client value is stored on the control, in `toggle.props["value"]`.
React to changes with `on_change`:

```ruby
mode = text(value: "Light mode")
toggle = switch(
  label: "Dark mode",
  value: false,
  on_change: ->(event) { page.update(mode, value: event.value ? "Dark mode" : "Light mode") }
)
page.add(column(children: [toggle, mode]))
```
