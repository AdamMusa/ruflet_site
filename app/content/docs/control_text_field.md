# TextField

A text input for single-line and multi-line entry. The client draws a Material
text field on Android, web, Windows and Linux and an iOS-style one on iOS and
macOS; [`cupertino_text_field`](/docs/control-cupertino-text-field) builds the
same control with iOS defaults.

## Example

```ruby
greeting = text(value: "Hello")
page.add(
  column(
    children: [
      text_field(
        label: "Name",
        hint_text: "Your first name",
        max_length: 40,
        on_change: ->(event) { page.update(greeting, value: "Hello #{event.data}") }
      ),
      greeting
    ]
  )
)
```

## Common properties

- `value` — the text; the first positional argument sets it
- `label` / `hint_text`
- `password` / `can_reveal_password`
- `multiline` / `min_lines` / `max_lines` / `shift_enter`
- `max_length` — a limit, with a counter on Android, web, Windows and Linux
- `keyboard_type` / `capitalization` / `autocorrect` / `autofill_hints`
- `prefix` / `suffix` — text or a control inside the field
- `read_only` / `disabled` / `autofocus`
- `on_change` / `on_submit` / `on_focus` / `on_blur`

## Usage

`on_change` fires on every keystroke and `event.data` is the whole text. The
client writes the text to `value` first, so later, in another handler, read
`field.props["value"]`:

```ruby
field = text_field(label: "Email", keyboard_type: "email", autofill_hints: ["email"])
result = text(value: "")
page.add(
  column(
    children: [
      field,
      filled_button(
        "Subscribe",
        on_click: ->(_event) { page.update(result, value: "Subscribed #{field.props["value"]}") }
      ),
      result
    ]
  )
)
```

`field.value` and `event.control.value` return the same text as
`props["value"]`, and `field.selection` the same range as
`props["selection"]`; with 0.0.23 they raise NoMethodError. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

`on_submit` fires when the user presses the keyboard's done key, or Enter in a
single-line field; `event.data` is the text. In a `multiline` field Enter
starts a new line. With `shift_enter: true`, Enter submits and Shift+Enter
starts a new line; that submit carries no data, so read
`event.control.props["value"]`.

`on_selection_change` fires when the cursor moves or the selection changes.
`event.data["selected_text"]` is the selected text and
`event.data["selection"]` holds `base_offset`, `extent_offset`, `affinity` and
`directional`. While the field has this handler, the client also writes the
range to `selection`.

## Platform differences

The iOS text field has no Material decoration. These properties apply on
Android, web, Windows and Linux only: `helper`, `counter` and their styles and
line limits, `icon`, `prefix_icon`, `suffix_icon`, `prefix_style`,
`suffix_style`, `dense`, `collapsed`, `align_label_with_hint`, `hover_color`,
`focus_color`, `hint_fade_duration`, `hint_max_lines`, `size_constraints`,
`cursor_error_color`, `mouse_cursor`, `can_request_focus`, `always_call_on_tap`
and `ignore_pointers`. On iOS and macOS a text `label` becomes the placeholder
when there is no `hint_text`.

These apply on iOS and macOS only: `placeholder_text` and `placeholder_style`,
`clear_button_visibility_mode` and `clear_button_semantics_label`,
`prefix_visibility_mode` and `suffix_visibility_mode`, `padding`, `gradient`,
`image`, `shadows` and `blend_mode`.

On iOS and macOS, `error` (with `error_style` and `error_max_lines`), `filled`,
`fill_color`, `focused_bgcolor`, `focused_border_color` and
`focused_border_width` need the next release; with 0.0.23 the iOS field
ignores them. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
