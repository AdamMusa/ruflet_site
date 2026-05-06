# Checkbox

A boolean input control for toggled state.

## Example

```ruby
checkbox(
  label: "Enable notifications",
  value: true
)
```

## Common properties

- `label`
- `value`
- `on_change`
- `disabled`

## Usage

```ruby
checkbox(
  label: "I agree",
  value: accepted,
  on_change: ->(e) { accepted = e.data == "true" }
)
```

## Notes

- `on_change` is used when the checked state should update app state
