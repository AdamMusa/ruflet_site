# IndexedStack

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). With 0.0.23 the client shows "Unknown control".

Shows one child at a time while keeping every child mounted, so typed text and
scroll positions survive switching between them.

## Example

```ruby
panes = indexed_stack(
  [
    text_field(label: "Draft", multiline: true),
    text("Sent messages"),
    text("Archived messages")
  ],
  index: 0
)

buttons = %w[Draft Sent Archive].each_with_index.map do |label, index|
  text_button(content: text(label), on_click: ->(_event) { page.update(panes, index: index) })
end

page.add(column(children: [row(children: buttons), panes]))
```

Text typed into the draft field is still there after switching to another
pane and back.

## Properties

- `children` — the stacked controls, as the first argument, `children:`, or a block.
- `index` — the child to show (default `0`).
- `alignment` — where smaller children sit inside the stack.
- `fit` — how children are sized: `"loose"` (default), `"expand"` or `"passthrough"`.
- `clip_behavior` and the common layout properties.

Use `stack` to show every child at once, layered.
