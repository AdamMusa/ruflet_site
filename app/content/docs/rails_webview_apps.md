# WebView Apps

`Ruflet::Rails.native_app` wraps Rails pages in a managed native shell. The
page body remains an HTML WebView while Ruflet owns the native view stack,
loading state, and shell chrome declared by supported Rails view helpers.

The `webview` extension is required in the built client.

## Start the shell

```ruby
# app/views/ruflet/main.rb
Ruflet.run do |page|
  Ruflet::Rails.native_app(
    page,
    start_url: "#{Ruflet::Rails.backend_url}/dashboard",
    title: "Dashboard",
    loading: :shimmer
  )
end
```

The full signature is:

```ruby
Ruflet::Rails.native_app(
  page,
  start_url:,
  title: nil,
  actions: nil,
  navigation_bar: nil,
  bottom_appbar: nil,
  loading: :shimmer
)
```

Use `Ruflet::Rails.backend_url` so the entrypoint uses the configured
development or production host. A phone cannot reach Rails through its own
`localhost`.

## Declare native chrome in ERB

The helpers produce ordinary HTML that works in a browser and hidden
annotations that the native shell reads after the page loads.

```erb
<%= ruflet_appbar "Dashboard" do %>
  <%= ruflet_appbar_action "search", search_path, nav: :push %>
<% end %>

<%= ruflet_drawer do %>
  <%= ruflet_drawer_item "Dashboard", dashboard_path,
        icon: "dashboard", selected: current_page?(dashboard_path) %>
  <%= ruflet_drawer_item "Settings", settings_path,
        icon: "settings", nav: :push %>
<% end %>

<%= ruflet_bottom_nav do %>
  <%= ruflet_nav_item "Home", root_path, icon: "home",
        selected: current_page?(root_path) %>
  <%= ruflet_nav_item "Account", account_path, icon: "person",
        selected: current_page?(account_path) %>
<% end %>
```

For wider layouts, use `ruflet_navigation_rail` (or its `ruflet_rail` alias)
with `ruflet_rail_item`.

## Platform actions

```erb
<%= ruflet_share_link "Share", invite_path, text: "Join me" %>
<%= ruflet_copy_button "Copy code", text: @invite.code %>
<%= ruflet_launch_link "Open website", "https://example.com" %>
<%= ruflet_haptic_button "Saved" %>
```

The native shell intercepts these annotations and invokes the corresponding
client service. In a browser they remain normal links or buttons.

## Authentication and sessions

The WebView uses normal Rails cookies and sessions. The Ruflet WebSocket is a
separate connection, so authenticate and authorize both surfaces as required
by the application.

## Platform support

Test external links, downloads, file inputs, authentication redirects,
keyboard resizing, and back navigation on every target. Ensure the site permits
embedding where relevant and every URL is reachable from the device.

## Choosing a Rails API

- Use `Ruflet::Rails.endpoint` or `app` for Ruby-built Ruflet controls on native
  and desktop clients.
- Use `Ruflet::Rails.web_app` for a Ruflet control app mounted on a Rails route.
- Use `Ruflet::Rails.native_app` for Rails HTML in a native WebView shell.

See [Rails API Reference](/docs/rails-api-reference) and
[Rails View Helpers](/docs/rails-native-components) for exact signatures.
