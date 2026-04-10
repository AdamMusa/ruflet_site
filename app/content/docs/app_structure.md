# App Structure

After creating a Ruflet app, this is the first page you should read.

The most useful thing to understand early is the real project structure Ruflet gives you and what each file is responsible for.

## The generated project structure

A newly generated Ruflet app starts with a small Ruby-side structure:

```text
my_app/
  Gemfile
  README.md
  main.rb
  ruflet.yaml
```

Over time, you will usually add your own folders, for example:

```text
my_app/
  Gemfile
  README.md
  main.rb
  ruflet.yaml
  assets/
    icon.png
    splash.png
  views/
  components/
  services/
```

Ruflet also manages a Flutter client workspace behind the scenes for builds and platform packaging. In normal Ruflet app development, you should not need to edit Flutter files directly.

## The Ruby-side files

### `main.rb`

This is the application entry point.

It is the first file you run and the first place you write UI code.

The scaffold currently generates a starter counter app like this:

```ruby
require "ruflet"

Ruflet.run do |page|
  page.title = "Counter Demo"
  count = 0
  count_text = text(count.to_s, style: {size: 40})

  page.add(
    container(
      expand: true,
      alignment: Ruflet::MainAxisAlignment::CENTER,
      content: column(
        alignment: Ruflet::MainAxisAlignment::CENTER,
        horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
        children: [
          text("You have pushed the button this many times:"),
          count_text
        ]
      )
    ),
    floating_action_button: fab(
      icon: Ruflet::MaterialIcons::ADD,
      on_click: ->(_e) do
        count += 1
        page.update(count_text, value: count.to_s)
      end
    )
  )
end
```

What belongs here:

- app entry logic
- first screen composition
- state for small apps
- route/view setup for early prototypes

As the app grows, you can split code into more files and keep `main.rb` focused on bootstrapping.

### `Gemfile`

This defines the Ruby dependencies for the app.

The current scaffold generates:

```ruby
source "https://rubygems.org"

gem "ruflet_core", ">= 0.0.10"
gem "ruflet_server", ">= 0.0.10"
```

What this means:

- `ruflet_core` contains the core UI/runtime pieces
- `ruflet_server` provides the server-driven runtime/backend side

This file is where you add normal Ruby gems for your app as well.

### `README.md`

This gives the local project workflow.

The generated README includes the basic setup, run, and build commands:

```bash
bundle install
bundle exec ruflet run main
bundle exec ruflet build apk
bundle exec ruflet build ios
```

Treat it as the first local “how to work on this app” note for your project.

### `ruflet.yaml`

This file is one of the most important parts of the app structure.

It is the configuration layer for app identity, assets, enabled services, and build settings.

The generated structure includes sections like:

```yaml
app:
  name: my_app
  display_name: My App
  package_name: my_app
  organization: com.example
  version: 1.0.0+1
  description: A new Ruflet app.
  backend_url: ""

services: []

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

What each section means:

- `app`: the identity and metadata of your application
- `services`: optional client extensions such as camera, video, or webview
- `assets`: where Ruflet should find branding assets
- `build`: build-time appearance settings

## The managed Flutter client side

Ruflet is Ruby-first, but packaging still relies on a Flutter client.

That client is usually managed for you and bootstrapped from the Ruflet template. In practice, Ruflet can keep or create a client workspace under managed build paths instead of making you hand-author Dart code for the app layer.

The template contains the platform projects and Flutter configuration needed for:

- Android
- iOS
- macOS
- Windows
- Linux
- web

The important point is this:

- your day-to-day app code lives in Ruby
- the Flutter side is managed infrastructure for hosting and packaging
- Ruflet users should not need to work in Flutter files for normal app development

## How to organize your own app after generation

The scaffold is intentionally small, but most real apps will eventually grow into something like:

```text
my_app/
  main.rb
  Gemfile
  ruflet.yaml
  assets/
  views/
  components/
  models/
  services/
```

A practical split looks like this:

- `main.rb`: app entry and boot
- `views/`: full screens or route-level UI
- `components/`: reusable UI pieces
- `models/`: Ruby domain objects or state objects
- `services/`: wrappers around app logic, APIs, or platform interactions

Ruflet does not force one folder convention, which is useful, but it also means you should choose a structure early once the app grows beyond one file.

## Two authoring styles inside that structure

### Small app style

Use `Ruflet.run do |page| ... end` when:

- the app is small
- you are prototyping
- you want to keep everything in `main.rb`

### Larger app style

Use `Ruflet::App` when:

- the app has state that lives longer
- you want helper methods
- you want multiple views or more structure

## How the runtime responsibilities are split

### Builder helpers

Helpers like these create controls:

- `text`
- `row`
- `column`
- `container`
- `image`
- `text_field`
- `tabs`
- `navigation_bar`

### `page`

`page` handles runtime behavior:

- `page.add(...)`
- `page.update(...)`
- page title and layout properties
- dialogs
- navigation
- host/device APIs

This split is one of the main structural ideas in Ruflet:

- builders define UI
- `page` manages runtime interaction

## What to understand before moving on

Before you leave this page, make sure these things are clear:

1. `main.rb` is the real app entry point
2. `Gemfile` controls Ruby dependencies
3. `ruflet.yaml` controls app identity, services, and build behavior
4. the Flutter client side is mostly packaging/runtime infrastructure
5. your actual product code starts in Ruby

## Recommended next step

Now move to [`/docs/running-a-ruflet-app`](/docs/running-a-ruflet-app) and run the generated app with the structure in mind.
