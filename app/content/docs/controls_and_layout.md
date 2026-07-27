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

## Text styling

Pass text styles as a Ruby hash on `style:`:

```ruby
text(value: "Dashboard", style: { size: 28, weight: "w700" })
```

This is the normal Ruflet application API: call the DSL helper and pass a
plain Ruby hash.

## Sizing

- `expand: true` fills available space along the parent's main axis.
- `width` and `height` request fixed dimensions.
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

## Control families

Ruflet includes Material and Cupertino controls, form inputs, navigation
surfaces, lists, tables, charts, maps, media controls, and drawing primitives.
Browse [Controls](/docs/component-reference) for individual properties and
events.
