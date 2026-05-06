# FloatingActionButton

Floating action button helper exposed through `fab`.

## Example

```ruby
fab(
  icon: "add",
  content: "Create",
  on_click: ->(_e) { page.update(status, value: "Create pressed") }
)
```

## Common properties

- positional content: `fab("Create")`
- `icon`
- `content`
- `on_click`

## Usage

```ruby
count = 0
count_text = text(count.to_s, style: {size: 40})

page.add(
  container(
    expand: true,
    alignment: Ruflet::MainAxisAlignment::CENTER,
    content: count_text
  ),
  floating_action_button: fab(
    icon: "add",
    on_click: ->(_e) do
      count += 1
      page.update(count_text, value: count.to_s)
    end
  )
)
```

## Supported forms

- `fab("Create")`
- `fab(icon: "add")`
- `fab(icon: "add", content: "Create")`
- `fab(icon: Ruflet::MaterialIcons::ADD)`
