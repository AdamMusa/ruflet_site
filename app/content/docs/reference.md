# API Reference

Use the reference pages after you understand the basic Ruflet application
model.

## UI

- [Controls](/docs/component-reference) lists controls and dedicated reference pages.
- [Controls and Layout](/docs/controls-and-layout) explains composition and sizing.
- [Navigation and Feedback](/docs/navigation-feedback) covers views, routes, dialogs, sheets, and snackbars.
- [Charts and Canvas](/docs/charts-and-canvas) documents chart and drawing helpers.
- [Maps](/docs/maps) documents map controls and layers.

## Color Values

Every color property, including `color`, `bgcolor`, `border_color`,
`icon_color`, `shadow_color`, gradient `colors`, and theme color fields,
accepts named colors or hex strings.

```ruby
container(
  bgcolor: :surface_container_high,
  border: { color: "Blue Grey 200", width: 1 },
  content: text("Named colors", color: "DeepOrange500")
)

filled_button(
  "Save",
  bgcolor: :deep_orange_500,
  color: "#ffffff"
)
```

Use named colors for Material/theme colors and hex for exact brand values.
Ruflet accepts Ruby-style symbols such as `:deep_orange_500`, compact strings
such as `"DeepOrange500"`, spaced names such as `"Deep Orange 500"`, and
hyphenated names such as `"deep-orange-500"`. Hex values can use `#rrggbb`,
`#aarrggbb`, `0xrrggbb`, or `0xaarrggbb`; append `,0.5` to apply opacity.

## Runtime and tooling

- [Services and Device APIs](/docs/services-and-plugins) covers client services, permissions, and extensions.
- [CLI Workflow](/docs/cli-workflow) covers project, run, build, update, and install commands.
- [App Structure](/docs/app-structure) explains generated files and configuration.
