# CupertinoTextField

`cupertino_text_field` builds the same `TextField` control as
[`text_field`](/docs/control-text-field), with iOS-style defaults such as
7-point padding. It sends `clear_button_visibility_mode: "never"` unless you
set another mode, so set one to get a clear button, as below. The client draws
an iOS text field on iOS and macOS and a Material one elsewhere.

## Example

```ruby
greeting = text(value: "Hello")
page.add(
  column(
    children: [
      cupertino_text_field(
        hint_text: "Your name",
        clear_button_visibility_mode: "editing",
        on_change: ->(event) { page.update(greeting, value: "Hello #{event.data}") }
      ),
      greeting
    ]
  )
)
```

## Common properties

- `value` — the text; the first positional argument sets it
- `hint_text` — shown while the field is empty, on every platform
- `placeholder_text` / `placeholder_style` — the iOS placeholder; only the Cupertino look reads them, and `hint_text` wins when both are set
- `clear_button_visibility_mode` — `"never"`, `"editing"`, `"notEditing"` or `"always"`; iOS and macOS only, the Material field has no clear button
- `prefix` / `suffix` with `prefix_visibility_mode` / `suffix_visibility_mode`; the visibility modes apply on iOS and macOS only
- `password` / `multiline` / `max_lines` / `max_length`
- `keyboard_type` / `capitalization` / `autocorrect`
- `on_change` / `on_submit` — `event.data` is the text
- `text_input_action` and `on_paste_files`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Usage

Use `hint_text` for the empty-field prompt: the Material look ignores
`placeholder_text`. A `label` does not show on iOS and macOS, because this
helper sends an empty `placeholder_text`.

`on_change` and `on_submit` work as on [`text_field`](/docs/control-text-field),
and so does `on_selection_change`: `event.data["selected_text"]` is the
selected text and `event.data["selection"]` its range. Read the text later with
`field.props["value"]`.

`field.value` and `event.control.value` return the same text as
`props["value"]`, and `field.selection` the same range as
`props["selection"]`; with 0.0.23 they raise NoMethodError. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Platform differences

The iOS defaults this helper sends (7-point `padding`, the clear-button and
visibility modes) matter on iOS and macOS only. On Android, web, Windows and
Linux the field is a Material text field: it ignores the Cupertino-only
properties above and reads the Material decoration ones, such as `helper`,
`counter`, `icon`, `prefix_icon`, `suffix_icon` and `dense`, which iOS and macOS
ignore. The full list is on the [`text_field`](/docs/control-text-field) page.
