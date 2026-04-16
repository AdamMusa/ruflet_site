# Getting Started

Ruflet is a Ruby-first UI framework for building web, desktop, and mobile apps from one codebase. It follows the same broad idea as Flet, but the authoring experience is centered on Ruby, RubyGems, and Ruflet's runtime/page APIs.

## What Ruflet gives you

- One Ruby app can run against mobile, web, and desktop clients.
- You can start with a tiny `Ruflet.run do |page| ... end` app and grow into class-based apps with `Ruflet::App`.
- The CLI can scaffold projects, run local servers, launch web and desktop clients, install builds, and package apps for multiple targets.
- Ruflet already ships demos for counters, dialogs, tabs, todo apps, calculators, image galleries, navigation patterns, and larger showcase apps like solitaire and Ruflet Studio.

## Install Ruflet

```bash
gem install ruflet
```

## Create a new app

```bash
ruflet new my_app
cd my_app
bundle install
ruflet run main
```

`ruflet new` creates:

```tree
my_app/
  Gemfile
  README.md
  main.rb
  ruflet.yaml
  assets/
    icon.png
    splash.png
```

The generated app `Gemfile` includes the runtime gems you need to execute your app:

- `gem "ruflet_core"`
- `gem "ruflet_server"`

By default Ruflet runs in mobile mode. The local backend starts first, then you connect a Ruflet client.

You can also target web or desktop directly:

```bash
ruflet run main --web
ruflet run main --desktop
```

## Connect from the client

For mobile, install the Ruflet client from the [Ruflet releases page](https://github.com/AdamMusa/Ruflet/releases). The terminal output from `ruflet run` includes the connection URL, WebSocket endpoint, and QR code hints used by the mobile client.

## Your first app

```ruby
require "ruflet"

Ruflet.run do |page|
  page.title = "Counter Demo"
  count = 0
  count_text = text(count.to_s, style: { size: 40 })

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

This is the current Ruflet style used in the scaffold:

- Widget builders such as `text`, `row`, `column`, `container`, and `fab` are free helpers.
- `page` is used for runtime operations such as `add`, `update`, navigation, dialogs, services, and platform interaction.

## Learn the framework in the right order

1. Start with [`/docs/cli-workflow`](/docs/cli-workflow) to understand the developer loop.
2. Continue with [`/docs/app-structure`](/docs/app-structure) to learn how Ruflet apps are composed.
3. Browse [`/docs/controls-and-layout`](/docs/controls-and-layout) and [`/docs/navigation-feedback`](/docs/navigation-feedback) for the most common APIs.
4. Use [`/docs/examples`](/docs/examples) when you want runnable patterns from the repo.

## Where Ruflet is strongest today

- Fast iteration for Ruby developers who want Flutter-powered UI without writing Dart for the app layer.
- Shared UI code for app shells, dashboards, forms, utilities, media viewers, and internal tools.
- Server-driven experiences, plus self-contained packaging when you want to ship a standalone client.
