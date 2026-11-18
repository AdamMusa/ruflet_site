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
- `clear_button_visibility_mode` — `"never"`, `"editing"`, `"notEditing"` or `"always"`
- `prefix` / `suffix` with `prefix_visibility_mode` / `suffix_visibility_mode`
- `password` / `multiline` / `max_lines` / `max_length`
- `keyboard_type` / `capitalization` / `autocorrect`
- `on_change` / `on_submit` — `event.data` is the text
- `text_input_action` and `on_paste_files`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Usage

Use `hint_text` for the empty-field prompt: the Material look ignores
`placeholder_text`.
