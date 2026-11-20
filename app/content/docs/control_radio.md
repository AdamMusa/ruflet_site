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

On iOS and macOS the client draws Cupertino radios, which have no ink:
`overlay_color`, `hover_color`, `visual_density` and `splash_radius` apply on
Android, Windows and Linux only. The other way round, `inactive_color`
(the color of an unselected radio) and `use_checkmark_style` (a check mark, as
in iOS settings lists, instead of a filled circle) apply on iOS and macOS
only. [`cupertino_radio`](/docs/control-cupertino-radio) builds the same
control. A web app follows the device: in a browser on an iPhone, iPad or Mac it gets the iOS design.

A radio sends no `on_change` of its own; the group does. Read the choice in the
group's handler from `event.data` or `event.control.props["value"]`.

On iOS and macOS, the 0.0.23 client ignores `label_style`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
