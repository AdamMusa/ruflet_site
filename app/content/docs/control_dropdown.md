# Dropdown

A material dropdown menu for choosing one value from a list of options. Options
are built with `dropdown_option`.

## Example

```ruby
dropdown(
  label: "Fruit",
  value: "apple",
  options: [
    dropdown_option(key: "apple", text: "Apple"),
    dropdown_option(key: "banana", text: "Banana"),
    dropdown_option(key: "cherry", text: "Cherry")
  ],
  on_select: ->(event) { page.update(status, value: "Picked #{event.control.props["value"]}") }
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
`on_text_change`, `on_focus`, and `on_blur`; the current Dropdown API does not
define an `on_change` event.

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
client writes it to the control before the event fires. `event.data` carries
the same key. To use the choice later, keep it in Ruby state or read
`field.props["value"]`:

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
