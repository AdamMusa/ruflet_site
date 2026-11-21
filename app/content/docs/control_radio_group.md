# RadioGroup

Holds the selection of the [`radio`](/docs/control-radio) controls inside it:
the user picks one radio, and the group reports that radio's `value`. Lay the
radios out with any control, such as a `column` or a `row`, and pass it as the
group's `content`.

## Example

```ruby
plan = text(value: "Plan: monthly")
page.add(
  column(
    children: [
      radio_group(
        value: "monthly",
        on_change: ->(event) { page.update(plan, value: "Plan: #{event.data}") },
        content: row(
          children: [
            radio(value: "monthly", label: "Monthly"),
            radio(value: "yearly", label: "Yearly")
          ]
        )
      ),
      plan
    ]
  )
)
```

## Common properties

- `value` — the `value` of the selected radio, or `nil` for none
- `content` — the control holding the radios; the first positional argument sets it
- `on_change` — the user picked a radio; `event.data` is its `value`

## Usage

The client writes the picked radio's `value` to the group before it sends
`on_change`, so `event.data` and `event.control.props["value"]` hold the same
value. To read the choice later, keep it in Ruby state or read
`choice.props["value"]`:

```ruby
billing = "monthly"
choice = radio_group(
  value: billing,
  on_change: ->(event) { billing = event.control.props["value"] },
  content: column(
    children: [
      radio(value: "monthly", label: "Monthly"),
      radio(value: "yearly", label: "Yearly")
    ]
  )
)
page.add(choice)
```

With 0.0.23, Ruflet parses the value as JSON when it can, so a radio `value`
such as `"2"` arrives as the Integer 2 in both; give radios values that are not
numbers, or compare with `.to_s`. In the next release a String `value` stays a
String, and an Integer `value` such as `2` still arrives as the Integer 2. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

`event.control.value` and `choice.value` return the same value as
`props["value"]`; with 0.0.23 they raise NoMethodError. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

Change the selection from Ruby with `page.update(choice, value: "yearly")`.
Give every radio in a group a distinct `value`.
