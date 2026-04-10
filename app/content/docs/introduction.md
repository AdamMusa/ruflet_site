# Introduction

Ruflet is a Ruby-first framework for building web, desktop, and mobile applications from one codebase.

If Flet is the inspiration, Ruflet is the Ruby-native interpretation: Ruby app code, RubyGems packaging, Ruby-friendly examples, and a runtime that lets you stay out of Dart for the application layer.

## Why developers like Ruflet

- Build the app layer in Ruby.
- Target mobile, web, and desktop from one codebase.
- Keep iteration fast with `ruflet run`.
- Grow from a tiny counter app to larger product UIs.
- Bring Rails and Ruby gems into the same ecosystem naturally.

## Start in 60 seconds

```bash
gem install ruflet
ruflet new my_app
cd my_app
bundle install
ruflet run main
```

## Ruflet app example

```ruby
require "ruflet"

Ruflet.run do |page|
  page.title = "Ruflet counter example"
  page.vertical_alignment = Ruflet::MainAxisAlignment::CENTER

  counter = text("0", style: { size: 32 })

  page.add(
    row(
      alignment: Ruflet::MainAxisAlignment::CENTER,
      children: [
        icon_button(
          icon: Ruflet::MaterialIcons::REMOVE,
          on_click: ->(_e) { page.update(counter, value: (counter.value.to_i - 1).to_s) }
        ),
        counter,
        icon_button(
          icon: Ruflet::MaterialIcons::ADD,
          on_click: ->(_e) { page.update(counter, value: (counter.value.to_i + 1).to_s) }
        )
      ]
    )
  )
end
```

## What Ruflet already includes

- CLI scaffolding with `ruflet new`
- local development with `ruflet run`
- build targets for Android, iOS, web, macOS, Windows, and Linux
- both `Ruflet.run` and `Ruflet::App` authoring styles
- Material and Cupertino controls
- navigation, dialogs, feedback, charts, media, and service integrations
- Rails integration through `ruflet_rails`

## Best path through these docs

1. Start with Installation.
2. Create a new app.
3. Run it on mobile, web, or desktop.
4. Work through the tutorials.
5. Come back to the reference pages when you need specifics.

## Good next pages

- [Installation](/docs/installation)
- [Creating a New Ruflet App](/docs/creating-a-new-app)
- [Running a Ruflet App](/docs/running-a-ruflet-app)
- [Rails Integration](/docs/rails-integration)
