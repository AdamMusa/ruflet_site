# OutlinedButton

A medium-emphasis button: an outline and a label, with no fill. Pair it with a
[`filled_button`](/docs/control-filled-button) for the secondary action, such
as Cancel next to Save.

## Example

```ruby
status = text(value: "Draft not saved")
page.add(
  row(
    spacing: 12,
    children: [
      outlined_button("Discard", icon: "delete", on_click: ->(_event) { page.update(status, value: "Draft discarded") }),
      filled_button("Save", icon: "save", on_click: ->(_event) { page.update(status, value: "Draft saved") })
    ]
  )
)
page.add(status)
```

## Common properties

- `content` — the label, a string or a control; the first positional argument sets it
- `icon` / `icon_color` — an icon shown before the label
- `style` — colors, padding, shape and outline, for example `style: { color: "#b91c1c" }`
- `on_click` / `on_long_press`
- `url` — open a link on click
- `disabled`
- `autofocus`, `on_focus` / `on_blur`
- `action` / `on_action_result` — a client action the button runs inside the tap. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Usage

Set colors through `style:`. The top-level `bgcolor:` and `color:` keywords are
accepted, but the Material button only uses them as defaults for `style`, so
they have no effect without it.

```ruby
outlined_button("Delete account", icon: "delete_forever", style: { color: "#b91c1c" })
```
