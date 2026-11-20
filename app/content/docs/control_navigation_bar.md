# NavigationBar

The bar along the bottom of the screen for switching between an app's main
destinations, such as Home, Search and Profile. On Android, web, Windows and
Linux it is a Material navigation bar; on iOS and macOS the client draws the
iOS tab bar.

## Example

```ruby
sections = %w[Home Saved Settings]
heading = text(value: "Home", size: 24)
page.navigation_bar = navigation_bar(
  selected_index: 0,
  destinations: [
    navigation_bar_destination(icon: "home", label: "Home"),
    navigation_bar_destination(icon: "bookmark_border", selected_icon: "bookmark", label: "Saved"),
    navigation_bar_destination(icon: "settings", label: "Settings")
  ],
  on_change: ->(event) { page.update(heading, value: sections[event.data.to_i]) }
)
page.add(heading)
```

## Common properties

- `destinations` — [`navigation_bar_destination`](/docs/control-navigation-bar-destination)`(icon:, label:, selected_icon:)` entries; two to five work best
- `selected_index` — the highlighted destination, starting at 0
- `on_change` — `event.data` is the index of the picked destination
- `bgcolor`
- `indicator_color` — the pill behind the selected icon; on iOS and macOS the selected color when `active_color` is not set
- `label_behavior` — `"alwaysShow"`, `"onlyShowSelected"` or `"alwaysHide"` (Android, web, Windows and Linux only)
- `active_color` / `inactive_color` / `icon_size` (iOS and macOS only)

## Usage

Assign the bar with `page.navigation_bar = navigation_bar(...)`, or pass it to
a `view` as `navigation_bar:`. The client sets `selected_index` itself when the
user taps a destination, then sends `on_change`; change what the page shows in
the handler, as above, or call `page.go(...)` for route-based apps.

`elevation`, `shadow_color`, `indicator_shape`, `label_behavior`,
`label_padding`, `overlay_color` and `animation_duration` shape the Material
bar only. `surface_tint_color` does too, and the 0.0.23 client ignores it.
**Requires the next Ruflet release** (on `main`, not in 0.0.23).

On iOS and macOS the tab bar always shows the labels and a thin separator line
on top; `active_color`, `inactive_color` and `icon_size` style it there. The
`border` keyword is accepted but no client draws it.
[`cupertino_navigation_bar`](/docs/control-cupertino-navigation-bar) builds the
same control with the iOS keywords only.
