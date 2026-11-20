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
- `selected_icon` / `selected_icon_color` — on iOS and macOS these need the next release. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `url`
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
- Use `url:` to open a link through the client `url_launcher`; use `on_click:`
  for application actions.
