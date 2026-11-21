# API Reference

Use the reference pages after you understand the basic Ruflet application
model.

## Controls (components and widgets)

- [Controls](/docs/component-reference) lists controls and dedicated reference pages.
- [Controls and Layout](/docs/controls-and-layout) explains composition and sizing.
- [Navigation and Feedback](/docs/navigation-feedback) covers views, routes, dialogs, sheets, and snackbars.
- [Charts and Canvas](/docs/charts-and-canvas) documents chart and drawing helpers.
- [Maps](/docs/maps) documents map controls and layers.

## Page, events and theming

- [Page, View and Window](/docs/page-reference) lists every page property, event and method, the View keywords, and the desktop window.
- [Events and State](/docs/events-and-state) documents event payloads, payload classes and control updates.
- [Theming](/docs/theming) covers `page.theme`, dark mode, fonts and per-container themes.

## Color Values

Every color property, including `color`, `bgcolor`, `border_color`,
`icon_color`, `shadow_color`, gradient `colors`, and theme color fields,
accepts named colors or hex strings.

```ruby
container(
  bgcolor: :surfacecontainerhigh,
  border: { color: :bluegrey200, width: 1 },
  content: text(value: "Named colors", style: { color: :deeporange500 })
)

filled_button(
  "Save",
  style: { bgcolor: :deeporange500, color: "#ffffff" }
)
```

Set button colors in `style:`. Material buttons ignore a top-level `bgcolor:`
or `color:` when no `style:` is given.

Use named colors for Material/theme colors and hex for exact brand values.
Write a named color as a symbol in the client's spelling, without
underscores: a Material color and shade such as `:deeporange500`,
`:bluegrey200`, `:red` or `:white70`, or a role of the current theme such as
`:primary`, `:onsurface` or `:surfacecontainerhigh`. A name with underscores,
such as `:deep_orange_500`, matches no color on 0.0.23 or on `main`, and the
client draws the default color instead. The `Ruflet::Colors` constants hold the
client spelling: `Ruflet::Colors::DEEP_ORANGE_500` is `"deeporange500"`.
Hex values can use `#rrggbb`, `#aarrggbb`, `0xrrggbb`, or `0xaarrggbb`; append
`,0.5` to apply opacity.

## Value types and constants

Ruflet defines a few Ruby types and constant modules for property values. Every
one of them also has a plain form (a Hash, a String or a number), which is what
the client receives.

- `Ruflet::TextStyle.new(size:, height:, weight:, italic:, decoration:, decoration_color:, decoration_thickness:, decoration_style:, font_family:, font_family_fallback:, color:, bgcolor:, shadow:, foreground:, letter_spacing:, word_spacing:, overflow:, baseline:)` — a text style for `style:` and theme `text_theme` entries; `copy(**overrides)` returns a changed copy and `to_h` the Hash form. The clients do not read `baseline:`; to set the baseline, pass a style Hash with `text_baseline:`. The 0.0.23 client also ignores `font_family_fallback:`; the client on `main` reads it. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `Ruflet::StrutStyle.new(size:, height:, weight:, italic:, font_family:, leading:, force_strut_height:)` — line-height settings for the `strut_style:` of a `text_field` or `cupertino_text_field`, with `copy` and `to_h`.
- `Ruflet::Offset.new(x:, y:)` — a point or offset; `to_h` gives `{ "x" => x, "y" => y }`. Gesture events return positions as `Ruflet::Offset`.
- `Ruflet::Duration.new(milliseconds:)` — a length of time with `milliseconds` and `to_h`. Duration properties also take a number of milliseconds, or `duration(seconds: 1, milliseconds: 500)` from the DSL.
- `Ruflet::IconData.new(name)` — an icon by name; `value` is the name. Icon properties take it or a plain String. The `Ruflet::Icons` constants are plain Strings: `Ruflet::Icons::HOME` is `"home"`.
- `Ruflet::WidgetBuilder` — the object a DSL block runs in; you rarely create one.

Constants for String-valued properties:

- `Ruflet::MainAxisAlignment` — `START`, `CENTER`, `FINISH` (`"end"`), `SPACE_BETWEEN`, `SPACE_AROUND` and `SPACE_EVENLY`.
- `Ruflet::CrossAxisAlignment` — `START`, `CENTER`, `FINISH` and `STRETCH`.
- `Ruflet::TextAlign` — `LEFT`, `RIGHT`, `CENTER`, `JUSTIFY`, `START` and `FINISH`.
- `Ruflet::TextOverflow` — `CLIP`, `ELLIPSIS`, `FADE` and `VISIBLE`.
- `Ruflet::TextBaseline` — `ALPHABETIC` and `IDEOGRAPHIC`.
- `Ruflet::TextThemeStyle` — the text theme roles, `DISPLAY_LARGE` to `BODY_SMALL`, as the client's names such as `"titleLarge"`.
- `Ruflet::TextDecoration` — `NONE`, `UNDERLINE`, `OVERLINE` and `LINE_THROUGH`, which are bit flags: `Ruflet::TextDecoration.combine([Ruflet::TextDecoration::UNDERLINE, Ruflet::TextDecoration::OVERLINE])`.
- `Ruflet::TextDecorationStyle` — `SOLID`, `DOUBLE`, `DOTTED`, `DASHED` and `WAVY`.

`Ruflet::UI::Types` is a second name for five of these modules and four of the
types: `Ruflet::UI::Types::TextBaseline` is `Ruflet::TextBaseline`, and the same
goes for `TextDecoration`, `TextDecorationStyle`, `TextOverflow`,
`TextThemeStyle`, `TextStyle`, `StrutStyle`, `Offset` and `Duration`.
`MainAxisAlignment`, `CrossAxisAlignment` and `TextAlign` exist only under
`Ruflet::`.

```ruby
heading = Ruflet::TextStyle.new(size: 24, weight: "bold", color: :indigo700)

page.add(
  column(
    horizontal_alignment: Ruflet::CrossAxisAlignment::CENTER,
    children: [
      text("Ruflet", style: heading, text_align: Ruflet::TextAlign::CENTER),
      text("A long subtitle that may not fit", style: heading.copy(size: 14, overflow: Ruflet::TextOverflow::ELLIPSIS)),
      icon(Ruflet::Icons::HOME)
    ]
  )
)
```

### Icons and colors

- `Ruflet::Icons::HOME` and the other constants name Material icons first, then Cupertino ones. `Ruflet::Icons.material` and `Ruflet::Icons.cupertino` limit the lookup to one set: `Ruflet::Icons.cupertino[:house_fill]`, `.names`, `.all` and `.random`. `icon("home")` with a String name works too.
- `Ruflet::Colors` holds the Material color names (`RED`, `RED_100` to `RED_900`, the `*_ACCENT` shades, `WHITE70`, `BLACK54` and so on) and the theme roles (`PRIMARY`, `ON_SURFACE` and so on), each as the client's spelling, such as `"red900"`.

## DSL entry points

- `Ruflet.run(entrypoint = nil, host: "0.0.0.0", port: nil) { |page| ... }` — starts the server and calls the block, or `entrypoint` (any object with `call`, such as a lambda), with the `page` of each connected client. It raises ArgumentError without either. `port` is resolved by `Ruflet.resolved_run_port`; `host` does not read `RUFLET_HOST`.
- `Ruflet.resolved_run_port(port)` — the port `Ruflet.run` listens on: `port`, else the `RUFLET_PORT` environment variable, else 8550. A negative or blank value gives 8550, and a value that does not start with digits, such as `"abc"`, gives 0, so the server takes any free port.
- `Ruflet.with_run_interceptor(interceptor) { ... }` — while the block runs, `Ruflet.run` calls `interceptor.call(entrypoint:, host:, port:)` instead of starting a server and returns what it returns. An interceptor that returns `:pass` lets `Ruflet.run` start the server as usual. The innermost interceptor wins. Hot reload and the Rails mobile loader use it to capture an app's entrypoint.
- `Ruflet.app(host: nil, port: nil) { ... }` / `Ruflet::DSL.app` — builds an app from DSL calls; call `.run` on it. `host` defaults to `Ruflet::DSL.default_host` (`RUFLET_HOST`, or `"0.0.0.0"` when it is blank), and `port` to `Ruflet::DSL.default_port` (`RUFLET_PORT`, read as `Ruflet.resolved_run_port` reads it).
- Inside the block, `page(**props) { ... }` sets page properties and builds the controls, `service(type, **props)` declares a service, and the control helpers add controls.
- The returned app answers `host`, `port` and `page_props` (the page properties it will send, a Hash with String keys that starts as `{ "route" => "/" }`), `set_endpoint!(host:, port:)`, which changes the host and port before `run`, and `run`, which starts the server and gives every client the page properties, the services and the controls.

```ruby
require "ruflet"

app = Ruflet.app(port: 8550) do
  page(title: "Counter", theme_mode: "light") do
    text("Hello")
  end
end

puts "Serving on #{app.host}:#{app.port} with #{app.page_props.keys.inspect}"
app.run
```

`page(...)`, `service(...)` and the control helpers also work at the top level
of a script, outside any block. They collect into a pending app, and the next
`app(host:, port:)` call without a block returns that app with its endpoint
set:

```ruby
require "ruflet"

page(title: "Notes") do
  text("Top-level DSL")
end

app(port: 8551).run
```

### DSL helpers

These helpers work in a DSL block, at the top level, and in `Ruflet.run`:

- `control(type, **props) { ... }` / `widget(type, **props) { ... }` — builds a control by its type name, such as `control(:text, value: "Hi")`. Use it for an extension control that has no helper.
- `duration(days:, hours:, minutes:, seconds:, milliseconds:, microseconds:)` — the total as an Integer number of milliseconds, for duration properties: `duration(seconds: 1, milliseconds: 500)` is `1500`. `Ruflet::DSL.duration_in_milliseconds(parts)` does the same with a Hash. Each part is a number or a numeric String such as `"2"` or `"1.5"`, so `duration(seconds: 1.5)` is `1500`; any other value counts as 0. The total is rounded to whole milliseconds.
- `pagelet(content, **props)` — a page-like area inside the page, with its own `appbar`, `navigation_bar` or `bottom_appbar`, `drawer`, `end_drawer`, `bottom_sheet`, `floating_action_button` and `floating_action_button_location`, and `bgcolor`. It needs `content`, and a `height:` or a parent that bounds its height, such as `expand: true` in a column; otherwise the client shows "height is unbounded". iOS and macOS draw it with Cupertino widgets.
- `window(**props)` — a `Window` control. Ruflet creates the one the client draws, `page.window`; see [Window](/docs/page-reference#window).
- `base_page(**props)` / `basepage`, `service_registry(services, **props)` / `serviceregistry`, `dialogs(controls, **props)` and `map_layer(**props)` / `maplayer` — the base and container controls Ruflet uses itself. No client draws a `BasePage` or a bare `MapLayer`, and the page already holds its own service registry and dialogs. Use `page`, `page.add_service`, `page.show_dialog` and the [map layer helpers](/docs/maps) instead.
- `Ruflet::DSL.default_host` and `Ruflet::DSL.default_port` — the host and port `app` uses when you pass none.

`animation(duration, curve: nil)` builds the value of an `animate_*:`
property, `{ "duration" => 300, "curve" => "easeIn" }`, and takes duration parts
too: `animation(seconds: 1)`. `animation_style(duration:, reverse_duration:,
curve:, reverse_curve:)` builds the value of an `animation_style:` property.
Both raise ArgumentError for a negative duration or an unknown keyword. **Requires the next Ruflet release** (on `main`, not in 0.0.23). On 0.0.23 both raise NameError; write the Hash instead, such as `animate_opacity: { duration: 300, curve: "easeIn" }`.

```ruby
note = pagelet(
  container(content: text("Three new messages"), padding: 16),
  height: 320,
  appbar: app_bar(title: text("Inbox")),
  floating_action_button: floating_action_button(icon: "edit"),
  bgcolor: :surfacecontainerlow
)

page.add(column(children: [text("Pagelet below"), note]))
```

## Services

- [Services and Device APIs](/docs/services-and-plugins) covers page convenience
  methods, persistent service objects, and protected device access.

## Extensions

- [Extension Catalog](/docs/extensions) lists optional Flutter packages and the
  Ruby controls or services they provide.
- [QRCodeScanner](/docs/qrcode-scanner) documents the first-party scanner
  extension.
- [Extension Authoring](/docs/extension-authoring) explains how a Ruby control
  and a Flutter package that extends `RufletExtension` fit together.

## Runtime and tooling

- [CLI Reference](/docs/cli-reference) covers every project, run, build, update, install, and tooling option.
- [Configuration](/docs/configuration-reference) documents `ruflet.yaml`, `services.yaml`, extensions, and environment overrides.
- [App Structure](/docs/app-structure) explains how generated files fit together.

Rails documentation, including the complete [Rails API](/docs/rails-api-reference),
is grouped under **Integrations**.
