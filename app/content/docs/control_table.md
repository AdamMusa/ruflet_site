# Table

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). With 0.0.23 the client shows "Unknown control".

A plain grid of cells laid out in rows and columns. Build each row with
`table_row`. Use [`data_table`](/docs/control-data-table) instead when you need
column headings, sorting or row selection.

## Example

```ruby
plans = [["Starter", "1", "Free"], ["Team", "10", "49 USD"], ["Business", "50", "199 USD"]]

page.add(
  table(
    [
      table_row([text("Plan"), text("Seats"), text("Price")], bgcolor: :surfacecontainerhigh),
      *plans.map { |plan| table_row(plan.map { |cell| text(cell) }) }
    ],
    column_widths: { 0 => { type: "flex", value: 2 }, 2 => { type: "fixed", value: 96 } },
    border_color: :outlinevariant,
    border_radius: 8,
    cell_padding: 8
  )
)
```

Give the rows as the first argument, as `rows:`, or in a block. Every row must
be a `table_row`. A short row is padded with empty cells.

## Rows

`table_row(cells, bgcolor:)` (alias `tablerow`) takes its cells as the first
argument, as `controls:`, or in a block. `bgcolor` fills the row.

## Properties

- `rows` — the `table_row` controls.
- `column_widths` — widths per column index: `{ index => { type:, value: } }`, where `type` is `"flex"`, `"fixed"`, `"fraction"` or `"intrinsic"`. A bare number is a fixed width.
- `default_column_width` — the width of columns missing from `column_widths` (default: equal flex).
- `border_color`, `border_width` (default 1) and `border_radius` — the outer border. Nothing is drawn without `border_color`.
- `inner_borders` — also draw lines between cells (default `true`).
- `cell_padding` — padding inside every cell.
- `default_vertical_alignment` — `"top"` (default), `"middle"`, `"bottom"`, `"baseline"` or `"fill"`.
