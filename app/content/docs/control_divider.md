# Divider

A thin horizontal rule for separating content. Use `vertical_divider` for a
vertical rule inside a `row`.

## Example

```ruby
column(
  controls: [
    text("Account"),
    divider(),
    text("Notifications")
  ]
)
```

## Common properties

- `color`
- `thickness`
- `height` — the total space the divider occupies (the line sits in the middle)
- `leading_indent` / `trailing_indent`
- `radius`

## Usage

A divider takes its own vertical space via `height` while the visible line uses
`thickness`:

```ruby
divider(thickness: 1, height: 24, color: "#e5e7eb")
```

For columns laid out in a `row`, use `vertical_divider` with the same
properties.
