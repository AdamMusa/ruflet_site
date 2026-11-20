# Styling Rails Pages

How you style a Rails screen depends on how Ruflet shows it. Pages displayed
by `Ruflet::Rails.native_shell` stay HTML inside a WebView, so CSS styles them.
Screens rendered with `Ruflet::Rails.erb_to_native` become native controls,
and Ruflet reads their `class` attribute as Tailwind-style utility classes.

## Pages in the native shell

Style native-shell pages with the same CSS, asset pipeline, import maps,
JavaScript, and responsive techniques used by the browser version of the Rails
application.

- Keep body content responsive because the native shell can add an app bar,
  drawer, navigation rail, or bottom navigation around it.
- Use normal Rails asset helpers for stylesheets and images.
- Avoid duplicating visible HTML navigation that is also promoted to native
  chrome. Ruflet view helpers mark promoted elements as hidden.
- Test safe areas, keyboard resizing, text scaling, and narrow device widths.
- Use reachable absolute URLs for resources loaded outside the WebView.

```erb
<main class="account-page">
  <h1>Account</h1>
  <%= image_tag "profile-placeholder.png", alt: "" %>
  <%= form_with model: @account do |form| %>
    <%= form.email_field :email %>
    <%= form.submit "Save" %>
  <% end %>
</main>
```

In the native shell, classes stay CSS: Ruflet does not turn them into native
control properties. If the screen must be a native control tree, render it
with [ERB to Native](/docs/rails-erb-to-native) or build it with Ruflet's Ruby
control helpers.

## Utility classes in ERB-to-native screens

In an ERB-to-native screen, Ruflet reads each element's `class` list and turns
the utility classes it knows into properties of the native control. Classes it
does not know are ignored, so a template shared with the browser keeps working.
There is no stylesheet and no cascade: a class styles only the element it is
written on.

```erb
<%= column class: "p-6 gap-4 bg-slate-50 rounded-xl shadow-md" do %>
  <%= text "Revenue", class: "text-sm font-medium text-slate-500 uppercase tracking-wide" %>
  <%= text "$48,200", class: "text-3xl font-bold text-slate-900" %>
  <%= row class: "gap-2 items-center" do %>
    <%= icon "trending_up", color: "#16a34a" %>
    <%= text "12% this week", class: "text-green-600" %>
  <% end %>
<% end %>
```

Here the column becomes a Container with `padding: 24`, `bgcolor: "#f8fafc"`,
`border_radius: 12` and a shadow, holding a Column with `spacing: 16`. The
first text becomes `Text(value: "REVENUE", size: 14, weight: "w500",
color: "#64748b")` with a letter spacing of 0.4.

### Where a class lands

- **Text**: `text`, `span`, `p`, `label` and `h1` to `h6` take the typography classes. Box classes wrap the text in a Container. `flex-1` and the other classes that set `expand` apply to that Container, so without a box class they do nothing to a text.
- **Boxes**: `div`, `section`, `article`, `main`, `header`, `footer`, `aside` and `container` become a Container that takes the box classes. With more than one child, the children sit in a Column that takes the layout classes.
- **Flex**: `column` and `row` take the layout classes. Box classes wrap them in a Container. `form` works the same way as a `column`, and `ul` and `ol` take only the layout classes.
- **Images**: `img` and `image` take only the size, corner, `object-*`, opacity, aspect ratio, rotation and scale classes.
- **Cards**: `card` takes only `p-*`, the padding inside the card (16 by default), and the layout classes for its children.
- **Links**: an `a` with only text takes the typography classes except letter spacing, line height, decoration and case. An `a` around other elements wraps them in a box with its box classes.
- **Other widgets**: `button`, `input`, `textarea`, `text-field`, `select`, `list`, `grid`, `stack`, `list-tile` and the widget tags without a helper of their own (such as `<progress-ring>`) take each class whose property the widget has. For example, `list` takes `p-*`, `gap-*` and `flex-1`.
- **No classes**: `avatar` takes only `bg-*` and a `text-*` color for its initials. `icon`, `markdown`, `divider`, `progress`, `switch`, `checkbox`, `slider`, `chip`, `badge` and `tooltip` take none; put them in a `div` to style the box around them.

A property that reaches a control still renders the way that control renders
it on each platform. On a `button`, for instance, the classes become the
Button's own `bgcolor`, `color`, `padding` and `border_radius`. The iOS and
macOS button draws them, but the Material button on Android, the web, Windows
and Linux takes those from `style` and ignores them. Use `variant="filled"`
for a button in the theme's colors on every platform.

### Lengths and colors

Lengths follow Tailwind's spacing scale: a step is 4 logical pixels, so `p-4`
is 16 and `w-2.5` is 10, and `px` (as in `p-px`) is 1. An arbitrary value in
brackets may be `[7px]` or `[40]` (pixels), `[1.5rem]` or `[1.5em]` (16 pixels
each) or `[12pt]`. Percentages, `vw` and `ch` are ignored.

Colors are the Tailwind v3 palette: `slate`, `gray`, `zinc`, `neutral`,
`stone`, `red`, `orange`, `amber`, `yellow`, `lime`, `green`, `emerald`,
`teal`, `cyan`, `sky`, `blue`, `indigo`, `violet`, `purple`, `fuchsia`,
`pink` and `rose`, in shades `50` to `900`; a bare family such as `blue` is
`500`. `white`, `black` and `transparent` work too, and so do the theme colors
`primary`, `on-primary`, `primary-container`, `on-primary-container`,
`secondary`, `on-secondary`, `secondary-container`, `on-secondary-container`,
`tertiary`, `on-tertiary`, `error`, `on-error`, `surface`, `on-surface`,
`surface-variant`, `on-surface-variant`, `inverse-surface` and `outline`,
which follow the app theme. A hex value works directly (`bg-#0f172a`) or in
brackets: `bg-[#0f172a]`, `bg-[#fff]`, `text-[rgb(15_23_42)]` or
`border-[rgba(0,0,0,0.5)]`. Other notations, such as `hsl()`, are ignored.
A `/NN` suffix sets the opacity in percent: `bg-blue-500/50`.

### Spacing

| Class | Property | Notes |
| --- | --- | --- |
| `p-N`, `px-N`, `py-N`, `pt-N`, `pr-N`, `pb-N`, `pl-N` | `padding` | Box. |
| `m-N`, `mx-N`, `my-N`, `mt-N`, `mr-N`, `mb-N`, `ml-N`, `-m-N` | `margin` | Box. A leading `-` makes the margin negative. |
| `mx-auto`, `m-auto` | `alignment` | Box. Centers the box's content. |
| `gap-N` | `spacing` and `run_spacing` | Layout. The gap between children, and between rows when they wrap. |
| `gap-x-N`, `space-x-N` | `spacing` | Layout. The gap between children along the layout's own direction, in a column too. |
| `gap-y-N`, `space-y-N` | `run_spacing` | Layout. Only the gap between wrapped runs: in a column that does not wrap it has no effect. Use `gap-N`. |

### Size and flex

| Class | Property | Notes |
| --- | --- | --- |
| `w-N`, `h-N`, `size-N` | `width`, `height` | Box. `size-N` sets both. |
| `w-full`, `h-full`, `w-screen`, `h-screen`, `min-h-screen`, `min-w-full`, `size-full`, `flex-1`, `flex-auto`, `grow`, `expand`, `basis-full` | `expand: true` | Takes the free space of the parent row or column. |
| `w-1/3`, `basis-2/3` and other fractions | `expand: <numerator>` | A flex factor: siblings `w-1/3` and `w-2/3` share the space 1 to 2. |
| `shrink-0`, `flex-none`, `flex-initial`, `grow-0`, `basis-auto` | `expand: false` | Keeps the natural size. |
| `basis-N` | `width` | |
| `aspect-square`, `aspect-video`, `aspect-[4/3]`, `aspect-3/2` | `aspect_ratio` | Box. |

### Layout and alignment

| Class | Property | Notes |
| --- | --- | --- |
| `justify-start`, `-center`, `-end`, `-between`, `-around`, `-evenly` | `alignment` | Layout, along the main axis. |
| `items-start`, `-center`, `-end`, `-stretch`, `-baseline` | `horizontal_alignment` in a column, `vertical_alignment` in a row | Layout. |
| `items-center justify-center` together | `alignment: { x: 0, y: 0 }` | Box. Also centers the box's content. |
| `wrap`, `flex-wrap` | `wrap` | Layout. |
| `scroll`, `overflow-auto`, `overflow-y-auto`, `overflow-scroll` | `scroll: "auto"` | Layout. |
| `self-start`, `-center`, `-end`, `place-self-*`, `justify-self-*` | `align` | Box. Places the element inside its parent. |
| `place-center`, `grid-center`, `place-items-*`, `place-content-*` (`start`, `center` or `end`) | `alignment` | Box. Places the box's content. |
| `top-N`, `right-N`, `bottom-N`, `left-N`, `inset-N`, `inset-x-N`, `inset-y-N` | `top`, `right`, `bottom`, `left` | Box. For children of a `stack`. A leading `-` makes the offset negative. |

### Typography

| Class | Property | Notes |
| --- | --- | --- |
| `text-xs`, `-sm`, `-base`, `-lg`, `-xl` to `-9xl`, `text-[13px]` | `size` | Text. 12, 14, 16, 18, 20, 24, 30, 36, 48, 60, 72, 96 and 128. |
| `text-<color>` | `color` | Text. `text-opacity-N` sets its opacity. |
| `text-left`, `-center`, `-right`, `-justify` | `text_align` | Text. |
| `font-thin` to `font-black` | `weight` | Text. `thin` is `w100`, `normal` and `bold` are themselves, the rest are `w200` to `w900`. |
| `font-mono`, `font-serif`, `font-sans`, `font-[Inter]` | `font_family` | Text. `font-['Fira_Code']` is `Fira Code`. |
| `italic`, `not-italic` | `italic` | Text. |
| `tracking-tighter` to `tracking-widest`, `tracking-[2px]` | letter spacing | Text, in its `style`. -0.8 to 1.6. |
| `leading-none` to `leading-loose`, `leading-[1.8]` | line height | Text, in its `style`, as a multiple of the font size (1.0 to 2.0). |
| `underline`, `overline`, `line-through`, `no-underline` | decoration | Text, in its `style`. They combine. |
| `uppercase`, `lowercase`, `capitalize` | | Text. Ruflet changes the text itself. |
| `truncate` | `max_lines: 1`, `overflow: "ellipsis"` | Text. |
| `line-clamp-N`, `line-clamp-none` | `max_lines` | Text. With `overflow: "ellipsis"`. |
| `text-ellipsis`, `text-clip` | `overflow` | Text. |
| `whitespace-nowrap`, `break-keep` | `no_wrap: true` | Text. |
| `whitespace-normal`, `break-words`, `break-normal`, `break-all` | `no_wrap: false` | Text. |
| `select-text`, `select-all`, `select-none` | `selectable` | Text. |

Typography classes on a box are not inherited by the text inside it; put them
on the text.

### Backgrounds

| Class | Property | Notes |
| --- | --- | --- |
| `bg-<color>` | `bgcolor` | Box. `bg-opacity-N` sets its opacity. |
| `bg-gradient-to-r`, `-l`, `-t`, `-b`, `-tr`, `-tl`, `-br`, `-bl` with `from-<color>`, `via-<color>`, `to-<color>` | `gradient` | Box. A linear gradient; it needs at least two of the color stops and runs top to bottom without a direction. |
| `mix-blend-<mode>`, `bg-blend-<mode>` | `blend_mode` | Box. Tailwind's blend modes; `normal` is Flutter's `srcOver` and `plus-lighter` is `plus`. |

### Borders and corners

| Class | Property | Notes |
| --- | --- | --- |
| `rounded`, `rounded-sm` to `rounded-3xl`, `rounded-full`, `rounded-none`, `rounded-N`, `rounded-[10px]` | `border_radius` | Box. 4 for `rounded`, then 2, 6, 8, 12, 16 and 24; `full` is 9999. |
| `rounded-t-*`, `-r-*`, `-b-*`, `-l-*`, `-tl-*`, `-tr-*`, `-bl-*`, `-br-*` | `border_radius` | Box. The named corners only. |
| `border`, `border-N` | `border` | Box. 1 pixel, or N, in `#e2e8f0` unless a color is set. |
| `border-t`, `-r`, `-b`, `-l`, `-x`, `-y`, with an optional width | `border` | Box. The named sides. One width applies to every side set. |
| `border-<color>` | `border` | Box. |
| `ring`, `ring-N`, `ring-<color>`, `outline`, `outline-N`, `outline-<color>` | `border` | Box. A ring is 3 pixels and an outline 1 by default; both draw the border. |

### Effects and transforms

| Class | Property | Notes |
| --- | --- | --- |
| `shadow`, `shadow-sm` to `shadow-2xl`, `drop-shadow`, `drop-shadow-sm` to `drop-shadow-2xl` | `shadow` | Box. `shadow-<color>` tints it, for example `shadow-indigo-500/40`. `shadow-none` adds none. |
| `opacity-N` | `opacity` | Box. N percent. |
| `blur`, `blur-sm` to `blur-3xl`, `blur-[6px]`, `backdrop-blur-*` | `blur` | Box. Blurs what shows through the box. |
| `rotate-N`, `-rotate-N`, `rotate-[30deg]` | `rotate` | Box. N is 0, 1, 2, 3, 6, 12, 45, 90 or 180 degrees. |
| `scale-N` | `scale` | Box. N is 0, 50, 75, 90, 95, 100, 105, 110, 125 or 150. |
| `translate-x-1/2`, `-translate-y-full` and other fractions | `offset` | Box. A fraction of the element's own size. |
| `hidden`, `invisible`, `visible` | `visible` | Box. A hidden element takes no space. |
| `overflow-hidden`, `overflow-clip` | `clip_behavior: "hardEdge"` | Box. |
| `object-contain`, `-cover`, `-fill`, `-none`, `-scale-down` | `fit` | Images. |
| `cursor-pointer` and the other cursors | `mouse_cursor` | Widgets that have `mouse_cursor`, such as `input`, `list-tile`, `gesture-detector` and `button`. Each renderer decides whether it applies it: the iOS and macOS button does, but the Material button on Android, the web, Windows and Linux takes its cursor from `style` and ignores it. |

### Transitions

`transition`, `transition-all`, `transition-colors` and `transition-shadow`
animate every change of the box (`animate`). `transition-opacity` animates only
its opacity, and `transition-transform` its offset, scale and rotation.
`duration-N` sets the length in milliseconds (150 by default) and `ease-linear`,
`ease-in`, `ease-out` or `ease-in-out` the curve. `transition-none` turns
animation off.

```erb
<div class="opacity-50 transition-opacity duration-300 ease-in-out">
  <%= text "Fades when its opacity changes" %>
</div>
```

### Classes that have no effect

These classes are read in 0.0.23 and on `main` but do not reach a control:

- `flex-row`, `flex-col` and their `-reverse` forms: a box always lays out its children as a column. Use `row` or `column`.
- `content-*`, `w-fit`, `h-fit`, `size-fit`, and the `min-*` and `max-*` sizes. `max-w-*` on text sends the Text a `max_width`, but no renderer reads it.
- `leading-N` with a spacing-scale value; use `leading-tight` or `leading-[1.5]`.
- `text-wrap` and `text-nowrap`; use `whitespace-normal` and `whitespace-nowrap`.
- `border-none`, `border-hidden`, `ring-0`, `outline-0` and `border-opacity-N`: they do not remove or fade a border set by another class.
- `border-s` and `border-e` draw all four sides, and the logical corners `rounded-s-*`, `rounded-e-*`, `rounded-ss-*`, `rounded-se-*`, `rounded-es-*` and `rounded-ee-*` set no corner.
- `cursor-*` and `pointer-events-*` on boxes and text, `translate-*` with a spacing-scale value, and `rotate-N` or `scale-N` values outside the lists above.
- On images, the box classes other than those listed above; on cards, every class except `p-*` and the layout classes.

See [Native Shell](/docs/rails-native-shell) for shell annotations,
[ERB to Native: Widgets](/docs/rails-native-components) for the tags and
helpers, and [Rails Assets and URLs](/docs/rails-assets) for client-reachable
assets.
