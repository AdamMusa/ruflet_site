# Button

A standard elevated action button created with `elevated_button`.

## Example

```ruby
elevated_button(
  content: text(value: "Save"),
  on_click: ->(_e) { puts "saved" }
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
elevated_button(
  width: 160,
  content: text(value: "Continue"),
  on_click: ->(_e) { page.go("/next") }
)
```

## Notes

- Use `content:` for the visible label or nested control
