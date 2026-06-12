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

```ruby
toggle = switch(label: "Dark mode", value: false)
# later:
toggle.value # => false
```
