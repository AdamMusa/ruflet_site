# Rails API Reference

`ruflet_rails` integrates Ruflet with Rails through routes, assets, sessions,
views, and build tasks. Add the gem, install the integration, then choose a
WebSocket endpoint, mounted web app, native ERB renderer, or native WebView
shell.

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
bin/rails generate ruflet:install [--web] [--desktop]
                                  [--client web|desktop|all|none]
```

The generator creates the Ruflet entrypoint and initializer and adds an
explicit WebSocket route. `--web` also mounts and downloads the web client;
`--desktop` downloads the desktop client. `--client` is the combined form and
defaults to `none`.

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

## Endpoints and mounted apps

```text
Ruflet::Rails.endpoint(app_file: nil) { |page| ... }
Ruflet::Rails.app(file_path)
Ruflet::Rails.web_app(app_file: nil, build_dir: nil) { |page| ... }
Ruflet::Rails.web_app_entrypoint(app_file: nil)
```

- `endpoint` returns a Rack endpoint for native and desktop WebSocket clients.
  Supply exactly one source: `app_file:` or a block.
- `app(file_path)` is shorthand for `endpoint(app_file: file_path)`.
- `web_app` returns a mountable Rack application that serves the Flutter web
  build and WebSocket on the same mount. Supply exactly one app source;
  `build_dir:` selects a non-default web build.
- `web_app_entrypoint` returns the loader callable used for an app file. Most
  applications call `web_app` instead.

```ruby
Rails.application.routes.draw do
  match "/ws",
    to: Ruflet::Rails.app(Rails.root.join("app/views/ruflet/main.rb")),
    via: :all

  mount Ruflet::Rails.web_app(
    app_file: Rails.root.join("app/views/ruflet/main.rb")
  ), at: "/ruflet"
end
```

## ERB to native controls

```ruby
Ruflet::Rails.erb_to_native(
  page,
  start_url:,
  title: nil,
  fetcher: nil
)
```

`erb_to_native` returns a started `Ruflet::Rails::HtmlDsl::HtmlApp`.
`start_url:` is required and points to a normal Rails route. The default
fetcher dispatches that route in-process through Rails. `title:` supplies a
fallback screen title, and `fetcher:` is available for isolated tests.

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
stack, actions invoke Rails routes, forms submit named field values, and
declared services mount on the Ruflet page. See
[ERB to Native](/docs/rails-erb-to-native),
[Components](/docs/rails-native-components), and
[Services](/docs/rails-native-services).

## Native WebView shell

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

`native_app` starts a managed native shell whose body is a WebView. It returns
the started `Ruflet::Rails::NativeApp`. `start_url:` is required. The shell
tracks navigation, reads Ruflet annotations from loaded Rails HTML, and can
promote annotated app bars, drawers, navigation, overlays, and actions to
native controls.

```ruby
Ruflet.run do |page|
  Ruflet::Rails.native_app(
    page,
    start_url: "#{Ruflet::Rails.backend_url}/dashboard",
    title: "Dashboard"
  )
end
```

`native_app` itself does not convert the page body. Rails pages inside it remain
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
ruflet_frame(path, height: 600, width: "100%", title: "Ruflet", style: nil, **attributes)

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

`ruflet_frame` embeds a mounted Ruflet web app in an iframe. The remaining
helpers emit ordinary HTML plus `data-ruflet-*` annotations. Browsers keep
normal HTML behavior; `native_app` reads the annotations and builds native
shell controls or platform actions. These are separate from the component
helpers used by `erb_to_native`. Extra keyword attributes use dashed HTML
names.

## Rails tasks

```text
rake ruflet:web
rake ruflet:update[desktop|all]
rake ruflet:install[DEVICE_ID]
rake ruflet:build[apk|android|ios|aab|desktop|macos|windows|linux]
```

- `ruflet:web` installs the prebuilt web client in `frontend/`.
- `ruflet:update` refreshes the requested prebuilt client.
- `ruflet:install` installs the last compatible mobile build, optionally on a
  named device.
- `ruflet:build` serializes the Rails initializer and invokes the Ruflet CLI
  for the selected native or desktop target. The web client is installed with
  `ruflet:web`, not built by this task.

See [Rails Integration](/docs/rails-integration) for setup examples,
[ERB to Native](/docs/rails-erb-to-native) for native Rails views,
[WebView Apps](/docs/rails-webview-apps) for the shell workflow, and
[Rails Assets and URLs](/docs/rails-assets) for deployment details.
