# ListTile

A single fixed-height row with optional leading/trailing controls, a title, and
a subtitle — the building block of lists and menus.

## Example

```ruby
list_tile(
  leading: icon("person"),
  title: text("Ada Lovelace"),
  subtitle: text("Engineer"),
  trailing: icon_button("chevron_right", on_click: ->(_e) { open_profile }),
  on_click: ->(_e) { open_profile }
)
```

## Common properties

- `title`
- `subtitle`
- `leading` / `trailing`
- `dense`
- `is_three_line`
- `content_padding`
- `bgcolor` / `hover_color`
- `selected` / `selected_color` / `selected_tile_color`
- `shape`
- `url` — open a URL on tap

## Usage

`list_tile` is commonly the child of a [`list_view`](/docs/control-list-view) or
[`column`](/docs/control-column):

```ruby
column(controls: people.map { |p| list_tile(title: text(p.name)) })
```
