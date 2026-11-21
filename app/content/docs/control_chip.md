# Chip

A compact element for an attribute, filter, or action. Chips are commonly shown
in a `row` and can be selectable or deletable. The client draws a Material chip
on Android, Windows and Linux and a rounded iOS-style button on iOS and
macOS. A web app follows the device: in a browser on an iPhone, iPad or Mac it gets the iOS design.

## Example

```ruby
names = %w[Open Closed Draft]
shown = text(value: "Showing: Open")
filters = names.map do |name|
  chip(
    label: text(name),
    selected: name == "Open",
    on_select: ->(_event) {
      picked = names.zip(filters).select { |_name, filter| filter.props["selected"] }.map(&:first)
      page.update(shown, value: "Showing: #{picked.join(', ')}")
    }
  )
end
page.add(column(children: [row(spacing: 8, children: filters), shown]))
```

## Common properties

- `label` — the chip's text or control (required); the first positional argument sets it
- `selected` / `selected_color` / `show_checkmark`
- `leading` — a control before the label, such as `icon("star")` or an avatar; a bare icon name such as `"star"` draws nothing
- `delete_icon` / `on_delete` — make the chip deletable
- `bgcolor`
- `padding`
- `on_click` / `on_select`

## Usage

Give a chip `on_select` to make it a toggle: each tap flips `selected` on the
client, which then sends `on_select`. Read the new state from
`event.control.props["selected"]`; `event.data` is `true` when the chip was
selected and `nil` when it was deselected. Give it `on_click` instead for an
action chip. A chip may not have both: the client then draws an error box in
its place.

`event.control.selected` returns the same value as `props["selected"]`; with
0.0.23 it raises NoMethodError. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

The delete button shows only when the chip has an `on_delete` handler, which
gets no data. Hide or remove the chip in the handler:

```ruby
tags = %w[ruby flutter mobile].map do |name|
  chip(label: text(name), on_delete: ->(event) { page.update(event.control, visible: false) })
end
page.add(row(spacing: 8, children: tags))
```

## Platform differences

On iOS and macOS the chip reads `label`, `leading`, `selected`,
`selected_color`, `bgcolor`, `padding`, `show_checkmark` and `delete_icon`.
The Material styling applies on Android, Windows
and Linux only: `border_side`, `shape`, `color`, `check_color`,
`disabled_color`, `elevation`, `elevation_on_click`, `shadow_color`,
`selected_shadow_color`, `label_padding`, `label_text_style`,
`delete_icon_color`, `leading_size_constraints`,
`delete_icon_size_constraints`, `clip_behavior`, `visual_density` and the
`*_animation_style` properties.
