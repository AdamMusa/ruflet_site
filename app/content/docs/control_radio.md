# Radio

One choice in a set of mutually exclusive options. A `radio` does not hold the
selection itself: put the radios inside a
[`radio_group`](/docs/control-radio-group), which owns `value` and fires
`on_change`.

## Example

```ruby
plan = text(value: "Plan: monthly")
page.add(
  radio_group(
    value: "monthly",
    on_change: ->(event) { page.update(plan, value: "Plan: #{event.data}") },
    content: column(
      children: [
        radio(value: "monthly", label: "Monthly"),
        radio(value: "yearly", label: "Yearly"),
        radio(value: "lifetime", label: "Lifetime", disabled: true)
      ]
    )
  )
)
page.add(plan)
```

## Common properties

- `value` — the value the group reports when this radio is chosen
- `label` / `label_position` (`"right"` or `"left"`) / `label_style`
- `disabled`
- `active_color` / `fill_color` / `overlay_color`
- `toggleable` — let a second tap clear the selection
- `visual_density` / `splash_radius`

## Usage

`event.data` in the group's `on_change` is the chosen radio's `value`. Lay the
radios out with any control, for example a `row` for a compact choice.
