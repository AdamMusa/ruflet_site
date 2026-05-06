# WebView

Embed a web page or local web content inside the app.

## Example

```ruby
web_view(
  url: "https://example.com"
)
```

## Common properties

- `url`
- `expand`
- `on_page_started`
- `on_page_ended`

## Usage

```ruby
container(
  expand: true,
  content: web_view(url: "https://flet.dev")
)
```

## Notes

- `web_view` is useful for embedded docs, auth flows, or hosted content
