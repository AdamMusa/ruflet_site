# API Reference

Use the reference pages after you understand the basic Ruflet application
model.

## Controls (components and widgets)

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
  border: { color: :blue_grey_200, width: 1 },
  content: text(value: "Named colors", style: { color: :deep_orange_500 })
)

filled_button(
  "Save",
  bgcolor: :deep_orange_500,
  color: "#ffffff"
)
```

Use named colors for Material/theme colors and hex for exact brand values.
Use Ruby-style symbols such as `:deep_orange_500`, `:blue_grey_200`, and
`:surface_container_high` for named colors. Hex values can use `#rrggbb`,
`#aarrggbb`, `0xrrggbb`, or `0xaarrggbb`; append `,0.5` to apply opacity.

## Services

- [Services and Device APIs](/docs/services-and-plugins) covers page convenience
  methods, persistent service objects, and protected device access.

## Extensions

- [Extension Catalog](/docs/extensions) lists optional Flutter packages and the
  Ruby controls or services they provide.
- [QRCodeScanner](/docs/qrcode-scanner) documents the first-party scanner
  extension.
- [Extension Authoring](/docs/extension-authoring) explains the standard Flet
  package contract used by Ruflet.

## Runtime and tooling

- [Events and State](/docs/events-and-state) documents event payloads and control updates.
- [CLI Reference](/docs/cli-reference) covers every project, run, build, update, install, and tooling option.
- [Configuration](/docs/configuration-reference) documents `ruflet.yaml`, `services.yaml`, extensions, and environment overrides.
- [App Structure](/docs/app-structure) explains how generated files fit together.

Rails documentation, including the complete [Rails API](/docs/rails-api-reference),
is grouped under **Integrations**.
