# IconButton

A compact button that shows only an icon, such as search, share or a
favorite toggle. On Android, web, Windows and Linux it is a Material icon
button; on iOS and macOS the client draws a plain iOS button around the icon.

## Example

```ruby
status = text(value: "Nothing yet")
starred = false
page.add(
  row(
    children: [
      icon_button("search", tooltip: "Search", on_click: ->(_event) { page.update(status, value: "Searching") }),
      icon_button(
        "star_border",
        selected_icon: "star",
        selected: starred,
        tooltip: "Star",
        on_click: ->(event) {
          starred = !starred
          page.update(event.control, selected: starred)
          page.update(status, value: starred ? "Starred" : "Not starred")
        }
      ),
      status
    ]
  )
)
```

## Common properties

- `icon` — an icon name, a `Ruflet::MaterialIcons` constant or an `icon(...)` control; the first positional argument sets it
- `icon_color` / `icon_size`
- `tooltip`
- `selected` — show `selected_icon` and `selected_icon_color`; the client does not toggle it, so update it in `on_click`
- `selected_icon` / `selected_icon_color` / `disabled_color` — on iOS and macOS these need the next release. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `url` — open a link on click
- `on_click` / `on_long_press` / `on_hover`
- `action` / `on_action_result` — a client action the button runs inside the tap. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Usage

On Android, web, Windows and Linux, style the button with `style:`, for
example `style: { bgcolor: "#e0f2fe" }`; the top-level `bgcolor:` applies on
iOS and macOS only. With 0.0.23 the Material icon button ignores `style:`.
**Requires the next Ruflet release** (on `main`, not in 0.0.23).

`highlight_color`, `hover_color`, `splash_color`, `splash_radius` and
`size_constraints` shape the Material button only; iOS buttons fade when
pressed instead of showing ink.

`visual_density` makes the Material button more compact; the 0.0.23 client
ignores it. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

The filled, filled tonal and outlined variants are
[`filled_icon_button`](/docs/control-filled-icon-button),
[`filled_tonal_icon_button`](/docs/control-filled-tonal-icon-button) and
[`outlined_icon_button`](/docs/control-outlined-icon-button). Unlike
`icon_button`, they need an explicit `alignment` and `padding` until
[ruflet#94](https://github.com/AdamMusa/ruflet/issues/94) ships.
