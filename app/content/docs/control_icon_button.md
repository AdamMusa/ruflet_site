# IconButton

A compact icon action control with click handlers and optional selected state.

## Example

```ruby
icon_button(
  icon: :add,
  on_click: ->(_e) { page.update(status, value: "Added") }
)
```

## Common properties

- `icon`
- `icon_color`
- `icon_size`
- `tooltip`
- `selected`
- `selected_icon`
- `selected_icon_color`
- `on_click`

## Usage

```ruby
icon_button(
  icon: "search",
  tooltip: "Search",
  on_click: ->(_e) { page.update(status, value: "Search pressed") }
)
```

## Notes

- Ruflet accepts icon names as strings, symbols, and `Ruflet::MaterialIcons::*`
- `selected_icon` is supported by the underlying control model
