# FilledButton

The high-emphasis button for the main action of a screen, such as Save or
Pay. On Android, web, Windows and Linux it is a Material filled button in the
theme's primary color; on iOS and macOS the client draws a filled iOS button.

## Example

```ruby
status = text(value: "Draft")
page.add(
  row(
    spacing: 12,
    children: [
      text_button("Cancel", on_click: ->(_event) { page.update(status, value: "Draft") }),
      filled_button("Publish", icon: "send", on_click: ->(_event) { page.update(status, value: "Published") })
    ]
  )
)
page.add(status)
```

## Common properties

- `content` — the label, a string or a control; the first positional argument sets it
- `icon` / `icon_color` — an icon before the label (Android, web, Windows and Linux also need `content`)
- `style` — colors, padding and shape on every platform, for example `style: { bgcolor: "#0f766e", padding: 20 }`
- `on_click` / `on_long_press` / `on_hover`
- `url` — open a link on click
- `disabled`
- `autofocus`, `on_focus` / `on_blur`
- `action` / `on_action_result` — a client action the button runs inside the tap. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Usage

Use one filled button per screen or dialog, next to lower-emphasis buttons
such as a [`text_button`](/docs/control-text-button) or an
[`outlined_button`](/docs/control-outlined-button).

Set colors through `style:`. The top-level `bgcolor:`, `color:` and
`elevation:` keywords take effect on Android, web, Windows and Linux only
together with `style`; the iOS button uses them directly, and a key in
`style:` wins over them.

`size`, `border_radius`, `padding`, `alignment`, `min_size`,
`opacity_on_click`, `disabled_bgcolor`, `focus_color` and `mouse_cursor` shape
the iOS button only; on the other platforms use the matching `style:` keys.
