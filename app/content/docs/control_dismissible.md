# Dismissible

Wraps a control so the user can swipe it away, as in mail and to-do lists.
Show `background` behind the control while it slides one way and
`secondary_background` while it slides the other.

## Example

```ruby
status = text(value: "Swipe a message")
inbox = nil
messages = ["Weekly report", "Team lunch", "Invoice #1042"].map do |subject|
  dismissible(
    list_tile(leading: icon("mail"), title: text(subject)),
    background: container(bgcolor: "#bbf7d0", padding: 16, content: icon("archive")),
    secondary_background: container(bgcolor: "#fecaca", padding: 16, content: icon("delete")),
    on_dismiss: ->(event) {
      messages.delete(event.control)
      page.update(inbox, controls: messages)
      action = event.direction == "startToEnd" ? "archived" : "deleted"
      page.update(status, value: "#{subject} #{action}")
    }
  )
end
inbox = column(children: messages)
page.add(column(children: [status, inbox]))
```

## Common properties

- `content` — the control that can be swiped; the first positional argument sets it
- `background` / `secondary_background`
- `dismiss_direction` — which swipes dismiss: `"horizontal"` (default), `"endToStart"`, `"startToEnd"`, `"vertical"`, `"up"`, `"down"` or `"none"`
- `dismiss_thresholds` — how far the control must travel before it is dismissed
- `movement_duration` / `resize_duration` — slide and close times, in milliseconds; the 0.0.23 client ignores them. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
- `on_dismiss` — `event.direction` is the swipe direction, such as `"startToEnd"`
- `on_update` — reports drag progress while the user swipes
- `on_confirm_dismiss` — asks before the control goes; reply with `page.invoke(event.control, "confirm_dismiss", args: { dismiss: true })`, or `dismiss: false` to keep it. Without a reply the client cancels the dismissal after five minutes

## Usage

Remove the dismissed control from its parent in `on_dismiss`, as the example
does. Flutter does not allow a dismissed `Dismissible` to stay in the tree.
