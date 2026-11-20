# Theming

A Ruflet theme is one Hash of colors, fonts and component styles. The client
draws iOS and macOS with Cupertino widgets and every other platform with
Material widgets, and both read the same Hash: Material uses all of it, and
Cupertino uses its colors, font family and text styles.

## App theme

Set the theme on the page, then send it with `page.update` (assignments made
while your app block runs go out with the first screen):

```ruby
page.fonts = { "Inter" => "fonts/Inter-Regular.ttf" }
page.theme = {
  color_scheme_seed: :indigo,
  font_family: "Inter",
  color_scheme: { primary: "#3949ab", on_primary: "#ffffff" },
  text_theme: { body_medium: { size: 16 }, title_large: { size: 24, weight: "w600" } },
  appbar_theme: { bgcolor: "#e8eaf6" }
}
page.dark_theme = {
  color_scheme_seed: :indigo,
  font_family: "Inter",
  scaffold_bgcolor: "#101418"
}
page.theme_mode = "system"
page.appbar = app_bar(title: text("Themed app"))
page.add(filled_button("Continue"))
page.update
```

- `page.theme` — the light theme, and the dark one too when `dark_theme` is not set.
- `page.dark_theme` — the theme used in dark mode.
- `page.theme_mode` — `"system"` (the default) follows the device's light or dark setting; `"light"` and `"dark"` force one. Read the device setting with `page.platform_brightness` and follow its changes with `page.on(:platform_brightness_change)`.
- `page.fonts` — font families to load: a Hash of family name => font file. A value is an asset path in the app's `assets` directory, a file path, or a URL. Use the family name in `font_family:` of a theme or a text style.

The DSL takes the same keys: `page(theme: { ... }, theme_mode: "dark") { ... }`.

## Colors in a theme

A color is a hex String such as `"#3949ab"` (`"#aarrggbb"` and `"0xrrggbb"`
work too, and `",0.5"` adds opacity), a Material color name, or a color role
of the current theme. Write names without underscores, as the client spells
them: `:indigo`, `:blue700`, `:deeporange500`, `:bluegrey200`, `:primary` or
`:surfacecontainerhigh`. The `Ruflet::Colors` constants hold these names:
`Ruflet::Colors::DEEP_ORANGE_500` is `"deeporange500"`. A name with
underscores, such as `:deep_orange_500`, does not match any color on 0.0.23
or on `main`, and the client draws the default color instead.

## Theme keys

### Read by both designs

- `color_scheme_seed` — the color the Material palette is generated from (default blue). Cupertino uses it as the primary color when `color_scheme` has no `primary`.
- `color_scheme` — role colors: `primary`, `on_primary`, `primary_container`, `on_primary_container`, `secondary`, `on_secondary`, `tertiary`, `on_tertiary`, the `*_container` and `*_fixed` forms, `error`, `on_error`, `error_container`, `on_error_container`, `surface`, `on_surface`, `on_surface_variant`, `surface_tint`, `surface_bright`, `surface_dim`, the `surface_container*` levels, `inverse_surface`, `on_inverse_surface`, `inverse_primary`, `outline`, `outline_variant`, `shadow` and `scrim`. Cupertino uses `primary` for its tint, `on_primary` for text on it, `surface` for bars and backgrounds and `on_surface` for text, and lets controls read the other roles by name.
- `font_family` — the default font family.
- `text_theme` — text styles by role: `display_large`, `display_medium`, `display_small`, `headline_large`, `headline_medium`, `headline_small`, `title_large`, `title_medium`, `title_small`, `label_large`, `label_medium`, `label_small`, `body_large`, `body_medium` and `body_small`. Cupertino maps them onto its own styles: `body_medium` (or `body_large`) for body text, `label_large` for buttons, `label_medium` for tab labels, `title_large` for navigation titles and `display_large` (or `headline_large`) for large titles.
- `scaffold_bgcolor` — the page background.
- `appbar_theme` — app bar styles. Cupertino reads only its `bgcolor`, for the navigation bar.
- `disabled_color` — the color of disabled controls.

### Read by Material only

- `use_material3` — `false` switches to Material 2 styling.
- `primary_text_theme` — text styles on primary-colored surfaces, with the `text_theme` roles.
- `visual_density` — `"standard"`, `"comfortable"`, `"compact"` or `"adaptivePlatformDensity"`.
- `page_transitions` — the route transition per platform.
- `system_overlay_style` — the Android status and navigation bar colors and icon brightness.
- Single colors: `canvas_color`, `card_bgcolor`, `divider_color`, `focus_color`, `highlight_color`, `hint_color`, `hover_color`, `secondary_header_color`, `splash_color` and `unselected_control_color`.
- Component themes, each a Hash of that control's style keys: `badge_theme`, `banner_theme`, `bottom_app_bar_theme`, `bottom_sheet_theme`, `button_theme` (elevated buttons), `card_theme`, `checkbox_theme`, `chip_theme`, `data_table_theme`, `date_picker_theme`, `dialog_theme`, `divider_theme`, `dropdown_theme`, `expansion_tile_theme`, `filled_button_theme`, `floating_action_button_theme`, `icon_button_theme`, `icon_theme`, `list_tile_theme`, `navigation_bar_theme`, `navigation_drawer_theme`, `navigation_rail_theme`, `outlined_button_theme`, `popup_menu_theme`, `progress_indicator_theme`, `radio_theme`, `scrollbar_theme`, `search_bar_theme`, `search_view_theme`, `segmented_button_theme`, `slider_theme`, `snackbar_theme`, `switch_theme`, `tab_bar_theme`, `text_button_theme`, `time_picker_theme` and `tooltip_theme`.

## Text styles

A text style, in `text_theme` or a control's `style:`, takes `size`, `weight`
(`"normal"`, `"bold"` or `"w100"` to `"w900"`), `italic`, `color`, `bgcolor`,
`font_family`, `font_family_fallback`, `height` (a multiple of the font size),
`letter_spacing`, `word_spacing`, `decoration`, `decoration_color`,
`decoration_style`, `decoration_thickness`, `overflow`, `text_baseline`,
`shadow` and `foreground`. Write it as a Hash or build it with
`Ruflet::TextStyle.new(size: 16, weight: "bold")`; see
[Value types](/docs/reference#value-types-and-constants).

## Theme one part of the page

A `container` takes `theme:`, `dark_theme:` and `theme_mode:` too. They apply
to the container's content and leave the rest of the page alone:

```ruby
page.add(
  column(children: [
    filled_button("Uses the page theme"),
    container(
      theme: { color_scheme_seed: :teal },
      dark_theme: { color_scheme_seed: :teal, scaffold_bgcolor: "#0b1f1d" },
      theme_mode: "dark",
      padding: 16,
      content: filled_button("Always dark teal")
    )
  ])
)
```

Without `theme_mode`, the container follows the page's light or dark mode,
and on Material its theme starts from the enclosing one and overrides only what
it sets. With `theme_mode`, Material builds the container's theme from its own
keys alone. Cupertino always starts from the enclosing Cupertino theme. With a
`theme` and no `dark_theme`, dark mode uses `theme`.

## Not applied

- `page.locale_configuration` (supported locales and the current locale) is a Page keyword, but Ruflet stores it on the page's View, which the client does not read it from. It has no effect on 0.0.23 or on `main`: the client keeps English (United States) as its only supported locale for the built-in Material and Cupertino texts.
- `page.theme_animation_style` is sent to the client, which does not read it.
