# AppBar

A material design app bar.

## Example

```ruby
page.appbar = app_bar(
  leading: icon(Ruflet::MaterialIcons::MENU),
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

Create the app bar with the free `app_bar(...)` helper and attach it to the
page with `page.appbar=`:

```ruby
page.appbar = app_bar(
  title: text(value: "Gallery", style: { size: 20 }),
  actions: []
)

page.add(
  container(content: text(value: "Body"))
)
```

## Notes

- Attach an app bar with `page.appbar = app_bar(...)`; do not add it to `view(...)`
- `title` is a control, usually `text(...)`
- `actions` takes an array of controls
- `leading` is commonly an `icon_button(...)` or `icon(...)`
