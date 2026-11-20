# Controls and Layout

Ruflet interfaces are trees of controls built with Ruby helper methods.

```ruby
page.add(
  safe_area(
    container(
      expand: true,
      padding: 24,
      content: column(
        spacing: 16,
        children: [
          text(value: "Profile", style: { size: 28, weight: "w700" }),
          text_field(label: "Display name"),
          row(
            spacing: 12,
            children: [
              filled_button(content: text("Save")),
              outlined_button(content: text("Cancel"))
            ]
          )
        ]
      )
    )
  )
)
```

## Composition

- `column` lays out children vertically.
- `row` lays out children horizontally.
- `container` adds size, spacing, alignment, decoration, and one content control.
- `stack` overlays positioned children.
- `list_view` and `grid_view` provide scrolling collections.
- `safe_area` avoids operating-system display cutouts and insets.

Most controls use `children:` for a list or `content:` for one nested control.
Some compatibility helpers also accept `controls:`.

## Platform designs

The client draws every control with the design of the platform it runs on:

- iOS and macOS get Cupertino (Apple) widgets. A web app opened in a browser on
  an iPhone, iPad or Mac gets them too, because the client reports the
  browser's operating system.
- Android, Windows, Linux and other browsers get Material widgets.

Your Ruby code stays the same: `switch`, `button`, `list_tile` or `app_bar`
send one control, and each client draws it in its own design. The
`cupertino_*` helpers do not force the iOS look either. `cupertino_switch`
sends the same `Switch` control as `switch`, `cupertino_button` the same
`Button` as `button`, and so on, so an Android client still draws a Material
switch. Older wire names, such as `CupertinoSwitch`, are normalized to the same
control by the client.

The `adaptive:` keyword that some controls accept comes from Flet. No Ruflet
client reads it, and the design follows the platform with or without it.

Some properties exist in only one design. A property page says so in its
description, for example "Android, web, Windows and Linux only" or "iOS and
macOS only". In that short form, "web" means a browser on a non-Apple system.
The other design ignores those properties.

## Option values

Options that name a choice are Strings. Write a multi-word value in camelCase,
such as `alignment: "spaceBetween"`, `fit: "fitWidth"` or
`curve: "easeInOut"`; the constants `Ruflet::MainAxisAlignment`,
`Ruflet::CrossAxisAlignment` and `Ruflet::TextAlign` hold these spellings.

```ruby
row(
  alignment: Ruflet::MainAxisAlignment::SPACE_BETWEEN,
  vertical_alignment: "center",
  children: [text("Total"), text("$24.00", weight: "bold")]
)
```

Snake case, such as `"space_between"`, also works on Ruflet main, but a 0.0.23
client does not recognize it and falls back to the default.
**Requires the next Ruflet release** (on `main`, not in 0.0.23).

Alignments of a single child, such as `align:` or a stack's `alignment:`, are
`{ x:, y: }` hashes from -1 to 1 (`{ x: 0, y: 0 }` is the center). On 0.0.23,
`container(alignment: "center")` is the one String shortcut.

On Ruflet main these alignments also take a name, such as `"center"`,
`"top_left"` or `"bottomRight"`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Text styling

Pass text styles as a Ruby hash on `style:`:

```ruby
text(value: "Dashboard", style: { size: 28, weight: "w700" })
```

This is the normal Ruflet application API: call the DSL helper and pass a
plain Ruby hash.

`decoration:` takes the Integer constants `Ruflet::TextDecoration::UNDERLINE`,
`OVERLINE` and `LINE_THROUGH`, which combine with `|`. A String such as
`"underline"` draws no line.

## Sizing

- `expand: true` fills available space along the parent's main axis, inside a
  `row`, a `column` or the page. An integer shares the space out: in a row with
  `expand: 2` and `expand: 1` children, the first gets two thirds.
  `expand_loose: true` lets a child stay smaller than its share.
- A [`form`](/docs/control-form) lays out its children like a `column`, so `expand` works inside it too. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `width` and `height` request fixed dimensions.
- `left`, `top`, `right` and `bottom` position a child of a `stack`.
- `col` sets a child's span in a [`responsive_row`](/docs/control-responsive-row).
- `padding` adds space inside a control.
- `margin` adds space around a control.
- `spacing` controls gaps between row or column children.

Use `page.client_details` when a layout must respond to client width, height,
or platform.

## Updating controls

Keep a reference to controls that change:

```ruby
status = text("Ready")
page.add(status)

page.update(status, value: "Saved")
```

For large state changes, rebuild the relevant view or replace `page.views`.
For small changes, patch the mounted control with `page.update`.

## Scrolling

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). On 0.0.23 `on_refresh:` raises ArgumentError (unknown keyword).

Scrolling collections can refresh, load more items at the end, and scroll on
command:

```ruby
posts = (1..20).map { |number| "Post #{number}" }
rows = -> { posts.map { |title| list_tile(title: text(title)) } }

feed = list_view(
  children: rows.call,
  expand: true,
  keyboard_dismiss_behavior: "on_drag",
  on_refresh: ->(_event) {
    posts = (1..20).map { |number| "Post #{number}" }
    page.update(feed, children: rows.call)
  },
  end_reached_threshold: 400,
  on_end_reached: ->(_event) {
    posts += (posts.length + 1..posts.length + 20).map { |number| "Post #{number}" }
    page.update(feed, children: rows.call)
  }
)

page.add(
  column(
    expand: true,
    children: [
      text_button(content: text("Back to top"), on_click: ->(_event) { feed.scroll_to(offset: 0, duration: 300) }),
      feed
    ]
  )
)
```

- `on_refresh` — pull to refresh on `list_view`, `grid_view`, `column` and `view`. Ruflet stops the spinner when the handler returns, also when it raises. If the work finishes later, call `control.end_refresh` yourself.
- `refresh_color`, `refresh_bgcolor`, `refresh_displacement`, `refresh_trigger_distance` and `refresh_timeout` — the refresh indicator. `refresh_timeout` (milliseconds, default 30000) stops a spinner that was never ended.
- `page.on_refresh =` — pull to refresh for the default page view, when you do not set `page.views` yourself.
- `on_end_reached` — fires when the user scrolls within `end_reached_threshold` pixels of the end (default 200), on `list_view`, `grid_view`, `column`, `row` and `view`. Use it to load the next page of items.
- `keyboard_dismiss_behavior` — `"on_drag"` hides the on-screen keyboard when the user drags the list; `"manual"` is the default. `page.keyboard_dismiss_behavior =` sets it for the default page view.
- `scroll_to(offset:, delta:, scroll_key:, duration:, curve:)` — scrolls a mounted `list_view`, `grid_view`, `column`, `row` or `view`. A negative `offset` counts from the end, so `-1` is the very end. `scroll_key` scrolls to the descendant control with that `key`.
- `animate_changes: true` — on `list_view` and `column`, animate children that are added or removed by `page.update`. `item_animation: { type:, duration:, curve: }` picks the animation: `type` is `"fade"`, `"size"`, `"fade_size"` (default) or `"slide"`.
- `auto_scroll_animation` — how `auto_scroll: true` moves to the end: `{ duration:, curve: }`, a duration in milliseconds, or `true`. `0` jumps.

```ruby
log = column(
  scroll: "auto",
  auto_scroll: true,
  auto_scroll_animation: { duration: 250, curve: "ease_out" },
  animate_changes: true,
  item_animation: { type: "slide", duration: 200 },
  children: [text("Started")]
)

page.add(log)
page.add(
  filled_button(
    content: text("Add entry"),
    on_click: ->(_event) { page.update(log, children: log.children + [text("Entry at #{Time.now.strftime('%H:%M:%S')}")]) }
  )
)
```

## Transitions, clips and sizing boxes

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). With 0.0.23 the client shows "Unknown control".

Each of these controls wraps one `content` control, given as the first
argument or `content:`.

The explicit transitions animate on the client, so a loop needs no Ruby patch
per frame. They share the timing keywords of
[`fade_transition`](/docs/control-fade-transition): `duration` (milliseconds,
default 1000), `curve`, `delay`, `repeat`, `reverse` (back and forth while
repeating) and `animating` (`false` pauses). `on_animation_end` fires when a
run that does not repeat finishes.

- `fade_transition(content, begin: 0, end: 1)` — opacity.
- `scale_transition(content, begin: 0, end: 1, alignment:)` — scale around `alignment`, a `{ x:, y: }` hash from -1 to 1 (default the center).
- `rotation_transition(content, begin: 0, end: 1, alignment:)` — rotation, in full turns.
- `slide_transition(content, begin: { x: 0, y: 1 }, end: { x: 0, y: 0 })` — position, in fractions of the content's own size.
- `size_transition(content, begin: 0, end: 1, axis: "vertical", axis_alignment: 0)` — grows the content along `axis` and clips the part that does not fit yet.

```ruby
page.add(
  row(
    spacing: 24,
    children: [
      scale_transition(icon("notifications", size: 40), begin: 1, end: 1.15, duration: 600, repeat: true, reverse: true),
      rotation_transition(icon("sync", size: 40), curve: "linear", repeat: true),
      slide_transition(text("Saved"), duration: 300, curve: "ease_out")
    ]
  )
)
```

Clips, sizing boxes and pointer wrappers:

- `clip_oval(content)` — clips to the oval that fills the content's box, a circle for a square box. Use it for round avatars.
- `clip_rsuperellipse(content, border_radius:)` — rounded corners with the continuous iOS "squircle" curve. `border_radius` is one number or `{ top_left:, top_right:, bottom_left:, bottom_right: }`.
- `fractionally_sized_box(content, width_factor:, height_factor:, alignment:)` — sizes the content to a fraction of the space its parent offers. A factor you leave out leaves that axis to the content.
- `intrinsic_height(content)` — sizes the content to its own intrinsic height, so a `row` with `vertical_alignment: "stretch"` makes every child as tall as the tallest one.
- `intrinsic_width(content, step_width:, step_height:)` — sizes the content to its own intrinsic width, for example a `column` of buttons as wide as the widest one.
- `ignore_pointer(content, ignoring: true)` — the content ignores taps, which reach whatever lies behind it.
- `absorb_pointer(content, absorbing: true)` — the content swallows taps, and nothing behind it receives them either.

Clips also take `clip_behavior`: `"anti_alias"` (default), `"hard_edge"`,
`"anti_alias_with_save_layer"` or `"none"`.

```ruby
editor = absorb_pointer(
  column(children: [text_field(label: "Title"), text_field(label: "Notes", multiline: true)]),
  absorbing: false
)

page.add(
  column(
    spacing: 16,
    children: [
      row(
        spacing: 16,
        children: [
          clip_oval(image("https://picsum.photos/id/64/96", width: 64, height: 64, fit: "cover")),
          clip_rsuperellipse(container(width: 64, height: 64, bgcolor: :blue_600), border_radius: 16)
        ]
      ),
      intrinsic_height(
        row(
          vertical_alignment: "stretch",
          children: [
            container(padding: 12, bgcolor: :surface_container_high, content: text("Short")),
            container(padding: 12, bgcolor: :surface_container_high, content: text("A longer card\nwith two lines"))
          ]
        )
      ),
      editor,
      fractionally_sized_box(
        filled_button(content: text("Save"), on_click: ->(_event) { page.update(editor, absorbing: true) }),
        width_factor: 0.5
      )
    ]
  )
)
```

## Control methods

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). On 0.0.23 these methods are missing: calling one raises NoMethodError or does nothing.

Some controls take commands from Ruby. Call these methods on a control once
it is on a page; before that they do nothing and return `nil`. Each method
accepts `timeout:` and `on_result:`.

- `focus` — on buttons, icon buttons, dropdowns and text fields. Text fields also have `blur`, which hides the on-screen keyboard.
- `page_view` — `go_to_page(index, duration:, curve:)`, `jump_to_page(index)`, `jump_to(value)`, `next_page(duration:, curve:)` and `previous_page(duration:, curve:)`.
- `tabs` — `move_to(index, duration:, curve:)`.
- `canvas` — `capture(pixel_ratio:)` takes a snapshot of the drawing, `get_capture` passes it to `on_result` as PNG bytes, and `clear_capture` drops it.

```ruby
name = text_field(label: "Name")
steps = page_view([text("Welcome"), text("Choose a plan"), text("Done")], expand: true)

page.add(
  column(
    expand: true,
    children: [
      name,
      steps,
      row(
        children: [
          text_button(content: text("Edit name"), on_click: ->(_event) { name.focus }),
          text_button(content: text("Back"), on_click: ->(_event) { steps.previous_page(duration: 300, curve: "ease_in_out") }),
          text_button(content: text("Next"), on_click: ->(_event) { steps.next_page(duration: 300, curve: "ease_in_out") })
        ]
      )
    ]
  )
)
```

Capture a canvas drawing:

```ruby
status = text(value: "")
sketch = canvas([circle(x: 60, y: 60, radius: 40, paint: paint(color: "#4dabf7", style: "fill"))], width: 120, height: 120)

save = ->(_event) {
  sketch.capture(on_result: ->(_result, error) {
    next page.update(status, value: error.to_s) if error

    sketch.get_capture(on_result: ->(png, _get_error) {
      page.update(status, value: "Captured #{png.to_s.bytesize} bytes")
    })
  })
}

page.add(column(children: [sketch, filled_button(content: text("Capture"), on_click: save), status]))
```

## Input and display options

These options of existing controls are on Ruflet main. Everything else on
those controls works on 0.0.23.

- `text_field(text_input_action:)` — the keyboard's action key, for example `"next"`, `"done"`, `"search"` or `"send"`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `text_field(on_paste_files:)` — the user pasted files into the field. `event.files` lists `Ruflet::Events::PastedFile` values with `name`, `mime_type` and `bytes`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `list_tile(chevron: true)` — draws a trailing chevron, on `list_tile` and `cupertino_list_tile`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `list_tile(focus_color:)` — the Material keyboard-focus highlight. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `search_bar(on_tap_outside_view:)` — the user tapped outside the open search view. `on_tap_outside_bar` stays the event of the closed bar. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `semantics(identifier:)` — a stable ID for accessibility tools and UI tests: the Android resource-id, the iOS accessibilityIdentifier and the web `flt-semantics-identifier`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `app_bar(large: true)` — the Material 3 large app bar. 0.0.23 accepts the keyword, but its Material client ignores it. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

This example uses several of them. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

```ruby
page.appbar = app_bar(title: text("Settings"), large: true)

page.add(
  column(
    children: [
      text_field(label: "Search", text_input_action: "search", on_submit: ->(event) { puts event.data }),
      list_tile(title: text("Account"), chevron: true, focus_color: :blue_100, on_click: ->(_event) {}),
      semantics(text("Signed in"), identifier: "status-label")
    ]
  )
)
```

## Control families

Ruflet includes Material and Cupertino controls, form inputs, navigation
surfaces, lists, tables, charts, maps, media controls, and drawing primitives.
Browse [Controls](/docs/component-reference) for individual properties and
events.
