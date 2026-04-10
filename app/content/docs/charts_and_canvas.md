# Charts and Canvas

Ruflet already reaches beyond basic forms and CRUD screens. The current demo surface includes charting, drawing primitives, and richer visual controls that are useful for dashboards, analytics, and interactive apps.

## Chart controls already present

Ruflet Studio exercises several chart types:

- `bar_chart`
- `line_chart`
- `pie_chart`
- `candlestick_chart`
- `radar_chart`
- `scatter_chart`

Supporting chart types and helpers include:

- `chart_axis`
- `chart_axis_label`
- `bar_chart_group`
- `bar_chart_rod`
- `line_chart_data`
- `line_chart_data_point`
- `pie_chart_section`
- `candlestick_chart_spot`
- `radar_data_set`
- `radar_data_set_entry`
- `radar_chart_title`
- `scatter_chart_spot`

## Drawing and visual building blocks

The current control map also includes lower-level visual primitives such as:

- `canvas`
- `line`
- `path`
- `arc`
- `rect`
- `circle`
- `oval`
- `points`
- `shadow`
- `shader_mask`
- `animated_switcher`
- `hero`

These help when you want something more custom than standard layout widgets.

## Why this matters

This makes Ruflet viable for:

- internal dashboards
- metrics-heavy admin apps
- utility apps with interactive graphics
- media-rich product surfaces

## Example direction

Ruflet Studio's chart section shows that the framework can already express:

- configured axes
- labels
- tooltips and interactive events
- multi-series line charts
- themed bar and pie charts

If your app needs more than plain forms, this part of the stack is worth exploring early.
