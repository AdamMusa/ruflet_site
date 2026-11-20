# ERB to Native: Widgets

Every helper on this page emits ERB markup that
`Ruflet::Rails.erb_to_native` transforms into a real native Ruflet widget. Use
widgets in ERB like normal Rails tags. Attributes use snake case in Ruby helper
calls and dashed names in literal tags.

```erb
<%= column class: "p-6 gap-4" do %>
  <%= text "Hello from Rails" %>
  <%= button "Save", on_click: save_path %>
<% end %>
```

Every Ruflet widget is supported. Common widgets have convenient Rails
helpers, and every other widget works as a literal native tag or through
`widget(...)`. The complete widget catalog appears at the bottom of this page.

## Layout

| Helper | Native purpose |
| --- | --- |
| `column`, `row` | Vertical or horizontal flex layout. |
| `stack` | Overlay children. |
| `container`, `section` | Box layout; `section` is a semantic alias in ERB. |
| `card` | Material card containing child content. |
| `center` | Center one child. |
| `list` | Scrollable native list view. |
| `grid` | Scrollable native grid view, or a responsive row with `grid-cols-N`. |
| `spacer` | Expanded empty space in a flex layout. |
| `divider` | Native divider. |

```erb
<%= column class: "p-6 gap-4" do %>
  <%= row class: "gap-3 items-center" do %>
    <%= icon "check_circle", color: "#22c55e" %>
    <%= text "Saved" %>
  <% end %>
  <%= divider %>
<% end %>
```

Give `grid` a `grid-cols-N` class to lay its children out on a 12-column
`responsive_row` instead of a grid view. Each child gets `12 / N` columns,
rounded, and `col-span-N` on a child multiplies its share, up to the full row:

```erb
<%= grid class: "grid-cols-3" do %>
  <%= card do %><%= text "Open" %><% end %>
  <%= card class: "col-span-2" do %><%= text "Revenue this week" %><% end %>
<% end %>
```

Here the first card takes 4 of 12 columns and the second takes 8.

## Utility classes

The `class` attribute takes Tailwind-style utility classes, which Ruflet turns
into properties of the native widget: `p-6` is `padding: 24`, `gap-4` is
`spacing: 16`, `bg-slate-50` is a background color, `text-sm font-bold` sets
the text's size and weight, and `flex-1` on a box, row or column makes it take
the free space. Box classes on a text, column or row wrap it in a container;
most other widgets take the classes whose property they have.

```erb
<%= row class: "gap-3 items-center p-4 bg-white rounded-lg shadow" do %>
  <%= icon "inbox", color: "#475569" %>
  <%= text "Inbox", class: "text-lg font-semibold text-slate-900" %>
<% end %>
```

[Styling Rails Pages](/docs/rails-native-styling#utility-classes-in-erb-to-native-screens)
lists every class, the property it sets, and the classes that have no effect.

## Content

| Helper | Signature and behavior |
| --- | --- |
| `text` | `text(value = nil, **attrs)` renders native text. |
| `markdown` | `markdown(value = nil, **attrs)` renders Markdown. |
| `icon` | `icon(name, **attrs)` renders a Material icon. |
| `image` | `image(src, **attrs)` renders a native image. |
| `heading` | `heading(value = nil, level: 1, **attrs)` selects heading level 1–6. |
| `h1`, `h2`, `h3`, `h4`, `h5`, `h6` | Native text with the matching heading defaults. |

Plain `span`, `p`, and `label` tags are also transformed into native text.
Plain `div`, `article`, `main`, `header`, `footer`, and `aside` tags become
native containers, which makes gradual conversion of conventional ERB easier.

## Actions and navigation

| Helper | Signature and behavior |
| --- | --- |
| `button` | `button(label = nil, **attrs)`; use `on_click:`, `href:`, or `service:`. |
| `link` | `link(label, href, **attrs)` pushes, replaces, resets, or pops a native screen. |
| `appbar` | `appbar(title = nil, **attrs)` declares the screen app bar. |
| `appbar_action` | `appbar_action(icon, href = nil, **attrs)` adds an app-bar action. |
| `fab` | `fab(label = nil, **attrs)` declares the screen floating action button. |
| `bottom_nav` | Declares native bottom navigation. |
| `nav_item` | Adds a destination with `icon:`, `label:`, `href:`, and `selected:`. |

```erb
<%= appbar "Inbox" do %>
  <%= appbar_action "search", search_path %>
<% end %>

<%= bottom_nav do %>
  <%= nav_item icon: "inbox", label: "Inbox", href: inbox_path, selected: true %>
  <%= nav_item icon: "person", label: "Account", href: account_path %>
<% end %>
```

## Material and data-entry widgets

| Helper | Native purpose |
| --- | --- |
| `badge` | Label or notification badge around content. |
| `tooltip` | Native tooltip around its child. |
| `avatar` | Circle avatar with text, image, icon, or child content. |
| `chip` | Material chip with optional selection or delete actions. |
| `progress` | Linear progress bar. |
| `switch`, `checkbox`, `slider`, `radio` | Native selection controls. |
| `list_tile` | Leading/title/subtitle/trailing row with navigation or actions. |
| `expansion_tile` | Expandable native section. |
| `radio_group` | Named native radio group. |
| `segmented_button` | Segments supplied as values or `{ value:, label:, icon: }` hashes. |
| `tabs`, `tab` | Native tabs and their content. |

`textfield` and `text-field` tags are also supported directly for single-line
or multiline native input.

## Forms

| Helper | Signature and behavior |
| --- | --- |
| `form` | `form(action:, method: "post", **attrs)` collects its named fields. |
| `input` | `input(name = nil, **attrs)` supports text, checkbox, range, radio, submit, and hidden types. |
| `textarea` | `textarea(name = nil, value = nil, **attrs)` renders multiline input. |
| `dropdown` | `dropdown(name = nil, options: [], value: nil, **attrs)` renders native selection. |
| `submit` | `submit(label = "Submit", **attrs)` submits the enclosing form. |

Conventional `select`, `option`, `ul`, `ol`, and table markup (`table`,
`thead`, `tbody`, `tfoot`, `tr`, `th`, `td`) is transformed into the matching
native controls as well.

## Extensions use normal ERB tags

Extensions are not a different Rails API. Call an extension with its normal
ERB helper just like any other widget, and Ruflet renders it natively. The
matching extension only needs to be declared in the Rails Ruflet configuration
so its package is included in the client build.

```erb
<%= lottie src: asset_url("loading.json"), width: 160, height: 160 %>
<%= video playlist: [{ resource: video_url(@lesson) }], expand: true %>
<%= camera id: "profile-camera", preview_enabled: true, expand: true %>
```

An extension does not need to be built into Ruflet's catalog. Point the Rails
configuration at its public or private Git repository, then use its wire type
as a normal ERB tag. See
[Private and external extensions](/docs/extensions#use-an-extension-ruflet-does-not-bundle).

| Family | Helpers |
| --- | --- |
| Media and animation | `video`, `lottie`, `rive`, `spinkit` |
| Editing and web | `code_editor`, `web_view`, `color_picker` |
| Device view | `camera` |
| Map | `map` |
| Charts | `bar_chart`, `line_chart`, `pie_chart`, `scatter_chart`, `candlestick_chart`, `radar_chart` |

## Compound extension children

Map helpers are `tile_layer`, `marker_layer`, `marker`, `circle_layer`,
`circle_marker`, `polyline_layer`, `polyline_marker`, `polygon_layer`,
`polygon_marker`, and `simple_attribution`.

Chart data helpers are `bar_chart_group`, `bar_chart_rod`,
`bar_chart_rod_stack_item`, `line_chart_data`, `line_chart_data_point`,
`pie_chart_section`, `candlestick_chart_spot`, `scatter_chart_spot`,
`radar_dataset`, `radar_dataset_entry`, `radar_chart_title`, `chart_axis`, and
`chart_axis_label`.

```erb
<%= map expand: true do %>
  <%= tile_layer url_template: "https://tile.openstreetmap.org/{z}/{x}/{y}.png" %>
  <%= marker_layer do %>
    <%= marker coordinates: { latitude: 40.7128, longitude: -74.0060 } do %>
      <%= icon "location_on", color: "#ef4444" %>
    <% end %>
  <% end %>
<% end %>
```

## Every Ruflet widget works as a tag

Named helpers cover common Rails UI and extension families. For every other
widget, write its Ruflet name as a normal tag:

```erb
<progress-ring value="0.65" width="48" height="48"></progress-ring>
<date-picker value="<%= @task.due_on&.iso8601 %>"></date-picker>
```

If Ruby composition is more convenient, `widget` reaches the same complete
widget registry:

```erb
<%= widget "progress-ring", value: 0.65, width: 48, height: 48 %>
<%= widget "date-picker", value: @task.due_on&.iso8601 %>
```

Unknown tags are looked up in the core control registry and built with their
real schema. Browse every supported widget directly below; each card opens its
properties, events, methods, and Ruby examples.

Widgets added after 0.0.23, such as `<stepper>`, `<carousel-view>`, and
`<indexed-stack>`, also work as tags and helpers. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

Continue with [ERB-to-native Services](/docs/rails-native-services) or return
to the [ERB-to-native overview](/docs/rails-erb-to-native).
