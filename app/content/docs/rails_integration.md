# Rails Integration

`ruflet_rails` lets a Rails application serve Ruflet screens to native,
desktop, and web clients. Ruflet code can use Rails models, services, and
application logic directly.

## Install

Add the gem and run the generator:

```ruby
gem "ruflet_rails"
```

```bash
bundle install
bin/rails generate ruflet:install
```

The generator creates:

- `app/views/ruflet/main.rb`, the native client entrypoint
- `ruflet.yaml`, containing Rails build metadata
- an explicit `/ws` route in `config/routes.rb`

```ruby
match "/ws",
  to: Ruflet::Rails.app(Rails.root.join("app/views/ruflet/main.rb")),
  via: :all
```

No initializer is required.

## Build a screen

Widget helpers are available directly in Ruflet application files:

```ruby
# app/views/ruflet/main.rb
Ruflet.run do |page|
  page.title = "Account"
  page.add(
    safe_area(
      container(
        padding: 24,
        content: column(
          spacing: 12,
          children: [
            text("Account", size: 28, weight: "bold"),
            text("Signed in as #{Current.user.email}")
          ]
        )
      )
    )
  )
end
```

Each connected client receives its own `page` instance.

## Mount a web application

Install the prebuilt Ruflet web client:

```bash
bundle exec rake ruflet:web
```

Then mount an application file, component class, or block:

```ruby
Rails.application.routes.draw do
  match "/ws",
    to: Ruflet::Rails.app(Rails.root.join("app/views/ruflet/main.rb")),
    via: :all

  mount Ruflet::Rails.web_app(
    app_file: Rails.root.join("app/views/ruflet/main.rb")
  ), at: "/app"

  mount Ruflet::Rails.web_app(view: "DashboardComponent"), at: "/dashboard"
end
```

`web_app` serves the installed web client and its WebSocket from the same
mount. The browser URL remains the mounted route without query parameters.

## Endpoint sources

Native endpoints and web mounts require one explicit source:

```ruby
Ruflet::Rails.endpoint(app_file: Rails.root.join("app/views/ruflet/main.rb"))
Ruflet::Rails.endpoint(view: "DashboardComponent")
Ruflet::Rails.endpoint { |page| Dashboard.render(page) }
```

`Ruflet::Rails.app(path)` is shorthand for `endpoint(app_file: path)`.

## Rails scaffolds

The normal Rails scaffold generator also creates a Ruflet resource component:

```bash
bin/rails generate scaffold Post title:string body:text
```

Use `--skip-ruflet` when a scaffold should not create one. Ruflet resource
routes are never mounted automatically.

## Build native clients

`ruflet_rails` builds native clients through Rails tasks:

```bash
bundle exec rake ruflet:build[desktop]
bundle exec rake ruflet:build[macos]
bundle exec rake ruflet:build[apk]
bundle exec rake ruflet:build[ios]
bundle exec rake ruflet:build[aab]
```

The Rails integration installs the web client with `rake ruflet:web`; it does
not compile a web client through `ruflet:build`.

## Related guides

- [Scaffolding](/docs/rails-scaffolding)
- [Navigation](/docs/rails-navigation)
- [Assets and URLs](/docs/rails-assets)
- [Webview Apps](/docs/rails-webview-apps)
