# Webview Apps

Ruflet can wrap your existing website in a native shell — native AppBar and
bottom navigation around a `WebView` body — and turn web navigation into native
navigation, the way Hotwire Native or NativePHP work.

There are three layers, from lowest to highest:

1. The [`WebView` control](#the-webview-control) — render web content, inject JS.
2. [`webview_app`](#webview_app--a-native-shell) — a native shell around a
   webview body, with explicit navigation.
3. [`native_app`](#native_app--hotwire-native-style) — a declarative,
   Hotwire-style driver where navigation works out of the box.

> Platform note: the native webview (and its methods/events, including
> `run_javascript`) runs on **iOS, Android, and macOS**. On web it falls back to
> an `<iframe>`, which can't run the methods and which most external sites block
> via `X-Frame-Options`/CSP — embed your own same-origin pages there. To put
> native UI *inside* a web page instead, see
> [`ruflet_frame`](/docs/rails-assets#ruflet_frame--embed-native-ui-in-an-erb-page).

## The WebView control

```ruby
webview(url: "https://flet.dev", expand: true,
        on_page_ended: ->(e) { ... },
        on_url_change: ->(e) { ... })
```

### Properties

- `url`
- `bgcolor`
- `prevent_links` — URL prefixes the webview must not follow (blocked silently)

### Events

`on_page_started`, `on_page_ended`, `on_web_resource_error`, `on_progress`,
`on_url_change`, `on_scroll`, `on_console_message`, `on_javascript_alert_dialog`.

### Methods

Methods are invoked on a **mounted** webview (after `page.add`):

- `run_javascript(value)` — execute JS in the page
- `reload` — reload the current URL
- `go_back` / `go_forward` — history navigation
- `can_go_back { |ok, _| }` / `can_go_forward { ... }` — query history
- `load_html(value, base_url:)` — load an HTML string
- `load_request(url, method:)` — load a URL
- `load_file(path)` — load a local file
- `scroll_to(x, y)` / `scroll_by(x, y)` — scroll
- `clear_cache` / `clear_local_storage` — clear storage
- `enable_zoom` / `disable_zoom` — zoom controls
- `set_javascript_mode(mode)` — JS execution mode
- `get_current_url { |url, _| }` / `get_title { ... }` / `get_user_agent { ... }` — read state into a block

### Injecting JavaScript

`run_javascript` lets a Ruflet app reach into the page — for example, hide a
node so a native control can replace it:

```ruby
webview.run_javascript("document.querySelector('.web-banner').remove()")
```

## `webview_app` — a native shell

Build the classic webview-app layout: native AppBar on top, native
NavigationBar (or bottom AppBar) below, a webview body in between. Following a
link can open a native view instead of navigating inside the frame.

```ruby
Ruflet::Rails.routed(page) do |route, nav|
  if route == "/"
    nav.push(
      Ruflet::Rails.webview_app(
        url: "https://myapp.com",
        appbar: app_bar(title: text("My App")),
        navigation_bar: navigation_bar(destinations: [...]),
        on_navigate: ->(url) { page.go("/details") if url.include?("/product/") }
      )
    )
  elsif route == "/details"
    nav.push(detail_view)   # native screen; back returns to the shell
  end
end
```

- `on_navigate` fires from the webview's URL change with the target URL — map it
  to a native route with `page.go`.
- `prevent_links:` stops the webview from ever loading matching URLs.
- Pass a block to capture the `WebView` control (e.g. to `run_javascript` later):
  `Ruflet::Rails.webview_app(url: "...") { |wv| @web = wv }`.

## `native_app` — Hotwire Native-style

`native_app` removes the per-route branching. Navigation works out of the box:
a small JS bridge injected into each page intercepts same-origin link clicks and
proposes them to native, so every visit becomes a native screen push with an
automatic back button. The AppBar title tracks each page's `<title>`, and
special paths are declared as data.

```ruby
Ruflet.run do |page|
  Ruflet::Rails.native_app(
    page,
    start_url: "https://myapp.com",
    title: "My App",                                  # auto-updates from <title>
    actions: -> { [icon_button("search", on_click: ->(_e) { ... })] },
    navigation_bar: navigation_bar(destinations: [...]),

    # web content shown in a bottom sheet (auth, quick forms):
    modal: ["/sign_in", "/sign_up", %r{/new\z}],

    # optional: override a path with a fully native screen:
    native: { %r{\A/products/(\d+)\z} => ->(ctx) { product_screen(ctx.match[1]) } }
  )
end
```

How a navigation is handled:

- a path listed in `native:` → render your native screen (`ctx.match` carries the regexp captures)
- a path listed in `modal:` → open the web content in a bottom sheet (auth, forms)
- anything else → push a native webview screen (back returns)

`native:` takes precedence over `modal:`. Normal links need no configuration.

### How the bridge works

The driver injects a small script into every page that:

- reports `document.title` over the webview console channel, so native can
  update the AppBar title per page;
- intercepts same-origin link clicks, calls `preventDefault()`, and proposes the
  URL to native (so the link does not load in place).

Native receives these via `on_console_message`, which works on iOS, Android, and
macOS. External links and `target="_blank"` are left to the webview.
