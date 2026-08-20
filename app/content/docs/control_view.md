# View

A full-screen route surface used in page-based navigation.

## Example

```ruby
page.appbar = app_bar(
  title: text(value: "Home")
)

page.views = [
  view(
    route: "/home",
    controls: [
      container(
        padding: 16,
        content: text(value: "Welcome")
      )
    ]
  )
]
```

## Common properties

- `route`
- `controls`
- `padding`
- `bgcolor`
- `floating_action_button`

## Usage

Use `view` when the app manages multiple routes or full-screen destinations:

```ruby
view(
  route: "/settings",
  controls: [
    text(value: "Settings")
  ]
)
```

## Notes

- Attach the top app bar to the page with `page.appbar = app_bar(...)`
- `page.views` usually holds the current navigation stack
- `controls` takes an array of child controls
