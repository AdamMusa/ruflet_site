# Creating a New Ruflet App

The fastest way to start a Ruflet project is with the CLI scaffold.

## Create the project

```bash
ruflet new my_app
cd my_app
bundle install
```

## What happens next

This is the important part many frameworks skip: after generating the app, you should understand the structure before jumping into features.

Ruflet writes a practical starter structure:

- `main.rb`
- `Gemfile`
- `README.md`
- `ruflet.yaml`

## Read the app structure first

Right after scaffolding, the next thing you should learn is what each generated file is for:

- `main.rb` is your app entry point
- `Gemfile` defines the runtime dependencies
- `ruflet.yaml` controls metadata, assets, and client build behavior
- `README.md` gives the local project commands

That is why the next recommended page is [`/docs/app-structure`](/docs/app-structure).

## The generated starter app

The scaffold uses the current Ruflet style:

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

## Why this starter is useful

The starter app already teaches the core Ruflet mental model:

- controls are built with helper methods like `text`, `column`, and `container`
- `page` handles runtime behavior
- button events mutate state and then update the page

## Recommended next step

Continue to [`/docs/app-structure`](/docs/app-structure) before moving to run targets or tutorials.
