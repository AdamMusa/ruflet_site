# WebView

Embeds a web page inside the app. It needs the `webview` extension in
`ruflet.yaml`:

```yaml
extensions:
  - webview
```

What you get depends on the platform:

- **iOS, Android and macOS** draw a native web view that runs JavaScript,
  follows links, reports its navigation in events and runs the methods below.
- **The web** shows the `url` in an `<iframe>`. Pages that refuse to be
  framed (most sites that send `X-Frame-Options` or a strict CSP) stay blank,
  no event is sent, and the methods answer with an error.
- **Windows and Linux** draw an error box: the web view is not supported there
  yet.

## Example

```ruby
status = text(value: "Loading…")
browser = web_view(
  url: "https://ruflet.dev",
  expand: true,
  on_page_started: ->(event) { page.update(status, value: "Opening #{event.data}") },
  on_page_ended: ->(event) { page.update(status, value: "Showing #{event.data}") },
  on_web_resource_error: ->(event) { page.update(status, value: "Failed: #{event.data}") }
)
page.add(column(expand: true, children: [status, browser]))
```

Add navigation buttons that call the methods below on the mounted view:

```ruby
page.add(
  row(children: [
    button("Back", on_click: ->(_event) { browser.go_back }),
    button("Reload", on_click: ->(_event) { browser.reload }),
    button("Docs home", on_click: ->(_event) { browser.load_request("https://ruflet.dev/docs") })
  ])
)
```

## Properties

- `url` — the page to load when the view appears (default `https://flet.dev`).
  To open another page later, call `load_request`. With the next release,
  changing `url` with `page.update` also navigates on iOS, Android and macOS;
  with 0.0.23 only the first `url` is loaded. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `method` — HTTP method of the request for `url`: `"get"` (the default) or
  `"post"`.
- `prevent_links` — a list of URL prefixes the view must not open. A link or
  redirect whose address starts with one of them is blocked instead of
  navigating. iOS, Android and macOS only.
- `bgcolor` — the color shown behind the page before it paints. iOS, Android
  and macOS only.
- `expand`, `width` / `height` — size the view: in a `column`, give it
  `expand: true` or a fixed height.
- `tooltip`, `visible`, `opacity`, `rtl` — the usual layout properties.

There is no property that turns JavaScript on or off: call
`set_javascript_mode` after the view is on the page. Until you do, the platform
decides: JavaScript is off in Android's web view and on in iOS and macOS.

## Events

Events are sent on iOS, Android and macOS only.

- `on_page_started` — a page started loading. `event.data` (also
  `event.value`) is its URL.
- `on_page_ended` — a page finished loading. `event.data` is its URL.
- `on_url_change` — the address of the view changed, including navigation
  inside a single-page app. `event.data` is the new URL.
- `on_progress` — loading progress; `event.data` is a number from 0 to 100.
- `on_web_resource_error` — the page or one of its resources failed to load;
  `event.data` is the error description.
- `on_scroll` — the page scrolled; `event.data` is `{ "x" => x, "y" => y }` in
  pixels. iOS and Android only: macOS does not report scrolling.
- `on_console_message` — the page wrote to the JavaScript console;
  `event.data` has `message` and `severity_level` (`"debug"`, `"error"`,
  `"info"`, `"log"` or `"warning"`).
- `on_javascript_alert_dialog` — the page called `alert()`; the view sends
  this event instead of showing the alert. `event.data` has `message` and
  `url`.

## Methods

Call these on a **mounted** view, after `page.add`: before that they raise
`WebView #… is not mounted yet`. They run on iOS, Android and macOS.

- `reload` — reload the current page.
- `go_back` / `go_forward` — move through the history; they do nothing when
  there is no page to go to.
- `can_go_back { |ok, error| }` / `can_go_forward { |ok, error| }` — whether
  there is a page to go back or forward to.
- `load_request(url, method: "get")` — load a URL, with `"get"` or `"post"`.
- `load_html(value, base_url: nil)` — show an HTML string; `base_url` is the
  address relative links resolve against.
- `load_file(path)` — load an HTML file from an absolute path on the device.
- `run_javascript(value)` — run JavaScript in the page. It returns no result.
- `set_javascript_mode(mode)` — `"unrestricted"` turns JavaScript on,
  `"disabled"` turns it off.
- `scroll_to(x, y)` / `scroll_by(x, y)` — scroll to, or by, a position in
  pixels.
- `clear_cache` / `clear_local_storage` — clear the view's cache or the
  page's local storage.
- `enable_zoom` / `disable_zoom` — allow or stop pinch-to-zoom.
- `get_current_url { |url, error| }`, `get_title { |title, error| }` and
  `get_user_agent { |agent, error| }` — read the current state; the block
  receives the value and an error.

The getters and `can_go_back` / `can_go_forward` take a block, not
`on_result:`, and accept `timeout:` (default 10 seconds).

### Injecting JavaScript

`run_javascript` lets the app reach into the page, for example to hide a node so
a native control can take its place:

```ruby
webview = web_view(url: "https://myapp.com", method: "get", expand: true)
page.add(webview)

# later, in a handler:
webview.set_javascript_mode("unrestricted")
webview.run_javascript("document.querySelector('.web-banner')?.remove()")
```

### Reading a value back

```ruby
label = text(value: "")
webview.get_current_url { |url, _err| page.update(label, value: url.to_s) }
```

## Building native shells

To wrap a Rails website in a native shell and turn annotated link taps into
native navigation, see [Native Shell](/docs/rails-native-shell).
`Ruflet::Rails.native_shell` provides the managed navigation stack.

## Reference

- Family: `materials`
- Widget type: `WebView`
- Helpers: `web_view`, `webview`
