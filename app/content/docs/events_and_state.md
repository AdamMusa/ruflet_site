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
