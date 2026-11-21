# ExpansionPanelList

A list of panels that each open to show more content below their header, such
as the answers in an FAQ. Build each panel with
[`expansion_panel`](/docs/control-expansion-panel). Use
[`expansion_tile`](/docs/control-expansion-tile) instead for a single row that
opens.

## Example

```ruby
faq = {
  "How do I reset my password?" => "Open Settings, then Account, then Reset password.",
  "Can I use the app offline?" => "Yes. Changes sync when you are back online.",
  "How do I delete my account?" => "Write to support from the Help page."
}
status = text("Tap a question")
panels = faq.map do |question, answer|
  expansion_panel(
    header: list_tile(title: text(question)),
    content: list_tile(title: text(answer)),
    can_tap_header: true
  )
end

answers = nil
answers = expansion_panel_list(
  panels,
  on_change: ->(event) {
    panel = panels[event.data.to_i]
    state = panel.props["expanded"] ? "opened" : "closed"
    page.update(status, value: "You #{state} question #{event.data.to_i + 1}")
    # iOS and macOS redraw the panels only when the list is updated.
    page.update(answers, controls: panels)
  }
)

page.add(column(children: [answers, status]))
```

Give the panels as the first argument or as `controls:`. Several panels can be
open at once.

## Opening and closing

When the user taps a panel's header, the client flips that panel's
`expanded`, sends the new value to Ruby, and then fires the list's
`on_change` with the panel's index in `event.data`. Read the new state from
`panel.props["expanded"]`. To open or close a panel from code, set its
`expanded` and update the list: `page.update(answers, controls: panels)`.

With the next release `panel.expanded` reads the same value as
`panel.props["expanded"]`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

On Android, web, Windows and Linux the panel opens as soon as it is tapped. On
iOS and macOS it is redrawn only when Ruby updates the list, so update the
list in `on_change`, as the example does.

## Properties

- `controls` — the `expansion_panel` panels.
- `divider_color` — the lines between panels.
- `expand_icon_color` — the color of the arrow icons. The 0.0.23 client ignores it. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `elevation` (default 2), `spacing` (the gap around an open panel, default 16) and `expanded_header_padding` (the header padding while open, default 16 above and below) — Android, web, Windows and Linux only.
- `scroll`, `auto_scroll`, `scroll_interval` and `on_scroll` — make the list scroll when it does not fit. The 0.0.23 client ignores them. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Panels

`expansion_panel` takes keyword arguments only.

- `header` — the control in the header row, usually a `list_tile`.
- `content` — the control shown while the panel is open.
- `expanded` — whether the panel is open (default `false`).
- `can_tap_header` — let a tap anywhere on the header toggle the panel, not only on the arrow (default `false`). On iOS and macOS the whole header always toggles it.
- `bgcolor` — the panel's background.
- `highlight_color` and `splash_color` — the header's tap feedback, Android, web, Windows and Linux only.

A panel is drawn only inside an `expansion_panel_list`. Its common layout
properties, such as `width` or `margin`, have no effect.

## Events

- `on_change` — a panel's header was tapped. `event.data` is the panel's index.

## Platform differences

On iOS and macOS each panel is a row on the system's secondary background
color with a chevron, and the open content has 12 of padding. A panel without
a `header` or `content` shows placeholder text in its place.
