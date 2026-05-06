# View

A full-screen route surface used in page-based navigation.

## Example

```ruby
page.views = [
  view(
    route: "/home",
    appbar: app_bar(
      title: text(value: "Home")
    ),
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
- `appbar`
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

- `page.views` usually holds the current navigation stack
- `controls` takes an array of child controls
