# ERB to Native

`Ruflet::Rails.erb_to_native` renders Rails ERB views as real Ruflet controls.
There is no WebView in this mode. Your controllers, models, validations, and
templates do the work; Ruflet calls the controller action for each screen,
renders its template, and transforms the markup into the native control tree.

## Start an ERB-to-native app

Point the Ruflet entrypoint at the first screen:

```ruby
# app/views/ruflet/main.rb
Ruflet.run do |page|
  Ruflet::Rails.erb_to_native(
    page,
    start_url: "#{Ruflet::Rails.backend_url}/mobile",
    title: "My app"
  )
end
```

`start_url:` names the first screen. It defaults to `"/"`, which names no
controller, so pass a screen path. A full URL is accepted and only its path is
used: this example opens `MobileController#home`. `title:` is optional, and a
custom `fetcher:` can be injected in tests.

## How screens are found

A screen path names a controller action by convention. No Rails route is
needed for it:

- `/native` runs `NativeController#home`; without `home`, it tries `#index`,
  then `#show`.
- `/native/counter` runs `NativeController#counter`.
- `/native/counter/increment` runs `NativeController#counter_increment`.
- `/native/device_feature/camera` runs `NativeController#device_feature` with
  `params[:id]` set to `"camera"`.

```ruby
# app/controllers/tasks_controller.rb
class TasksController < ApplicationController
  def index
    @tasks = Task.order(:due_at)
  end

  def show
    @task = Task.find(params[:id])
  end
end
```

With this controller, `/tasks` renders `app/views/tasks/index.html.erb` and
`/tasks/show/42` renders `show.html.erb` for task 42.

Ruflet calls the action inside the WebSocket session and keeps the controller
instance for the whole session, so `@count` survives from one tap to the next.
An action without a template of its own, such as `counter_increment`, re-renders
the screen it belongs to (`counter`). `render :other` and
`redirect_to "/native/other"` show a different screen.

No request is made for a screen. Rails routing, middleware, and
`before_action` callbacks do not run, and `cookies`, `flash`, and CSRF tokens
are not available. `session` lasts for the WebSocket connection, and `params`
holds form fields and trailing path segments.

## Render a native screen from ERB

The helpers are included in Action View:

```erb
<%# app/views/tasks/index.html.erb %>
<%= appbar "Tasks" do %>
  <%= appbar_action "add", "/tasks/new" %>
<% end %>

<%= column class: "p-6 gap-4" do %>
  <%= h1 "Today", class: "text-3xl font-bold" %>

  <% @tasks.each do |task| %>
    <%= list_tile title: task.title,
          subtitle: task.due_at&.to_fs(:short),
          leading: task.completed? ? "check_circle" : "radio_button_unchecked",
          href: "/tasks/show/#{task.id}" %>
  <% end %>
<% end %>

<%= fab icon: "add", href: "/tasks/new" %>
```

Helper keyword names use Ruby snake case and render as dashed attributes:
`on_click:` becomes `on-click`. Hash and Array values are JSON encoded, `true`
becomes a bare attribute, and `nil` or `false` is omitted.

## Navigation, actions, and forms

- `link` and `href:` push a native screen by default. Set `nav: "root"`,
  `"replace"`, or `"back"` when the stack behavior should differ.
- `on_click: "/native/counter/increment"` runs
  `NativeController#counter_increment` and re-renders the current native
  screen. A relative path such as `"counter_increment"` resolves against the
  current screen. A leading verb such as `post:` or `delete:` is stripped, not
  obeyed.
- `form`, `input`, `textarea`, `dropdown`, and `submit` collect native field
  values into `params`, run the action named by the form's `action:`, and show
  the screen it renders or redirects to. Field names become `params` keys as
  written; they are not nested.

```erb
<%= form action: "/tasks/create", class: "gap-4" do %>
  <%= input "title", label: "Task", value: @task.title %>
  <%= dropdown "priority",
        options: [["normal", "Normal"], ["high", "High"]],
        value: @task.priority %>
  <%= submit "Create task" %>
<% end %>
```

Submitting this form runs `TasksController#create` with `params[:title]` and
`params[:priority]`.

## Styling

`class:` accepts Ruflet's Tailwind-flavored native style tokens for spacing,
sizing, flex alignment, typography, colors, borders, radius, shadows, opacity,
position, transforms, gradients, visibility, scrolling, wrapping, animation,
and image fitting. These tokens become control properties; they are not loaded
as browser CSS.

Use direct widget attributes whenever a style is not represented by a class:

```erb
<%= container class: "p-6 rounded-xl bg-slate-900", expand: true do %>
  <%= text "Native ERB", color: "#ffffff", selectable: true %>
<% end %>
```

## Widgets, services, and extensions

- [Widgets](/docs/rails-native-components) explains normal ERB tags and lists
  every Ruflet widget available to a native Rails view.
- [Services](/docs/rails-native-services) use normal non-visual ERB tags such
  as `<%= battery %>` and `<%= geolocator %>`.
- Extensions use their normal ERB tags too, such as
  `<%= lottie src: "loading.json" %>` or `<%= camera expand: true %>`. Declare
  the extension in the Rails Ruflet configuration so the client includes it.

## Choose the correct Rails renderer

- Use `erb_to_native` when Rails ERB should produce native controls.
- Use `native_shell` when an existing HTML/CSS/JavaScript page should remain in
  a managed WebView with optional promoted native chrome.
- Use `native` with a Ruflet app file or block for a Ruby-built native or
  desktop Ruflet app.

See [Rails Integration](/docs/rails-integration) for installation and build
setup and [Rails API Reference](/docs/rails-api-reference) for method
signatures.
