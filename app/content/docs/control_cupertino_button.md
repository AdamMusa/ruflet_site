# CupertinoButton

`cupertino_button` builds the same `Button` control as
[`button`](/docs/control-button), with iOS-style defaults: `size: "large"`, an
8-point `border_radius` and `opacity_on_click: 0.4`. The client picks the look
from the platform: the Cupertino button on iOS and macOS, the Material button
elsewhere.

## Example

```ruby
status = text(value: "Not saved")
page.add(
  column(
    children: [
      cupertino_button("Save", icon: "save", on_click: ->(_event) { page.update(status, value: "Saved") }),
      status
    ]
  )
)
```

## Common properties

- `content` — the label, a string or a control; the first positional argument sets it
- `icon` / `icon_color`
- `bgcolor` / `color` — the Cupertino look uses them directly
- `size` — `"small"`, `"medium"` or `"large"` (iOS and macOS only)
- `border_radius` / `padding` / `min_size` (iOS and macOS only; Material buttons take padding, shape and minimum size from `style:`)
- `opacity_on_click` — how much the button fades while pressed (iOS and macOS only)
- `on_click` / `on_long_press`
- `url` — open a link on click
- `action` / `on_action_result` — a client action the button runs inside the tap. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Usage

On Android, web, Windows and Linux the button renders as a Material button, which
takes its colors from `style:` (see
[OutlinedButton](/docs/control-outlined-button)). Set both `style` and the
top-level colors when one button must look right everywhere.
