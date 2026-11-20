# ExpansionTile

A list row that expands to reveal more controls below it, for settings groups,
FAQs or details that most users do not need at first.

## Example

```ruby
status = text(value: "Collapsed")
page.add(
  column(
    children: [
      expansion_tile(
        [
          list_tile(title: text("Email notifications")),
          list_tile(title: text("Push notifications"))
        ],
        title: text("Notifications"),
        subtitle: text("Choose how we contact you"),
        leading: icon("notifications"),
        on_change: ->(event) { page.update(status, value: event.data ? "Expanded" : "Collapsed") }
      ),
      status
    ]
  )
)
```

## Common properties

- `title` — required; a string or a control
- `controls` — the controls revealed when expanded; the first positional argument sets them
- `subtitle` / `leading` / `trailing`
- `expanded` — start expanded
- `maintain_state` — keep the hidden controls alive while collapsed
- `bgcolor` / `collapsed_bgcolor`, `text_color` / `collapsed_text_color`, `icon_color` / `collapsed_icon_color`
- `tile_padding` / `controls_padding`
- `on_change` — `event.data` is `true` when the tile expands

## Usage

Several tiles in a [`column`](/docs/control-column) or
[`list_view`](/docs/control-list-view) form an accordion. Each tile opens and
closes on its own.

On iOS and macOS the tile uses `title`, `subtitle`, `leading`, `trailing`,
`expanded`, `bgcolor` / `collapsed_bgcolor`, `tile_padding` and
`controls_padding`, and removes the hidden controls while it is collapsed.
`maintain_state`, the text colors and the icon colors apply on Android, web,
Windows and Linux only.
