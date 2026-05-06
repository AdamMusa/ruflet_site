# AppBar

A material design app bar.

## Example

```ruby
app_bar(
  leading: icon(icon: Ruflet::MaterialIcons::MENU),
  title: text(value: "Dashboard"),
  bgcolor: "#1f2937",
  actions: [
    icon_button(icon: "search"),
    icon_button(icon: "more_vert")
  ]
)
```

## Common properties

- `title`
- `leading`
- `actions`
- `bgcolor`
- `color`
- `center_title`
- `leading_width`
- `elevation`
- `toolbar_height`

## Usage

`app_bar` is usually assigned inside a `view`:

```ruby
view(
  appbar: app_bar(
    title: text(value: "Gallery", style: { size: 20 }),
    actions: []
  ),
  controls: [
    container(content: text(value: "Body"))
  ]
)
```

## Notes

- `title` is a control, usually `text(...)`
- `actions` takes an array of controls
- `leading` is commonly an `icon_button(...)` or `icon(...)`
