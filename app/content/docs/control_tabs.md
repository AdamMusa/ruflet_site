# Tabs

Switch between related sections inside one screen. A `tabs` control coordinates
a `tab_bar` and `tab_bar_view`.

## Example

```ruby
tabs(
  length: 2,
  selected_index: 0,
  content: column(
    children: [
      tab_bar([
        tab(label: "Home", icon: "home"),
        tab(label: "Settings", icon: "settings")
      ]),
      container(
        height: 240,
        content: tab_bar_view([
          text("Home content"),
          text("Settings content")
        ])
      )
    ]
  ),
  on_change: ->(event) {
    page.update(status, value: "Selected tab: #{event.value}")
  }
)
```

## Properties

- `length` — number of coordinated tabs and views.
- `selected_index` — initially selected tab index.
- `content` — layout containing the tab bar and tab views.
- `animation_duration` — tab transition duration.
- `expand`, `width`, and `height` — layout sizing.

## Events

- `on_change` — fired after selection changes; read the selected index from `event.value`.

The number of `tab` controls in `tab_bar` should match the number of children
in `tab_bar_view` and the `length` value.
