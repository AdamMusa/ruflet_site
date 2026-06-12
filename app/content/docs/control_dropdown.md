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
  on_change: ->(event) { page.update(status, value: "Picked #{event.control.value}") }
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

Read the choice from `control.value`:

```ruby
field = dropdown(
  label: "Size",
  options: [dropdown_option(key: "s", text: "Small"), dropdown_option(key: "l", text: "Large")]
)
# later:
field.value # => "s"
```
