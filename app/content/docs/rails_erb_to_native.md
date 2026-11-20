# ERB to Native

`Ruflet::Rails.erb_to_native` renders Rails routes and ERB templates as real
Ruflet controls. There is no WebView in this mode. Rails still owns routing,
controllers, models, authorization, validations, and template rendering;
Ruflet transforms the returned markup into the native control tree.

## Start an ERB-to-native app

Point the Ruflet entrypoint at a normal Rails route:

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

`start_url:` is required. `title:` is optional. Production uses an in-process
Rack dispatcher, so following a link or submitting a form runs the Rails route
without opening a second network connection. A custom `fetcher:` can be
injected in tests.

## Render a native screen from ERB

The helpers are included in Action View:

```erb
<%= appbar "Tasks" do %>
  <%= appbar_action "add", new_task_path %>
<% end %>

<%= column class: "p-6 gap-4" do %>
  <%= h1 "Today", class: "text-3xl font-bold" %>

  <% @tasks.each do |task| %>
    <%= list_tile title: task.title,
          subtitle: task.due_at&.to_fs(:short),
          leading: task.completed? ? "check_circle" : "radio_button_unchecked",
          href: task_path(task) %>
  <% end %>
<% end %>

<%= fab icon: "add", href: new_task_path %>
```

Helper keyword names use Ruby snake case and render as dashed attributes:
`on_click:` becomes `on-click`. Hash and Array values are JSON encoded, `true`
becomes a bare attribute, and `nil` or `false` is omitted.

## Navigation, actions, and forms

- `link` and `href:` push a native screen by default. Set `nav: "root"`,
  `"replace"`, or `"back"` when the stack behavior should differ.
- `on_click: tasks_path` sends a POST action and re-renders the current native
  screen. Prefix with `delete:`, `patch:`, or `put:` for another verb.
- `form`, `input`, `textarea`, `dropdown`, and `submit` collect native field
  values, submit them through Rails, follow redirects, and render the response.
- Rails CSRF metadata is read from the rendered document and sent with
  non-GET requests.

```erb
<%= form action: tasks_path, method: "post", class: "gap-4" do %>
  <%= input "task[title]", label: "Task", value: @task.title %>
  <%= dropdown "task[priority]",
        options: [["normal", "Normal"], ["high", "High"]],
        value: @task.priority %>
  <%= submit "Create task" %>
<% end %>
```

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

- Use `erb_to_native` when Rails routes and ERB should produce native controls.
- Use `native_app` when an existing HTML/CSS/JavaScript page should remain in a
  managed WebView with optional promoted native chrome.
- Use `web_app` when the UI is written in Ruby Ruflet controls and mounted as a
  browser application under a Rails route.
- Use `endpoint` or `app` for a Ruby-built native or desktop Ruflet app.

See [Rails Integration](/docs/rails-integration) for installation and build
setup and [Rails API Reference](/docs/rails-api-reference) for method
signatures.
