# Dropdown

A field that opens a list of options for choosing one value. Options are built
with [`dropdown_option`](/docs/control-dropdown-option). On Android, Windows and Linux the client draws a Material dropdown menu; on iOS and macOS a
text field that opens a wheel of the options, with Cancel and Done, from the
bottom of the screen. A web app follows the device: in a browser on an iPhone, iPad or Mac it gets the iOS design.

## Example

```ruby
status = text(value: "Picked apple")
page.add(
  column(
    children: [
      dropdown(
        label: "Fruit",
        hint_text: "Choose a fruit",
        value: "apple",
        options: [
          dropdown_option(key: "apple", text: "Apple"),
          dropdown_option(key: "banana", text: "Banana"),
          dropdown_option(key: "cherry", text: "Cherry")
        ],
        on_select: ->(event) { page.update(status, value: "Picked #{event.control.props["value"]}") }
      ),
      status
    ]
  )
)
```

## Common properties

- `value` — the selected option key
- `options` — an array of `dropdown_option`
- `label`
- `hint_text`
- `helper_text`
- `error_text`
- `filled`
- `bgcolor`
- `border` / `border_color` / `border_radius`
- `editable` — allow typing into the field
- `enable_filter` / `enable_search`
- `leading_icon` / `trailing_icon`

Use `on_select` when an option is selected. Editable dropdowns also expose
`on_text_change`, which reports the typed text in `event.data`; `on_focus` and
`on_blur` work on every dropdown. `on_change` is the `dropdown_m2` spelling of
`on_select`, and the 0.0.23 client never sends it, so handle `on_select`.

With 0.0.23, Ruflet parses `on_text_change` data as JSON when it can, so typed
`42` arrives as the Integer 42; call `.to_s` when you need the text. In the
next release the typed text stays a String. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Options

```ruby
dropdown_option(key: "us", text: "United States", leading_icon: "flag")
```

- `key` — the value stored on the dropdown
- `text` — the visible label
- `content` — a custom control instead of `text`
- `leading_icon` / `trailing_icon`
- `disabled`

## Usage

In `on_select`, read the chosen key from `event.control.props["value"]`; the
client writes it to the control, as a String (`"1"` for a key `1`), before the
event fires. `event.value` is `nil` for this event. To use the choice later,
keep it in Ruby state or read `field.props["value"]`:

```ruby
size = "s"
field = dropdown(
  label: "Size",
  value: size,
  options: [dropdown_option(key: "s", text: "Small"), dropdown_option(key: "l", text: "Large")],
  on_select: ->(event) { size = event.control.props["value"] }
)
page.add(field)

# later, for example in another handler:
size                 # => "l" after the user picks Large
field.props["value"] # => "l"
```

`event.data` carries the same key. With 0.0.23, Ruflet parses it as JSON when
it can, so a key such as `"1"` arrives as the Integer 1. In the next release a
String key stays a String, and an Integer key such as `1` still arrives as the
Integer 1. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

`event.control.value` and `field.value` return the same key as
`props["value"]`; with 0.0.23 they raise NoMethodError. An `on_change` handler
runs when the user picks an option. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Platform differences

The iOS dropdown is a plain text field. It reads `value`, `options`, `text`,
`hint_text`, `leading_icon`, `trailing_icon`, `content_padding`, `editable` and
`autofocus`, shows each option's `content` or `text`, and also fires the
`on_click` of a picked [`option`](/docs/control-option). `label` and the Material field and menu styling apply on
Android, Windows and Linux only: `bgcolor`, `border`, `border_color`,
`border_radius`, `border_width`, `color`, `filled`, `fill_color`, `dense`,
`elevation`, `error_text`, `helper_text`, their styles, `hint_style`,
`label_style`, `text_style`, `text_size`, `text_align`, `hover_color`,
`focused_border_color`, `focused_border_width`, `menu_height`, `menu_width`,
`menu_style`, `selected_trailing_icon`, `capitalization`, `input_filter`,
`enable_filter` and `enable_search`. Use `hint_text` for a prompt that every
platform shows.

A `disabled` option cannot be picked. On iOS and macOS the 0.0.23 client still
lets the user pick it. In the next release the wheel there dims it and Done
stays off while the wheel rests on it. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
