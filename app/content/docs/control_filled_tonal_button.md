# FilledTonalButton

A filled button that uses the secondary container color. It sits between a
[`filled_button`](/docs/control-filled-button) and an
[`outlined_button`](/docs/control-outlined-button) in emphasis, which suits
actions such as "Add to cart" next to "Buy now".

## Example

```ruby
cart = text(value: "Cart is empty")
page.add(
  row(
    spacing: 12,
    children: [
      filled_tonal_button("Add to cart", icon: "add_shopping_cart", on_click: ->(_event) { page.update(cart, value: "1 item in cart") }),
      filled_button("Buy now", on_click: ->(_event) { page.update(cart, value: "Checking out") })
    ]
  )
)
page.add(cart)
```

## Common properties

- `content` — the label, a string or a control; the first positional argument sets it
- `icon` / `icon_color`
- `style` — colors, padding and shape, for example `style: { bgcolor: "#ccfbf1", color: "#134e4a" }`
- `on_click` / `on_long_press`
- `url` — open a link on click
- `disabled`
- `action` / `on_action_result` — a client action the button runs inside the tap. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Usage

As with the other Material buttons, put colors in `style:`; the top-level
`bgcolor:` and `color:` keywords only take effect together with `style`.

On iOS and macOS the client draws a tinted Cupertino button instead, which
uses the top-level `bgcolor:` and `color:` directly; a color in `style:` wins
over them.
