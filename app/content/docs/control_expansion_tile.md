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
        on_change: ->(event) {
          expanded = event.data == true
          # iOS and macOS redraw the tile only when Ruby sets `expanded`.
          page.update(event.control, expanded: expanded)
          page.update(status, value: expanded ? "Expanded" : "Collapsed")
        }
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
- `on_change` — `event.data` is `true` when the tile expands and `nil` when it collapses

## Usage

Several tiles in a [`column`](/docs/control-column) or
[`list_view`](/docs/control-list-view) form an accordion. Each tile opens and
closes on its own.

On Android, web, Windows and Linux a tile opens and closes as soon as it is
tapped. On iOS and macOS it is redrawn only when Ruby sets `expanded`, so set
it in `on_change`, as the example does. Setting `expanded` with `page.update`
also opens or closes a tile from code on every platform.

The client sets the tile's `expanded` and sends it to Ruby before it fires
`on_change`, so `event.control.props["expanded"]` is the new state too: `true`
when the tile opens and `false` when it closes.

With the next release `event.control.expanded` reads the same value. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

On iOS and macOS the tile uses `title`, `subtitle`, `leading`, `trailing`,
`expanded`, `bgcolor` / `collapsed_bgcolor`, `tile_padding` (12 on every side
by default) and `controls_padding`, and removes the hidden controls while it
is collapsed. It always shows an arrow when `trailing` is not set.
`maintain_state`, the text colors and the icon colors apply on Android, web,
Windows and Linux only, and so do `affinity`, `shape` / `collapsed_shape`,
`clip_behavior`, `dense`, `visual_density`, `min_tile_height`,
`show_trailing_icon`, `enable_feedback`, `expanded_alignment`,
`expanded_cross_axis_alignment` and `animation_style`.
