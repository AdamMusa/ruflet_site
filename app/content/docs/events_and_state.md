# Events and State

Ruflet keeps application state in Ruby. Event handlers update that state and
then patch mounted controls or rebuild the relevant view.

## Event handlers

Control events are `on_*` properties whose value is a callable:

```ruby
count = 0
label = text(value: "0", style: { size: 40, weight: "w700" })

button = filled_button(
  content: text(value: "Increment"),
  on_click: ->(_event) {
    count += 1
    page.update(label, value: count.to_s)
  }
)

page.add(column(children: [label, button]))
```

Each control reference page lists the events supported by that control. Do not
substitute a generic `on_change` when the page names a more specific event such
as `on_select`, `on_text_change`, or `on_change_end`.

## Event data

Handlers receive a `Ruflet::Event` with these application-facing readers:

- `name` — event name without guessing which handler fired
- `data` — parsed payload; JSON strings become Ruby arrays or hashes
- `raw_data` — unparsed client payload
- `page` — connected page
- `control` — control that emitted the event
- `target` — client target id
- `typed_data` — typed payload wrapper when the event has one

Typed payloads also delegate useful readers directly to the event. Depending
on the event, these include `value`, `selection`, `coordinates`, `position`,
`progress`, pointer coordinates, keyboard keys, drag details, and scale or
rotation values. Control pages identify their supported events; use `data` and
`typed_data` when an event exposes additional payload fields.

## Updating mounted controls

Keep references to controls that will change:

```ruby
status = text(value: "Ready")
page.add(status)

page.update(status, value: "Saved")
```

Use `page.update(control, **properties)` for a targeted patch. Calling
`page.update` with no control flushes pending page/view changes. Replace
`page.views` or rebuild a subtree when navigation or a large state transition
changes the structure.

## Page events

Route and view-stack events have focused writers:

```ruby
page.on_route_change = ->(_event) { render_route(page) }
page.on_view_pop = ->(_event) { page.views.pop }
```

Register other page events with `page.on`:

```ruby
page.on(:platform_brightness_change) { |_event| refresh_theme(page) }
```

Use callbacks such as `on_result:` for client method and device-service
results. These callbacks normally receive `|result, error|`; handle both paths
because platform capabilities vary.

### Popping several views

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). On 0.0.23 `page.pop_views_until` builds an unknown control and the views stay.

`page.pop_views_until(route, result: nil)` pops every view above the first
view whose route is `route` and makes that route current. It then calls
`page.on_views_pop_until`, fires `route_change` when the route changed, and
sends one update to the client. It raises ArgumentError, and leaves the stack
alone, when no view has that route.

```ruby
page.on_views_pop_until = ->(event) {
  puts "Back on #{event.route} with #{event.result.inspect}"
}

page.views = [
  view(route: "/", controls: [text("Cart")]),
  view(route: "/checkout", controls: [text("Address")]),
  view(
    route: "/checkout/pay",
    controls: [
      filled_button(
        content: text("Pay"),
        on_click: ->(_event) { page.pop_views_until("/", result: "paid") }
      )
    ]
  )
]
page.update
```

The event has `route`, `result` and `view`, the view that is now on top.

### Handler writers

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). On 0.0.23 a writer such as `page.on_resize =` sends the handler itself to the client, and it never runs.

Any `page.on_<event> =` writer registers a page handler, like `page.on`, and
sends only the event flag to the client. This covers page events such as
`on_resize` and `on_keyboard_event`, and the events of the default page view
such as `on_scroll`. Assign `nil` to remove a handler.

```ruby
size = text(value: "")
page.add(size)

page.on_resize = ->(event) { page.update(size, value: "Resized: #{event.data.inspect}") }
page.on_keyboard_event = ->(event) { page.update(size, value: "Key: #{event.data.inspect}") }
page.on_scroll = ->(event) { puts "Scrolled: #{event.data.inspect}" }
```
