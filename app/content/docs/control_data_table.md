# DataTable

A table with a header row, data rows and optional sorting and row selection.
Build it from [`data_column`](/docs/control-data-column) headers and
[`data_row`](/docs/control-data-row) rows of
[`data_cell`](/docs/control-data-cell) values.

## Example

```ruby
fruits = [["Apple", 12], ["Mango", 4], ["Cherry", 30]]
sort_index = nil
ascending = true
table = nil
rows_for = ->(items) {
  items.map { |name, qty| data_row([data_cell(text(name)), data_cell(text(qty.to_s))]) }
}
sort_by_column = ->(event) {
  index = event.data["ci"].to_i
  # The same column again flips the direction; another column starts ascending.
  ascending = index == sort_index ? !ascending : true
  sort_index = index
  sorted = fruits.sort_by { |row| row[index] }
  sorted.reverse! unless ascending
  page.update(table, rows: rows_for.call(sorted), sort_column_index: index, sort_ascending: ascending)
}
table = data_table(
  [
    data_column(text("Fruit"), on_sort: sort_by_column),
    data_column(text("Quantity"), numeric: true, on_sort: sort_by_column)
  ],
  rows: rows_for.call(fruits)
)
page.add(table)
```

## Common properties

- `columns` — the `data_column(label, numeric:, on_sort:)` headers; the first positional argument sets them
- `rows` — `data_row(cells, selected:, on_select_change:)` rows of `data_cell(content)`
- `sort_column_index` / `sort_ascending` — which column shows the sort arrow, and its direction
- `show_checkbox_column` / `on_select_all` — row selection with a header checkbox. On iOS and macOS, the 0.0.23 client draws no checkbox column and sends neither `on_select_all` nor the rows' `on_select_change`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `column_spacing` / `horizontal_margin` / `data_row_min_height` / `data_row_max_height` / `heading_row_height`
- `border` / `border_radius` / `vertical_lines` / `divider_thickness`
- `horizontal_lines` — lines between rows; the 0.0.23 client ignores it. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `heading_row_color` / `data_row_color` / `heading_text_style` / `data_text_style`

## Usage

The table does not sort itself. A column's `on_sort` receives the column
index in `event.data["ci"]`. Keep the direction in Ruby, as above: tapping the
sorted column again flips it, and another column starts ascending. Then update
`rows` together with `sort_column_index` and `sort_ascending`. `numeric: true`
right-aligns a column.

`event.data["asc"]` is the new direction on Android, web, Windows and Linux.
On iOS and macOS it is the table's current `sort_ascending` (`false` until you
set it), so passing `asc` back as `sort_ascending` never changes the direction
there.

On iOS and macOS the client draws a plainer table. It uses
`heading_row_color`, each row's `color` and its `selected` highlight,
`show_bottom_border` and the cells' tap events. The sort arrow, `numeric`
alignment, `column_spacing`, `horizontal_margin`, the row and heading heights,
`border`, `border_radius`, `divider_thickness`, `data_row_color` and the two
text styles apply on Android, web, Windows and Linux only.

On iOS and macOS, the 0.0.23 client also ignores `vertical_lines`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

For fixed header rows or columns on large tables, use the `datatable2`
[DataTable2 extension](/docs/extension-datatable2).
