# CupertinoRadio

`cupertino_radio` builds the same `Radio` control as
[`radio`](/docs/control-radio), with iOS defaults: it sends
`label_position: "right"`, `toggleable: false` and
`use_checkmark_style: false`. Like every radio it goes inside a
[`radio_group`](/docs/control-radio-group), which holds the selection and
fires `on_change`. The client draws iOS-style radios on iOS and macOS and
Material ones on Android, web, Windows and Linux.

## Example

```ruby
sound = text(value: "Alert: Chime")
page.add(
  column(
    children: [
      radio_group(
        value: "chime",
        on_change: ->(event) { page.update(sound, value: "Alert: #{event.data.capitalize}") },
        content: column(
          children: [
            cupertino_radio(value: "chime", label: "Chime", use_checkmark_style: true),
            cupertino_radio(value: "bell", label: "Bell", use_checkmark_style: true),
            cupertino_radio(value: "none", label: "None", use_checkmark_style: true)
          ]
        )
      ),
      sound
    ]
  )
)
```

## Common properties

- `value` — the value the group reports when this radio is picked
- `label` / `label_position` (`"right"` or `"left"`)
- `use_checkmark_style` — draw a check mark, as in iOS settings lists, instead of a filled circle
- `active_color` / `inactive_color` / `fill_color`
- `toggleable` — let a second tap clear the selection
- `disabled`

## Usage

A radio sends no `on_change` of its own: the group does, with the picked
radio's `value` in `event.data`. `use_checkmark_style` and `inactive_color`
apply on iOS and macOS only; on Android, web, Windows and Linux the radios are
Material radio buttons that read `active_color` and `fill_color`.
