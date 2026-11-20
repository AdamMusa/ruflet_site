# TextButton

A low-emphasis button: a label with no fill or outline, for secondary actions
such as Cancel, Skip or Learn more. On iOS and macOS the client draws a plain
iOS button.

## Example

```ruby
step = text(value: "Step 1 of 3")
page.add(
  row(
    spacing: 8,
    children: [
      text_button("Skip", on_click: ->(_event) { page.update(step, value: "Skipped") }),
      filled_button("Next", on_click: ->(_event) { page.update(step, value: "Step 2 of 3") })
    ]
  )
)
page.add(step)
```

## Common properties

- `content` — the label, a string or a control; the first positional argument sets it
- `icon` / `icon_color` — an icon before the label (Android, web, Windows and Linux also need `content`)
- `style` — colors and padding, for example `style: { color: "#b91c1c" }`
- `on_click` / `on_long_press` / `on_hover`
- `url` — open a link in the browser on click, before `on_click` fires
- `disabled`
- `action` / `on_action_result` — a client action the button runs inside the tap. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Usage

A text button with `url:` opens the link in the browser, with no handler:

```ruby
page.add(text_button("Read the guide", icon: "open_in_new", url: "https://ruflet.dev/docs"))
```

Set the label color with `style: { color: ... }`. The top-level `color:` and
`bgcolor:` keywords take effect on Android, web, Windows and Linux only
together with `style`; the iOS button uses them directly, and a key in
`style:` wins over them.

`size`, `border_radius`, `padding`, `alignment`, `min_size`,
`opacity_on_click`, `disabled_bgcolor`, `focus_color` and `mouse_cursor` shape
the iOS button only; on the other platforms use the matching `style:` keys.
