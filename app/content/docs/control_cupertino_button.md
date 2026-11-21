# CupertinoButton

`cupertino_button` builds the same `Button` control as
[`button`](/docs/control-button), with iOS-style keywords and defaults: Ruby
sends `size: "large"`, `opacity_on_click: 0.4`, `autofocus: false`, an
`alignment` and a `border_radius` unless you set them. The client picks the
look from the platform: an iOS button on iOS and macOS, a Material elevated
button elsewhere. [`cupertino_filled_button`](/docs/control-cupertino-filled-button)
and [`cupertino_tinted_button`](/docs/control-cupertino-tinted-button) are the
filled and tinted variants.

## Example

```ruby
status = text(value: "Not saved")
page.add(
  column(
    children: [
      cupertino_button(
        "Save",
        icon: "save",
        alignment: { x: 0, y: 0 },
        border_radius: 8,
        on_click: ->(_event) { page.update(status, value: "Saved") }
      ),
      status
    ]
  )
)
```

## Known issue: pass `alignment` and `border_radius`

With the default arguments, Ruby sends `alignment: "center"` and
`border_radius: { "all" => 8.0 }`, and the 0.0.23 client cannot read them
([ruflet#94](https://github.com/AdamMusa/ruflet/issues/94)). On iOS and macOS,
and in a web app opened on an Apple device, the `alignment` makes it draw an
error box instead of the button, and the radius comes out as square corners.
The Material button on the other platforms reads neither key. The client fix
is merged in ruflet-engine and reaches apps with the next update of the client
template; the Ruby-side fix,
[ruflet#100](https://github.com/AdamMusa/ruflet/pull/100), is still open. Until
one of them reaches your app, pass `alignment: { x: 0, y: 0 }` and
`border_radius: 8`, as in the example; the same applies to
`cupertino_filled_button` and `cupertino_tinted_button`.

## Common properties

- `content` — the label, a string or a control; the first positional argument sets it
- `icon` / `icon_color` — on iOS and macOS the icon may stand alone; elsewhere it needs `content`
- `bgcolor` / `color` — background and label colors on iOS and macOS
- `size` — `"small"`, `"medium"` or `"large"` (iOS and macOS only)
- `border_radius` / `padding` / `alignment` / `min_size` (iOS and macOS only)
- `opacity_on_click` — how much the button fades while pressed (iOS and macOS only)
- `disabled_bgcolor` / `focus_color` / `mouse_cursor` (iOS and macOS only)
- `on_click` / `on_long_press`
- `url` — open a link on click
- `action` / `on_action_result` — a client action the button runs inside the tap. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Usage

`cupertino_button` has no `style:` keyword. On Android, web, Windows and Linux
it renders as a Material elevated button, which takes its colors only from
`style:`, so `bgcolor:` and `color:` have no effect there. When one button must
look the same everywhere, use [`button`](/docs/control-button) with `style:`:
the iOS button reads the same `style:` keys.
