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
accepted = false
submit = filled_button("Continue", disabled: true)
terms = checkbox(
  label: "I agree to the terms",
  value: accepted,
  on_change: ->(event) {
    accepted = event.value
    page.update(submit, disabled: !accepted)
  }
)
page.add(column(children: [terms, submit]))
```

## Notes

- `on_change` is used when the checked state should update app state
