# RadioGroup

Group related radio choices into one selection.

## Example

```ruby
radio_group(
  value: "monthly",
  content: column(
    children: [
      radio(value: "monthly", label: "Monthly"),
      radio(value: "yearly", label: "Yearly")
    ]
  )
)
```

## Common properties

- `value`
- `content`
- `on_change`

## Usage

```ruby
plan = "basic"
choice = radio_group(
  value: plan,
  on_change: ->(e) { plan = e.data },
  content: column(
    children: [
      radio(value: "basic", label: "Basic"),
      radio(value: "pro", label: "Pro")
    ]
  )
)
page.add(choice)
```

## Notes

- A `radio_group` typically wraps one layout control containing several `radio(...)` controls
