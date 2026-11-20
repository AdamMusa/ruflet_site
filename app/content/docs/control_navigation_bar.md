# NavigationBar

Bottom navigation control for switching between primary destinations.

## Example

```ruby
navigation_bar(
  selected_index: 0,
  destinations: [
    navigation_bar_destination(icon: "home", label: "Home"),
    navigation_bar_destination(icon: "settings", label: "Settings")
  ]
)
```

## Common properties

- `destinations`
- `selected_index`
- `on_change`
- `bgcolor`
- `elevation`
- `indicator_color`
- `label_behavior`

## Destination properties

`navigation_bar_destination(...)` commonly uses:

- `icon`
- `selected_icon`
- `label`

## Usage

```ruby
navigation_bar(
  selected_index: 0,
  on_change: ->(e) { page.update(status, value: "Tab #{e.data}") },
  destinations: [
    navigation_bar_destination(icon: "home", selected_icon: "home", label: "Home"),
    navigation_bar_destination(icon: "bookmark_border", selected_icon: "bookmark", label: "Saved")
  ]
)
```

## Notes

- Ruflet supports icon name strings for both `icon` and `selected_icon`
- use `page.go(...)` or `page.views = [...]` in response to navigation changes
