# Introduction

Ruflet is a Ruby framework for building web, desktop, and mobile user
interfaces from one application codebase.

Ruby code creates controls and handles events. A Ruflet client renders the UI
and provides access to browser, desktop, and device capabilities.

## First application

```bash
gem install ruflet
ruflet new my_app
cd my_app
bundle install
ruflet run main.rb --web
```

```ruby
require "ruflet"

Ruflet.run do |page|
  count = 0
  label = text(value: "0", style: { size: 40 })

  page.add(
    column(
      spacing: 12,
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

The control tree describes the interface. Event handlers update Ruby state and
use `page.update` to patch mounted controls.

## Application modes

- During mobile development, `ruflet run main.rb` starts a server that Ruflet Explorer can connect to.
- `ruflet run main.rb --web` launches the managed web client.
- `ruflet run main.rb --desktop` launches the managed desktop client.
- Server-driven builds connect to a deployed Ruby server.
- Self-contained builds package the Ruby project with the client.

Rails applications can use `ruflet_rails` to serve Ruflet screens from the
existing Rails process.

## Continue

- [Installation](/docs/installation)
- [Creating a New Ruflet App](/docs/creating-a-new-app)
- [Running a Ruflet App](/docs/running-a-ruflet-app)
- [Rails Integration](/docs/rails-integration)
