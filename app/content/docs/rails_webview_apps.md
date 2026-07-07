# Webview Apps

A webview app displays pages from your Rails website inside a Ruflet native
client. This is useful when you already have working Rails pages and want to
add native navigation, native actions, or selected fully native screens without
rebuilding the whole product at once.

Ruflet provides three levels of webview integration:

1. `web_view` embeds one page and gives you direct control over navigation, events, and JavaScript.
2. `Ruflet::Rails.webview_app` places a webview inside a native Ruflet `View` with an optional app bar and bottom navigation.
3. `Ruflet::Rails.native_app` builds a Ruflet native shell around your Rails pages, with app bars, drawers, navigation, sheets, dialogs, and services declared from ERB.

Start with `web_view` when you need one embedded page. Use `webview_app` when
you want to control navigation yourself. Use `native_app` when your Rails views
should remain the body of the app while Ruflet owns the native shell around
them.

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

## Wrap Rails pages with `native_app`

`Ruflet::Rails.native_app` is a normal Ruflet app whose body is a WebView. The
native app bar, drawer, bottom navigation, navigation rail, menus, dialogs,
sheets, loading state, and platform services are Ruflet controls. Rails only
declares what the shell should look like using ERB helpers or
`data-ruflet-*` attributes.

In a regular browser those helpers still render ordinary HTML, links, and
buttons. In a Ruflet client, the native shell reads the declarations and
updates the Ruflet page.

```ruby
# app/views/ruflet/main.rb
Ruflet.run do |page|
  Ruflet::Rails.native_app(
    page,
    start_url: "#{Ruflet::Rails.backend_url}/dashboard",
    loading: {
      type: "shimmer",
      container_props: { bgcolor: "#f8fafc" }
    }
  )
end
```

The default loading view is a body-only shimmer. Native chrome stays visible
while a new page loads, so the app bar, drawer, and bottom navigation do not
flash or get replaced by a web loading screen.

## Declare native chrome from ERB

Use the Rails helpers in your normal views to promote web markup into native
chrome. Helper names and data attributes use the `ruflet` namespace, and custom
data keys use `data-ruflet-*`.

```erb
<%= ruflet_appbar "Dashboard",
      leading: { icon: "menu", action: "drawer" },
      actions: [
        {
          icon: "language",
          action: "menu",
          title: "Language",
          items: [
            { label: "FR", icon: "check", url: url_for(locale: :fr), action: "root", selected: I18n.locale == :fr },
            { label: "EN", icon: "translate", url: url_for(locale: :en), action: "root" },
            { label: "AR", icon: "translate", url: url_for(locale: :ar), action: "root" }
          ]
        }
      ],
      payload: { center_title: true, bgcolor: "#ffffff" } %>

<%= ruflet_drawer(payload: { title: current_account.name, subtitle: current_account.email }) do %>
  <%= ruflet_drawer_item "Dashboard", dashboard_path, icon: "dashboard", selected: current_page?(dashboard_path) %>
  <%= ruflet_drawer_item "Campaigns", campaigns_path, icon: "sms", selected: current_page?(campaigns_path) %>
  <%= ruflet_drawer_item "Settings", settings_path, icon: "settings", selected: current_page?(settings_path) %>
  <%= ruflet_drawer_item "Sign out", session_path, icon: "logout", method: :delete %>
<% end %>

<%= ruflet_bottom_nav(payload: { label_behavior: "alwaysHide" }) do %>
  <%= ruflet_nav_item "Features", features_path, icon: "inventory_2", selected: current_page?(features_path) %>
  <%= ruflet_nav_item "How it works", how_it_works_path, icon: "schedule", selected: current_page?(how_it_works_path) %>
  <%= ruflet_nav_item "Sign up", new_registration_path, icon: "person_add", selected: current_page?(new_registration_path) %>
  <%= ruflet_nav_item "Company", company_path, icon: "business", selected: current_page?(company_path) %>
<% end %>
```

For desktop-style shells, use a navigation rail from the same Rails view:

```erb
<%= ruflet_navigation_rail extended: true, breakpoint: 720 do %>
  <%= ruflet_rail_item "Inbox", inbox_path, icon: "mail", selected: current_page?(inbox_path) %>
  <%= ruflet_rail_item "Profile", profile_path, icon: "person", selected: current_page?(profile_path) %>
  <%= ruflet_rail_item "Settings", settings_path, icon: "settings", selected: current_page?(settings_path) %>
<% end %>
```

The selected state should come from the current Rails route. Ruflet mirrors that
state in the drawer, bottom navigation, and navigation rail so all native
navigation stays in sync.

## Open native screens and sheets

Use normal Rails links for normal Rails navigation. Add a Ruflet payload only
when the link should become a native action.

```erb
<%= link_to "Open inbox", inbox_path,
      data: {
        ruflet_screen: {
          action: "push",
          title: "Inbox",
          leading: { icon: "menu", action: "drawer" }
        }.to_json
      } %>

<%= link_to "Compose", new_message_path,
      data: {
        ruflet_screen: {
          action: "sheet",
          title: "Compose"
        }.to_json
      } %>

<%= link_to "Replace with settings", settings_path,
      data: {
        ruflet_screen: {
          action: "replace",
          title: "Settings",
          leading: { icon: "menu", action: "drawer" }
        }.to_json
      } %>
```

Supported navigation actions include `push`, `replace`, `root`, `sheet`, and
`back`. A pushed or replaced screen still uses the Rails URL as the WebView
body; only the surrounding shell is native.

## Menus, bottom sheets, and close callbacks

Native menus are useful for language pickers, account menus, and compact action
sets. Menu items close their sheet by default before they run navigation or a
callback.

```erb
<%= ruflet_appbar "T4U",
      leading: { icon: "menu", action: "drawer" },
      actions: [
        {
          icon: "language",
          action: "menu",
          title: "Language",
          items: [
            { label: "FR", icon: "check", url: url_for(locale: :fr), action: "root", selected: I18n.locale == :fr },
            { label: "EN", icon: "translate", url: url_for(locale: :en), action: "root" },
            { label: "AR", icon: "translate", url: url_for(locale: :ar), action: "root" }
          ]
        }
      ] %>
```

Set `close: false` on an item when the menu should remain open:

```ruby
{ label: "Preview", icon: "visibility", action: "toast", message: "Still open", close: false }
```

WebView bottom sheets use the same close lifecycle. Plain links inside a
Ruflet-owned sheet close the sheet first, then continue the requested
navigation. If a link should stay inside the sheet, opt out explicitly:

```erb
<%= link_to "English", url_for(locale: :en) %>

<%= link_to "Preview without closing", preview_language_path,
      data: { ruflet_close: "false" } %>
```

This keeps native sheet state predictable: one tap produces one close action,
Ruflet waits for the native dismiss event, and then the callback or navigation
runs.

## Native dialogs, toasts, and services

Rails views can request native feedback and platform services without adding
custom JavaScript.

```erb
<%= button_tag "Show dialog",
      data: {
        ruflet_action: {
          component: "dialog",
          title: "Delete draft?",
          message: "This cannot be undone.",
          actions: [
            { label: "Cancel", role: "cancel" },
            { label: "Delete", role: "destructive", url: draft_path(@draft), method: "delete" }
          ]
        }.to_json
      } %>

<%= ruflet_share_link "Share invite",
      text: "Join my workspace",
      url: invite_url(@invite) %>

<%= ruflet_copy_button "Copy code", value: @invite.code %>
<%= ruflet_launch_link "Open website", "https://example.com" %>
<%= ruflet_haptic_button "Saved", style: "success" %>
```

Dialogs, menus, sheets, share sheets, clipboard actions, URL launching, and
haptics use the native platform presentation on iOS, Android, and desktop where
available.

## How the HTML adapter works

After each WebView page loads, `native_app` scans the HTML for Ruflet
declarations and updates the native shell. The adapter:

- reads `data-ruflet-*` payloads for app bars, drawers, bottom navigation, navigation rails, tabs, dialogs, sheets, menus, and services;
- hides promoted chrome in the WebView so users do not see both the HTML navbar and the native navbar;
- keeps unannotated Rails links as normal Rails links;
- turns annotated links and buttons into native Ruflet actions;
- closes drawers and bottom sheets before running item callbacks or navigation;
- keeps the loading state inside the body WebView, not over the native app bar or bottom navigation.

The important rule is that Rails remains Rails. You augment specific HTML with
Ruflet data, and Ruflet turns that data into native controls.

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

- your Rails ERB should declare native app bars, drawers, bottom navigation, rails, menus, tabs, dialogs, sheets, and services;
- most screens can remain web pages;
- only the screen body should be rendered by WebView;
- the same Rails pages should still work in a browser.

## Troubleshooting

- **The page cannot connect on a phone:** configure `backend_url` with a URL reachable from the device. Do not use `localhost`.
- **A page is blank on Ruflet web:** the site may block iframe embedding with `X-Frame-Options` or Content Security Policy.
- **A method does nothing:** call webview methods only after the control is mounted, and remember that native methods are unavailable in the iframe fallback.
- **A native destination also loads in the webview:** add its URL prefix to `prevent_links:` when using `webview_app`.
- **The HTML navbar still appears:** make sure the navbar is declared with the Ruflet helpers or `data-ruflet-*` attributes so `native_app` can promote and hide it.
- **A drawer or sheet stays open after an item tap:** native menu and drawer items close by default. For links inside a WebView sheet, use a normal link for close-and-navigate or add `data-ruflet-close="false"` when the sheet should remain open.
- **The app bar flashes while loading:** keep app bar and bottom navigation declarations in the native shell payload. The loading state should cover only the body WebView.
