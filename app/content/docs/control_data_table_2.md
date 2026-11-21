# DataTable2

A data table for long and wide data: the heading row and the first columns
can stay in place while the rest scrolls, and columns share the width by
size. It comes from the `datatable2` extension: add `datatable2` to
`extensions` in `ruflet.yaml` and rebuild the client (see the
[DataTable2 extension](/docs/extension-datatable2)). Build it from
[`data_column2`](/docs/control-data-column-2) headings and
[`data_row2`](/docs/control-data-row-2) rows of
[`data_cell`](/docs/control-data-cell) values.

## Example

```ruby
orders = (1..40).map { |n| ["##{1000 + n}", "Customer #{n}", "Berlin", (n * 7.5).round(2)] }
rows_for = ->(items) {
  items.map do |id, customer, city, total|
    data_row2(
      [
        data_cell(text(id)),
        data_cell(text(customer)),
        data_cell(text(city)),
        data_cell(text(format("%.2f", total)))
      ],
      on_tap: ->(_event) {}
    )
  end
}
table = nil
sort_by_total = ->(event) {
  ascending = event.data[:asc]
  sorted = orders.sort_by(&:last)
  sorted.reverse! unless ascending
  page.update(table, rows: rows_for.call(sorted), sort_column_index: 3, sort_ascending: ascending)
}
table = data_table2(
  [
    data_column2(text("Order"), size: "s"),
    data_column2(text("Customer"), size: "l"),
    data_column2(text("City"), size: "m"),
    data_column2(text("Total"), numeric: true, fixed_width: 96, on_sort: sort_by_total)
  ],
  rows: rows_for.call(orders),
  fixed_top_rows: 1,
  fixed_left_columns: 1,
  min_width: 640,
  height: 400,
  empty: text("No orders yet")
)
page.add(table)
```

Give the table a height, as above, or put it where it can expand: it scrolls
inside its own bounds. With `min_width`, a narrower screen scrolls the table
sideways while `fixed_left_columns` stay in place.

## Columns and rows

- `data_column2(label, size:, fixed_width:, numeric:, on_sort:)` — `size` is `"s"` (default), `"m"` or `"l"`. The table shares its width between the columns by size: an `"s"` column is `sm_ratio` (default 0.67) and an `"l"` column `lm_ratio` (default 1.2) times as wide as an `"m"` one. `fixed_width` gives a column an exact width instead.
- `data_row2(cells, selected:, specific_row_height:, decoration:)` — one `data_cell` per column. A row can have its own height and box decoration, and it fires `on_tap`, `on_double_tap`, `on_long_press`, `on_secondary_tap`, `on_secondary_tap_down` and `on_select_change`.
- `data_cell(content)` — give the content as a control, such as `text(...)`, not as a bare string.

With 0.0.23 write `size` as `"s"`, `"m"` or `"l"`: the 0.0.23 client draws
`"small"`, `"medium"` and `"large"`, which `size: :medium` sends, as `"s"`
columns.

The next release also accepts `"small"`, `"medium"` and `"large"`, so `size: :medium` gives an `"m"` column. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Common properties

- `fixed_top_rows` — rows at the top that stay in place while the table scrolls, the heading row included (default 1)
- `fixed_left_columns` — columns at the start that stay in place while the table scrolls sideways (default 0)
- `fixed_columns_color` / `fixed_corner_color` — the background of the fixed columns, and of the corner where they meet the fixed rows
- `min_width` — the narrowest the table gets; below it the table scrolls sideways
- `empty` — a control shown while there are no rows
- `data_row_height` / `heading_row_height` / `bottom_margin`
- `heading_row_decoration` / `heading_row_color` / `data_row_color` / `heading_text_style` / `data_text_style`
- `sort_column_index` / `sort_ascending` / `sort_arrow_icon` / `sort_arrow_icon_color` / `sort_arrow_animation_duration`
- `show_checkbox_column` / `show_heading_checkbox` / `checkbox_alignment` / `heading_checkbox_theme` / `data_row_checkbox_theme` / `on_select_all`
- `visible_horizontal_scroll_bar` / `visible_vertical_scroll_bar`
- `border` / `border_radius` / `horizontal_lines` / `vertical_lines` / `divider_thickness` / `bgcolor` / `gradient`

`sort_arrow_animation_duration` is in milliseconds. Without it, the 0.0.23
client turns the sort arrow in 150 ms on iOS and macOS, but on Android, web,
Windows and Linux its default is 150 microseconds, so the arrow flips at once;
pass `sort_arrow_animation_duration: 150` to animate it there.

The next release turns the sort arrow in 150 ms by default on every platform. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Usage

Sorting and selection work as in [`data_table`](/docs/control-data-table): the
table does not reorder rows or change `selected` by itself. A column's
`on_sort` gets the column index in `event.data[:ci]` and the new direction in
`event.data[:asc]` on every platform. A row's `on_select_change` gets `true`
when the row is selected and `nil` when it is cleared; set `selected` with
`page.update`. Without `on_select_all`, the heading checkbox calls each row's
`on_select_change`.

The table is drawn the same way on Android, web, Windows, Linux, iOS and
macOS, except for two 0.0.23 differences: the default speed of the sort arrow,
above, and the iOS and macOS layout below. On iOS and macOS its checkboxes are
iOS checkboxes.

On iOS and macOS, the 0.0.23 client lays out a table whose rows do not fill
its height differently: the rows sit in the middle of the space under the
heading instead of right under it, and `empty` keeps its own height and is
centered there instead of filling that space.

The next release lays out the rows and `empty` on iOS and macOS as Android, web, Windows and Linux do. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
