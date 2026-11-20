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

Handlers receive a `Ruflet::Event` with these readers:

- `name` — the event name without its `on_` prefix, such as `"change"` or `"tap_down"`
- `data` — the client's payload: a Hash, an Array, a String, a number or `nil`. The server turns the keys of a Hash into Symbols, nested Hashes included. A String that holds JSON is parsed, and its keys stay Strings. On `main`, a String that is the control's own new value, such as typed text or a picked option, stays that String even when it looks like JSON (`"123"` or `"null"`); only an option key or radio value the app declared as a number or boolean still arrives as that value. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `raw_data` — the payload before a JSON String is parsed. A Hash already has Symbol keys here
- `control` — the control that fired the event (`nil` for Page events)
- `page` — the connected `Ruflet::Page`
- `target` — the wire id the client sent the event to (`1` for the Page)
- `typed_data` — the payload wrapped in a `Ruflet::Events` class picked by the event name, or `nil` when the name has none (see [Payload classes](#payload-classes))
- `value` — `typed_data.value` when the class has one; otherwise the payload's `value`, `v`, `data`, `state` or `route` entry (a Symbol or String key), or the payload itself when it is not a Hash

The event also answers every reader of its `typed_data`, so `event.local_position`
is `event.typed_data.local_position`. Each control page lists its events, and
the payload of each event is described there or in the service reference.

Read a Hash payload with Symbol keys:

```ruby
network = text(value: "Checking connection…")
page.add(network)

page.connectivity(on_change: ->(event) {
  connections = Array(event.data[:connectivity])
  page.update(network, value: connections.include?("none") ? "Offline" : "Online: #{connections.join(', ')}")
})
```

A String key, such as `"connectivity"`, finds nothing. The `on_result`
callbacks of client calls are different: their Hashes keep String keys, as each
[service page](/docs/service-geolocator) shows.

### Reading a control's new value

Before a `change`, `select` or `select_change` event, the client sends the
control's new value, and Ruflet stores it in the control's props. Read it there:

```ruby
status = text(value: "Notifications off")
toggle = switch(
  label: "Notifications",
  value: false,
  on_change: ->(event) {
    on = event.control.props["value"]
    page.update(status, value: on ? "Notifications on" : "Notifications off")
  }
)
page.add(column(children: [toggle, status]))
```

Range sliders store `props["start_value"]` and `props["end_value"]`, and
other controls the prop they change, such as `props["selected"]`,
`props["selected_index"]` or `props["expanded"]`. `event.data` holds the change
as the client sent it, which differs between controls and platforms.

### Control state readers

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). On 0.0.23 `event.control.value` raises NoMethodError; read `event.control.props["value"]` instead.

Controls that the client changes also have readers for those props, so
`event.control.value` is `event.control.props["value"]`:

- `value` — checkboxes, switches, sliders, radio groups, text fields, search bars, auto-complete, dropdowns, date and time pickers, and timer pickers
- `selection` — text fields
- `start_value` and `end_value` — range sliders and date range pickers
- `entry_mode` — date and time pickers
- `selected` — chips and segmented buttons
- `selected_index` — pickers, Cupertino segmented buttons, tabs, navigation bars, drawers and rails, and page views
- `expanded` — expansion tiles and panels

A reader returns `nil` until the prop is set.

### Payload classes

`Ruflet::Events::GestureEventFactory::EVENT_CLASS_MAP` maps an event name to
the class that wraps its payload in `event.typed_data`:

- `GenericEvent` — `raw` (the payload, keys as Strings) and `value`. The classes `ChangeEvent` (`change`), `FocusEvent` (`focus`), `BlurEvent` (`blur`), `ClickEvent` (`click`), `SubmitEvent` (`submit`), `SelectEvent`, `VisibleEvent` (`visible`), `ResultEvent` (`result`), `UploadEvent` (`upload`), `ErrorEvent` (`error`) and `ActionEvent` (`action`) add nothing to it. `GenericEvent` itself wraps `select_change`, `confirm_pop`, `route_change`, `view_pop`, `animation_end`, `size_change`, `selection_change`, `entry_mode_change`, `media_change`, `resize`, `load`, `loaded`, `accept_with_details`, `open`, `close`, `double_tap`, the `*_cancel` gestures, `long_press`, `long_press_up`, `multi_long_press` and their secondary and tertiary forms.
- `AutoCompleteSelectEvent` (`select`) — `selection`, the picked suggestion's Hash; `value` is its value.
- `DismissEvent` (`dismiss`) — `direction`, such as `"startToEnd"`, when the control sends one.
- `DismissibleUpdateEvent` (`update`) — `direction`, `progress` from 0.0 to 1.0, and `reached`.
- `ReorderEvent` (`reorder`, `reorder_start`, `reorder_end`) — `old_index` and `new_index`; `value` is `[old_index, new_index]`.
- `DragTargetEvent` (`accept`, `will_accept`, `move`, `leave`) — `src_id`, the dragged control's id, and `accept`, `x` and `y` when sent.
- `StateChangeEvent` (`state_change`) — `state`, the new state.
- `TapEvent` (`tap`, `tap_down`, `tap_up`, `double_tap_down`, and the `secondary_tap*` and `tertiary_tap*` downs and ups) — `kind` (the pointer kind, such as `"touch"` or `"mouse"`), `local_position` and `global_position`.
- `TapMoveEvent` (`tap_move`) — `kind`, `local_position`, `global_position` and `delta`.
- `MultiTapEvent` (`multi_tap`) — `correct_touches`.
- `LongPressDownEvent`, `LongPressStartEvent`, `LongPressMoveUpdateEvent` and `LongPressEndEvent` (`long_press_down`, `long_press_start`, `long_press_move_update` and `long_press_end`, and their secondary and tertiary forms) — `local_position` and `global_position`, plus `kind` (down), `offset_from_origin` and `local_offset_from_origin` (move update), and `velocity` (end).
- `DragDownEvent`, `DragStartEvent`, `DragUpdateEvent` and `DragEndEvent` (`pan_*`, `horizontal_drag_*`, `vertical_drag_*`, `drag_down` and `right_pan_*`) — `local_position` and `global_position`, plus `kind` and `timestamp` (start), `local_delta`, `global_delta`, `primary_delta` and `timestamp` (update), and `velocity` and `primary_velocity` (end).
- `ForcePressEvent` (`force_press*`) — `local_position`, `global_position` and `pressure`.
- `ScaleStartEvent` and `ScaleUpdateEvent` (`scale_start`, `scale_update`) — `local_focal_point`, `global_focal_point`, `pointer_count` and `timestamp`, plus `focal_point_delta`, `scale`, `horizontal_scale`, `vertical_scale` and `rotation` (update). `ScaleEndEvent` (`scale_end`) — `pointer_count` and `velocity`.
- `PointerEvent`, also named `HoverEvent` (`hover`, `enter`, `exit`) — `kind`, `local_position`, `global_position`, `local_delta`, `global_delta`, `timestamp`, `device`, `pressure`, `pressure_min`, `pressure_max`, `distance`, `distance_max`, `size`, `radius_major`, `radius_minor`, `radius_min`, `radius_max`, `orientation` and `tilt`.
- `ScrollEvent` (`scroll`) — `local_position`, `global_position` and `scroll_delta`. The scrolling controls send none of these: read `event.data` instead, such as `event.data[:pixels]`, with `:pixels`, `:min_scroll_extent`, `:max_scroll_extent`, `:viewport_dimension`, `:event_type` (`"start"`, `"update"`, `"end"`, `"user"` or `"overscroll"`), and `:scroll_delta`, `:direction`, `:overscroll` or `:velocity` for the matching type.

Positions, deltas and velocities are `Ruflet::Offset` values with `x` and `y`,
and are `nil` when the client left them out. The gesture classes (from
`TapEvent` on) derive from `Ruflet::Events::BasePayload`, not `GenericEvent`,
so they have no `raw`; `event.value` on them falls back to the payload rules
above.

```ruby
where = text(value: "Tap the square")
target = gesture_detector(
  content: container(width: 160, height: 160, bgcolor: :blue100),
  on_tap_down: ->(event) {
    point = event.local_position
    page.update(where, value: "#{event.kind} at #{point.x.round}, #{point.y.round}")
  }
)
page.add(column(children: [target, where]))
```

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). On 0.0.23 these names have no payload class, so `typed_data` is `nil` and `event.data` holds the payload.

- `ActionResultEvent` (`action_result`) — the outcome of a [client action](/docs/services-and-plugins#client-actions): `action`, `index`, `service`, `method_name`, `result`, `error`, `ok?`, `error?` and, for `:pick_files`, `files`.
- `PasteFilesEvent` (`paste_files`) — `files`, a list of `Ruflet::Events::PastedFile` with `name`, `mime_type`, `bytes` (a binary String), `size` and `to_h`.
- `ViewsPopUntilEvent` (`views_pop_until`) — `route`, `result` and `view`; see [Popping several views](#popping-several-views). Ruby sends this event itself, so its `event.data` keeps String keys: use these readers.
- `GenericEvent` also wraps `end_reached` and `refresh`.
- `event.with_name(name)` returns a copy of the event under another name.
- `event.relayed(name:, target:, control:)` returns a copy that `control` relays under `name`, with the same `data`. A `form` relays its fields' `change` and `submit` this way.

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

The client always sends `route_change`, `view_pop`,
`platform_brightness_change` and `app_lifecycle_state_change`, and in a
multi-view embedding `multi_view_add` and `multi_view_remove`, so `page.on`
works for them. It sends `keyboard_event`, `resize`, `media_change`,
`locale_change` and `error` only when the page asks for them, which takes the
[handler writers](#handler-writers) below. The [Page reference](/docs/page-reference#page-events)
lists every Page event with its payload.

Use callbacks such as `on_result:` for client method and device-service
results. These callbacks receive `|result, error|`; handle both paths
because platform capabilities vary. See
[Result and error handling](/docs/services-and-plugins#result-and-error-handling).

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
