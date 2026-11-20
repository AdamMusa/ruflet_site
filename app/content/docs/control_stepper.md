# Stepper

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). With 0.0.23 the client shows "Unknown control".

A sequence of numbered steps, such as a checkout or a setup wizard. Build each
step with `stepper_step`.

## Example

```ruby
current = 0
steps = [
  stepper_step(title: "Account", content: text_field(label: "Email")),
  stepper_step(title: "Address", content: text_field(label: "Street")),
  stepper_step(title: "Confirm", content: text("Ready to create your account"))
]

wizard = stepper(
  steps,
  current_step: current,
  on_step_continue: ->(_event) {
    current = [current + 1, steps.length - 1].min
    page.update(wizard, current_step: current)
  },
  on_step_cancel: ->(_event) {
    current = [current - 1, 0].max
    page.update(wizard, current_step: current)
  },
  on_step_tap: ->(event) {
    current = event.data.to_i
    page.update(wizard, current_step: current)
  }
)

page.add(wizard)
```

The stepper never moves by itself: your handlers decide the next step and set
`current_step`. Give the steps as the first argument, as `steps:`, or in a
block.

## Steps

`stepper_step` (alias `stepperstep`) builds one step. There is no bare `step`
helper.

- `title` — the step name, as a String or a control (required).
- `subtitle` and `label` — extra text, as a String or a control.
- `content` — the control shown while the step is current.
- `state` — `"indexed"` (default), `"editing"`, `"complete"`, `"disabled"` or `"error"`. It sets the step's icon.
- `is_active` — draw the step as active (default `false`).

## Properties

- `steps` — the `stepper_step` controls.
- `current_step` — the index of the open step (default `0`).
- `type` — `"vertical"` (default) or `"horizontal"`.
- `show_controls` — show the Continue and Cancel buttons (default `true`).
- `continue_text` and `cancel_text` — labels for those buttons.
- `connector_color` and `connector_thickness` — the line between steps.
- `elevation` and `clip_behavior` — appearance.

## Events

- `on_step_continue` — the user pressed Continue. `event.data` is the current step index.
- `on_step_cancel` — the user pressed Cancel. `event.data` is the current step index.
- `on_step_tap` — the user tapped a step header. `event.data` is the tapped step index.
