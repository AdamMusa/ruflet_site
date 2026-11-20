# Switch

A material on/off toggle.

## Example

```ruby
switch(
  label: "Email notifications",
  value: true,
  on_change: ->(event) { settings.notify = event.control.props["value"] }
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

In `on_change`, read the new state from `event.control.props["value"]`; the
client writes it to the control before the event fires. Prefer it to
`event.data`, which the iOS switch can leave empty. To use the state later,
keep it in Ruby state or read `toggle.props["value"]`:

```ruby
dark_mode = false
toggle = switch(
  label: "Dark mode",
  value: dark_mode,
  on_change: ->(event) { dark_mode = event.control.props["value"] }
)
page.add(toggle)

# later, for example in another handler:
dark_mode             # => true after the user turns it on
toggle.props["value"] # => true
```
