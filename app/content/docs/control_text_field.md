# TextField

Material text input control for single-line and multi-line entry.

## Example

```ruby
text_field(
  label: "Name",
  value: "Ruflet"
)
```

## Common properties

- `label`
- `value`
- `hint_text`
- `password`
- `multiline`
- `on_change`
- `on_submit`

## Usage

```ruby
status = text(value: "")

text_field(
  label: "Name",
  on_change: ->(e) { page.update(status, value: e.data.to_s) }
)
```

## Notes

- `on_change` is commonly used with `page.update(...)`
- use `multiline: true` for larger text entry areas
