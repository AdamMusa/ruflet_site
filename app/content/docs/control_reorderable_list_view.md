# ReorderableListView

A scrolling list whose items the user can drag into a new order. The client
moves the item itself and then tells Ruby the old and new positions.

## Example

```ruby
tasks = ["Write the outline", "Draft the post", "Review", "Publish"]
order = text(value: tasks.join(" → "))
page.add(
  column(
    expand: true,
    children: [
      reorderable_list_view(
        tasks.map { |task| list_tile(title: text(task), leading: icon("drag_indicator")) },
        expand: true,
        on_reorder: ->(event) {
          task = tasks.delete_at(event.old_index)
          tasks.insert(event.new_index, task)
          page.update(order, value: tasks.join(" → "))
        }
      ),
      order
    ]
  )
)
```

## Common properties

- `controls` — the items; the first positional argument sets them
- `horizontal` — lay the items out in a row
- `reverse` / `padding` / `item_extent`
- `spacing` — space between items; the 0.0.23 client ignores it. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `header` / `footer` — controls before and after the items that cannot be moved
- `show_default_drag_handles` — set `false` to drag only by your own `reorderable_drag_handle`
- `on_reorder` — `event.old_index` and `event.new_index`
- `on_reorder_start` — `event.old_index` is the item the user picked up
- `on_reorder_end` — `event.new_index` is where it was dropped; it fires even when the item lands where it started, so update your list in `on_reorder`
- `on_scroll` — `event.data` has the scroll position, with the same keys as [`list_view`](/docs/control-list-view#scroll-events)
- `mouse_cursor` — the cursor over the default drag handles; Android, web, Windows and Linux only
- `semantic_child_count` is accepted, but no Ruflet client reads it on this list
- `auto_scroll_animation` and `keyboard_dismiss_behavior`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Usage

`new_index` is already adjusted for the removed item, so
`delete_at(old_index)` followed by `insert(new_index, item)` keeps your Ruby
list in the order the user sees, as above. You do not need to send the items
back.
