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

The generator creates two files and adds one route:

- `app/views/ruflet/main.rb` — your home screen, served to native clients over
  `/ws` and to any web mount. You own this file; nothing is auto-discovered.
- `ruflet.yaml` — app metadata and build options (name, `backend_url`,
  services, assets).
- a `/ws` route in `config/routes.rb`:

```ruby
match "/ws", to: Ruflet::Rails.app(Rails.root.join("app/views/ruflet/main.rb")), via: :all
```

Nothing is auto-mounted — you mount everything explicitly in `routes.rb`, the
same way you mount a web frontend. No initializer is required.

You can add `config/initializers/ruflet.rb` to set `backend_url` (used by asset
URLs and the desktop launcher) or other build metadata:

```ruby
Ruflet::Rails.configure do |config|
  # Base URL the Flutter client uses to reach this Rails app. Point it at a LAN
  # IP (not localhost) to test on a real device.
  config.backend_url = ENV.fetch("RUFLET_BACKEND_URL") do
    Rails.env.production? ? "https://example.com" : "http://localhost:3000"
  end
end
```

See [Assets and URLs](/docs/rails-assets) for more on `backend_url`.

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

`Ruflet::Rails.app(path)` is shorthand for `endpoint(app_file: path)`. You must
declare an entry — `view:`, `app_file:`, or a block. A bare
`Ruflet::Rails.endpoint` with no arguments raises `ArgumentError`; there is no
auto-discovery fallback.

### `Ruflet::Rails.web_app` — a web frontend

`web_app` serves the Flutter web build (rewriting `<base href>` to the mount
point) and answers the Ruflet WebSocket on the same path. Pass exactly one
source:

- `view:` — a component/view class name, resolved lazily per session.
- `app_file:` — a standalone Ruflet app file (`Ruflet.run { |page| ... }`).
- a block — `web_app { |page| ... }`.

## Build the native clients from Rails

The build reads `ruflet.yaml` (created by the install generator — see Build
metadata below):

```bash
bundle exec rake ruflet:build[web]
bundle exec rake ruflet:build[macos]
bundle exec rake ruflet:build[apk]      # android
bundle exec rake ruflet:build[ios]
```

### Build metadata

By default `ruflet.yaml` in the Rails root is the source of build metadata — its
`app:`, `services:`, `assets:`, and `build:` sections.

You can configure it in Ruby instead: set `Ruflet::Rails.config` (e.g. in
`config/initializers/ruflet.rb`) and, when no `ruflet.yaml`/`ruflet.yml` is on
disk, `rake ruflet:build` serializes the config to a temp file the CLI reads via
`RUFLET_CONFIG`:

- `app_name`, `backend_url` → the `app:` section
- `services` → the `services:` section
- `splash_screen`, `icon_launcher`, `icon_*` → the `assets:` section
- `splash_color`, `theme_color`, … → the `build:` section

A real `ruflet.yaml`/`ruflet.yml` on disk always takes precedence over config.

## What else `ruflet_rails` gives you

- [Scaffolding](/docs/rails-scaffolding) — generate a full CRUD resource as a
  single mountable component.
- [Navigation](/docs/rails-navigation) — a Flet-style routed view stack.
- [Assets and URLs](/docs/rails-assets) — `asset_url`, `backend_url`, and the
  `ruflet_frame` ERB helper.
- [Webview Apps](/docs/rails-webview-apps) — wrap your website in a native
  shell, Hotwire Native-style.
