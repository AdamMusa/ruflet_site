# Rails Integration

`ruflet_rails` runs Ruflet UI inside an existing Rails app. The Rails server
*is* the Ruflet server: it drives native screens over a WebSocket, serves the
web build, and builds the native clients — all from one codebase.

Use it when your product already lives in Rails and you want native screens
backed by your existing models, routes, and business logic.

## Add the gem

```ruby
gem "ruflet_rails"
```

## Install

```bash
bin/rails generate ruflet:install
```

The generator creates `config/initializers/ruflet.rb`:

```ruby
Ruflet::Rails.configure do |config|
  config.app_file    = Rails.root.join("app/views/ruflet/main.rb")
  config.ws_path     = "/ws"

  # Base URL the Flutter client uses to reach this Rails app. Always required —
  # it backs asset URLs, the build-time RUFLET_URL define, and the desktop
  # launcher. Point it at a LAN IP (not localhost) to test on a real device.
  config.backend_url = ENV.fetch("RUFLET_BACKEND_URL") do
    Rails.env.production? ? "https://example.com" : "http://localhost:3000"
  end
end
```

See [Assets and URLs](/docs/rails-assets) for why `backend_url` is always
required.

## Widget helpers work directly

After the gem is loaded, the widget helpers (`view`, `text`, `container`,
`app_bar`, `filled_button`, …) build controls anywhere — no builder to
instantiate, no prefix:

```ruby
# app/views/ruflet/main.rb
Ruflet.run do |page|
  page.title = "Hello"
  page.add(
    safe_area(container(padding: 24, content: text("Hello from Rails")))
  )
end
```

The `page` block parameter is the live runtime page for each connected client.

## Mounting a Ruflet frontend

Routes declare only the mount point — UI lives in your Ruby files, never in
`routes.rb`.

```ruby
Rails.application.routes.draw do
  # Native mobile/desktop clients connect here. The home screen is declared in
  # app/views/ruflet/main.rb (dev code), not auto-discovered by the framework.
  match "/ws", to: Ruflet::Rails.app(Rails.root.join("app/views/ruflet/main.rb")), via: :all

  # A web frontend, mounted at a route. Pick ONE source:
  mount Ruflet::Rails.web_app(app_file: Rails.root.join("app/ruflet/store/main.rb")), at: "/store"
  mount Ruflet::Rails.web_app(view: "ProductComponent"), at: "/products"
end
```

### `Ruflet::Rails.endpoint` — the mobile/desktop entry

The `/ws` endpoint is declared the same way as a web mount, so the screens your
app shows live in dev code:

```ruby
# a standalone Ruflet app file (per session):
match "/ws", to: Ruflet::Rails.endpoint(app_file: Rails.root.join("app/views/ruflet/main.rb")), via: :all

# a single component/view class (resolved lazily, so reloading works):
match "/ws", to: Ruflet::Rails.endpoint(view: "HomeComponent"), via: :all

# a custom block:
match "/ws", to: Ruflet::Rails.endpoint { |page| MyHome.render(page) }, via: :all
```

`Ruflet::Rails.app(path)` is shorthand for `endpoint(app_file: path)`. A bare
`Ruflet::Rails.endpoint` (no arguments) falls back to a convenience view router
that auto-discovers `RufletView` subclasses — useful for zero-config, but
declare an entry above to own your home screen.

### `Ruflet::Rails.web_app` — a web frontend

`web_app` serves the Flutter web build (rewriting `<base href>` to the mount
point) and answers the Ruflet WebSocket on the same path. Pass exactly one
source:

- `view:` — a component/view class name, resolved lazily per session.
- `app_file:` — a standalone Ruflet app file (`Ruflet.run { |page| ... }`).
- a block — `web_app { |page| ... }`.

## Build the native clients from Rails

The build reads metadata from your initializer config — no `ruflet.yaml` on disk
required (see Build metadata below):

```bash
bundle exec rake ruflet:build[web]
bundle exec rake ruflet:build[macos]
bundle exec rake ruflet:build[apk]      # android
bundle exec rake ruflet:build[ios]
```

### Build metadata

`rake ruflet:build` serializes `Ruflet::Rails.config` to the `ruflet.yaml`
structure and writes it to a temp file the CLI reads via `RUFLET_CONFIG`. So
`config/initializers/ruflet.rb` *is* your `ruflet.yaml` for a Rails app:

- `app_name`, `backend_url` → the `app:` section
- `services` → the `services:` section
- `splash_screen`, `icon_launcher`, `icon_*` → the `assets:` section
- `splash_color`, `theme_color`, … → the `build:` section

If you drop a real `ruflet.yaml`/`ruflet.yml` in the Rails root, it takes
precedence and the initializer config is ignored for the build.

## What else `ruflet_rails` gives you

- [Scaffolding](/docs/rails-scaffolding) — generate a full CRUD resource as a
  single mountable component.
- [Navigation](/docs/rails-navigation) — a Flet-style routed view stack.
- [Assets and URLs](/docs/rails-assets) — `asset_url`, `backend_url`, and the
  `ruflet_frame` ERB helper.
- [Webview Apps](/docs/rails-webview-apps) — wrap your website in a native
  shell, Hotwire Native-style.
