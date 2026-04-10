# App Structure

Ruflet supports two authoring styles:

- `Ruflet.run do |page| ... end`
- class-based apps built on `Ruflet::App`

Both styles are used in the repo today, but the current scaffold starts with `Ruflet.run`.

## `Ruflet.run`

This is the shortest path from idea to UI:

```ruby
require "ruflet"

Ruflet.run do |page|
  page.title = "Hello"
  page.add(
    column(
      alignment: Ruflet::MainAxisAlignment::CENTER,
      horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
      children: [
        text(value: "Hello Ruflet"),
        elevated_button(text: "Press me")
      ]
    )
  )
end
```

Use it when:

- you are prototyping
- you want a single-file app
- your state is simple enough to keep in local variables

## `Ruflet::App`

Class-based apps are better when the app grows:

```ruby
class CounterApp < Ruflet::App
  def initialize
    super
    @count = 0
  end

  def view(page)
    counter = text(value: @count.to_s, style: { size: 48 })

    page.add(
      column(
        horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
        children: [
          text(value: "You clicked:"),
          counter
        ]
      ),
      floating_action_button: fab(
        icon: Ruflet::MaterialIcons::ADD,
        on_click: ->(e) do
          @count += 1
          e.page.update(counter, value: @count.to_s)
        end
      )
    )
  end
end

CounterApp.new.run
```

Use it when:

- you want reusable methods
- you have longer-lived state
- the app has multiple views or helper objects
- you want cleaner organization for complex demos

## Page responsibilities

The `page` object is where runtime and host interaction happens. Common page responsibilities include:

- setting title, route, background, and alignment
- mounting UI with `page.add(...)`
- mutating controls with `page.update(...)`
- navigation with routes and views
- showing and closing dialogs
- registering or retrieving services
- calling platform APIs such as file picker, clipboard, or URL launch

## Control builders

Most UI is built with free helper functions such as:

- `text`
- `row`
- `column`
- `container`
- `stack`
- `image`
- `text_field`
- `button`, `elevated_button`, `filled_button`, `text_button`
- `tabs`, `tab_bar`, `tab_bar_view`
- `navigation_bar`, `navigation_rail`

This separation keeps the code easy to scan:

- builders create controls
- `page` manages lifecycle, events, and runtime communication

## Updating UI

The usual Ruflet update flow is:

1. Create a control and keep a reference to it.
2. Handle an event.
3. Call `page.update(control, ...)` with the changed properties.

```ruby
name = text(value: "Anonymous")

page.add(
  column(
    children: [
      name,
      text_button(
        content: text(value: "Rename"),
        on_click: ->(_e) { page.update(name, value: "Ruflet User") }
      )
    ]
  )
)
```

## Views, routes, and navigation

Ruflet already uses view-driven navigation in the repo:

- `page.route`
- `page.views`
- navigation bars and rails
- tabs and tab views

This makes it practical to build multi-screen apps and shell layouts without leaving the Ruby layer.

## Dialogs and transient UI

Ruflet examples and Ruflet Studio use:

- `page.show_dialog(control)`
- `page.pop_dialog`

Combined with alert dialogs, bottom sheets, Cupertino sheets, banners, and snack bars, this gives you a good range of feedback and decision flows.

## Services and platform APIs

When a feature belongs to the host platform instead of a normal widget, the code usually goes through `page`:

- `page.service(:battery)`
- `page.service(:camera)`
- `page.service(:connectivity)`
- `page.pick_files`
- `page.save_file`
- `page.get_directory_path`
- `page.launch_url`
- `page.set_clipboard`

The full capability map is covered in [`/docs/services-and-plugins`](/docs/services-and-plugins).
