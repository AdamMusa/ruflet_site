# BottomAppBar

A bar along the bottom of the screen for a few actions. Assign it to
`page.bottom_appbar`.

## Example

```ruby
status = text(value: "Ready")
page.bottom_appbar = bottom_app_bar(
  row(
    children: [
      icon_button("menu", tooltip: "Menu", on_click: ->(_event) { page.update(status, value: "Menu") }),
      icon_button("search", tooltip: "Search", on_click: ->(_event) { page.update(status, value: "Search") }),
      icon_button("favorite", tooltip: "Favorites", on_click: ->(_event) { page.update(status, value: "Favorites") })
    ]
  ),
  bgcolor: "#f1f5f9"
)
page.add(status)
```

## Common properties

- `content` — the bar's content, usually a `row` of icon buttons; the first positional argument sets it
- `bgcolor` / `elevation` / `shadow_color`
- `height` / `padding`
- `shape` — a notch for a docked floating action button, for example `{ _type: "circular" }`
- `notch_margin` — space between the notch and the button
- `border_radius` / `clip_behavior`

## Usage

For switching between top-level destinations, use a
[`navigation_bar`](/docs/control-navigation-bar) instead; a bottom app bar is
for actions on the current screen.
