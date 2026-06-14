# Webview Apps

A webview app displays pages from your Rails website inside a Ruflet native
client. This is useful when you already have working Rails pages and want to
add native navigation, native actions, or selected fully native screens without
rebuilding the whole product at once.

Ruflet provides three levels of webview integration:

1. `web_view` embeds one page and gives you direct control over navigation, events, and JavaScript.
2. `Ruflet::Rails.webview_app` places a webview inside a native Ruflet `View` with an optional app bar and bottom navigation.
3. `Ruflet::Rails.native_app` manages a stack of web pages and lets selected paths open as native screens or bottom sheets.

Start with `web_view` when you need one embedded page. Use `webview_app` when
you want to control navigation yourself. Use `native_app` when most navigation
should follow links from your Rails website automatically.

## Platform support

The full native webview runs on **iOS, Android, and macOS**. It supports
navigation events, JavaScript execution, browser history, and page state
queries.

On the web, `web_view` falls back to an `<iframe>`. Browser security rules may
prevent external sites from loading in that frame, and native webview methods
are not available.

## Embed one Rails page

Use the `web_view` helper to display a page directly:

```ruby
# app/views/ruflet/main.rb
Ruflet.run do |page|
  account = web_view(
    url: "#{Ruflet::Rails.backend_url}/account",
    method: "get",
    expand: true,
    on_page_started: ->(event) { puts "Loading #{event.data}" },
    on_page_ended: ->(event) { puts "Loaded #{event.data}" },
    on_web_resource_error: ->(event) { puts "Webview error: #{event.data}" }
  )

  page.add(account)
end
```

Use `Ruflet::Rails.backend_url` instead of hard-coding `localhost`. On a real
phone, `localhost` points to the phone itself, not your Rails development
server. Configure a reachable LAN or production URL in `ruflet.yaml`.

## Control a mounted webview

Webview methods work after the control has been added to the page:

```ruby
Ruflet.run do |page|
  browser = web_view(url: "#{Ruflet::Rails.backend_url}/dashboard", method: "get", expand: true)

  page.add(
    column(
      expand: true,
      controls: [
        row(
          controls: [
            icon_button("arrow_back", on_click: ->(_event) { browser.go_back }),
            icon_button("refresh", on_click: ->(_event) { browser.reload }),
            icon_button(
              "info",
              on_click: ->(_event) {
                browser.get_title { |title, _error| page.snack_bar = snack_bar(content: text(title)) }
              }
            )
          ]
        ),
        browser
      ]
    )
  )
end
```

Common methods include:

- `reload`, `go_back`, and `go_forward`
- `can_go_back { |value, error| ... }`
- `get_current_url { |url, error| ... }`
- `get_title { |title, error| ... }`
- `run_javascript(source)`
- `load_request(url, method:)`
- `clear_cache` and `clear_local_storage`

See the [WebView control reference](/docs/control-web-view) for the complete
property, event, and method list.

## Add a native shell with `webview_app`

`Ruflet::Rails.webview_app` creates a Ruflet `View` whose body is a webview. It
accepts native app bars and navigation controls while your Rails page remains
the main content.

```ruby
# app/views/ruflet/main.rb
Ruflet.run do |page|
  Ruflet::Rails.routed(page) do |route, nav|
    case route
    when "/"
      nav.push(
        Ruflet::Rails.webview_app(
          url: "#{Ruflet::Rails.backend_url}/dashboard",
          appbar: app_bar(title: text("Dashboard")),
          on_navigate: ->(url) {
            page.go("/settings") if url.end_with?("/settings")
          }
        ) { |webview| @dashboard_webview = webview }
      )
    when "/settings"
      nav.push(
        view(
          route: "/settings",
          appbar: app_bar(title: text("Native settings")),
          controls: [text("This screen is built with Ruflet controls.")]
        )
      )
    end
  end
end
```

Important options:

- `url:` sets the initial page.
- `appbar:`, `navigation_bar:`, and `bottom_appbar:` add native controls.
- `route:` sets the Ruflet route for the returned view.
- `on_navigate:` receives each URL reported by the webview.
- `prevent_links:` blocks matching URL prefixes from loading.
- `on_page_started:` and `on_page_ended:` receive loading events.
- A block receives the created webview so you can call methods on it later.
- Additional keyword arguments are passed to `web_view`.

`on_navigate` observes URL changes; it does not automatically stop the webview
from loading the URL. Add the same URL prefix to `prevent_links:` when a link
must open only as a Ruflet route.

```ruby
Ruflet::Rails.webview_app(
  url: "#{Ruflet::Rails.backend_url}/dashboard",
  prevent_links: ["#{Ruflet::Rails.backend_url}/settings"],
  on_navigate: ->(url) { page.go("/settings") if url.end_with?("/settings") }
)
```

## Manage website navigation with `native_app`

`Ruflet::Rails.native_app` is useful when your Rails website should provide the
main navigation structure. It opens same-origin links as screens in a native
view stack and provides an automatic back action.

You can keep most destinations as web pages, open selected paths in a bottom
sheet, and replace selected paths with Ruflet controls.

```ruby
# app/views/ruflet/main.rb
Ruflet.run do |page|
  Ruflet::Rails.native_app(
    page,
    start_url: "#{Ruflet::Rails.backend_url}/account",
    title: "Account",
    actions: -> {
      [
        icon_button(
          "refresh",
          on_click: ->(_event) { puts "Add your refresh action here" }
        )
      ]
    },
    modal: [
      "/sign_in",
      "/support/new"
    ],
    native: {
      "/settings" => ->(_context) {
        view(
          route: "/settings",
          appbar: app_bar(title: text("Settings")),
          controls: [text("Native settings screen")]
        )
      },
      %r{\A/orders/(\d+)\z} => ->(context) {
        order_id = context.match[1]
        view(
          route: "/orders/#{order_id}",
          appbar: app_bar(title: text("Order #{order_id}")),
          controls: [text("Build this order screen with Rails models and Ruflet controls.")]
        )
      }
    }
  )
end
```

When the user follows a same-origin link:

1. A matching `native:` rule renders the Ruflet view returned by its block.
2. Otherwise, a matching `modal:` rule opens the web page in a bottom sheet.
3. Otherwise, the URL opens as another webview screen in the native stack.

`native:` accepts exact paths and regular expressions. Its block receives a
context with:

- `context.url` — the complete proposed URL
- `context.path` — the URL path used for matching
- `context.match` — the `MatchData` for a regular-expression rule

The root screen can also receive `navigation_bar:` or `bottom_appbar:`. The
`actions:` value can be an array or a callable that returns app-bar actions.

## How link navigation works

After each page loads, `native_app` injects a small navigation bridge. The
bridge:

- reads the page `<title>` and updates the native app-bar title;
- captures same-origin link clicks and sends the destination to Ruflet;
- leaves external links and links with `target="_blank"` unchanged.

Because navigation is based on normal links, your Rails pages do not need a
special JavaScript framework or Ruflet-specific markup.

## Run JavaScript in a page

Capture the mounted webview and call `run_javascript` from a Ruflet event:

```ruby
shell = Ruflet::Rails.webview_app(
  url: "#{Ruflet::Rails.backend_url}/account"
) { |webview| @account_webview = webview }

hide_banner = filled_button(
  "Hide banner",
  on_click: ->(_event) {
    @account_webview.run_javascript(
      "document.querySelector('.mobile-banner')?.remove()"
    )
  }
)
```

Only run JavaScript against pages you control. Treat interpolated values as
untrusted input and encode them before inserting them into JavaScript source.

## Authentication and sessions

A native webview keeps its own cookies and browser storage. If the user signs
in inside the webview, later requests from that webview can use the resulting
session normally.

The Ruflet WebSocket connection and the embedded Rails page are separate
connections. Do not assume that authentication from one is automatically
available to the other. Pass only the minimum information needed and validate
authorization in Rails for every request.

## Choosing an API

Use `web_view` when:

- you need one embedded page;
- you want direct access to browser methods and events;
- Ruflet controls already manage the surrounding layout.

Use `webview_app` when:

- you want a native app bar or bottom navigation;
- you want to choose which URL changes become Ruflet routes;
- you need access to the underlying webview.

Use `native_app` when:

- your existing Rails links should drive the native screen stack;
- most screens can remain web pages;
- selected routes should become native views or bottom sheets.

## Troubleshooting

- **The page cannot connect on a phone:** configure `backend_url` with a URL reachable from the device. Do not use `localhost`.
- **A page is blank on Ruflet web:** the site may block iframe embedding with `X-Frame-Options` or Content Security Policy.
- **A method does nothing:** call webview methods only after the control is mounted, and remember that native methods are unavailable in the iframe fallback.
- **A native destination also loads in the webview:** add its URL prefix to `prevent_links:` when using `webview_app`.
- **A `native:` rule does not match:** rules match the URL path, such as `/orders/42`, not the complete URL.
