# Ruflet Docs

Ruflet is a Ruby UI framework for building realtime web, mobile, and desktop apps from one codebase.

## Install

```bash
gem install ruflet_cli
```

## Create a new app

```bash
ruflet new my_app
cd my_app
bundle install
```

## Run the app

```bash
ruflet run main.rb
```

## Counter example

```ruby
require "ruflet"

Ruflet.run do |page|
  page.title = "Counter Demo"
  count = 0
  count_text = nil
  count_text ||= text(value: count.to_s, style: { size: 40 })
  page.add(
    container(
      expand: true,
      alignment: Ruflet::MainAxisAlignment::CENTER,
      content: column(
        alignment: Ruflet::MainAxisAlignment::CENTER,
        horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
        children: [
          text(value: "You have pushed the button this many times:"),
          count_text
        ]
      )
    ),
    floating_action_button: fab(
      icon(icon: Ruflet::MaterialIcons::ADD),
      on_click: ->(_e) do
        count += 1
        page.update(count_text, value: count.to_s)
      end
    )
  )
end
```
