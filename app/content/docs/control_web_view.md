# WebView

Embeds a web page inside the app. On iOS, Android and macOS it is a native
webview that can run JavaScript and navigate freely; on the web it falls back to
an `<iframe>`, so it can only show pages that allow framing (most sites that send
`X-Frame-Options`/CSP will appear blank), and the methods/events below are not
available there.

## Example

```ruby
web_view(
  url: "https://ruflet.dev",
  method: "get",
  expand: true,
  on_page_ended: ->(event) { @loading = false }
)
```

## Properties

- `url` — the page to load.
- `bgcolor` — background color shown before the page paints.
- `prevent_links` — an array of URL prefixes the webview must not follow; a tap
  on a matching link is blocked instead of navigating.
- `enable_javascript` — enable/disable JavaScript execution.
- `method` — HTTP method used for the initial `url` request (e.g. `"get"`).
- `expand` — fill the available space in a `row`/`column`.
- `width` / `height` — fixed size when not expanding.
- `tooltip`, `visible`, `opacity`, `rtl` — the usual layout properties.

## Events

- `on_page_started` — page load has begun (data: the URL).
- `on_page_ended` — page load finished (data: the URL).
- `on_web_resource_error` — a resource failed to load (data: the description).
- `on_progress` — load progress changed (data: 0–100).
- `on_url_change` — the current URL changed (data: the new URL).
- `on_scroll` — the scroll position changed (data: `{x, y}`).
- `on_console_message` — a JavaScript `console.*` message (data: `{message, severity_level}`).
- `on_javascript_alert_dialog` — the page called `alert()` (data: `{message, url}`).

## Methods

Call these on a **mounted** webview (after `page.add`). They run on
iOS/Android/macOS.

- `reload` — reload the current page.
- `go_back` / `go_forward` — move through history.
- `can_go_back { |ok, _err| }` / `can_go_forward { |ok, _err| }` — query history; result delivered to the block.
- `run_javascript(value)` — execute JavaScript in the page.
- `load_html(value, base_url:)` — load an HTML string.
- `load_request(url, method:)` — load a URL with an HTTP method.
- `load_file(path)` — load a local HTML file.
- `scroll_to(x, y)` / `scroll_by(x, y)` — scroll to / by an offset.
- `clear_cache` / `clear_local_storage` — clear browser storage.
- `enable_zoom` / `disable_zoom` — toggle pinch-zoom.
- `set_javascript_mode(mode)` — set the JavaScript execution mode.
- `get_current_url { |url, _err| }` / `get_title { ... }` / `get_user_agent { ... }` — read state into the block.

### Injecting JavaScript

`run_javascript` lets the app reach into the page — for example, hide a node so a
native control can take its place:

```ruby
webview = web_view(url: "https://myapp.com", method: "get", expand: true)
page.add(webview)

# later, in a handler:
webview.run_javascript("document.querySelector('.web-banner')?.remove()")
```

### Reading a value back

```ruby
webview.get_current_url { |url, _err| page.update(label, value: url) }
```

## Building webview apps

To wrap a Rails website in a native shell and turn annotated link taps into
native navigation, see [WebView Apps](/docs/rails-webview-apps).
`Ruflet::Rails.native_app` provides the managed navigation stack.

## Reference

- Family: `materials`
- Widget type: `webview`
- Helper: `web_view`
