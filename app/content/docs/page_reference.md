# Page, View and Window

`page` is the `Ruflet::Page` of one connected client. Ruflet creates it when
the client connects and passes it to your app block; every session has its
own. The page holds the controls on screen, the view stack, the page chrome,
the client's services and the desktop window.

```ruby
require "ruflet"

Ruflet.run do |page|
  page.title = "Inbox"
  page.appbar = app_bar(title: text("Inbox"))
  page.add(text("Hello from #{page.platform}"))
end
```

## Where page properties go

The client draws a Page control that holds one or more View controls. A page
property you assign lands on one of them:

- On the Page: `title`, `route`, `theme`, `dark_theme`, `theme_mode`, `fonts`, `rtl`, `show_semantics_debugger` and `theme_animation_style`. `vertical_alignment`, `horizontal_alignment` and `scroll` go to both.
- On the page's own View: everything else, such as `appbar`, `bgcolor`, `padding`, `spacing`, `drawer`, `navigation_bar` and `floating_action_button`.

The page's own View is the screen while `page.views` is empty. Once you assign
`page.views`, the client shows those views instead, and the View properties you
set on `page` no longer appear: give each `view(...)` its own `appbar`,
`bgcolor` and so on.

`page.update` sends what changed. Assignments made while your app block runs are
sent with the first screen.

## Page properties

- `title` — the window or browser tab title. Ruflet starts it as `"Ruflet App"`.
- `route` — the current route, such as `"/settings?tab=2"`. Change it with `page.go`.
- `views` — the view stack, an Array of `view(...)` controls; the last one is on top. See [View](#view).
- `controls` / `controls=` — the controls of the page's own View.
- `theme`, `dark_theme`, `theme_mode` and `fonts` — see [Theming](/docs/theming).
- `rtl` — lays the page out right to left when `true`.
- `show_semantics_debugger` — draws the accessibility tree over the app when `true`.
- `scroll` — makes the page's own View scroll: `"auto"`, `"always"`, `"adaptive"` or `"hidden"`.
- `vertical_alignment` / `horizontal_alignment` — how the page's own View lays out its controls, for example `"center"`.
- `bgcolor`, `padding` and `spacing` — the background, padding and gap between controls of the page's own View.
- `decoration` / `foreground_decoration` — a box decoration drawn behind or in front of the page's View content: `bgcolor:`, `gradient:`, `image:`, `border:`, `border_radius:`, `shadows:`, `shape:` and `blend_mode:`.
- `appbar`, `bottom_appbar` (alias `bottomappbar=`), `navigation_bar`, `drawer`, `end_drawer` and `floating_action_button` — the page's chrome. Assign one control each.
- `floating_action_button_location` — where the floating action button sits: `"endFloat"` (the default), `"centerFloat"`, `"startFloat"`, `"endDocked"`, `"centerDocked"`, `"endTop"`, the `mini` forms such as `"miniEndFloat"`, or `{ x:, y: }` for an exact offset.
- `auto_scroll` — keeps a scrolling page's View scrolled to the end as controls are added.
- `dialog`, `snack_bar` (alias `snackbar=`) and `bottom_sheet` (alias `bottomsheet=`) — the page's single dialog, snack bar and bottom sheet slots. `page.show_dialog` and the other show methods are usually simpler.
- `overlay` / `overlay=` — controls drawn above the page, such as a progress ring or a snack bar.
- `services` / `services=` — the service controls registered on the page; see [Services and Device APIs](/docs/services-and-plugins).
- `window` — the desktop window; see [Window](#window).

Any other `page.name = value` is stored as a property of the page's own View.
`page.disabled = true` is one that helps: controls inherit `disabled` from
their parents, so it disables every control on the page's View.

### Accepted, but not applied

These keywords exist on the Page control, but setting them from Ruby changes
nothing on 0.0.23 or on `main`:

- `locale_configuration` and `enable_screenshots` — the client reads them from the Page, but Ruflet stores them on the page's View.
- `adaptive` — the design always follows the platform: Cupertino on iOS and macOS, Material elsewhere.
- `col`, `expand` and `expand_loose` — they size a control inside a row, column or responsive row, and a page has no such parent. (`badge`, `tooltip`, `opacity` and `visible`, the other keywords the Page shares with every control, are stored on the page's View like any View property.)
- `multi_views` — the client's list of Flutter views in a multi-view embedding. Ruflet does not send it.

## Client-reported properties

The client reports these when it connects and keeps some of them current. Read
them; do not assign them.

- `page.platform` — `"android"`, `"android_tv"`, `"ios"`, `"macos"`, `"windows"`, `"linux"` or `"fuchsia"`. In a browser it is the operating system the browser runs on.
- `page.platform_brightness` — `"light"` or `"dark"`, the system setting. It stays current.
- `page.width` and `page.height` — the page's size in logical pixels. They stay current.
- `page.media` — a Hash with `"padding"`, `"view_padding"` and `"view_insets"` (each with `"top"`, `"right"`, `"bottom"` and `"left"`), `"device_pixel_ratio"`, `"orientation"` (`"portrait"` or `"landscape"`) and `"always_use_24_hour_format"`. It stays current.
- `page.route` — the current route.
- `page.session_id` — the session's id, a String.
- `page.client_details` — everything the client reported at connection, as a Hash.
- `page.web` / `page.web?` — `true` only when the connection details include `web`. The Ruflet server does not keep that flag from the client yet, so it is `false` on every client with 0.0.23 and on `main`. Check `page.platform` and the layout instead.

The other client flags on the Page control (`pwa`, `wasm`, `debug`, `test`,
`multi_view`, `pyodide`, `client_ip`, `client_user_agent` and `sess`) are not
kept, and `page.pwa` and the others raise NoMethodError.

## Page events

The client sends these to the page. `event.control` is `nil` and
`event.target` is `1`.

- `route_change` — the route changed, from the browser's address bar, a deep link or `page.go`. `event.data["route"]` (also `event.value`) is the new route. Set it with `page.on_route_change = ->(event) { ... }`.
- `view_pop` — the user went back from the top view (back button, back gesture or the app bar's back arrow). `event.data["route"]` is that view's route. Ruflet does not change `page.views`: remove the view and call `page.update`. Set it with `page.on_view_pop =`.
- `platform_brightness_change` — the system switched between light and dark. `event.data` is `"light"` or `"dark"`.
- `app_lifecycle_state_change` — the app moved between foreground and background. `event.data["state"]` is `"show"`, `"resume"`, `"inactive"`, `"hide"`, `"pause"`, `"detach"` or `"restart"`.
- `multi_view_add` / `multi_view_remove` — a Flutter view was added or removed in a multi-view embedding: `event.data` is `{ "view_id" => ..., "initial_data" => ... }`, or the removed view id.
- `keyboard_event` — a key was pressed: `event.data` has `"key"` (the key's label, such as `"A"` or `"Enter"`) and `true`/`false` for `"shift"`, `"ctrl"`, `"alt"` and `"meta"`. Modifier keys alone send nothing.
- `resize` — the page's size changed: `event.data` has `"width"` and `"height"`.
- `media_change` — `page.media` changed: `event.data` is the new media Hash.
- `locale_change` — the system languages changed: `event.data["locales"]` lists them.
- `error` — the client caught an error while drawing the app.
- `views_pop_until` — sent by Ruby's `page.pop_views_until`; see [Popping several views](/docs/events-and-state#popping-several-views). **Requires the next Ruflet release** (on `main`, not in 0.0.23).

`page.on(:name) { |event| ... }` receives the first four events with 0.0.23 and
on `main`, because the client sends them without being asked. The client sends
`keyboard_event`, `resize`, `media_change`, `locale_change` and `error` only
when the page asks for them, which takes a handler writer such as
`page.on_keyboard_event = ->(event) { ... }`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

```ruby
theme_label = text(value: "System theme: #{page.platform_brightness}")
state_label = text(value: "App state: running")
page.add(column(children: [theme_label, state_label]))

page.on(:platform_brightness_change) do |event|
  page.update(theme_label, value: "System theme: #{event.data}")
end

page.on(:app_lifecycle_state_change) do |event|
  page.update(state_label, value: "App state: #{event.data["state"]}")
end
```

`on_close`, `on_connect`, `on_disconnect`, `on_login` and `on_logout` are
accepted, but no client sends these events. To act before a desktop window
closes, use the window's [`on_event`](#window).

## Page methods

### Content

- `add(control)` — appends one control to the page's own View and sends it. It raises ArgumentError for anything but a single control: set chrome such as `page.floating_action_button` first, then add the body.
- `insert(index, *controls)`, `remove(*controls)`, `remove_at(index)` and `clean` — change the page's own controls and send the result.
- `controls` / `controls=(list)` — read or replace them.
- `update` — with no arguments, sends every change made in Ruby since the last update: control props, page properties and views.
- `update(control, **props)` — sets those props on one mounted control and sends only them. `update(:page, **props)` sets page properties.
- `schedule_update` — the same as `update` with no arguments.
- `patch_page(control_or_id, **props)` — the same as `update(control_or_id, **props)`.
- `get_control(id)` — the mounted control with that control id, or with that wire id when it is a number.
- `set_view_props(hash)` — assigns several page properties at once, as the DSL's `page(...)` does.
- `mount { ... }` — runs a block with the control helpers and adds each control it builds to the page.

### Navigation

- `go(route, **query)` — makes `route` current, with `query` appended as `?key=value`. It calls `on_route_change` with the new route and sends the page.
- `navigate(route, **query)` and `push_route(route, **query)` — the same as `go`.
- `query` — the current route's query string as a Hash; a key that appears twice maps to an Array.
- `views=` — replaces the view stack; call `page.update` to send it.
- `on_route_change=`, `on_view_pop=` and `on_views_pop_until=` — set those handlers.
- `pop_views_until(route, result: nil)` — pops back to the view with that route. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

```ruby
page.on_route_change = ->(_event) {
  tab = page.query["tab"] || "inbox"
  page.views = [view(route: page.route, controls: [text("Showing #{tab}")])]
  page.update
}

page.go("/mail", tab: "starred")
```

### Dialogs, sheets and overlays

- `show_dialog(dialog)` (alias `open`) — opens an alert dialog, date or time picker, banner, snack bar or bottom sheet. Opening one that is already open does nothing.
- `close_dialog(dialog = nil)` (aliases `close` and `pop_dialog`) — closes that overlay, or the one opened last. It returns the closed control, or `nil`.
- `show_snack_bar(snack_bar)` / `show_snackbar` — shows a snack bar.
- `show_bottom_sheet(sheet)` / `show_bottomsheet` and `close_bottom_sheet(sheet = nil)` / `close_bottomsheet` — open and close a bottom sheet.
- `show_banner(banner)` / `close_banner(banner = nil)` — open and close a banner.

See [Navigation and Feedback](/docs/navigation-feedback) for examples.

### Drawers and scrolling

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). With 0.0.23 these calls go to the Page control, which answers each with an error and does nothing.

- `show_drawer` / `close_drawer` and `show_end_drawer` / `close_end_drawer` — open or close the top view's drawer. `show_drawer` raises ArgumentError when there is no drawer.
- `scroll_to(offset: nil, delta: nil, scroll_key: nil, duration: nil, curve: nil)` — scrolls the root view, which must scroll (`page.scroll = "auto"`): to `offset` in pixels (negative counts from the end), by `delta`, or to the control whose `key` is `scroll_key`, animated over `duration` milliseconds with `curve`.

### Services and client calls

- `service(type, **props)` — returns the page's service of that type, creating and registering it on first use, or the one with the `id:` you pass. Visual services such as the camera are returned without registering, ready for `page.add`.
- `add_service(*services)` / `remove_service(*services_or_ids)` — register or remove service controls.
- `invoke(control, method_name, args: nil, timeout: 10, on_result: nil)` — calls a client method on a mounted control or service and returns the call id at once. `on_result` receives `|result, error|`; after `timeout` seconds without an answer it receives `nil, "execution expired"`.
- `invoke_sync(control, method_name, args: nil, timeout: 10)` — waits for the answer and returns it. It raises RuntimeError with the client's error and Timeout::Error after `timeout`. Do not call it inside an event handler: handlers run on the thread that delivers the answer, so the call always times out.
- `on(event_name, &block)` — registers a Page event handler; see [Page events](#page-events).
- `get_device_info(on_result:)`, `get_device_info_sync` and `set_allowed_device_orientations(orientations)` — see [Device information and orientation](/docs/services-and-plugins#device-information-and-orientation). **Requires the next Ruflet release** (on `main`, not in 0.0.23).

The service helpers (`page.clipboard`, `page.geolocator` and the others) and the
one-shot calls (`page.launch_url`, `page.pick_files` and the others) are listed
under [Services](/docs/services-and-plugins).

`apply_client_update`, `dispatch_event`, `handle_invoke_method_result`,
`register_page_patch`, `prepare_for_reconnect!`, `reset_for_reload!`,
`finalize_reload!` and `replay_route_after_reload!` are runtime internals that
the server and hot reload call.

## View

A `view(...)` is one screen of the stack in `page.views`. It takes the same
chrome and layout properties as the page's own View (`appbar`, `controls`,
`bgcolor`, `padding`, `spacing`, `scroll`, `vertical_alignment`,
`horizontal_alignment`, `drawer`, `end_drawer`, `navigation_bar`,
`bottom_appbar`, `floating_action_button`, `auto_scroll`) plus `route`. See the
[View control](/docs/control-view) for every keyword. These need a closer
look:

- `route` — identifies the view. Give every view in the stack its own route: the client uses it to animate pushes and to name the view in `view_pop`.
- `can_pop` — when `false`, the back button, the back gesture and the app bar's back arrow do not pop this view (default `true`).
- `on_confirm_pop` — together with `can_pop: false`, asks Ruby whether to pop instead. Answer with `page.invoke(event.control, "confirm_pop", args: { should_pop: true })`, or `false` to stay. A view that gets no answer within five minutes stays. Popping the first view closes the app on Android.
- `fullscreen_dialog` — the view opens as a full-screen dialog, so its app bar shows a close button instead of a back arrow.
- `decoration` / `foreground_decoration` — a box decoration behind or in front of the view's content, as for the page.
- `floating_action_button_location` — as for the page.
- `scroll_interval` — the minimum time in milliseconds between two `on_scroll` events (default 10).
- `on_scroll` — the view scrolled. Read `event.data`: see `ScrollEvent` in [Payload classes](/docs/events-and-state#payload-classes).
- `services` — accepted, but no client reads services from a view. Register services on the page.

```ruby
editor = text_field(label: "Draft", multiline: true)

page.views = [
  view(route: "/", controls: [text("Notes")]),
  view(
    route: "/edit",
    can_pop: false,
    appbar: app_bar(title: text("Edit note")),
    controls: [editor],
    on_confirm_pop: ->(event) {
      unsaved = !editor.props["value"].to_s.empty?
      page.invoke(event.control, "confirm_pop", args: { should_pop: !unsaved })
    }
  )
]
page.on_view_pop = ->(_event) {
  page.views.pop
  page.update
}
page.update
```

`auto_scroll_animation`, `bottom_sheet`, `end_reached_threshold`,
`keyboard_dismiss_behavior`, the `refresh_*` keywords, `on_end_reached` and
`on_refresh` are View keywords on `main` only. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Window

`page.window` is the desktop window of a macOS, Windows or Linux client. Other
clients ignore it. It is a `Window` control that Ruflet creates from the
client's report: `page.window.props` holds the window state the client last
reported, and the client reports it again after each window event.

Change the window by updating it:

```ruby
status = text(value: "Window ready")
page.add(status)

page.title = "Notes"
page.update(page.window, width: 960, height: 640, min_width: 480, min_height: 360, prevent_close: true)
page.window.center

page.window.on(:event) do |event|
  case event.data["type"]
  when "close"
    page.update(status, value: "Saving before closing…")
    page.window.destroy
  when "focus", "blur"
    page.update(status, value: "Window #{event.data["type"]}")
  end
end
```

The window takes its title from `page.title`.

### Window properties

- `width`, `height`, `top` and `left` — the size and position in logical pixels. Size and position are not applied while the window is full screen, nor, on macOS, while it is maximized or minimized.
- `min_width`, `min_height`, `max_width` and `max_height` — size limits.
- `aspect_ratio` — keeps the window at this width-to-height ratio while it is resized.
- `alignment` — places the window on the screen: `{ x:, y: }`, each from -1.0 to 1.0, so `{ x: 0, y: 0 }` centers it and `{ x: 1, y: -1 }` puts it top right.
- `maximized`, `minimized` and `full_screen` — `true` maximizes, minimizes or enters full screen; `false` restores.
- `resizable`, `movable`, `minimizable` and `maximizable` — whether the user can resize, move, minimize and maximize the window.
- `always_on_top` / `always_on_bottom` — keep the window above or below other windows.
- `prevent_close` — when `true`, closing the window sends a `"close"` event instead of closing it. Call `page.window.destroy` to close it then.
- `frameless` — removes the title bar and border. `title_bar_hidden` hides the title bar only, and `title_bar_buttons_hidden: true` also hides its buttons.
- `skip_task_bar` — hides the window from the task bar or Dock.
- `visible` and `focused` — `false` hides or blurs the window; `true` shows or focuses it.
- `opacity` — from 0.0 to 1.0.
- `bgcolor` — the window's background color.
- `brightness` — `"light"` or `"dark"` for the native window chrome.
- `shadow` — whether the window has a shadow.
- `progress_bar` — a progress value from 0.0 to 1.0 shown on the task bar or Dock icon; `nil` removes it.
- `badge_label` — a label on the macOS Dock icon, such as `"3"`.
- `icon` — the window icon on Windows, an asset path.
- `ignore_mouse_events` — lets clicks pass through the window.
- `data` and `key` — as on other controls.

### Window methods

Each takes `timeout:` and `on_result:` like other client calls.

- `center` — centers the window on the screen.
- `close` — closes the window, as the close button does: with `prevent_close: true` it sends `"close"` instead.
- `destroy` — closes the window even when `prevent_close` is `true`.
- `to_front` — brings the window to the front.
- `wait_until_ready_to_show` — answers once the window can be shown.
- `start_dragging` — starts moving the window with the pointer; call it from a pointer-down handler on a custom title bar.
- `start_resizing(edge)` — starts resizing from `"top"`, `"bottom"`, `"left"`, `"right"`, `"top_left"`, `"top_right"`, `"bottom_left"` or `"bottom_right"`.

A [`window_drag_area`](/docs/control-window-drag-area) moves the window without code.

### Window events

`page.window.on(:event) { |event| ... }` receives the window's events.
`event.data["type"]` is one of `"close"` (only with `prevent_close: true`),
`"focus"`, `"blur"`, `"maximize"`, `"unmaximize"`, `"minimize"`, `"restore"`,
`"resized"`, `"moved"`, `"enter-full-screen"` or `"leave-full-screen"`. After
each one, `page.window.props` holds the new `maximized`, `minimized`,
`full_screen`, `always_on_top`, `focused`, `visible`, `width`, `height`, `top`,
`left` and `opacity`.
