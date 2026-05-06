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
