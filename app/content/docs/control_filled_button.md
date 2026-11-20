# FilledButton

A filled Material action button.

## Example

```ruby
filled_button(
  content: text(value: "Publish"),
  on_click: ->(_e) { puts "publish" }
)
```

## Common properties

- `content`
- `url`
- `on_click`
- `width`
- `height`
- `disabled`
- `style`

## Usage

```ruby
filled_button(
  content: text(value: "Create account"),
  on_click: ->(_e) { page.go("/signup") }
)
```

## Notes

- Use `filled_button` when the primary action needs stronger emphasis
- Use `url:` to open a link through the client `url_launcher`; use `on_click:`
  for application actions.
