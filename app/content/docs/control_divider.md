# Divider

A thin horizontal rule for separating content. Use `vertical_divider` for a
vertical rule inside a `row`.

## Example

```ruby
column(
  children: [
    text("Account"),
    divider(),
    text("Notifications")
  ]
)
```

## Common properties

- `color`
- `thickness`
- `height` — the total space the divider occupies (the line sits in the middle); 16 by default on Android, web, Windows and Linux and 1 on iOS and macOS, where the default line is 0.5 thick
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
