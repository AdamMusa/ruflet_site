# App Structure

A Ruflet application keeps product code in Ruby while Ruflet manages the
Flutter client used for rendering and packaging.

## Project files

```tree
my_app/
  Gemfile
  README.md
  main.rb
  ruflet.yaml
  services.yaml
  assets/
    icon.png
    splash.png
```

### `main.rb`

`main.rb` is the application entrypoint. Small apps can stay in one
`Ruflet.run` block:

```ruby
require "ruflet"

Ruflet.run do |page|
  count = 0
  label = text("0", size: 40)

  page.add(
    column(
      children: [
        label,
        filled_button(
          content: text("Increment"),
          on_click: ->(_event) {
            count += 1
            page.update(label, value: count.to_s)
          }
        )
      ]
    )
  )
end
```

Split larger applications into normal Ruby files and require them from
`main.rb`. Ruflet does not require a specific folder layout.

### `Gemfile`

Generated projects depend on the Ruflet runtime gems:

```ruby
source "https://rubygems.org"

gem "ruflet_core"
gem "ruflet_server"
```

Add other Ruby dependencies as you would in any Bundler project.

### `ruflet.yaml`

`ruflet.yaml` controls application metadata, optional Flutter extensions,
branding assets, and build appearance:

```yaml
app:
  name: my_app
  display_name: My App
  package_name: my_app
  organization: com.example
  version: 1.0.0+1
  description: A Ruflet app.
  backend_url: ""

extensions: []

assets:
  dir: assets
  splash_screen: assets/splash.png
  icon_launcher: assets/icon.png

build:
  splash_color: "#FFFFFF"
  splash_dark_color: "#0B0B0B"
  icon_background: "#FFFFFF"
  theme_color: "#FFFFFF"
```

`app.backend_url` is required for server-driven builds. It is not required for
`--self` builds.

### `services.yaml`

Protected device access is configured separately:

```yaml
services:
  - camera:
      description: Allows users to capture photos.
  - location:
      description: Shows nearby locations.
```

Ruflet uses this file during native builds to configure extensions,
permissions, usage descriptions, and entitlements.

## Runtime responsibilities

Control helpers such as `text`, `row`, `column`, and `container` describe UI.
The connected `page` manages runtime behavior:

- `page.add` mounts controls.
- `page.update` changes mounted controls.
- `page.go` changes the application route.
- dialog and feedback methods present transient UI.
- service methods interact with the connected client device.

## Managed client workspace

Ruflet creates or reuses a managed Flutter workspace under `build/client` when
a command needs Flutter source. Normal application development should not
require editing that workspace.

Build artifacts are exported under `build/`. Treat the managed client and
generated artifacts as tooling output, not application source.
