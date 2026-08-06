# Mounted Rails Web Apps

Ruflet supports two web-based Rails integrations: mount a Ruflet web frontend
inside Rails, or display ordinary Rails pages inside a managed native WebView
shell. These modes keep HTML as HTML. Use
[`erb_to_native`](/docs/rails-erb-to-native) when Rails ERB should become a
native control tree.

## Mount a Ruflet web app

Install the prebuilt frontend and mount an app file:

```bash
rake ruflet:web
```

```ruby
# config/routes.rb
mount Ruflet::Rails.web(
  app_file: Rails.root.join("app/views/ruflet/main.rb")
), at: "/ruflet"
```

The mount serves the web assets and WebSocket on the same route. It accepts
exactly one app source: `app_file:` or a block. Use `build_dir:` only when the
web build is stored outside the default location.

Embed the mounted app inside another Rails page when useful:

```erb
<%= ruflet_frame "/ruflet", height: 640, title: "Account app" %>
```

## Display Rails HTML in a native shell

```ruby
# app/views/ruflet/main.rb
Ruflet.run do |page|
  Ruflet::Rails.native_shell(
    page,
    start_url: "#{Ruflet::Rails.backend_url}/dashboard",
    title: "Dashboard"
  )
end
```

The requested URL renders through normal Rails controllers, views, sessions,
CSS, and JavaScript. The native shell hosts that page in a WebView and can read
supported `data-ruflet-*` annotations for native chrome and platform actions.

## Choose between them

- Use `web` when the UI is built with Ruflet controls and should run in a
  browser under a Rails route.
- Use `native_shell` when an existing Rails website should remain HTML while
  gaining native app chrome and selected platform actions.
- Use `erb_to_native` when Rails routes and ERB should render native controls
  without a WebView.
- Use `native` for Ruby-driven Ruflet controls rendered by native or
  desktop clients.

See [Rails API Reference](/docs/rails-api-reference) for exact signatures and
[WebView Apps](/docs/rails-webview-apps) for the managed shell.
