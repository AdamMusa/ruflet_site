# Creating a New Ruflet App

The fastest way to start a Ruflet project is with the CLI scaffold.

## Create the project

```bash
ruflet new my_app
cd my_app
bundle install
```

## Generated files

Ruflet writes a practical starter structure:

- `main.rb`
- `Gemfile`
- `README.md`
- `ruflet.yaml`

## What `ruflet.yaml` is for

`ruflet.yaml` is the source of truth for app metadata and client build configuration.

It includes:

- app name and display name
- package name and organization
- version
- description
- backend URL for server-driven builds
- enabled services/extensions
- icon and splash assets
- basic theming values

## Default starter app

The generated app starts with the current Ruflet scaffold style:

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

## What to do next

Run the app and connect a target client.
