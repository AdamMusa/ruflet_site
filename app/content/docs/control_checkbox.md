# Checkbox

A box the user checks and clears, with an optional label. The client draws an
iOS-style checkbox on iOS and macOS and a Material one on Android, Windows
and Linux; [`cupertino_checkbox`](/docs/control-cupertino-checkbox) builds the
same control. A web app follows the device: in a browser on an iPhone, iPad or Mac it gets the iOS design.

## Example

```ruby
submit = filled_button("Continue", disabled: true)
terms = checkbox(
  label: "I agree to the terms",
  value: false,
  on_change: ->(event) { page.update(submit, disabled: !event.control.props["value"]) }
)
page.add(column(children: [terms, submit]))
```

## Common properties

- `value` — `true` or `false` (default); `nil` is the mixed state of a `tristate` checkbox
- `label` / `label_position` (`"right"` or `"left"`) / `label_style`; tapping the label toggles the box too
- `tristate` — allow the mixed state
- `active_color` / `check_color` / `fill_color` / `border_side` / `shape`
- `disabled`
- `on_change`

## Usage

The client writes the new state to `value` before it sends `on_change`, so read
it from `event.control.props["value"]`, as above. Do not use `event.data`
alone: it is `true` when the box was checked, but `nil`, not `false`, when it
was cleared, because the client sends `false` and Ruby receives it as `nil`.
Outside a handler, read `terms.props["value"]`.

`event.control.value` (and `terms.value`) returns the same value as
`props["value"]`; with 0.0.23 it raises NoMethodError. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

With `tristate: true` a tap cycles unchecked, checked and mixed, and the mixed
state arrives as `nil`. Use it for a "select all" box over a list:

```ruby
items = %w[Milk Eggs Bread].map { |name| checkbox(label: name, value: false) }
all = checkbox(label: "Select all", tristate: true, value: false)
sync_all = ->(_event) {
  states = items.map { |item| item.props["value"] }
  page.update(all, value: states.all? ? true : (states.none? ? false : nil))
}
items.each { |item| item.on(:change, &sync_all) }
all.on(:change) do |event|
  checked = event.control.props["value"] == true
  items.each { |item| page.update(item, value: checked) }
  page.update(all, value: checked)
end
page.add(column(children: [all, *items]))
```

## Platform differences

`hover_color`, `overlay_color`, `splash_radius`, `visual_density` and `error`
apply on Android, Windows and Linux only: the iOS checkbox has no ink
and no error state.
