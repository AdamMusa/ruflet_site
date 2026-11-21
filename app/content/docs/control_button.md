# Button

The standard raised button, built with `button` or its alias
`elevated_button`. On Android, web, Windows and Linux it is a Material elevated
button; on iOS and macOS the client draws an iOS button instead.

## Example

```ruby
status = text(value: "Not saved")
page.add(
  column(
    children: [
      button("Save", icon: "save", on_click: ->(_event) { page.update(status, value: "Saved") }),
      elevated_button(
        "Delete",
        style: { bgcolor: "#b91c1c", color: :white },
        on_click: ->(_event) { page.update(status, value: "Deleted") }
      ),
      status
    ]
  )
)
```

## Common properties

- `content` — the label, a string or a control; the first positional argument sets it
- `icon` / `icon_color` — an icon before the label (Android, web, Windows and Linux also need `content`)
- `style` — colors, padding, shape and elevation on Android, web, Windows and Linux, for example `style: { bgcolor: "#0f766e", color: :white }`
- `bgcolor` / `color` / `elevation` — used as is on iOS and macOS; on the other platforms only together with `style`
- `on_click` / `on_long_press` / `on_hover`
- `url` — open a link on click
- `disabled`
- `autofocus`, `on_focus` / `on_blur`
- `action` / `on_action_result` — a client action the button runs inside the tap. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Usage

Put colors, padding and shape in `style:`, as the Delete button does: both
designs read it. The Material button reads the top-level `bgcolor:`, `color:`
and `elevation:` only as defaults for `style`, so without `style` they have no
effect there. The iOS button uses the top-level keywords directly, and a key in
`style:` wins over them.

These keywords shape the iOS button only: `size` (`"small"`, `"medium"` or
`"large"`), `border_radius`, `padding`, `alignment`, `min_size`,
`opacity_on_click`, `disabled_bgcolor`, `focus_color` and `mouse_cursor`.
Android, web, Windows and Linux ignore them; use the matching `style:` keys
there (`padding`, `shape`, `alignment`, `minimum_size`, `mouse_cursor`).

`on_hover` reports a mouse pointer entering (`event.data` is `true`) and
leaving (`nil`) the button. In the actions of an
[`alert_dialog`](/docs/control-alert-dialog) on iOS and macOS, a `button`
becomes a native dialog action, and `default: true` or `destructive: true`
draw it in bold or red.

For lower emphasis, use [`filled_tonal_button`](/docs/control-filled-tonal-button),
[`outlined_button`](/docs/control-outlined-button) or
[`text_button`](/docs/control-text-button); for the main action of a screen,
[`filled_button`](/docs/control-filled-button).
