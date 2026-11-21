# CupertinoTextField

`cupertino_text_field` builds the same `TextField` control as
[`text_field`](/docs/control-text-field), with iOS-style defaults such as
`padding: { all: 7 }`, which the 0.0.23 iOS field reads as no padding (see
Platform differences). It sends `clear_button_visibility_mode: "never"` unless you
set another mode, so set one to get a clear button, as below. The client draws
an iOS text field on iOS and macOS and a Material one elsewhere. A web app follows the device: in a browser on an iPhone, iPad or Mac it gets the iOS design.

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
- `on_change` / `on_submit` — `event.data` is the text; with 0.0.23, text such as `42` arrives parsed (see Usage)
- `text_input_action` and `on_paste_files`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Usage

Use `hint_text` for the empty-field prompt: the Material look ignores
`placeholder_text`. A `label` does not show on iOS and macOS, because this
helper sends an empty `placeholder_text`.

`on_change` and `on_submit` work as on [`text_field`](/docs/control-text-field),
and so does `on_selection_change`: `event.data[:selected_text]` is the
selected text and `event.data[:selection]` its range (the keys are Symbols). Read the text later from
the field's `props["value"]`.

With 0.0.23, Ruflet parses `on_change` and `on_submit` data as JSON when it
can, so typed `42` arrives as the Integer 42 in `event.data`, and typed `null`
as `nil`. `props["value"]` can then be the Integer 42 or the String `"42"`:
Ruflet copies the parsed data to `value` only on a change event, which the
client sends only while the field has `on_change`. Call `.to_s` when you need
the text. In the next release the typed text stays a String in both. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

`event.control.value` returns the same text as `props["value"]`, and
`event.control.selection` the same range as `props["selection"]`; with 0.0.23
they raise NoMethodError. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Platform differences

The iOS defaults this helper sends (`padding`, the clear-button and
visibility modes) matter on iOS and macOS only. On Android, Windows and
Linux the field is a Material text field: it ignores the Cupertino-only
properties above and reads the Material decoration ones, such as `helper`,
`counter`, `icon`, `prefix_icon`, `suffix_icon` and `dense`, which iOS and macOS
ignore. The full list is on the [`text_field`](/docs/control-text-field) page.

On iOS and macOS the 0.0.23 client reads the `{ all: 7 }` padding this helper
sends, and any `{ all: n }` map, as no padding, so the text touches the
field's edge. Pass a number, such as `padding: 7`, for the iOS inset on 0.0.23.
In the next release the client reads `{ all: 7 }` as 7 on every side. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
