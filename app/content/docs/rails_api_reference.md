# Rails API Reference

`ruflet_rails` integrates Ruflet with Rails through routes, assets, sessions,
views, and build tasks. Add the gem, install the integration, then serve one
WebSocket endpoint whose entrypoint builds Ruby controls, renders ERB as native
controls, or shows Rails HTML in a native WebView shell.

```ruby
# Gemfile
gem "ruflet_rails"
```

```bash
bundle install
bin/rails generate ruflet:install
```

## Generator

```text
bin/rails generate ruflet:install [--desktop] [--client desktop|none]
```

The generator creates the Ruflet entrypoint and initializer and adds an
explicit WebSocket route. `--desktop` downloads the prebuilt desktop client and
adds a `--desktop` flag to `bin/rails` and `bin/dev`, so
`bin/rails server --desktop` launches it. `--client desktop` does the same;
`--client` defaults to `none`, and any other value is an error.

## Configuration

```ruby
Ruflet::Rails.configure do |config|
  config.backend_url = "https://app.example.com"
  config.app_name = "My App"
  config.services = [
    { camera: { description: "Allows users to capture profile photos." } }
  ]
  config.extensions = %w[webview]

  config.splash_screen = Rails.root.join("app/assets/images/splash.png")
  config.splash_dark = Rails.root.join("app/assets/images/splash-dark.png")
  config.icon_launcher = Rails.root.join("app/assets/images/icon.png")
  config.icon_android = nil
  config.icon_ios = nil
  config.icon_web = nil
  config.icon_windows = nil
  config.icon_macos = nil

  config.splash_color = "#FFFFFF"
  config.splash_dark_color = "#0B0B0B"
  config.icon_background = "#FFFFFF"
  config.theme_color = "#FFFFFF"
end
```

`Ruflet::Rails.config` returns the global configuration object.
`Ruflet::Rails.configure { |config| ... }` yields it. Build tasks serialize
these settings to Ruflet's project configuration shape, so the initializer is
the Rails app's source of truth.

## WebSocket endpoint

```text
Ruflet::Rails.native(app_file = nil) { |page| ... }
```

`native` returns a Rack endpoint for native and desktop WebSocket clients.
Pass an app file or a block, not both. The entrypoint it runs can build Ruby
controls itself or hand the page to `erb_to_native` or `native_shell`.

```ruby
Rails.application.routes.draw do
  match "/ws",
    to: Ruflet::Rails.native(Rails.root.join("app/views/ruflet/main.rb")),
    via: :all
end
```

### Errors in event handlers

When an event handler raises (for example an `on_click` block or
`page.on_route_change`), the endpoint logs the error to `Rails.logger` at the
error level as `RUFLET CRASH: <class>: <message>`, followed by the first ten
backtrace lines.

The connection and the session stay up: the client shows no error, and the
next event reaches its handler on the page as the failed handler left it, as
under `ruflet run`. With 0.0.23 the client briefly shows the error message and
reconnects, and the endpoint runs the entrypoint again on a new page, so the
page loses everything the user did on it. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

An error raised by the entrypoint itself still ends the session.

### Rails executor

The endpoint runs each WebSocket message, and the disconnect, in its own
`Rails.application.executor` run, the way Rails runs a request. With 0.0.23 one
run lasts the whole connection. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

- The Active Record query cache lasts one message, so a handler reads rows that another process wrote after the previous message. With 0.0.23 a handler can get the cached result of an earlier message. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- A database connection that the entrypoint or a handler uses goes back to the pool when the message is done. With 0.0.23 a connected client keeps it until it disconnects, so the pool can run out and requests fail with `ActiveRecord::ConnectionTimeoutError`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- In development, the first request after you edit app code reloads it while clients stay connected, and their next events run the new code. With 0.0.23 that request waits until every connected client disconnects. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

What your entrypoint or a handler sets in `ActiveSupport::CurrentAttributes`
(such as `Current.user`), with `Rails.error.set_context` or in the Rails 8.1
event reporter context stays set for the whole connection, and is reset once,
when the client disconnects.

## ERB to native controls

```ruby
Ruflet::Rails.erb_to_native(
  page,
  start_url: "/",
  title: nil,
  fetcher: nil
)
```

`erb_to_native` returns a started `Ruflet::Rails::HtmlDsl::HtmlApp`.
`start_url:` is the path of the first screen. It defaults to `"/"`, which names
no controller, so pass a screen path; a full URL is accepted and only its path
is used. Screen paths name controller actions by convention: `/native` runs
`NativeController#home` (or `#index`, then `#show`, when there is no `home`),
and `/native/counter` runs `NativeController#counter`.
The action runs inside the WebSocket session, with no Rails route, request, or
CSRF token involved. `title:` supplies a fallback screen title, and `fetcher:`
replaces the screen source in isolated tests.

```ruby
Ruflet.run do |page|
  Ruflet::Rails.erb_to_native(
    page,
    start_url: "#{Ruflet::Rails.backend_url}/mobile",
    title: "My app"
  )
end
```

The rendered ERB is parsed into native controls. Links manage the native view
stack, actions call controller methods and re-render the screen, forms pass
named field values as `params`, and declared services mount on the Ruflet
page. See [ERB to Native](/docs/rails-erb-to-native),
[Widgets](/docs/rails-native-components), and
[Services](/docs/rails-native-services).

## Native WebView shell

```ruby
Ruflet::Rails.native_shell(
  page,
  start_url:,
  title: nil,
  actions: nil,
  navigation_bar: nil,
  bottom_appbar: nil,
  loading: :shimmer
)
```

`native_shell` starts a managed native shell whose body is a WebView. It returns
the started `Ruflet::Rails::NativeApp`. `start_url:` is required. The shell
tracks navigation, reads Ruflet annotations from loaded Rails HTML, and can
promote annotated app bars, drawers, navigation, overlays, and actions to
native controls.

```ruby
Ruflet.run do |page|
  Ruflet::Rails.native_shell(
    page,
    start_url: "#{Ruflet::Rails.backend_url}/dashboard",
    title: "Dashboard"
  )
end
```

`native_shell` itself does not convert the page body. Rails pages inside it remain
web content; only annotated shell elements are promoted to native controls.
Use `erb_to_native` for a native control tree.

## Assets and backend URLs

```ruby
Ruflet::Rails.backend_url(host: nil)
Ruflet::Rails.asset_url(source, host: nil)
Ruflet::Rails.image_url(source, host: nil)
```

`backend_url` resolves an explicit host, then configured `backend_url`, then
the current Ruflet request host. `asset_url` resolves Rails asset-pipeline
paths and makes them absolute for a remote client. `image_url` is an alias for
readability.

## Sessions and broadcast

```text
Ruflet::Rails.sessions
Ruflet::Rails.broadcast { |page| ... }
```

`sessions` returns the process-wide session registry. It supports `[]`,
`each`, `size`, `empty?`, `clear`, `pages`, `snapshot`, and `broadcast`.
`Ruflet::Rails.broadcast` is the module-level shortcut and yields each
connected page. Session registration methods are managed by the endpoint.

## Native WebView shell helpers

The helpers are included in Action View.

```text
ruflet_appbar(title = nil, payload: {}, leading: nil, actions: nil, **attributes) { ... }
ruflet_appbar_action(icon, href = nil, nav: :push, payload: {}, **attributes)

ruflet_bottom_nav(name: "bottom-navigation", payload: {}, **attributes) { ... }
ruflet_nav_item(label, href, icon:, selected: false, color: nil, size: 24,
                payload: {}, **attributes)

ruflet_drawer(action: :root, payload: {}, **attributes) { ... }
ruflet_drawer_item(label, href, icon:, selected: false, nav: nil,
                   payload: {}, **attributes)

ruflet_navigation_rail(action: :root, extended: nil, label_type: nil,
                       breakpoint: nil, payload: {}, **attributes) { ... }
ruflet_rail(...) # alias for ruflet_navigation_rail
ruflet_rail_item(label, href, icon:, selected: false, nav: nil,
                 payload: {}, **attributes)

ruflet_share_link(label, href = "#", text: nil, title: nil, subject: nil,
                  url: nil, files: nil, **attributes)
ruflet_copy_button(label, text:, toast: "Copied", haptic: true, **attributes)
ruflet_launch_link(label, href, mode: nil, **attributes)
ruflet_haptic_button(label, style: "selection", **attributes)
```

These helpers emit ordinary HTML plus `data-ruflet-*` annotations. Browsers keep
normal HTML behavior; `native_shell` reads the annotations and builds native
shell controls or platform actions. These are separate from the component
helpers used by `erb_to_native`. Extra keyword attributes use dashed HTML
names.

## Rails tasks

```text
rake ruflet:update[desktop|all]
rake ruflet:install[DEVICE_ID]
rake ruflet:build[apk|android|ios|aab|desktop|macos|windows|linux]
```

- `ruflet:update` refreshes the requested prebuilt client.
- `ruflet:install` installs the last compatible mobile build, optionally on a
  named device.
- `ruflet:build` serializes the Rails initializer and invokes the Ruflet CLI
  for the selected native or desktop target. `desktop` selects the host's
  desktop platform.

See [Rails Integration](/docs/rails-integration) for setup examples,
[ERB to Native](/docs/rails-erb-to-native) for native Rails views,
[Native Shell](/docs/rails-native-shell) for the shell workflow, and
[Rails Assets and URLs](/docs/rails-assets) for deployment details.
