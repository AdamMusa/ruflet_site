# Controls and Layout

Ruflet already exposes a broad Flutter-style control surface. The current generated Ruflet-layer index contains 159 discovered controls, spanning layout, forms, navigation, charts, media, and platform-aware UI.

## Core layout

These are the controls you will use in almost every app:

- `column`
- `row`
- `container`
- `stack`
- `responsive_row`
- `grid_view`
- `list_view`
- `safe_area`
- `card`
- `center`
- `view`
- `pagelet`

These controls are enough to build:

- dashboards
- settings screens
- forms
- split-view layouts
- mobile-first stacked flows

## Text and imagery

Common presentation controls include:

- `text`
- `text_span`
- `icon`
- `image`
- `circle_avatar`
- `tooltip`
- `markdown`

## Buttons and actions

Ruflet supports several action styles:

- `button`
- `elevated_button`
- `filled_button`
- `filled_tonal_button`
- `outlined_button`
- `text_button`
- `icon_button`
- `floating_action_button`
- `popup_menu_button`
- `menu_bar`
- `menu_item_button`

There is also good Cupertino coverage for adaptive interfaces:

- `cupertino_button`
- `cupertino_filled_button`
- `cupertino_tinted_button`

## Forms and input

Current form-friendly controls include:

- `text_field`
- `cupertino_text_field`
- `checkbox`
- `cupertino_checkbox`
- `radio`
- `radio_group`
- `switch`
- `cupertino_switch`
- `slider`
- `range_slider`
- `dropdown`
- `auto_complete`
- `segmented_button`
- `cupertino_segmented_button`
- `cupertino_sliding_segmented_button`
- `search_bar`

## Lists, tiles, and data display

For content-heavy apps you can use:

- `list_tile`
- `cupertino_list_tile`
- `expansion_tile`
- `data_table`
- `badge`
- `chip`
- `banner`
- `divider`
- `vertical_divider`

## Adaptive and Cupertino UI

Ruflet is not limited to Material-style components. The current layer also includes:

- `cupertino_app_bar`
- `cupertino_navigation_bar`
- `cupertino_action_sheet`
- `cupertino_alert_dialog`
- `cupertino_bottom_sheet`
- `cupertino_date_picker`
- `cupertino_timer_picker`
- `cupertino_picker`

## Practical layout pattern

```ruby
page.add(
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
            filled_button(content: text(value: "Save")),
            outlined_button(content: text(value: "Cancel"))
          ]
        )
      ]
    )
  )
)
```

## What to keep in mind

- Use builder helpers for normal controls.
- Use `page.update(...)` to mutate existing controls.
- Reach for `responsive_row`, `grid_view`, or `navigation_rail` when the app needs to scale to larger screens.
- When in doubt, study Ruflet Studio and the examples folder for the current preferred calling style.
